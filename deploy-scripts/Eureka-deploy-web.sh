#!/bin/bash
# Eureka deploy scripts

ACTION=$1
back_dir=/code_bak
array=($*)

env_init() {
[ -d /tmp/wtp ] && rm -fr /tmp/wtp && mkdir /tmp/wtp
[ ! -d /tmp/wtp ] && mkdir /tmp/wtp
[ ! -d $back_dir ] && mkdir -p "$back_dir"
backup_status=`ls -l $back_dir|grep wtp* |wc -l`
if [[ $backup_status == 0 ]]
  then
    cd /usr/local/
    /usr/bin/tar  zcf /code_bak/wtp_last_$(date +%F_%H-%M-%S).tar.gz ./wtp 

fi  
}
code_bak() {

[ ! -d "$back_dir" ]&& mkdir -p "$back_dir"
    cd /usr/local/
    /usr/bin/tar  zcf /code_bak/wtp_$(date +%F_%H-%M-%S).tar.gz ./wtp

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
/usr/bin/cp  -fr  /tmp/wtp/ /usr/local/wtp/ && rm -fr /tmp/wtp 
if [ $? -eq 0 ];then
  [ ${#array[*]} -gt 1 ] && deploy_args
else 
  echo "$(date '+%F %T') args error input!" >> /tmp/wtp-server.log
  exit 1  
fi
}

deploy_args(){
cd /usr/local/wtp
for ((i=1; i < ${#array[*]}; i++));do
    
    echo "$(date '+%F %T') restart app ${array[$i]}"
    if [[ ${array[$i]} == 'wtp-service-security' ]];then
        /usr/sbin/stopbootapp  -a wtp-service-security && nohup java -jar `ls |grep wtp-service-security*.jar` --spring.profiles.active=prod --auth-server=http://1.1.1.1/security >/dev/null 2>&1&
    elif [[ ${array[$i]} == 'wtp-eureka-server' ]];then
        /usr/sbin/stopbootapp  -a wtp-eureka-server &&  /usr/sbin/startbootapp -a wtp-eureka-server -p prod2 >> /tmp/wtp-server.log
    else 
        /usr/sbin/stopbootapp  -a ${array[$i]} && /usr/sbin/startbootapp -p prod -a ${array[$i]} >> /tmp/wtp-server.log

    fi
    sleep 1
done

}

main() {
> /tmp/backup_status.log
case $ACTION in
        backup)
            env_init
            code_bak
        ;;
        deploy)
            code_deploy
        ;;
        clean)
            code_clean
        ;;
        startapp)
            deploy_args
        ;;
        *)
        echo "USAGE: $0 init|backup|deploy|clean" 
esac
}
main
