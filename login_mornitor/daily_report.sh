#!/bin/bash
# this script recode user daily login info.

tag_day=$(date -d'-1 day' +'%b %d')
tag_year=$(date -d'-1 day' +%Y)


utmpdump /var/log/wtmp|grep "$tag_day .*$tag_year"|awk -F '\\] \\[' '{print $4" "$5" "$6" "$7" "$8}'|egrep -v "^[ ]" > /tmp/login.log
echo " " >> /tmp/login.log 
echo "操作记录：" >> /tmp/login.log
grep "COMMAND" /var/log/secure|egrep "$(env LANG=en_US.UTF-8 date -d'-1 day' +'%b %d')"|awk -F ';' '{print $1" "$4}' >> /tmp/login.log


mail -s "用户登录记录"  andy@example.com < /tmp/login.log

