#!/usr/bin/env bash

set -u
set -o pipefail

###############################################################################
# Configuração
###############################################################################

TARGET_IP='64.31.39.106'
PING_COUNT=4
PING_TIMEOUT=2
LOG_FILE='/var/log/ping_app.log'

###############################################################################
# Funções auxiliares
###############################################################################

json_escape() {
    local value="${1-}"
    local result=""
    local ch
    local i
    local code

    LC_ALL=C

    for ((i = 0; i < ${#value}; i++)); do
        ch="${value:i:1}"

        case "$ch" in
            '"')
                result+='\"'
                ;;
            '\')
                result+='\\'
                ;;
            $'\b')
                result+='\b'
                ;;
            $'\f')
                result+='\f'
                ;;
            $'\n')
                result+='\n'
                ;;
            $'\r')
                result+='\r'
                ;;
            $'\t')
                result+='\t'
                ;;
            *)
                printf -v code '%d' "'$ch"

                if ((code < 32)); then
                    printf -v code '%04x' "$code"
                    result+="\\u${code}"
                else
                    result+="$ch"
                fi
                ;;
        esac
    done

    printf '%s' "$result"
}

valid_ipv4_octet() {
    local octet="$1"

    [[ "$octet" =~ ^[0-9]+$ ]] || return 1
    ((octet >= 0 && octet <= 255))
}

ipv4_to_hex() {
    local ip="$1"
    local a b c d
    local hex=""

    [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1

    IFS='.' read -r a b c d <<< "$ip"

    valid_ipv4_octet "$a" || return 1
    valid_ipv4_octet "$b" || return 1
    valid_ipv4_octet "$c" || return 1
    valid_ipv4_octet "$d" || return 1

    printf -v hex '%02x%02x%02x%02x' "$a" "$b" "$c" "$d"
    printf '%s' "$hex"
}

# Obtém o IP do visitante. REMOTE_ADDR é fornecido pelo Apache CGI.
CLIENT_IP="${REMOTE_ADDR:-unknown}"
USER_AGENT="${HTTP_USER_AGENT:-}"
METHOD="${REQUEST_METHOD:-GET}"

HEX_PAYLOAD=""

if [[ "$CLIENT_IP" != "unknown" ]]; then
    HEX_PAYLOAD="$(ipv4_to_hex "$CLIENT_IP" 2>/dev/null || true)"
fi

# O ping -p aceita no máximo 16 bytes, ou 32 caracteres hexadecimais.
HEX_PAYLOAD="${HEX_PAYLOAD:0:32}"

PING_BIN="$(command -v ping 2>/dev/null || true)"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
RAW_OUTPUT=""
EXIT_CODE=127
TRANSMITTED=0
RECEIVED=0
LOSS_PCT="100"
MIN_MS=""
AVG_MS=""
MAX_MS=""
MDEV_MS=""
SUCCESS=false

if [[ -n "$PING_BIN" ]]; then
    PING_ARGS=(
        -n
        -c "$PING_COUNT"
        -W "$PING_TIMEOUT"
    )

    if [[ -n "$HEX_PAYLOAD" ]]; then
        PING_ARGS+=(-p "$HEX_PAYLOAD")
    fi

    # O destino é uma constante e nunca é recebido do cliente.
    RAW_OUTPUT="$("$PING_BIN" "${PING_ARGS[@]}" "$TARGET_IP" 2>&1)"
    EXIT_CODE=$?

    TRANSMITTED="$(
        printf '%s\n' "$RAW_OUTPUT" |
            sed -nE 's/^[[:space:]]*([0-9]+)[[:space:]]+packets transmitted.*/\1/p' |
            head -n 1
    )"

    RECEIVED="$(
        printf '%s\n' "$RAW_OUTPUT" |
            sed -nE 's/^[[:space:]]*[0-9]+[[:space:]]+packets transmitted,[[:space:]]*([0-9]+)[[:space:]]+received.*/\1/p' |
            head -n 1
    )"

    LOSS_PCT="$(
        printf '%s\n' "$RAW_OUTPUT" |
            sed -nE 's/.*,[[:space:]]*([0-9]+([.][0-9]+)?)% packet loss.*/\1/p' |
            head -n 1
    )"

    RTT_VALUES="$(
        printf '%s\n' "$RAW_OUTPUT" |
            sed -nE 's/^[^=]*=[[:space:]]*([^[:space:]]+)[[:space:]]+ms$/\1/p' |
            head -n 1
    )"

    if [[ -n "$RTT_VALUES" ]]; then
        IFS='/' read -r MIN_MS AVG_MS MAX_MS MDEV_MS <<< "$RTT_VALUES"
    fi

    [[ "$TRANSMITTED" =~ ^[0-9]+$ ]] || TRANSMITTED=0
    [[ "$RECEIVED" =~ ^[0-9]+$ ]] || RECEIVED=0
    [[ -n "$LOSS_PCT" ]] || LOSS_PCT="100"

    if ((EXIT_CODE == 0 && RECEIVED > 0)); then
        SUCCESS=true
    fi
