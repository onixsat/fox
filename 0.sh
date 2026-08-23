#!/usr/bin/env bash

set -u

TARGET_IP="64.31.39.106"
PING_COUNT=4
PING_TIMEOUT=2
LOG_FILE="/var/log/ping_app.log"

APP_DIR="/usr/local/libexec"
APP_FILE="${APP_DIR}/ping-app.cgi"
APACHE_CONFIG="/etc/apache2/conf-available/ping-app.conf"
LOGROTATE_CONFIG="/etc/logrotate.d/ping_app"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root or with sudo." >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    apache2 \
    iputils-ping \
    libcap2-bin

systemctl enable --now apache2

mkdir -p "${APP_DIR}"

cat > "${APP_FILE}" <<'CGI'
#!/usr/bin/env bash

# Fixed server-side configuration.
TARGET_IP="64.31.39.106"
PING_COUNT=4
PING_TIMEOUT=2
LOG_FILE="/var/log/ping_app.log"
PING_BIN="/usr/bin/ping"

# Escape a value for JSON.
json_escape() {
    local value="${1-}"

    printf '%s' "${value}" |
        sed \
            -e 's/\\/\\\\/g' \
            -e 's/"/\\"/g' \
            -e 's/\r/\\r/g' \
            -e 's/\t/\\t/g' \
            -e ':a' \
            -e 'N' \
            -e '$!ba' \
            -e 's/\n/\\n/g'
}

