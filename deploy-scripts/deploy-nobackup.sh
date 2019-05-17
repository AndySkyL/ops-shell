#!/bin/bash



username='gxUser'
project_name=shdp
NginxNode1=10.16.0.5
NginxNode2=10.16.0.6
app1=10.16.0.9
app2=10.16.0.10
app3=10.16.0.11
app4=10.16.0.12

app1_jars=(eureka-server zuul files  security )
app2_jars=(eureka-server zuul files  security)
app3_jars=(product system trade statistics)
app4_jars=(product system trade statistics)


## user-defined paramaters
COM_TYPE=$1
COM_NUM=$#
STATIC_DIR_NUM=0
JAR_NUM=0
array=($*)
BASE_DIR=`pwd`
static_hosts=($NginxNode1  $NginxNode2)
app_hosts=($app1 $app2 $app3 $app4)


deploy_init(){

mv /tmp/${project_name}.tar.gz  ./
tar xf ${project_name}.tar.gz && cd V*
[ -d jars ] && ls jars/ > ../jar.list
ls|grep -v jars > ../static.list

}


input_judege(){
if [[ $COM_NUM == 0 ]];then
  echo "deploy with no parameters"
  file_detribuation
elif [[ $COM_TYPE == 'static' &&  $COM_NUM == 1 ]];then
  file_detribuation static
elif [[ $COM_TYPE == 'web' &&  $COM_NUM == 1 ]];then
  file_detribuation web
else
  help_doc
  fi
}

help_doc(){
echo "USAGE: $0 {static}   only deploy static file.
             $0 {web}  only deploy jar file.
             $0  No parameters deploy all.
"
}


file_detribuation(){
if [[ $1 == 'static' ]];then
   for host in ${static_hosts[*]};do
     for static_dir in `ls |grep -v jars`;do
       echo "delete old version $static_dir..."
       ssh -p 10050 -t $username@$host rm -fr /usr/local/${project_name}/$static_dir
       echo "destributing static file $static_dir to host $host"
       scp -r -p -P 10050  $static_dir $username@$host:/usr/local/${project_name}/
     done
   done
elif [[ $1 == 'web' ]];then
   for host in ${app_hosts[*]};do
     if [[ $host == $app1 ]];then
        for jars in ${app1_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          if [[ $jars == "${project_name}-eureka-server" ]];then
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod1
          else
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
          fi
        done
     fi
     if [[ $host == $app2 ]];then
        for jars in ${app2_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          if [[ $jars == "${project_name}-eureka-server" ]];then
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod2
          else
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
          fi
        done
     fi
     if [[ $host == $app3 ]];then
        for jars in ${app3_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
        done
     fi
     if [[ $host == $app4 ]];then
        for jars in ${app4_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
        done
     fi

   done
else
  for host in ${static_hosts[*]};do
     echo "*******************distributing static data to host $host ...***********************"
     for static_dir in `ls |grep -v jars`;do
       echo "delete old version $static_dir..."
       ssh -p 10050 -t $username@$host rm -fr /usr/local/${project_name}/$static_dir
       echo "destributing static file $static_dir to host $host"
       scp -r -p -P 10050  $static_dir $username@$host:/usr/local/${project_name}/
     done
  done
   for host in ${app_hosts[*]};do
     if [[ $host == $app1 ]];then
        for jars in ${app1_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          if [[ $jars == "${project_name}-eureka-server" ]];then
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod1
          else
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
          fi
        done
     fi
     if [[ $host == $app2 ]];then
        for jars in ${app2_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          if [[ $jars == "${project_name}-eureka-server" ]];then
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod2
          else
              ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
          fi
        done
     fi
     if [[ $host == $app3 ]];then
        for jars in ${app3_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
        done
     fi
     if [[ $host == $app4 ]];then
        for jars in ${app4_jars[*]};do
          echo "stopping $jars on node $host..."
          ssh -p 10050 -t $username@$host  stopbootapp -a $jars
          sleep 1
          echo "distributing app  $jars to node $host ..."
          scp -P 10050 jars/`grep $jars ../jar.list` $username@$host:/usr/local/${project_name}/
          echo "start app $jars"
          ssh -p 10050 -t $username@$host cd /usr/local/${project_name} && startbootapp -a $jars -p prod
        done
     fi

   done
fi
}

deploy_fin(){
cd $BASE_DIR
mv  ${project_name}.tar.gz  ${project_name}-$(date +%F_%H-%M-%S).tar.gz
rm -fr V*

}

main(){
deploy_init
input_judege
deploy_fin
}
main
