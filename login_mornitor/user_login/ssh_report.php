<?php
include(dirname(__FILE__) . '/inc.php');

$stime = time();
echo date('Y-m-d H:i:s') . " start\n";

$date_str = sprintf('%s %2d', date('M', time()-86400), date('j', time()-86400));

$str = '';
$str .= '<b>' . date('Y-m-d', time()-86400) . "</b><br/>\n";
$str .= "<table>\n";
$str .=  "<tr><th width='80'>用户</th><th width='80'>时间</th><th width='80'>操作类型</th><th>记录</th></tr>\n";

$cmd = 'cat /var/log/secure | grep "' . $date_str . '" | grep "sudo.*" -o | grep COMMAND | grep -v "NOT" | awk \'{print $2, $9, $10}\'';
$lines = null;
exec($cmd, $lines);
$result = array();
foreach($lines as $line){
	$ps = explode(';', trim($line));
	$user = trim($ps[0]);
	$cmd = str_replace('COMMAND=', '', trim($ps[1]));
	$result[$user][$cmd] = $cmd;
}
foreach($result as $user=>$v){
	$str .= "<tr><td>$user</td><td></td><td>sudo</td><td>" . join(', ', $v) . "</td></tr>\n";
}


$cmd = 'cat /var/log/secure | grep "' . $date_str . '" | grep \'password for\' | awk \'{print $6, $9, $11, $3}\'';
$lines = null;
exec($cmd, $lines);
$result = array();
foreach($lines as $line){
	$ps = explode(' ', trim($line));
	$ok = $ps[0] == 'Accepted'? 'ok' : 'failed';
	$str .= "<tr><td>{$ps[1]}</td><td>{$ps[3]}</td><td>login $ok</td><td>{$ps[2]}</td></tr>\n";
}

$str .= "</table>\n";
$title = "每日服务器审计";
report_error($str, $title, 'default@example.com');

$ts = time() - $stime;
echo date('Y-m-d H:i:s') . " stop. $ts s\n";



