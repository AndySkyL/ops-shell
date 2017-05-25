#!/bin/bash

db_password=123456
backup_dir=/data_back/dbdata
LogFile=/var/log/db_back_status.log
file_name=$(date -d'-1 day' +%F).sql.gz

backup_db(){
if [ ! -d $backup_dir ]
then 
   mkdir -p $backup_dir
fi

mysqldump -uroot -p$db_password  -F  --single-transaction  -B  dbname1 dbname2|gzip > $backup_dir/$file_name

RETVAL=$?
if [ $RETVAL -eq 0 ];then
   echo "DB backup finished!" > $LogFile
else 
   echo "Error backup DB data!" > $LogFile
   send_mail
   exit 1
fi
}

file_clean(){
echo "clean data:" >> $LogFile
find $backup_dir  -type f -name "*.sql.gz" -mtime +60  >> $LogFile  2>&1
find $backup_dir  -type f -name "*.sql.gz" -mtime +60 -delete 

}

send_mail(){

mail -s "数据备份记录"  Andy@example.com < $LogFile

}

main() {
backup_db
file_clean
send_mail

}

main
