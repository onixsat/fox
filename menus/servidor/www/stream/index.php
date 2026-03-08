<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script> 
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
<link href='https://unpkg.com/boxicons@2.0.7/css/boxicons.min.css' rel='stylesheet'>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>Lista</title>
<link href="https://fonts.googleapis.com/css?family=Roboto:400,700" rel="stylesheet">
<style>
html {
    box-sizing: border-box;
    font-size: 100%;
}
*, :after, :before {
    box-sizing: inherit;
}
body {
    background-color: #cc1db9;
    background-image: linear-gradient(rgb(0, 43, 62) 2%, rgb(0, 43, 62) 108%);
    color: #fff;
    min-height: 100vh;
    text-align: center;
    font-family: Roboto, sans-serif;
}
.logo {
    width: 120px;
    border-radius: 400px;
    border: 3px solid #fff;
    margin-bottom: 10px;
    transition: all .2s ease-in-out;
}
.logo:hover {
    background-color: #cc1db9;
}
a.featured:hover, a:hover {
    background-color: #cc1db9;
    color: #fff;
}
a {
    display: block;
    max-width: 400px;
    margin: 0 auto 15px;
    padding: 1px 20px;
    font-size: .85rem;
    color: #fff;
    border: 1px solid #fff;
    text-decoration: none;
    transition: all .2s ease-in-out;
}
a.featured {
    position: relative;
    background-color: rgb(211, 211, 211);
    color: #cc1db9;
    font-weight: 700;
}
a.featured:before {
    content: "";
    position: absolute;
    top: 2px;
    left: 2px;
    width: calc(100% - 4px);
    height: calc(100% - 4px);
    border: 2px solid #cc1db9;
}
h2 {
    font-size: 14px;
    text-transform: uppercase;
    font-weight: 400;
    letter-spacing: 2px
}
.channels {
    font-size: small;
    padding-bottom: 10px;
    color: gold;
}
.channels a {
    flex: 1;
    padding: 5px 10px;
    margin-right: 10px;
    background-color: #cc1db9;
    border: none;
}
.channels a:last-child {
    margin-right: 0;
}
.channels a:hover {
    text-decoration: underline;
}
a.unavailable {
    position: relative;
    color: #9c9c9c;
    font-weight: 700;
    border: 2px solid #9c9c9c;
    opacity: 0.5;
}
a.featured:hover, a:hover {
    background-color: #cc1db869;
}
</style>
<style>

ul {
  list-style: none;
  margin: 0;
  padding: 0;
}

ul li a {
  display: block;
  text-decoration: none;
  transition: text-indent 0.3s ease;
    margin: 0 auto -1px;
}

ul li a:hover {
  text-indent: 0px;
}
</style>
</head>
<body>
<!--https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/Nginx-PHP-FPM-config-example-->
    
    
<!-- Logo --> 
<img class="logo" src="https://pluspng.com/img-png/nginx-logo-png-accelerate-your-website-with-nginx-as-a-reverse-proxy-cache-dev-1000x500.png"> <span id="desc"></span>
<h2>Porta 8080 e 8443</h2>
<!--<p><p>-->
<div class="channels">/var/www/stream</div>
<h2>A porta 443 e 9000 é exclusiva para o painel administrador</h2>
<div class="channels">O dominio vps-3026dd85.vps.ovh.net tem as mesmas permissoes que o ip 51.91.248.109</div>

<!-- Main Content -->

<div id="myList">
    <div class="login">
        <span>Dominio admin permitido, redireciona para https</span>
        <a href="http://vps-3026dd85.vps.ovh.net">http://vps-3026dd85.vps.ovh.net</a>
        
        <span>Permite o serviço para utilizadores</span>
        <a href="http://vps-3026dd85.vps.ovh.net:8080">http://vps-3026dd85.vps.ovh.net:8080</a>
    
        <span>Permite o serviço para utilizadores</span>
        <a href="https://vps-3026dd85.vps.ovh.net:8443">https://vps-3026dd85.vps.ovh.net:8443</a>

        <span>Dominio admin permitido em https</span>
        <a href="https://vps-3026dd85.vps.ovh.net">https://vps-3026dd85.vps.ovh.net</a>

        <span>Não permite o acesso</span>
        <a href="http://ospro.pt" class="featured">http://ospro.pt</a>

        <span>Permite o serviço para utilizadores</span>
        <a href="http://ospro.pt:8080" class="featured">http://ospro.pt:8080</a>

        <span>Permite o serviço para utilizadores</span>
        <a href="https://ospro.pt:8443" class="featured">https://ospro.pt:8443</a>

        <span>Não permite o acesso</span>
        <a href="https://ospro.pt" class="featured">https://ospro.pt</a>
    </div>
</div>
<h2>A key para restaurar backuo nginx ui</h2>
<div class="channels">2fjWcHLiDeQ2bCEp31dCeNcevDMPdVGEgN4zQmESjmE=:/WV4Mz77DQagKEyPOBeuKQ==</div>
    
<script>
$(document).ready(function(){
    $("#myList a").attr("target", "_blank");
    $("#myList a").attr("data-toggle", "tooltip");
    $("#myList a").attr("data-placement", "right");
    
    $("#myList a").css("text-decoration", "unset");
    
    $("#myList span").css("font-family", "monospace");
    $("#myList span").css("font-size", "12px");
    
    $('[data-toggle="tooltip"]').tooltip();   
});
</script>
</body>
</html>