fi

###############################################################################
# Registo JSON
###############################################################################

ESCAPED_TIMESTAMP="$(json_escape "$TIMESTAMP")"
ESCAPED_CLIENT_IP="$(json_escape "$CLIENT_IP")"
ESCAPED_USER_AGENT="$(json_escape "$USER_AGENT")"
ESCAPED_METHOD="$(json_escape "$METHOD")"
ESCAPED_TARGET_IP="$(json_escape "$TARGET_IP")"
ESCAPED_HEX_PAYLOAD="$(json_escape "$HEX_PAYLOAD")"
ESCAPED_RAW_OUTPUT="$(json_escape "$RAW_OUTPUT")"

LOG_LINE=$(
    cat <<JSON
{"timestamp":"$ESCAPED_TIMESTAMP","client_ip":"$ESCAPED_CLIENT_IP","user_agent":"$ESCAPED_USER_AGENT","method":"$ESCAPED_METHOD","target_ip":"$ESCAPED_TARGET_IP","hex_payload":"$ESCAPED_HEX_PAYLOAD","ping_count":$PING_COUNT,"success":$SUCCESS,"exit_code":$EXIT_CODE,"stats":{"transmitted":$TRANSMITTED,"received":$RECEIVED,"loss_pct":$LOSS_PCT,"min_ms":${MIN_MS:-null},"avg_ms":${AVG_MS:-null},"max_ms":${MAX_MS:-null},"mdev_ms":${MDEV_MS:-null}},"raw_output":"$ESCAPED_RAW_OUTPUT"}
JSON
)

if ! printf '%s\n' "$LOG_LINE" >> "$LOG_FILE" 2>/dev/null; then
    printf '%s\n' "$LOG_LINE" >> /tmp/ping_app.log 2>/dev/null || true
fi

###############################################################################
# Resposta HTTP
###############################################################################

printf 'Status: 200 OK\r\n'
printf 'Content-Type: text/plain; charset=UTF-8\r\n'
printf 'Cache-Control: no-store, no-cache, must-revalidate, max-age=0\r\n'
printf 'Pragma: no-cache\r\n'
printf 'Expires: 0\r\n'
printf '\r\n'

if [[ "$SUCCESS" == true ]]; then
    printf 'Ping executado com sucesso.\n'
    printf 'Pacotes enviados: %s\n' "$TRANSMITTED"
    printf 'Pacotes recebidos: %s\n' "$RECEIVED"
    printf 'Perda: %s%%\n' "$LOSS_PCT"

    if [[ -n "$MIN_MS" ]]; then
        printf 'Min/Med/Max/Mdev: %s/%s/%s/%s ms\n' \
            "$MIN_MS" "$AVG_MS" "$MAX_MS" "$MDEV_MS"
    fi
else
    printf 'Não foi possível concluir o ping.\n'
    printf 'Pacotes enviados: %s\n' "$TRANSMITTED"
    printf 'Pacotes recebidos: %s\n' "$RECEIVED"
    printf 'Perda: %s%%\n' "$LOSS_PCT"
fi