# Convert an IPv4 address to its packed hexadecimal representation.
ipv4_to_hex() {
    local ip="$1"
    local a b c d

    if [[ ! "${ip}" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        return 1
    fi

    a="${BASH_REMATCH[1]}"
    b="${BASH_REMATCH[2]}"
    c="${BASH_REMATCH[3]}"
    d="${BASH_REMATCH[4]}"

    if ((10#$a > 255 || 10#$b > 255 || 10#$c > 255 || 10#$d > 255)); then
        return 1
    fi

    printf '%02x%02x%02x%02x' \
        "$((10#$a))" \
        "$((10#$b))" \
        "$((10#$c))" \
        "$((10#$d))"
}

# Convert an IPv6 address or other validated address text to hexadecimal.
# The resulting pattern is limited to 16 hexadecimal characters because
# iputils ping accepts a maximum 16-character hexadecimal pattern.
address_to_hex() {
    local client_ip="$1"
    local result

    if result="$(ipv4_to_hex "${client_ip}")"; then
        printf '%s' "${result}"
        return 0
    fi

    # REMOTE_ADDR is supplied by the web server, not directly by the client.
    # Encode the textual address as hexadecimal bytes for correlation.
    result="$(
        LC_ALL=C printf '%s' "${client_ip}" |
            od -An -tx1 -v |
            tr -d '[:space:]'
    )"

    if [[ -z "${result}" ]]; then
        printf '00000000'
    else
        printf '%.16s' "${result}"
    fi
}

extract_packet_stats() {
    local output="$1"

    awk '
        /packets transmitted/ {
            transmitted=$1
            received=$4

            for (i = 1; i <= NF; i++) {
                if ($i ~ /%[[:space:]]*packet/) {
                    loss=$((i - 1))
                    gsub(/%/, "", loss)
                    break
                }
            }
        }

        END {
            if (transmitted == "") transmitted="null"
            if (received == "") received="null"
            if (loss == "") loss="null"

            printf "%s %s %s\n", transmitted, received, loss
        }
    ' <<< "${output}"
}

extract_rtt_stats() {
    local output="$1"

    awk -F'= ' '
        /^rtt / || /^round-trip / {
            split($2, values, " ")
            split(values[1], numbers, "/")

            if (numbers[1] != "") min=numbers[1]
            if (numbers[2] != "") avg=numbers[2]
            if (numbers[3] != "") max=numbers[3]
            if (numbers[4] != "") mdev=numbers[4]
        }

        END {
            if (min == "") min="null"
            if (avg == "") avg="null"
            if (max == "") max="null"
            if (mdev == "") mdev="null"

            printf "%s %s %s %s\n", min, avg, max, mdev
        }
    ' <<< "${output}"
}

client_ip="${REMOTE_ADDR:-unknown}"
user_agent="${HTTP_USER_AGENT:-}"
method="${REQUEST_METHOD:-GET}"
timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

hex_payload="$(address_to_hex "${client_ip}")"

# Use a fixed command structure. The target is never read from request data.
set +e
raw_output="$(
    LC_ALL=C "${PING_BIN}" \
        -n \
        -c "${PING_COUNT}" \
        -W "${PING_TIMEOUT}" \
        -p "${hex_payload}" \
        "${TARGET_IP}" \
        2>&1
)"
exit_code=$?
set -e

read -r transmitted received loss_pct < <(
    extract_packet_stats "${raw_output}"
)

read -r min_ms avg_ms max_ms mdev_ms < <(
    extract_rtt_stats "${raw_output}"
)

if [[ "${exit_code}" -eq 0 && "${received}" != "null" && "${received}" -gt 0 ]]; then
    success=true
else
    success=false
fi

log_line=$(
    printf \
        '{"timestamp":"%s","client_ip":"%s","user_agent":"%s","method":"%s","target_ip":"%s","hex_payload":"%s","ping_count":%d,"success":%s,"exit_code":%d,"stats":{"transmitted":%s,"received":%s,"loss_pct":%s,"min_ms":%s,"avg_ms":%s,"max_ms":%s,"mdev_ms":%s},"raw_output":"%s"}\n' \
        "$(json_escape "${timestamp}")" \
        "$(json_escape "${client_ip}")" \
        "$(json_escape "${user_agent}")" \
        "$(json_escape "${method}")" \
        "$(json_escape "${TARGET_IP}")" \
        "$(json_escape "${hex_payload}")" \
        "${PING_COUNT}" \
        "${success}" \
        "${exit_code}" \
        "${transmitted}" \
        "${received}" \
        "${loss_pct}" \
        "${min_ms}" \
        "${avg_ms}" \
        "${max_ms}" \
        "${mdev_ms}" \
        "$(json_escape "${raw_output}")"
)

if [[ -w "$(dirname "${LOG_FILE}")" ]] || [[ -w "${LOG_FILE}" ]]; then
    printf '%s' "${log_line}" >> "${LOG_FILE}" 2>/dev/null || true
else
    printf '%s' "${log_line}" >> /tmp/ping_app.log 2>/dev/null || true
fi

# Do not include TARGET_IP, raw ping output, or command errors in the response.
printf 'Status: 200 OK\r\n'
printf 'Content-Type: text/plain; charset=utf-8\r\n'
printf 'Cache-Control: no-store, no-cache, must-revalidate\r\n'
printf 'Pragma: no-cache\r\n'
printf 'Expires: 0\r\n'
printf '\r\n'

if [[ "${success}" == true ]]; then
    printf 'Ping successful.\n'
else
    printf 'Ping failed.\n'
fi

printf 'Transmitted: %s\n' "${transmitted}"
printf 'Received: %s\n' "${received}"
printf 'Packet loss: %s%%\n' "${loss_pct}"
printf 'Minimum: %s ms\n' "${min_ms}"
printf 'Average: %s ms\n' "${avg_ms}"
printf 'Maximum: %s ms\n' "${max_ms}"
printf 'Jitter: %s ms\n' "${mdev_ms}"
CGI

chmod 755 "${APP_FILE}"
chown root:root "${APP_FILE}"

# Configure Apache so that /ping.php executes the Bash CGI script.
cat > "${APACHE_CONFIG}" <<EOF
ScriptAlias /ping.php ${APP_FILE}

<Directory "${APP_DIR}">
    Options +ExecCGI
    Require all granted
</Directory>
EOF

a2enmod cgid
a2enconf ping-app

# Configure the application log.
touch "${LOG_FILE}"
chown www-data:www-data "${LOG_FILE}"
chmod 640 "${LOG_FILE}"

cat > "${LOGROTATE_CONFIG}" <<EOF
${LOG_FILE} {
    weekly
    rotate 8
    compress
    missingok
    notifempty
    create 640 www-data www-data
}
EOF

# Ensure ping has the capability required by unprivileged CGI processes.
PING_PATH="$(command -v ping)"
if command -v getcap >/dev/null 2>&1 &&
   ! getcap "${PING_PATH}" | grep -q 'cap_net_raw'; then
    setcap cap_net_raw+ep "${PING_PATH}"
fi

# Permit HTTP traffic when UFW is installed and active.
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    ufw allow 80/tcp
fi

apachectl configtest
systemctl reload apache2

echo
echo "Installation complete."
echo "Endpoint: http://$(hostname -I | awk '{print $1}')/ping.php"
echo "Log file: ${LOG_FILE}"
echo
echo "Check ping capability with:"
echo "  getcap ${PING_PATH}"
echo
echo "Test locally with:"
echo "  curl -s http://127.0.0.1/ping.php"
