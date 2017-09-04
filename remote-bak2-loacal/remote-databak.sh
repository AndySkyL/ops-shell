#!/bin/bash
#backup OST Production environment database data and nfs data
dbbackup_dir=/DATA/databases
nfsbackup_dir=/DATA/nfsdata
LogFile=/DATA/info.log


file_clean(){
echo "clean data:" >> $LogFile
find $dbbackup_dir  -type f -name "*.sql.gz" -mtime +60  >> $LogFile  2>&1
find $dbbackup_dir  -type f -name "*.sql.gz" -mtime +60 -delete 
find $nfsbackup_dir  -type f -name "*.nfs.tar.gz" -mtime +30  >> $LogFile  2>&1
find $nfsbackup_dir  -type f -name "*.nfs.tar.gz" -mtime +30 -delete 
}

backup_data() {
/usr/bin/expect /scripts/remote-bak/db-bak.exp  >> $LogFile 2>&1
/usr/bin/expect /scripts/remote-bak/nfs-bak.exp >> $LogFile 2>&1
}

main(){
file_clean
backup_data
}
main
