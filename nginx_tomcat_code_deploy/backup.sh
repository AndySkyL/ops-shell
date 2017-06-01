#!/bin/bash

# nginx 服务器对 mv, nginx, tar 等sudo命令设置免密码，在部署机上添加主机信任。
# 此脚本存放目录：/scripts/deploy/backup.sh ,权限 755
# 代码备份目录： /code_bak
# 日志文件：/tmp/code_deploy.log
# 返回码状态文件： /tmp/backup_status.log
# 代码临时存放目录： /tmp/ost_home
# webroot: /usr/local/nginx/conf/ost_home

ACTION=$1
back_dir=/code_bak/$(date +%F_%T)

start_mainten() {

sudo mv /usr/local/nginx/conf/conf.d/ost.conf /usr/local/nginx/conf/conf.d/ost.conf.pro
sudo mv /usr/local/nginx/conf/conf.d/ost.maintenance.conf.man /usr/local/nginx/conf/conf.d/ost.maintenance.conf
sudo /usr/local/nginx/sbin/nginx -s reload 
RETVAL=$? 
echo "$(date +%F' '%T) switch to maintenance mode." >> /tmp/code_deploy.log

}

start_product() {

sudo mv /usr/local/nginx/conf/conf.d/ost.maintenance.conf /usr/local/nginx/conf/conf.d/ost.maintenance.conf.man
sudo mv /usr/local/nginx/conf/conf.d/ost.conf.pro /usr/local/nginx/conf/conf.d/ost.conf
sudo /usr/local/nginx/sbin/nginx -s reload 
RETVAL=$?
echo "$(date +%F' '%T) switch to product mode." >> /tmp/code_deploy.log
} 

code_bak() {

[ ! -d "$back_dir" ]&& sudo mkdir -p "$back_dir"
cd  /usr/local/nginx/
sudo /usr/bin/tar  zcf $back_dir/ost_home.tar.gz ost_home
if [ $? -eq 0 ] 
then
    echo "1" >> /tmp/backup_status.log
    echo "$(date +%F' '%T) code backup finished" >>/tmp/code_deploy.log
    exit 0
else
    echo "$(date +%F' '%T) code backup failed! " >>/tmp/code_deploy.log
    exit 2
fi
}

main() {
> /tmp/backup_status.log
case $ACTION in

        backup)
        start_mainten
        if [ $RETVAL -ne 0 ] 
        then
            echo "$(date +%F' '%T) switch to maintance mode failed." >> /tmp/code_deploy.log 
            exit $RETVAL
        else
            code_bak
        fi
        ;;

        deploy)
        start_product
        if [ $RETVAL -ne 0 ] 
        then
            echo "0" >> /tmp/backup_status.log
            echo "$(date +%F' '%T) switch to product mode failed." >> /tmp/code_deploy.log 
            exit $RETVAL
        fi
        ;;

        *)
        echo "USAGE: $0 backup|deploy" 
       
esac
}

main

