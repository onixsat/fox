<?php
declare(strict_types=1);

$urlsPredefinidos = [
    1 => 'https://ospro.me:8443/get.php?username=dinistesteit&password=c4AhWITgRIuyhnwa&type=m3u&output=m3u8',
    2 => 'https://ospro.pt:8443/get.php?username=dinistesteit&password=c4AhWITgRIuyhnwa&type=m3u&output=m3u8',
    3 => 'https://teamninja21.xyz:8443/get.php?username=dinistesteit&password=c4AhWITgRIuyhnwa&type=m3u&output=m3u8',
    4 => 'https://juninho.xyz:8443/get.php?username=dinistesteit&password=c4AhWITgRIuyhnwa&type=m3u&output=m3u8',
    5 => 'https://teamninja21.xyz:8443/live/dinistesteit/c4AhWITgRIuyhnwa/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
    6 => 'https://juninho.xyz:8443/live/_jQjaS_0y-Lc-JIbJcov-oMp6jY_SC3KNp1VjgmDhISNYLJRNu1ImDhjSOy3NNBV/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
    7 => 'https://ospro.me:8443/live/_jQjaS_0y-Lc-JIbJcov-oMp6jY_SC3KNp1VjgmDhISNYLJRNu1ImDhjSOy3NNBV/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
    8 => 'http://juninho.xyz:8080/live/_jQjaS_0y-Lc-JIbJcov-oMp6jY_SC3KNp1VjgmDhISNYLJRNu1ImDhjSOy3NNBV/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
    9 => 'https://teamninja21.xyz:8443/live/dinistesteit/c4AhWITgRIuyhnwa/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
    10 => 'http://teamninja21.xyz:8080/live/dinistesteit/c4AhWITgRIuyhnwa/9356a7ca-f176-48a2-823d-7e74ed71b47a.m3u8',
];

function e(mixed $value): string
{
    return htmlspecialchars(
        (string) $value,
        ENT_QUOTES | ENT_SUBSTITUTE,
        'UTF-8'
    );
}

$ficheiroUrls = __DIR__ . DIRECTORY_SEPARATOR . 'urls.json';
$ficheiroLogs = __DIR__ . DIRECTORY_SEPARATOR . 'stream-logs.json';
$mensagem = null;
$tipoMensagem = 'sucesso';

function urlValida(string $url): bool
{
    $url = trim($url);
    $partes = filter_var($url, FILTER_VALIDATE_URL);

    if ($partes === false) {
        return false;
    }

    $esquema = strtolower((string) parse_url($url, PHP_URL_SCHEME));
    $anfitriao = parse_url($url, PHP_URL_HOST);

    return in_array($esquema, ['http', 'https'], true)
        && is_string($anfitriao)
        && $anfitriao !== '';
}

function categoriaUrl(string $url): string
{
    $caminho = strtolower((string) parse_url($url, PHP_URL_PATH));
    $consulta = strtolower((string) parse_url($url, PHP_URL_QUERY));

    if (
        preg_match('/(?:^|&)type=m3u(?:&|$)/i', $consulta) === 1
        || preg_match('/(?:^|&)output=m3u(?:&|$)/i', $consulta) === 1
        || preg_match('/\.m3u(?:$|[?#])/i', $caminho) === 1
    ) {
        return 'm3u';
    }

    if (
        preg_match('/\.m3u8(?:$|[?#])/i', $caminho) === 1
        || str_contains($caminho, '/live/')
        || str_contains($caminho, '/stream/')
    ) {
        return 'streaming';
    }

    return 'outras';
}

function carregarUrls(string $ficheiro, array $predefinidas): array
{
    if (!is_file($ficheiro)) {
        guardarUrls($ficheiro, $predefinidas);
        return $predefinidas;
    }

    $conteudo = file_get_contents($ficheiro);
    $dados = $conteudo === false ? null : json_decode($conteudo, true);

    if (!is_array($dados)) {
        return $predefinidas;
    }

    $urls = [];
    foreach ($dados as $url) {
        if (is_string($url) && urlValida($url) && !in_array($url, $urls, true)) {
            $urls[] = trim($url);
        }
    }

    return $urls !== [] ? array_combine(range(1, count($urls)), $urls) : $predefinidas;
}

function guardarUrls(string $ficheiro, array $urls): bool
{
    $json = json_encode(
        array_values($urls),
        JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
    );

    if ($json === false) {
        return false;
    }

    $temporario = $ficheiro . '.tmp';
    if (file_put_contents($temporario, $json . PHP_EOL, LOCK_EX) === false) {
        return false;
    }

    return rename($temporario, $ficheiro);
}

function carregarLogs(string $ficheiro): array
{
    if (!is_file($ficheiro)) {
        return [];
    }

    $conteudo = file_get_contents($ficheiro);
    $dados = $conteudo === false ? null : json_decode($conteudo, true);

    return is_array($dados) ? $dados : [];
}

function guardarLogs(string $ficheiro, array $logs): bool
{
    $json = json_encode(
        array_values($logs),
        JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
    );

    if ($json === false) {
        return false;
    }

    $temporario = $ficheiro . '.tmp';
    if (file_put_contents($temporario, $json . PHP_EOL, LOCK_EX) === false) {
        return false;
    }

    return rename($temporario, $ficheiro);
}

