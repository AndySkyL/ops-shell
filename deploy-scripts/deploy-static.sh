#!/bin/bash


ACTION=$1
back_dir=/code_bak

env_init() {
[ -d /tmp/app-old ] && rm -fr /tmp/app-old 
[ -d /tmp/app ]&& mv /tmp/app /tmp/app-old && mkdir /tmp/app
[ ! -d /tmp/app ]&& mkdir /tmp/app
backup_status=`ls -l $back_dir|grep app|wc -l`
if [[ $backup_status == 0 ]]
  then
    cd /usr/local/
    /usr/bin/tar  zcf /code_bak/app_$(date +%F_%H-%M-%S).tar.gz ./app
fi  
}

back_up(){

[ ! -d "$back_dir" ]&& mkdir -p "$back_dir"
cd  /usr/local/
/usr/bin/tar  zcf $back_dir/app_$(date +%F_%H-%M-%S).tar.gz ./app
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
for n in `find $back_dir -type f -name "app*"|xargs ls -larc|awk '{print $9}'|sed -n "6,+20p"`; do rm -f $n;done

}

code_deploy(){
if [ -d /tmp/app ] 
   then
   curr_dir=`ls -l /usr/local/app/|wc -l`
   dep_dir=`ls -l /tmp/app/ |wc -l`
   if [[ $curr_dir == $dep_dir ]]
      then
       rm -fr /usr/local/app/* && mv /tmp/app/* /usr/local/app/
   else
      cd /usr/local/app/ && for dn in `ls /tmp/app/`; do rm -fr $dn;done && mv /tmp/app/* /usr/local/app/
      
   fi
fi
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

        *)
        echo "USAGE: $0 backup|deploy|clean" 
esac
}
main
