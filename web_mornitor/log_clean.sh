#/bin/bash

LogDir="/var/log/"
LogFile="/var/log/web_page_clean.log"
log_clean(){
if [ -f "/var/log/web_page_status_$(date +%F).log" ]; then

   find $LogDir -type f -name "web_page_status_*" -mtime +2 >> $LogFile 2>&1
   find $LogDir -type f -name "web_page_status_*" -mtime +2 -delete >> $LogFile  2>&1
   echo "监控旧日志清除成功！ "|mail -s "Log cleared successfully "  example@domain.com
else
   echo "定时删除日志失败，日志不存在,请查看监控脚本是否正常运行"|mail -s "监控异常"  example@domain.com
   echo "send mail"
fi

}

log_clean

