<?php

require 'vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;

$mail = new PHPMailer();
$mail->Encoding = "base64";
$mail->SMTPAuth = true;
$mail->Host = "smtp.zeptomail.eu";
$mail->Port = 587;
$mail->Username = "emailapikey";
$mail->Password = 'yA6KbHtc6gX0k2JWRhI4gZjZ89szrK1s2X+xsi2weZN2Ldbmi6FpgxZsIYOzcWeJ3NPUs/4APY9Cc93r7d8KLcU8Yd5Uf5TGTuv4P2uV48xh8ciEYNYih5SvBbgRFadOdRgjCCUyQPEgWA==';
$mail->SMTPSecure = 'TLS';
$mail->isSMTP();
$mail->IsHTML(true);
$mail->CharSet = "UTF-8";
$mail->From = "noreply@ospro.pt";
$mail->addAddress('test-g8fhy0vl8@srv1.mail-tester.com');
$mail->Body="Test email sent successfully.Questions? Contact our support team: unsub@example.com?subject=unsubscribe
Acme, Inc. 123 Market Street, San Francisco, CA 94103
Privacy: privacyUrl
Terms: termsUrl

List-Unsubscribe: https://form.flodesk.com/preferences/V2RYYlBGMmJYRmNTRzYtOEomTmtNUy1lS0hhVnRBbmt0Ji1qU09XaVhzZ1l6Z1ctdk5ROVRUMGdIS2xYd2paLklSU2NUQzR0SkI5UXpqMThGU05tTk8zalVBa09Iay1aSg/unsubscribe?id=xyz
Unsubscribe: https://form.flodesk.com/preferences/V2RYYlBGMmJYRmNTRzYtOEomTmtNUy1lS0hhVnRBbmt0Ji1qU09XaVhzZ1l6Z1ctdk5ROVRUMGdIS2xYd2paLklSU2NUQzR0SkI5UXpqMThGU05tTk8zalVBa09Iay1aSg/unsubscribe?id=xyz

List-Unsubscribe-Post: List-Unsubscribe=One-Click.";
$mail->Subject="Test Email";
$mail->SMTPDebug = 1;
$mail->Debugoutput = function($str, $level) {echo "debug level $level; message: $str"; echo "<br>";};
if(!$mail->Send()) {
    echo "Mail sending failed";
} else {
    echo "Successfully sent";
}
?>