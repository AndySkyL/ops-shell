#!/bin/bash
###/etc/keepalived/scripts/redis_backup.sh
REDISCLI="redis-cli"
LOGFILE="/var/log/keepalived/redis-state.log"
pid=$$

echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master]" >> $LOGFILE
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] Being slave state..." >> $LOGFILE 2>&1
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] wait 10 sec for data sync from old master" >> $LOGFILE
sleep 10
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[master] data rsync from old mater ok..." >> $LOGFILE
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[slaver] Run 'SLAVEOF 192.168.56.12 6379'" >> $LOGFILE
$REDISCLI SLAVEOF 192.168.56.12 6379 >> $LOGFILE  2>&1
echo "`date +'%Y-%m-%d:%H:%M:%S'`|$pid|state:[slaver] slave connect to 192.168.56.12 ok..." >> $LOGFILE
