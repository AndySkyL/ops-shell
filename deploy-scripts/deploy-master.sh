#!/bin/bash

# this is wtp deploy scripts

## global parameters
username='app'
nginx1=192.168.1.1
nginx2=192.168.1.2
web1=192.168.1.3
web2=192.168.1.4
web3=192.168.1.5
web4=192.168.1.6

web1_jars=(eureka-server zuul files  security )
web2_jars=(eureka-server zuul files  security)
web3_jars=(product system trade statistics)
web4_jars=(product system trade statistics)



## user-defined paramaters
COM_TYPE=$1
COM_NUM=$#
STATIC_DIR_NUM=0
JAR_NUM=0
array=($*)
static_hosts=($nginx1 $nginx2)
web_hosts=($web1 $web2 $web3 $web4)

deploy_init(){
mv /tmp/app.tar.gz /home/deploy/app/
cd /home/deploy/app/
tar xf app.tar.gz
cd V*  
[ -d jars ] && ls jars/ > ../jar.list  
ls|grep -v jars > ../static.list


echo "代码包初始化完成..."
sleep 1

}

input_judege(){
if [[ $COM_NUM == 0 ]];then
  echo "deploy with no parameters"
  remote_backup
  file_detribuation
  remote_deploy
elif [[ $COM_TYPE == 'static' ]];then
  if [[ $COM_NUM == 1 ]];then
    remote_backup static
    file_detribuation static
    remote_deploy static
  elif [ $COM_NUM -gt 1 ];then
    file_judge 
    remote_backup static
    file_detribuation static 
    for host in ${static_hosts[*]};do
      for ((i=1; i < ${#array[*]}; i++));do
        ssh -t $username@$host /bin/sh /scripts/deploy.sh ${array[i]}
      done
    done
  else
      help_doc
  fi
elif [[ $COM_TYPE == 'web' ]];then
    remote_backup web
    file_detribuation web
    remote_deploy web
else
    help_doc
  fi
}

help_doc(){
echo "USAGE: $0 {static}  [adminroot|shouguang|webroot]  only deploy static file.
             $0 {web}  only deploy backend file.
             $0  No parameters deploy all.
"
}

file_judge(){
cd /home/deploy/app/V*

  for ((i=1; i < ${#array[*]}; i++));do
    
      test -d ${array[i]}
      if [[ $? == 0 ]];then
        echo "${array[i]} checked ..."
      else
        echo "${array[i]} is not exits! please check parameters"
        exit 3
      fi
  done
}


remote_backup(){
if [[ $1 == 'static' ]];then
   for host in ${static_hosts[*]};do
     echo "backup data to host $host ..."
     ssh -t $username@$host /bin/sh /scripts/deploy.sh backup
     backup_status $host
   done 
elif [[ $1 == 'web' ]];then
   for host in ${web_hosts[*]};do
     echo "backup data to host $host ..."
     ssh -t $username@$host /bin/sh /scripts/deploy.sh backup
     backup_status $host
   done 
else  
   for host in ${static_hosts[*]} ${web_hosts[*]};do
     echo "backup data to host $host ..."
     ssh -t $username@$host /bin/sh /scripts/deploy.sh backup
     backup_status $host
   done
fi
}

backup_status(){
host=$1
echo "waiting host $host backup data..."
for m in {1..110};do
  status_code=$(ssh $username@$host cat /tmp/backup_status.log)
 #  echo $status_code
  if [[ $status_code == "1" ]];then
     echo "$host backup data successful!"
     break 
  elif [[ $status_code == "2" ]];then
     echo "$host backup data failed!"
     exit 2
  else
     sleep 3
  fi
  
  if [ $m -gt 100 ];then
    echo "backup timeout, please check the target server."
    exit 3
  fi
done
}


file_detribuation(){
if [[ $1 == 'static' ]];then
   for host in ${static_hosts[*]};do
     for static_dir in `ls |grep -v jars`;do 
       scp -r -p $static_dir $username@$host:/tmp/app
       echo "destributing static file $static_dir to host $host"
     done
   done
elif [[ $1 == 'web' ]];then
   for host in ${web_hosts[*]};do
     if [[ $host == $web1 ]];then
        for jars in ${web1_jars[*]};do
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
          echo "distributing jars $jars to host $host ..."
        done
     fi
     if [[ $host == $web2 ]];then
        for jars in ${web2_jars[*]};do
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
          echo "distributing jars $jars to host $host ..."
        done
     fi
     if [[ $host == $web3 ]];then
        for jars in ${web3_jars[*]};do
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
          echo "distributing jars $jars to host $host ..."
        done
     fi
     if [[ $host == $web4 ]];then
        for jars in ${web4_jars[*]};do
          echo "**************distributing jars $jars to host $host ...************************"
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
        done
     fi

   done
else   
  for host in ${static_hosts[*]};do
     echo "*******************distributing static data to host $host ...***********************"
     for static_dir in `ls |grep -v jars`;do
       scp -r -p $static_dir  $username@$host:/tmp/app/
     done
  done
   for host in ${web_hosts[*]};do
     if [[ $host == $web1 ]];then
        for jars in ${web1_jars[*]};do
          echo "distributing jars $jars to host $host ..."
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
        done
     fi
     if [[ $host == $web2 ]];then
        for jars in ${web2_jars[*]};do
          echo "distributing jars $jars to host $host ..."
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
        done
     fi
     if [[ $host == $web3 ]];then
        for jars in ${web3_jars[*]};do
          echo "distributing jars $jars to host $host ..."
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
        done
     fi
     if [[ $host == $web4 ]];then
        for jars in ${web4_jars[*]};do
          echo "distributing jars $jars to host $host ..."
          scp jars/`grep $jars ../jar.list` $username@$host:/usr/local/app/
        done
     fi
   
   done
fi
}


remote_deploy(){
if [[ $1 == 'static' ]];then
   for host in ${static_hosts[*]};do
     ssh -t $username@$host /bin/sh /scripts/deploy.sh  deploy
     echo "deploy to host $host ..."
   done
elif [[ $1 == 'web' ]];then
  web_deploy
else
   for host in ${static_hosts[*]};do
     echo "deploy to host $host ..."
     ssh -t $username@$host /bin/sh /scripts/deploy.sh deploy
     sleep 5
   done
#   for host in ${web_hosts[*]};do
#     echo "deploy to host $host ..."
     web_deploy
#   done
fi
}

web_deploy(){
  for host in ${web_hosts[*]};do
     echo "*************************** $host deploy **********************************"
     if [[ $host == $web1 ]];then
       ssh -t $username@$host /bin/sh /scripts/deploy.sh deploy  ${web1_jars[*]}
     fi
     if [[ $host == $web2 ]];then
       ssh -t $username@$host /bin/sh /scripts/deploy.sh deploy  ${web2_jars[*]}
     fi
     if [[ $host == $web3 ]];then
       ssh -t $username@$host /bin/sh /scripts/deploy.sh deploy  ${web3_jars[*]}
     fi
     if [[ $host == $web4 ]];then
       ssh -t $username@$host /bin/sh /scripts/deploy.sh deploy  ${web4_jars[*]}
     fi
     sleep 3
  done

}


deploy_fin(){
cd /home/deploy/app
mv  app.tar.gz app-$(date +%F_%H-%M-%S).tar.gz
rm -fr V*

}

main(){
deploy_init
input_judege
deploy_fin
}
main
