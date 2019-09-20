#!/bin/bash

# this is wtp deploy scripts

## global parameters
username='hjgp'
projectname='hjgp'
nginx1=192.168.0.11
nginx2=192.168.0.12




## user-defined paramaters
COM_TYPE=$1
COM_NUM=$#
static_hosts=($nginx1 $nginx2)

# app node list
hjgp_eureka_server=(192.168.0.15 192.168.0.16)
hjgp_zuul=(192.168.0.15 192.168.0.16)
hjgp_files=(192.168.0.15 192.168.0.16)
hjgp_origin_main=(192.168.0.15 192.168.0.16)
hjgp_security=(192.168.0.15 192.168.0.16)
hjgp_system=(192.168.0.15 192.168.0.16)
hjgp_oritrapla_business=(192.168.0.15 192.168.0.16)
hjgp_oritrapla_jpush_server=(192.168.0.15 192.168.0.16)
hjgp_tp_product=(192.168.0.17 192.168.0.18)
hjgp_tp_system=(192.168.0.17 192.168.0.18)
hjgp_tp_trade=(192.168.0.17 192.168.0.18)
hjgp_tp_statistics=(192.168.0.17 192.168.0.18)
hjgp_tp_lta=(192.168.0.17 192.168.0.18)
hjgp_glhy=(192.168.0.17 192.168.0.18)
hjgp_data_dashboard=(192.168.0.17 192.168.0.18)
hjgp_openserver=(192.168.0.17 192.168.0.18)
hjgp_third_party_glhy=(192.168.0.17 192.168.0.18)




deploy_init(){
mv /tmp/${projectname}.tar.gz /home/deploy/${projectname}/
cd /home/deploy/${projectname}/
tar xf ${projectname}.tar.gz
cd V*  
[ -d jars ] && ls jars/ > ../jar.list  
ls|grep -v jars > ../static.list


echo " 代码初始化完成，准备部署..."
sleep 1

}

input_judege(){
if [[ $COM_NUM == 0 ]];then
  echo "deploy with no parameters"
 static_file_detribuation
 app_deploy
elif [[ $COM_TYPE == 'static' ]];then
  if [[ $COM_NUM == 1 ]];then
   static_file_detribuation
  elif [ $COM_NUM -gt 1 ];then
      help_doc
  fi
elif [[ $COM_TYPE == 'app' ]];then
    app_deploy
else
    help_doc
  fi
}

help_doc(){
echo "USAGE: $0 {static}  only deploy static file.
             $0 {app}     only deploy backend file.
             $0  No parameters deploy all.
"
}



static_file_detribuation(){

static_dir_nums=`ls |grep -v jars|wc -l` 

if [[ $static_dir_nums -gt 0 ]];then
	echo "this version will deploy $static_dir_nums static_dirs"

   for host in ${static_hosts[*]};do
     ssh  $username@$host "[ -d /tmp/$projectname ] && rm -fr /tmp/$projectname"
     ssh  $username@$host "[ ! -d /tmp/$projectname ] && mkdir /tmp/$projectname"
     for static_dir in `ls |grep -v jars`;do 
       echo "*********************distributing  $static_dir to host $host***************************"
       scp -r -p $static_dir $username@$host:/tmp/$projectname/
       ssh  $username@$host "rm -fr /usr/local/$projectname/$static_dir && mv /tmp/$projectname/$static_dir  /usr/local/$projectname/ "
        done
   done

else 
	echo "this deploy version NO STATIC FILES!"
fi
}


app_deploy(){
if [[ -d jars/ ]];then
for jar in `ls jars`;do
   app_name_hosts=`echo $jar |sed 's/-latest.jar//'|sed 's/-/_/g'`
 
   app_name=`echo $jar |sed 's/-latest.jar//'`

   for host in `eval echo '${'$app_name_hosts'[*]}'`; do
        echo $host
        ssh  $username@$host "/usr/sbin/stopbootapp -a $app_name -v latest && sleep 1"
        echo "********************distributing  $app_name to host $host****************************"
        scp -r -p  jars/$jar  $username@$host:/usr/local/${projectname}/

        if [[ $app_name == 'hjgp-eureka-server' && $host == '192.168.0.15' ]];then
          ssh $username@$host "cd /usr/local/${projectname}/ && /usr/bin/startbootapp -a $app_name -v latest -p prod1" 
        elif [[ $app_name == 'hjgp-eureka-server' && $host == '192.168.0.16' ]];then
          ssh $username@$host "cd /usr/local/${projectname}/ && /usr/bin/startbootapp -a $app_name -v latest -p prod2" 
        elif [[ $app_name == 'hjgp-zuul' ]];then
         ssh $username@$host "cd /usr/local/${projectname}/ && /usr/bin/startbootapp -a $app_name -v latest -p prod"

        else
            ssh $username@$host "cd /usr/local/${projectname} && /usr/sbin/startbootapp -a $app_name -v latest -p prod"
        fi

   done
done

else
   echo "this deploy version NO JAR FILES!"
fi

}



deploy_fin(){
cd /home/deploy/${projectname}/
mv  ${projectname}.tar.gz ${projectname}-$(date +%F_%H-%M-%S).tar.gz
rm -fr V*

}

main(){
deploy_init
input_judege
deploy_fin
}
main

