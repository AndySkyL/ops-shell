# 修改inc.php中的邮箱地址，修改ssh_report.php的默认邮箱地址。
# crontab 中添加配置：

05 00 * * * php /home/work/ops/scripts/ssh_report.php 1>/dev/null
*/1 * * * * php /home/work/ops/scripts/ssh_monitor.php 1>/dev/null

