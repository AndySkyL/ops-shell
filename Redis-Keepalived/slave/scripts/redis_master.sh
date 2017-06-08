#!/bin/bash
###/etc/keepalived/scripts/redis_master.sh
REDISCLI="/usr/bin/redis-cli"
LOGFILE="/var/log/keepalived/redis-state.log"
pid=$$

echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[backup]" >> $LOGFILE
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[backup] Run 'SLAVEOF 192.168.56.11 6379'" >> $LOGFILE
$REDISCLI SLAVEOF 192.168.56.11 6379 >> $LOGFILE  2>&1
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[backup] wait 10 sec for data sync from old master" >> $LOGFILE
sleep 10
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] data rsync from old mater ok..." >> $LOGFILE
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] Run slaveof no one,close master/slave" >> $LOGFILE
$REDISCLI SLAVEOF NO ONE >> $LOGFILE 2>&1
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] wait other slave connect...." >> $LOGFILE
