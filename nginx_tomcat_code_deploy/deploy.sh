#!/bin/bash

# 此脚本运行在部署机上，调用nginx上的backup.sh脚本
nginx1=nginx_host1_ip
nginx2=nginx_host2_ip


### usage:
### deploy.sh ${deployVersion} ${jsVersion}


## need two parameter
deployVersion=$1
jsVersion=$2

deploy_init() {
cd /home/deploy

##deploy tomcat wars
mvn -f pom_deploy.xml -DdeployVersion=${deployVersion} antrun:run

## unzip web files
tar -xzf ./${deployVersion}/ost.web.war
ln -s ./${deployVersion}/ost.web/ webroot

## replace css & js file path
sh /home/jenkins/jscssreplace.sh ./${deployVersion}/webroot ${jsversion}
}

remote_bak() {

ssh -t  www@$nginx1 sudo /bin/sh /scripts/deploy/backup.sh backup
ssh -t  www@$nginx2 sudo /bin/sh /scripts/deploy/backup.sh backup

for n in  {1..11}
do
   sleep 1
   code_nginx1=$(ssh www@$nginx1 cat /tmp/backup_status.log)
   code_nginx2=$(ssh www@$nginx2 cat /tmp/backup_status.log)
   if [ $code_nginx1 -eq 1 -a $code_nginx2 -eq 1 ]
   then
       echo "nginx backup successful!"
       break
   else
       echo "backup in progress..."
   fi 
   
   if [ $n -eq 10 ]
   then
       echo "nginx backup failed!"
       exit 1	   

   fi	   
done
}


## copy web files over ssh to nginx server
deploy_files() {
for NginxServer in $nginx1  $nginx2
do
echo "copying file to $NginxServer"
cd /home/deploy

#scp -r webroot/aa  www@$NginxServer:/tmp/ost_home/
#scp -r webroot/bb/cc  www@$NginxServer:/tmp/ost_home/
#scp -r webroot/ac  www@$NginxServer:/tmp/ost_home/


scp -r webroot/modules www@$NginxServer:/tmp/ost_home/
scp -r webroot/css www@$NginxServer:/tmp/ost_home/
scp -r webroot/images www@$NginxServer:/tmp/ost_home/
scp -r webroot/js www@$NginxServer:/tmp/ost_home/
scp -r webroot/data www@$NginxServer:/tmp/ost_home/
scp -r webroot/fonts www@$NginxServer:/tmp/ost_home/
scp -r webroot/certs www@$NginxServer:/tmp/ost_home/
scp -r webroot/pdf2 www@$NginxServer:/tmp/ost_home/
scp -r webroot/modules/foreignDoor/*.html www@$NginxServer:/tmp/ost_home/

ssh -t www@$NginxServer sudo scp -r /tmp/ost_home/ /usr/local/nginx/
ssh -t www@$NginxServer sudo /bin/sh /scripts/deploy/backup.sh deploy
sleep 3
deploy_code=`ssh www@$NginxServer cat /tmp/backup_status.log`
if [ $deploy_code -eq 0 ]
then
    echo "$NginxServer reload failed! "
    exit 3
else
    echo "nginx reload successful! "
    exit 0
fi    

done

}

main () {
deploy_init
remote_bak
deploy_files

}
main