$logs = carregarLogs($ficheiroLogs);

$urls = carregarUrls($ficheiroUrls, $urlsPredefinidos);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $tipoConteudo = strtolower((string) ($_SERVER['CONTENT_TYPE'] ?? ''));

    if (str_contains($tipoConteudo, 'application/json')) {
        $entrada = json_decode((string) file_get_contents('php://input'), true);

        if (is_array($entrada) && ($entrada['acao'] ?? '') === 'registar_log') {
            $urlLog = trim((string) ($entrada['url'] ?? ''));
            $estadoLog = trim((string) ($entrada['estado'] ?? ''));
            $detalhesLog = $entrada['detalhes'] ?? [];

            if (!urlValida($urlLog) || $estadoLog === '') {
                http_response_code(400);
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode(['ok' => false, 'erro' => 'Dados de registo inválidos.']);
                exit;
            }

            $logs[] = [
                'url' => $urlLog,
                'data' => (new DateTimeImmutable(
                    'now',
                    new DateTimeZone('Europe/Lisbon')
                ))->format(DATE_ATOM),
                'estado' => substr($estadoLog, 0, 160),
                'detalhes' => is_array($detalhesLog)
                    ? $detalhesLog
                    : ['texto' => (string) $detalhesLog],
            ];

            // Evita que um histórico muito longo torne o ficheiro pesado.
            $logs = array_slice($logs, -2000);

            if (!guardarLogs($ficheiroLogs, $logs)) {
                http_response_code(500);
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode(['ok' => false, 'erro' => 'Não foi possível guardar o registo.']);
                exit;
            }

            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(['ok' => true]);
            exit;
        }
    }

    $acao = (string) ($_POST['acao'] ?? '');
    $urlRecebida = trim((string) ($_POST['url'] ?? ''));
    $idFormulario = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);

    if ($acao === 'remover' && $idFormulario !== false && isset($urls[$idFormulario])) {
        unset($urls[$idFormulario]);
        $urls = array_values($urls);
        if ($urls !== []) {
            $urls = array_combine(range(1, count($urls)), $urls);
        }

        if (guardarUrls($ficheiroUrls, $urls)) {
            header('Location: ?estado=removido');
            exit;
        }
        $mensagem = 'Não foi possível remover a URL do ficheiro JSON.';
        $tipoMensagem = 'erro';
    } elseif (!urlValida($urlRecebida)) {
        $mensagem = 'Indique uma URL válida que comece por http:// ou https://.';
        $tipoMensagem = 'erro';
    } elseif ($acao === 'adicionar') {
        $duplicado = in_array($urlRecebida, $urls, true);
        if ($duplicado) {
            $mensagem = 'Esta URL já está guardada.';
            $tipoMensagem = 'erro';
        } else {
            $urls[] = $urlRecebida;
            if (guardarUrls($ficheiroUrls, $urls)) {
                header('Location: ?estado=adicionado');
                exit;
            }
            array_pop($urls);
            $mensagem = 'Não foi possível guardar a URL no ficheiro JSON.';
            $tipoMensagem = 'erro';
        }
    } elseif ($acao === 'editar' && $idFormulario !== false && isset($urls[$idFormulario])) {
        $duplicado = in_array($urlRecebida, $urls, true)
            && $urls[$idFormulario] !== $urlRecebida;
        if ($duplicado) {
            $mensagem = 'Esta URL já existe noutra entrada.';
            $tipoMensagem = 'erro';
        } else {
            $urls[$idFormulario] = $urlRecebida;
            if (guardarUrls($ficheiroUrls, $urls)) {
                header('Location: ?estado=editado');
                exit;
            }
            $mensagem = 'Não foi possível guardar a alteração no ficheiro JSON.';
            $tipoMensagem = 'erro';
        }
    } else {
        $mensagem = 'Operação inválida ou URL não encontrada.';
        $tipoMensagem = 'erro';
    }
}

$categoriasUrls = [
    'm3u' => [],
    'streaming' => [],
    'outras' => [],
];
foreach ($urls as $numero => $url) {
    $categoriasUrls[categoriaUrl($url)][$numero] = $url;
}

$categoriaSelecionada = (string) ($_GET['categoria'] ?? 'm3u');
if (!array_key_exists($categoriaSelecionada, $categoriasUrls)) {
    $categoriaSelecionada = 'm3u';
}
$urlsVisiveis = $categoriaSelecionada === ''
    ? $urls
    : $categoriasUrls[$categoriaSelecionada];

$estado = (string) ($_GET['estado'] ?? '');
if ($estado === 'adicionado') {
    $mensagem = 'URL adicionada com sucesso.';
} elseif ($estado === 'editado') {
    $mensagem = 'URL editada com sucesso.';
} elseif ($estado === 'removido') {
    $mensagem = 'URL removida com sucesso.';
}

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
$idValido = $id !== false && $id !== null && isset($urls[$id]);

$erro = null;
$analise = null;
$playerDisponivel = false;
$respostaFalhaHttp = false;

