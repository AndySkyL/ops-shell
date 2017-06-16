#!/bin/sh

ssh node-1 cat /tmp/raid_check.log > /tmp/raid_check.log
[ -f /scripts/raid_check/raid_check.log ]&& rm -f /scripts/raid_check/raid_check.log
mv /tmp/raid_check.log /scripts/raid_check/
cd /scripts/raid_check/
check_stu=`md5sum -c raid_check.md5|grep "确定"|wc -l`
echo $check_stu

if [ $check_stu -eq 0 ];then
  
mail -s "RAID DISK ERROR" tangxs@fengkonglm.com 962824378@qq.com  < /scripts/raid_check/raid_check.log

else
  rm -f /scripts/raid_check/raid_check.log
  exit 0
fi







