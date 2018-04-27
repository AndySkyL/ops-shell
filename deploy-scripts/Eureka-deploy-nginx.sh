#!/bin/bash


ACTION=$1
back_dir=/code_bak

env_init() {
[ -d /tmp/wtp-old ] && rm -fr /tmp/wtp-old 
[ -d /tmp/wtp ]&& mv /tmp/wtp /tmp/wtp-old && mkdir /tmp/wtp
[ ! -d /tmp/wtp ]&& mkdir /tmp/wtp
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

deploy_shouguang(){
[ -d /tmp/wtp/shouguang ] && \
rm -fr /usr/local/wtp/shouguang  && \
mv /tmp/wtp/shouguang  /usr/local/wtp/
}

deploy_webroot(){
[ -d /tmp/wtp/webroot ] && \
rm -fr /usr/local/wtp/webroot  && \
mv /tmp/wtp/webroot  /usr/local/wtp/
}

deploy_adminroot(){
[ -d /tmp/wtp/adminroot ] && \
rm -fr /usr/local/wtp/adminroot  && \
mv /tmp/wtp/adminroot  /usr/local/wtp/
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
        shouguang)
            deploy_shouguang
        ;;
        adminroot)
            deploy_adminroot
        ;;
        webroot)
            deploy_webroot
        ;;
        *)
        echo "USAGE: $0 backup|deploy|clean|shouguang|adminroot|webroot" 
esac
}
main