if ($id !== null && $id !== false && !$idValido) {
    $erro = 'ID inválido. Escolha uma URL existente na lista.';
} else {
    if ($id === null || $id === false) {
        // A página inicial mostra apenas a lista; a análise começa ao escolher uma URL.
        $urlSelecionada = null;
    } else {
    $urlSelecionada = $urls[$id];
    $curl = curl_init($urlSelecionada);

    curl_setopt_array($curl, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HEADER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_AUTOREFERER => true,

        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
        CURLOPT_CERTINFO => true,
        CURLOPT_SSLVERSION => CURL_SSLVERSION_DEFAULT,

        CURLOPT_ENCODING => '',
        CURLOPT_HTTPHEADER => [
            'Accept: application/vnd.apple.mpegurl, application/x-mpegURL, application/mpegurl, video/*, */*',
            'Accept-Language: pt-PT,pt;q=0.9,en;q=0.8',
            'Cache-Control: no-cache',
            'Connection: keep-alive',
        ],

        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2TLS,
        CURLOPT_IPRESOLVE => CURL_IPRESOLVE_WHATEVER,
        CURLOPT_PROTOCOLS => CURLPROTO_HTTP | CURLPROTO_HTTPS,
        CURLOPT_REDIR_PROTOCOLS => CURLPROTO_HTTP | CURLPROTO_HTTPS,

        CURLOPT_DNS_CACHE_TIMEOUT => 120,
        CURLOPT_TCP_KEEPALIVE => 1,
        CURLOPT_TCP_KEEPIDLE => 30,
        CURLOPT_TCP_KEEPINTVL => 10,
        CURLOPT_BUFFERSIZE => 65536,
        CURLOPT_COOKIEFILE => '',
        CURLOPT_COOKIESESSION => true,
        CURLOPT_NOSIGNAL => true,

        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_CONNECTTIMEOUT_MS => 10000,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_LOW_SPEED_LIMIT => 128,
        CURLOPT_LOW_SPEED_TIME => 15,
        CURLOPT_USERAGENT => 'Mozilla/5.0',
    ]);

    $resposta = curl_exec($curl);
    $erroCurl = curl_error($curl);
    $info = curl_getinfo($curl);
    curl_close($curl);

    if ($resposta === false) {
        $erro = 'Erro ao consultar a URL: ' . $erroCurl;
    } else {
        $headerSize = (int) ($info['header_size'] ?? 0);
        $headers = substr($resposta, 0, $headerSize);
        $body = substr($resposta, $headerSize);
        $finalUrl = $info['url'] ?? $urlSelecionada;
        $contentType = $info['content_type'] ?? 'Não informado';

        $analise = [
            'headers' => str_replace("\r", '', $headers),
            'body' => str_replace("\r", '', $body),
            'http' => $info['http_code'] ?? 0,
            'redirects' => $info['redirect_count'] ?? 0,
            'finalUrl' => $finalUrl,
            'type' => $contentType,
            'time' => $info['total_time'] ?? 0,
            'sslVersion' => $info['ssl_version'] ?? 'Não informado',
            'sslVerifyResult' => $info['ssl_verifyresult'] ?? 'Não informado',
            'certInfo' => $info['certinfo'] ?? [],
        ];
 
         $respostaFalhaHttp = (int) ($analise['http'] ?? 0) >= 400;

        $ehCatalogoM3u = str_contains($body, '#EXTINF:')
            && !str_contains($body, '#EXT-X-TARGETDURATION')
            && !str_contains($body, '#EXT-X-STREAM-INF');

        $playerDisponivel = !$ehCatalogoM3u
            && (
                str_contains(strtolower((string) $contentType), 'mpegurl')
                || preg_match('/\.m3u8(?:$|[?#])/i', $finalUrl) === 1
            );
    }
    }
}

$urlParaHistorico = $analise['finalUrl'] ?? $urlSelecionada ?? null;
$historicoUrl = $urlParaHistorico === null
    ? []
    : array_reverse(array_values(array_filter(
        $logs,
        static fn (mixed $registo): bool =>
            is_array($registo)
            && ($registo['url'] ?? null) === $urlParaHistorico
    )));
