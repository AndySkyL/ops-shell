#!/bin/bash

#this script for xxx
### usage:
### deploy.sh ${deployVersion} 



## need one parameter
#deployVersion=$1

## global parameters
username='xxx'
nginx1=192.168.10.81
nginx2=192.168.10.82
web1=192.168.10.83
web2=192.168.10.84
admin=192.168.10.85
project_name='demo'


deploy_init() {
# check remote env
for nodes in $nginx1 $nginx2 $web1 $web2 $admin
do
ssh -t $username@$nodes /bin/sh /scripts/deploy/backup.sh init
done
echo "web server init finished"
sleep 2
mv /tmp/$(project_name).zip /home/deploy/$project_name/
cd /home/deploy/$(project_name)
unzip $(project_name).zip
echo "package is ready, copy to web node..."
 
##deploy tomcat wars
#mvn -f pom_deploy_pingxx.xml -DdeployVersion=${deployVersion} antrun:run 
scp -r -p  $web1/$(project_name).web.war $username@$web1:/tmp/
scp -r -p  $web2/$(project_name).web.war $username@$web2:/tmp/
scp -r -p  $admin/$(project_name).admin.war $username@$admin:/tmp/

## unzip web files
unzip -d  $admin/ $admin/$(project_name).admin.war
unzip -d  $web1/ $web1/$(project_name).web.war

# deploy to nginx-2
echo "######  deploy static file to nginx-2... ######"
scp -r -p $admin/static $username@$nginx2:/tmp/admin/
scp -r -p $admin/index.html $username@$nginx2:/tmp/admin/
scp -r -p $web1/static $username@$nginx2:/tmp/web/
scp -r -p $web1/index.html $username@$nginx2:/tmp/web/
scp -r -p $web1/app $username@$nginx2:/tmp/web/

# deploy to nginx-1
echo "######  deploy static file to nginx-1... ######"
scp -r -p $admin/static $username@$nginx1:/tmp/admin/
scp -r -p $admin/index.html $username@$nginx1:/tmp/admin/
scp -r -p $web1/static $username@$nginx1:/tmp/web/
scp -r -p $web1/index.html $username@$nginx1:/tmp/web/
scp -r -p $web1/app $username@$nginx1:/tmp/web/
}

remote_bak() {
for nodesbak in $nginx1 $nginx2 $web1 $web2 $admin
do
echo "backup file in $nodesbak..."
ssh -t $username@$nodesbak /bin/sh /scripts/deploy/backup.sh backup
done

for n in  {1..11}
do
   sleep 1
   code_nginx1=$(ssh $(username)@$nginx1 cat /tmp/backup_status.log)
   code_nginx2=$(ssh $(username)@$nginx2 cat /tmp/backup_status.log)
   if [[ $code_nginx1 == "1" && $code_nginx2 == "1" ]]
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
for node in $nginx1 $nginx2 $web1 $web2 $admin
do
sleep 3
echo "deploying  $node ..."
ssh -t $username@$node /bin/sh /scripts/deploy/backup.sh deploy
ssh -t $username@$node /bin/sh /scripts/deploy/backup.sh clean
done
}

local_clean() {
rm -fr $web1
rm -fr $web2
rm -fr $admin
mv $project_name.zip /tmp/

}
main () {
deploy_init
remote_bak
deploy_files
}
main

