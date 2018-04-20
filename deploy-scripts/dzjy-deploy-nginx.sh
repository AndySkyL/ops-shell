#!/bin/bash

# nginx 服务器对 mv, nginx, tar 等sudo命令设置免密码，在部署机上添加主机信任。
# 此脚本存放目录：/scripts/deploy/backup.sh ,权限root 755
# 代码备份目录： /code_bak
# 日志文件：/tmp/code_deploy.log
# 返回码状态文件： /tmp/backup_status.log
# 代码临时存放目录： /tmp/
# pro2: /usr/local/nginx/
ACTION=$1
back_dir=/code_bak

env_init() {
[ -d /tmp/wtp-old ] && rm -fr /tmp/wtp-old 
[ -d /tmp/wtp ]&& mv /tmp/wtp /tmp/wtp-old && mkdir /tmp/wtp
backup_status=`ls -l $back_dir|grep dzjy|wc -l`
if [[ $backup_status == 0 ]]
  then
    cd /usr/local/
    /usr/bin/tar  zcf /code_bak/wtp_last_$(date +%F_%H-%M-%S).tar.gz ./wtp 
fi  
}

back_up(){

[ ! -d "$back_dir" ]&& mkdir -p "$back_dir"
cd  /usr/local/
/usr/bin/tar  zcf $back_dir/wtp_$(date +%F_%H-%M-%S).tar.gz ./wtp
if [ $? -eq 0 ] 
then
    echo "1" > /tmp/backup_status.log
    echo "$(date +%F' '%T) code backup finished" >>/tmp/code_deploy.log
    exit 0
else
    echo "$(date +%F' '%T) code backup failed! " >>/tmp/code_deploy.log
    exit 2
fi
}

code_clean() {
for n in `find $back_dir -type f -name "wtp*"|xargs ls -larc|awk '{print $9}'|sed -n "6,+20p"`; do rm -f $n;done

}

code_deploy(){
[ -d /tmp/wtp ] && \
rm -fr /usr/local/wtp/* && \
mv /tmp/wtp/* /usr/local/wtp/

}

deploy_pro1(){
[ -d /tmp/wtp/pro1 ] && \
rm -fr /usr/local/wtp/pro1  && \
mv /tmp/wtp/pro1  /usr/local/wtp/
}

deploy_pro2(){
[ -d /tmp/wtp/pro2 ] && \
rm -fr /usr/local/wtp/pro2  && \
mv /tmp/wtp/pro2  /usr/local/wtp/
}

deploy_pro3(){
[ -d /tmp/wtp/pro3 ] && \
rm -fr /usr/local/wtp/pro3  && \
mv /tmp/wtp/pro3  /usr/local/wtp/
}

main() {
case $ACTION in
        backup)
            env_init
            back_up
        ;;
        deploy)
            code_deploy
        ;;
        clean)
            code_clean
        ;;
        pro1)
            deploy_pro1
        ;;
        pro3)
            deploy_pro3
        ;;
        pro2)
            deploy_pro2
        ;;
        *)
        echo "USAGE: $0 backup|deploy|clean|pro1|pro3|pro2" 
esac
}
main