?>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Análise de Stream</title>
<style>
*{box-sizing:border-box}
body{margin:0;padding:20px;background:#f1f5f9;color:#263238;font-family:Arial,sans-serif}
.container{max-width:1100px;margin:auto;padding:25px;background:#fff;border-radius:12px;box-shadow:0 4px 18px #0002}
h1{margin-top:0;color:#1e3a8a}
h2{margin-top:28px;color:#1e40af}
h3{color:#334155}
.mensagem{margin:20px 0;padding:15px;border-radius:8px}
.erro{color:#991b1b;background:#fee2e2;border-left:5px solid #dc2626}
.sucesso{color:#166534;background:#dcfce7;border-left:5px solid #16a34a}
.aviso{color:#854d0e;background:#fef9c3;border-left:5px solid #eab308}
table{width:100%;border-collapse:collapse;margin-top:15px}
th,td{padding:12px;text-align:left;vertical-align:top;border-bottom:1px solid #cbd5e1}
th{color:#1e3a8a;background:#dbeafe}
tr.selecionada{font-weight:bold;background:#dcfce7}
a{color:#1d4ed8;text-decoration:none}
a:hover{color:#dc2626;text-decoration:underline}
code{word-break:break-all}
pre{max-height:450px;overflow:auto;padding:16px;color:#e2e8f0;background:#0f172a;border-radius:8px;white-space:pre-wrap;word-break:break-all}
.metadados{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:12px;margin-top:25px}
.cartao{padding:15px;background:#f8fafc;border-left:5px solid #2563eb;border-radius:8px}
.cartao h3{margin:0 0 8px;color:#64748b;font-size:12px;text-transform:uppercase}
.cartao p{margin:0;font-size:18px;font-weight:bold;word-break:break-word}
.player{margin-top:28px;padding:20px;color:#e2e8f0;background:#0f172a;border-radius:12px}
.player-top{display:flex;justify-content:space-between;gap:16px;margin-bottom:16px}
.player h2{margin:6px 0;color:#f8fafc}
.etiqueta{color:#67e8f9;font-size:11px;font-weight:bold;letter-spacing:.12em}
.estado{padding:7px 10px;color:#bbf7d0;background:#16a34a33;border:1px solid #4ade8060;border-radius:999px;font-size:12px;white-space:nowrap}
.estado.erro-player{color:#fecaca;background:#dc262633;border-color:#f8717160}
#stream-player{display:block;width:100%;min-height:260px;background:#020617;border-radius:8px}
.ajuda{margin:12px 0 0;color:#94a3b8;font-size:13px}
 .detalhes-player{display:block;margin-top:16px}
 .detalhes-player summary{padding:10px 12px;color:#bae6fd;background:#082f49;border:1px solid #0369a1;border-radius:7px;cursor:pointer;font-weight:bold}
 .detalhes-player.erro-detalhes summary{color:#fecaca;background:#450a0a;border-color:#7f1d1d}
 .detalhes-player pre{max-height:320px;margin:10px 0 0;color:#bae6fd;background:#111827;border:1px solid #0e7490;font-size:12px}
 .detalhes-player.erro-detalhes pre{color:#fecaca;border-color:#7f1d1d}
 .telemetria{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));gap:10px;margin-top:16px}
 .telemetria-cartao{padding:12px;background:#111827;border:1px solid #1e3a5f;border-radius:8px}
 .telemetria-cartao small{display:block;color:#94a3b8;font-size:11px;text-transform:uppercase;letter-spacing:.04em}
 .telemetria-cartao strong{display:block;margin-top:5px;color:#e0f2fe;font-size:15px;word-break:break-word}
 .eventos-stream{margin-top:16px;padding:12px;background:#020617;border:1px solid #1e293b;border-radius:8px}
 .eventos-stream h3{margin:0 0 8px;color:#bae6fd;font-size:14px}
 #lista-eventos-stream{max-height:150px;margin:0;padding-left:20px;color:#cbd5e1;font-size:12px;overflow:auto}
 #lista-eventos-stream li{margin:4px 0}
 .menu-principal{display:flex;flex-wrap:wrap;gap:8px;margin:0 0 24px;padding:10px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px}
 .menu-botao{display:inline-block;padding:9px 12px;color:#1e3a8a;background:#dbeafe;border:1px solid transparent;border-radius:7px;cursor:pointer;font:inherit;font-weight:bold;text-decoration:none}
 .menu-botao:hover{color:#1e3a8a;background:#bfdbfe;text-decoration:none}
 .menu-botao.ativo{color:#fff;background:#2563eb;border-color:#1d4ed8;box-shadow:0 2px 5px #1d4ed855}
.historico{margin-top:28px}
.registo{margin:10px 0;border:1px solid #cbd5e1;border-radius:8px;background:#f8fafc}
.registo summary{padding:12px;cursor:pointer;font-weight:bold;color:#1e3a8a}
.registo.erro-registo summary{color:#991b1b}
.registo pre{margin:0;border-radius:0 0 8px 8px;font-size:12px}
.gestao{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:12px;align-items:end;margin:22px 0;padding:18px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px}
.campo{display:flex;flex-direction:column;gap:7px}
.campo label{font-weight:bold;color:#1e3a8a}
input[type=url]{width:100%;padding:11px 12px;border:1px solid #94a3b8;border-radius:7px;font:inherit}
input[type=url]:focus{outline:3px solid #bfdbfe;border-color:#2563eb}
button{padding:10px 14px;border:0;border-radius:7px;color:#fff;background:#2563eb;font:inherit;font-weight:bold;cursor:pointer}
button:hover{background:#1d4ed8}
.acoes{display:flex;flex-wrap:wrap;gap:7px;align-items:center}
.acoes form{display:inline-flex;gap:6px;align-items:center}
.botao-secundario{padding:7px 10px;color:#1e3a8a;background:#dbeafe;font-size:13px}
.botao-secundario:hover{background:#bfdbfe}
.botao-perigo{padding:7px 10px;color:#991b1b;background:#fee2e2;font-size:13px}
.botao-perigo:hover{background:#fecaca}
.url-tabela{min-width:240px}
.url-tabela code{display:block;margin-bottom:8px}
 .etiqueta-categoria{display:inline-block;margin-bottom:6px;padding:3px 7px;color:#1e3a8a;background:#dbeafe;border-radius:999px;font-size:10px;font-weight:bold;text-transform:uppercase;letter-spacing:.05em}
.editar-form{display:none;grid-template-columns:minmax(0,1fr) auto;gap:7px;margin-top:8px}
.editar-form.aberto{display:grid}
.editar-form input{min-width:0}
@media(max-width:700px){body{padding:8px}.container{padding:16px}th,td{padding:8px;font-size:13px}.player-top{flex-direction:column}}
@media(max-width:700px){.gestao{grid-template-columns:1fr}.editar-form{grid-template-columns:1fr}}
</style>
</head>
<body>
<main class="container">
<h1>Relatório de análise de stream</h1>
<p>Escolha uma URL para analisá-la ou gira a sua lista abaixo.</p>

<?php if ($erro !== null): ?>
<div class="mensagem erro"><strong>Erro:</strong> <?= e($erro) ?></div>
<?php endif; ?>

<?php if ($mensagem !== null): ?>
<div class="mensagem <?= e($tipoMensagem) ?>">
    <?= e($mensagem) ?>
</div>
<?php endif; ?>

<?php if ($analise !== null): ?>
<div class="mensagem sucesso">
    O parâmetro <strong>id=<?= e($id) ?></strong> foi inserido corretamente.
</div>
<?php endif; ?>

<h2>Adicionar URL</h2>
<form class="gestao" method="post">
    <input type="hidden" name="acao" value="adicionar">
    <div class="campo">
        <label for="nova-url">URL HTTP/HTTPS</label>
        <input
            id="nova-url"
            name="url"
            type="url"
            placeholder="https://exemplo.com/stream.m3u8"
            inputmode="url"
            required
        >
    </div>
    <button type="submit">Adicionar URL</button>
</form>
<p class="ajuda">As URLs ficam guardadas em <code>urls.json</code>, junto deste ficheiro PHP. Não são aceites endereços duplicados.</p>

<?php
$nomesCategorias = [
    'm3u' => 'URLs M3U',
    'streaming' => 'URLs streaming',
    'outras' => 'Outras URLs',
];
?>
<nav class="menu-principal" aria-label="Filtro de URLs">
<?php foreach ($nomesCategorias as $categoria => $nomeCategoria): ?>
    <a
        class="menu-botao <?= $categoriaSelecionada === $categoria ? 'ativo' : '' ?>"
        href="?categoria=<?= e($categoria) ?>#lista-urls"
        <?= $categoriaSelecionada === $categoria ? 'aria-current="page"' : '' ?>
    ><?= e($nomeCategoria) ?> (<?= e(count($categoriasUrls[$categoria])) ?>)</a>
<?php endforeach; ?>
</nav>

<h2 id="lista-urls">
    URLs disponíveis
    <?php if ($categoriaSelecionada !== ''): ?>
        — <?= e($nomesCategorias[$categoriaSelecionada]) ?>
    <?php endif; ?>
</h2>
<?php if ($categoriaSelecionada !== ''): ?>
<p class="ajuda">
    A mostrar <?= e(count($urlsVisiveis)) ?> URL(s) desta categoria.
</p>
<?php endif; ?>
<table>
<thead><tr><th>ID</th><th>URL clicável</th><th>Estado</th><th>Opções</th></tr></thead>
<tbody>
<?php if ($urlsVisiveis === []): ?>
<tr><td colspan="4"><div class="mensagem aviso">Não existem URLs disponíveis nesta categoria.</div></td></tr>
<?php endif; ?>
<?php foreach ($urlsVisiveis as $numero => $url): ?>
<tr id="url-<?= e($numero) ?>" class="<?= $idValido && $numero === $id ? 'selecionada' : '' ?>">
<td><?= e($numero) ?></td>
<td class="url-tabela">
    <span class="etiqueta-categoria"><?= e($nomesCategorias[categoriaUrl($url)]) ?></span>
    <a href="?id=<?= e($numero) ?>"><code><?= e($url) ?></code></a>
    <form id="editar-<?= e($numero) ?>" class="editar-form" method="post">
        <input type="hidden" name="acao" value="editar">
        <input type="hidden" name="id" value="<?= e($numero) ?>">
        <input type="url" name="url" value="<?= e($url) ?>" required aria-label="Editar URL <?= e($numero) ?>">
        <button type="submit">Guardar</button>
    </form>
</td>
<td><?= $idValido && $numero === $id ? 'Selecionada' : 'Disponível' ?></td>
<td class="acoes">
    <button type="button" class="botao-secundario" onclick="mostrarEdicao(<?= e($numero) ?>)">Editar</button>
    <form method="post" onsubmit="return confirm('Remover esta URL da lista?');">
        <input type="hidden" name="acao" value="remover">
        <input type="hidden" name="id" value="<?= e($numero) ?>">
        <button type="submit" class="botao-perigo">Remover</button>
    </form>
</td>
</tr>
<?php endforeach; ?>
</tbody>
</table>

<?php if ($analise !== null): ?>
<div class="metadados">
<?php
$dados = [
    'HTTP Code' => $analise['http'],
    'SSL' => $analise['sslVersion'],
    'Resultado SSL' => $analise['sslVerifyResult'],
    'Redirecionamentos' => $analise['redirects'],
    'Tipo de conteúdo' => $analise['type'],
    'Tempo' => number_format((float) $analise['time'], 2) . ' segundos',
];
foreach ($dados as $titulo => $valor):
?>
<div class="cartao">
<h3><?= e($titulo) ?></h3>
<p><?= e($valor) ?></p>
</div>
<?php endforeach; ?>
</div>

<h2>URL final</h2>
<pre><?= e($analise['finalUrl']) ?></pre>

<?php if ($playerDisponivel): ?>
<section class="player">
<div class="player-top">
<div>
<span class="etiqueta">REPRODUÇÃO AO VIVO</span>
<h2>Player do streaming</h2>
</div>
<span id="estado-player" class="estado">A preparar...</span>
</div>

<video id="stream-player" controls playsinline preload="metadata">
O seu navegador não suporta reprodução de vídeo.
</video>

<div class="telemetria" aria-live="polite">
    <div class="telemetria-cartao"><small>Estado do vídeo</small><strong id="telemetria-estado">A aguardar</strong></div>
    <div class="telemetria-cartao"><small>Qualidade</small><strong id="telemetria-qualidade">A aguardar</strong></div>
    <div class="telemetria-cartao"><small>Bitrate</small><strong id="telemetria-bitrate">A aguardar</strong></div>
    <div class="telemetria-cartao"><small>Buffer</small><strong id="telemetria-buffer">A aguardar</strong></div>
    <div class="telemetria-cartao"><small>Tempo atual</small><strong id="telemetria-tempo">A aguardar</strong></div>
    <div class="telemetria-cartao"><small>Eventos</small><strong id="telemetria-eventos">0</strong></div>
</div>

<div class="eventos-stream">
    <h3>Eventos recentes do streaming</h3>
    <ol id="lista-eventos-stream"><li>A iniciar diagnóstico...</li></ol>
</div>

<details id="detalhes-player" class="detalhes-player" open>
<summary id="titulo-detalhes-player">Detalhes completos do streaming</summary>
<pre id="texto-erro-player"></pre>
</details>

<p class="ajuda">Prima Play para iniciar o streaming.</p>
</section>
<?php else: ?>
<?php if ($respostaFalhaHttp): ?>
<div class="mensagem erro">
<strong>O servidor remoto recusou a abertura desta URL.</strong>
O endereço devolveu HTTP <code><?= e($analise['http']) ?></code>
<?= $analise['type'] !== 'Não informado' ? 'com o tipo de conteúdo ' . e($analise['type']) : '' ?>.
Não foi recebido nenhum conteúdo para reproduzir. Verifique o servidor,
a porta <code>8081</code> e se esta URL necessita de parâmetros adicionais.
</div>
<?php else: ?>
<div class="mensagem aviso">
<strong>URL final mantida acima.</strong>
Esta resposta é uma playlist/catálogo M3U e não um vídeo HLS direto.
Escolha uma URL direta terminada em <code>.m3u8</code> para utilizar o player.
</div>
<?php endif; ?>
<?php endif; ?>

<section class="historico">
<h2>Registo completo desta URL</h2>
<?php if ($urlParaHistorico === null): ?>
<div class="mensagem aviso">Selecione uma URL para consultar o histórico.</div>
<?php else: ?>
<p class="ajuda">Os registos são guardados em <code>stream-logs.json</code> com a data e hora de cada evento.</p>
<?php if ($historicoUrl !== []): ?>
<?php foreach ($historicoUrl as $registo): ?>
<?php
$registoErro = str_contains(
    strtolower((string) ($registo['estado'] ?? '')),
    'falha'
) || str_contains(
    strtolower((string) ($registo['estado'] ?? '')),
    'não suporta'
);
$detalhesRegisto = $registo['detalhes']['texto']
    ?? json_encode($registo['detalhes'] ?? [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>
<details class="registo <?= $registoErro ? 'erro-registo' : '' ?>">
<summary><?= e($registo['data'] ?? 'Data desconhecida') ?> — <?= e($registo['estado'] ?? 'Estado desconhecido') ?></summary>
<pre><?= e($detalhesRegisto) ?></pre>
</details>
<?php endforeach; ?>
<?php else: ?>
<div class="mensagem aviso">Ainda não existem registos para esta URL.</div>
<?php endif; ?>
<?php endif; ?>
</section>

<h2>SSL Certificate Checker</h2>
<?php if (!empty($analise['certInfo'])): ?>
<?php foreach ($analise['certInfo'] as $indice => $certificado): ?>
<h3>Certificado <?= e($indice + 1) ?></h3>
<pre><?= e(implode("\n", $certificado)) ?></pre>
<?php endforeach; ?>
<?php else: ?>
<div class="mensagem erro">
O servidor não devolveu informações do certificado SSL.
</div>
<?php endif; ?>

<h2>Cabeçalhos HTTP</h2>
<pre><?= e($analise['headers']) ?></pre>

<h2>Conteúdo do ficheiro M3U8</h2>
<pre><?= e($analise['body']) ?></pre>
<?php endif; ?>
</main>

<script>
function mostrarEdicao(id) {
    const formulario = document.getElementById('editar-' + id);
    if (!formulario) return;
    formulario.classList.toggle('aberto');
    if (formulario.classList.contains('aberto')) {
        formulario.querySelector('input[type="url"]').focus();
    }
}
</script>

<?php if ($analise !== null && $playerDisponivel): ?>
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
<script>
(() => {
    const video = document.getElementById('stream-player');
    const estado = document.getElementById('estado-player');
    const detalhesErro = document.getElementById('detalhes-player');
    const tituloDetalhes = document.getElementById('titulo-detalhes-player');
    const textoErro = document.getElementById('texto-erro-player');
    const telemetria = {
        estado: document.getElementById('telemetria-estado'),
        qualidade: document.getElementById('telemetria-qualidade'),
        bitrate: document.getElementById('telemetria-bitrate'),
        buffer: document.getElementById('telemetria-buffer'),
        tempo: document.getElementById('telemetria-tempo'),
        eventos: document.getElementById('telemetria-eventos'),
    };
    const listaEventos = document.getElementById('lista-eventos-stream');
    let totalEventos = 0;
    let ultimoEventoRegistado = '';
    const url = <?= json_encode(
        $analise['finalUrl'],
        JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT
    ) ?>;

    const atualizarEstado = (texto, erro = false) => {
        estado.textContent = texto;
        estado.classList.toggle('erro-player', erro);
        telemetria.estado.textContent = texto;
    };

    const registarEvento = (nome, dados = {}) => {
        const agora = new Date().toLocaleTimeString('pt-PT');
        const resumo = Object.entries(dados)
            .filter(([, valor]) => valor !== undefined && valor !== null && valor !== '')
            .map(([chave, valor]) => `${chave}: ${valor}`)
            .join(' · ');
        const texto = `[${agora}] ${nome}${resumo ? ` — ${resumo}` : ''}`;
        if (texto === ultimoEventoRegistado) return;
        ultimoEventoRegistado = texto;
        totalEventos += 1;
        telemetria.eventos.textContent = String(totalEventos);
        const item = document.createElement('li');
        item.textContent = texto;
        listaEventos.prepend(item);
        while (listaEventos.children.length > 12) {
            listaEventos.lastElementChild.remove();
        }
    };

    const guardarRegisto = (estadoAtual, texto) => {
        fetch(window.location.href, {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
            body: JSON.stringify({
                acao: 'registar_log',
                url,
                estado: estadoAtual,
                detalhes: { texto },
            }),
        }).catch(() => {
            // O diagnóstico local continua disponível mesmo se o servidor
            // não conseguir gravar o histórico neste momento.
        });
    };

    const mostrarDetalhesStreaming = (titulo, dados = {}, erro = false) => {
        const linhas = [
            `Estado: ${titulo}`,
            `URL analisada: ${url}`,
            `Momento: ${new Date().toISOString()}`,
        ];

        Object.entries(dados).forEach(([chave, valor]) => {
            if (valor === undefined || valor === null || valor === '') return;
            let valorFormatado;
            if (typeof valor === 'object') {
                try {
                    valorFormatado = JSON.stringify(valor, null, 2);
                } catch (_erro) {
                    valorFormatado = '[Objeto não serializável: ' + String(valor) + ']';
                }
            } else {
                valorFormatado = String(valor);
            }
            linhas.push(`${chave}: ${valorFormatado}`);
        });

        textoErro.textContent = linhas.join('\n');
        guardarRegisto(titulo, linhas.join('\n'));
        tituloDetalhes.textContent = erro
            ? 'Detalhes completos do erro'
            : 'Detalhes completos do streaming';
        detalhesErro.classList.toggle('erro-detalhes', erro);
        if (erro) {
            detalhesErro.open = true;
        }
    };

    const detalhesVideo = () => ({
        EstadoPronto: video.readyState,
        EstadoRede: video.networkState,
        LarguraVídeo: video.videoWidth,
        AlturaVídeo: video.videoHeight,
        DuraçãoSegundos: Number.isFinite(video.duration)
            ? video.duration
            : 'Não disponível',
        Volume: video.volume,
        Silencioso: video.muted,
        Reproduzindo: !video.paused,
        Buffer: video.buffered.length > 0
            ? `${video.buffered.start(0).toFixed(2)}s - ${video.buffered.end(video.buffered.length - 1).toFixed(2)}s`
            : 'Sem dados em buffer',
    });

    const atualizarTelemetria = (hls = null) => {
        const buffer = video.buffered.length > 0
            ? video.buffered.end(video.buffered.length - 1) - video.currentTime
            : 0;
        const nivel = hls && hls.currentLevel >= 0 ? hls.levels[hls.currentLevel] : null;
        const bitrate = hls && hls.bandwidthEstimate ? hls.bandwidthEstimate : (nivel && nivel.bitrate);
        telemetria.qualidade.textContent = nivel
            ? `${nivel.width || '?'}×${nivel.height || '?'}`
            : (video.videoWidth ? `${video.videoWidth}×${video.videoHeight}` : 'A aguardar');
        telemetria.bitrate.textContent = bitrate
            ? `${(Number(bitrate) / 1000000).toFixed(2)} Mbps`
            : 'Não disponível';
        telemetria.buffer.textContent = `${Math.max(0, buffer).toFixed(2)} s`;
        telemetria.tempo.textContent = Number.isFinite(video.currentTime)
            ? `${video.currentTime.toFixed(1)} s`
            : 'A aguardar';
    };

    const intervaloTelemetria = window.setInterval(() => atualizarTelemetria(), 1000);
    window.addEventListener('beforeunload', () => window.clearInterval(intervaloTelemetria));
    video.addEventListener('waiting', () => registarEvento('Buffering', detalhesVideo()));
    video.addEventListener('stalled', () => registarEvento('Rede parada', detalhesVideo()));
    video.addEventListener('pause', () => registarEvento('Reprodução pausada', detalhesVideo()));
    video.addEventListener('error', () => registarEvento('Erro do elemento de vídeo', {
        Código: video.error && video.error.code,
        Mensagem: video.error && video.error.message,
    }));

    if (window.Hls && window.Hls.isSupported()) {
        const hls = new window.Hls({
            enableWorker: true,
            lowLatencyMode: true,
            backBufferLength: 30
        });

        hls.loadSource(url);
        hls.attachMedia(video);

        hls.on(
            window.Hls.Events.MANIFEST_PARSED,
            (_evento, dados) => {
                atualizarEstado('Pronto para reproduzir');
                registarEvento('Manifesto carregado', {
                    Níveis: hls.levels.length,
                    URL: dados && dados.url,
                });
                atualizarTelemetria(hls);
                mostrarDetalhesStreaming('Streaming carregado com sucesso', {
                    Motor: 'HLS.js',
                    NívelInicial: dados && dados.level,
                    NíveisDisponíveis: hls.levels.length,
                    Resolução: dados && dados.levelInfo
                        ? `${dados.levelInfo.width || '?'}x${dados.levelInfo.height || '?'}`
                        : 'Não informada',
                    Manifesto: dados && dados.url,
                    ...detalhesVideo(),
                });
            }
        );

        ['loadedmetadata', 'canplay', 'playing'].forEach((evento) => {
            video.addEventListener(evento, () => {
                atualizarTelemetria(hls);
                registarEvento(evento === 'playing' ? 'Streaming em reprodução' : `Evento: ${evento}`, detalhesVideo());
                if (!detalhesErro.classList.contains('erro-detalhes')) {
                    mostrarDetalhesStreaming(
                        evento === 'playing'
                            ? 'Streaming em reprodução'
                            : 'Streaming carregado com sucesso',
                        {
                            Motor: 'HLS.js',
                            NíveisDisponíveis: hls.levels.length,
                            ...detalhesVideo(),
                        }
                    );
                }
            });
        });

        hls.on(
            window.Hls.Events.ERROR,
            (_evento, dados) => {
                registarEvento(dados.fatal ? 'Falha fatal HLS' : 'Aviso HLS', {
                    Tipo: dados.type,
                    Detalhe: dados.details,
                    CódigoHTTP: dados.response && dados.response.code,
                });
                if (dados.fatal) {
                    atualizarEstado('Não foi possível carregar o streaming', true);
                    mostrarDetalhesStreaming('Falha fatal do HLS', {
                        Tipo: dados.type,
                        Detalhe: dados.details,
                        Fatal: dados.fatal,
                        CódigoHTTP: dados.response && dados.response.code,
                        URLResposta: dados.response && dados.response.url,
                        TextoResposta: dados.response && dados.response.text,
                        Rede: dados.networkDetails,
                        DadosCompletos: dados,
                        ...detalhesVideo(),
                    }, true);
                }
            }
        );
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
        video.src = url;
        atualizarEstado('HLS nativo disponível');
        video.addEventListener('loadedmetadata', () => {
            atualizarTelemetria();
            registarEvento('Metadados carregados', detalhesVideo());
            mostrarDetalhesStreaming('Streaming carregado com sucesso', {
                Motor: 'HLS nativo do navegador',
                ...detalhesVideo(),
            });
        });
        video.addEventListener('playing', () => {
            atualizarTelemetria();
            registarEvento('Streaming em reprodução', detalhesVideo());
            mostrarDetalhesStreaming('Streaming em reprodução', {
                Motor: 'HLS nativo do navegador',
                ...detalhesVideo(),
            });
        });
        video.addEventListener('error', () => {
            atualizarEstado('Não foi possível carregar o streaming', true);
            mostrarDetalhesStreaming('Falha do leitor HLS nativo', {
                CódigoMediaError: video.error && video.error.code,
                MensagemMediaError: video.error && video.error.message,
                ...detalhesVideo(),
            }, true);
        });
    } else {
        atualizarEstado('HLS não suportado neste navegador', true);
        mostrarDetalhesStreaming('Este navegador não suporta reprodução HLS', {
            HlsJsDisponível: Boolean(window.Hls),
            CanPlayType: video.canPlayType('application/vnd.apple.mpegurl'),
            ...detalhesVideo(),
        }, true);
    }
})();
</script>
<?php endif; ?>
</body>
</html>