<?php
include(dirname(__FILE__) . '/inc.php');

$stime = time();
echo date('Y-m-d H:i:s') . " start\n";

check_log();

$ts = time() - $stime;
echo date('Y-m-d H:i:s') . " stop. $ts s\n";


function check_log(){
	$file = '/var/log/secure';
	if(!file_exists($file)){
		return;
	}
	$fp = fopen($file, 'r');
	if(!$fp){
		$tmp = date('H:i');
		if($tmp >= '00:00' && $tmp <= '00:05'){
			return;
		}   
		report_error("无法读取监控日志", $title);
		return;
	}
	$errors = array();
	$stime = time() - 60 * 2;
	$fileno = 0;
	while(($line = fgets($fp)) !== false){
		if(strpos($line, 'sshd:auth') === false){
			continue;
		}

		$ps = preg_split('/\s+/', $line);
		$time = "{$ps[0]} {$ps[1]} {$ps[2]}";
		$time = strtotime($time);
		if($time > $stime && $time - $stime < 3600){
			$errors[] = htmlspecialchars($line);
			if(count($errors) >= 10){
				break;
			}
		}
		$fileno ++;
	}

	if($errors){
		$str = join("<br/>\n", $errors) . "\n";
		$title = "ssh 监控";
		report_error($str, $title);
	}
	fclose($fp);
}

