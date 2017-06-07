:<?php
function report_error($str, $title=null, $to=null){
	if(!$to){
		$to = 'default_mail@example.com';
	}
	report_error_one($str, $title, 'user1@example.com');
	report_error_one($str, $title, 'user2@example.com');
	/*
	report_error_one($str, $title, 'user@example.com');
	
	*/
}

function report_error_one($msg, $title=null, $to=null){
	$host = gethostname();
	if(!$to){
		$to = 'default_mail@example.com';
	}
	$subject = "【系统监控】$host";
	if($title){
		$subject .= ' - ' . $title;
	}
	$text = <<<HTML
		<html>
		<head>
			<meta charset="utf-8" />
			<style>
				body{
					font-size: 16px;
				}
				table{
					border-collapse: collapse;
				}
				td{
					border: 1px solid #999;
					padding: 4px;
				}
			</style>
		</head>
		<body>
		<h1>Host: $host</h1>
		<br/>
		$msg
		</body>
		</html>
HTML;
	
	if(1){
		sendmail_smtp($to, $subject, $text);
	}else{
		$subject = "=?UTF-8?B?".base64_encode($subject)."?=";
		$headers  = 'MIME-Version: 1.0' . "\r\n";
		//$headers .= "From: alert_mail@126.com\r\n";
		$headers .= "From: alert@126.com\r\n";
		$headers .= 'Content-type: text/html; charset=utf-8' . "\r\n";
		mail($to, $subject, $text, $headers);
	}
}

function sendmail_smtp($to, $subject, $body){
	$SMTP_126_HOST = 'smtp.126.com';
	$SMTP_126_USERNAME = 'alert@126.com';
	$SMTP_126_PASSWORD = 'passwordxxx';
	$SMTP_126_HOST = 'smtp.126.com';
	$SMTP_126_USERNAME = 'alert@126.com';

   /*	require_once(dirname(__FILE__) . '/PHPMailer/class.phpmailer.php');
   */
        require_once(dirname(__FILE__) . '/PHPMailer/PHPMailerAutoload.php');

	$mail = new PHPMailer();
	$mail->FromName = 'monitor';
	$mail->From = $SMTP_126_USERNAME;
	$mail->isSMTP();
	$mail->isHTML(true);
	$mail->SMTPAuth = true;
	$mail->CharSet  = "utf-8";
	$mail->Host     = $SMTP_126_HOST;
	$mail->Username = $SMTP_126_USERNAME;
	$mail->Password = $SMTP_126_PASSWORD;

	if (is_string($to)) {
		$to = explode(',', $to);
	}
	foreach($to as $t){
		$t = trim($t);
		if(strlen($t)){
			$mail->addAddress($t);
		}
	}

	$mail->Subject = '=?UTF-8?B?' . base64_encode($subject) . '?=';;
	$mail->Body    = $body;
	if(!$mail->send()) {
		$error = $mail->ErrorInfo;
		echo "SMTP方式邮件发送失败: {$to}, {$subject}, {$body}, " . $error . "\n";
	} else {
	}
}

