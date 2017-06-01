#!/bin/bash




### usage:
### deploy.sh ${deployVersion} ${jsVersion}


## need two parameter
deployVersion=$1
jsVersion=$2

## nginx host list
host1=host1_ip
host2=host2_ip

deploy_init() {
cd /home/deploy/ost

##deploy tomcat wars
mvn -f pom_deploy.xml -DdeployVersion=${deployVersion} antrun:run

## unzip web files
unzip -d ./${deployVersion}/ost.web ./${deployVersion}/ost.web.war
ln -s ./${deployVersion}/ost.web/ webroot

## replace css & js file path
sh /scripts/deploy/jscssreplace.sh  /home/deploy/ost/webroot ${jsVersion}
echo "exe jscssreplace.sh "
sleep 5
}

remote_bak() {

ssh -t  www@$host1 sudo /bin/sh /scripts/deploy/backup.sh backup
ssh -t  www@$host2 sudo /bin/sh /scripts/deploy/backup.sh backup

for n in  {1..11}
do
   sleep 1
   code_nginx1=$(ssh www@$host1 cat /tmp/backup_status.log)
   code_nginx2=$(ssh www@$host2 cat /tmp/backup_status.log)
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
for NginxServer in $host1  $host2
do
echo "copying file to $NginxServer"
cd /home/deploy/ost

#scp -r webroot/aa  www@$NginxServer:/tmp/ost_home/
#scp -r webroot/bb/cc  www@$NginxServer:/tmp/ost_home/
#scp -r webroot/ac  www@$NginxServer:/tmp/ost_home/

[ -d /tmp/ost_home ]&& ssh  www@$NginxServer rm -fr /tmp/ost_home

scp -r webroot/modules www@$NginxServer:/tmp/ost_home/ &>/dev/null
scp -r webroot/css www@$NginxServer:/tmp/ost_home/     &>/dev/null
scp -r webroot/images www@$NginxServer:/tmp/ost_home/  &>/dev/null
scp -r webroot/js www@$NginxServer:/tmp/ost_home/      &>/dev/null
scp -r webroot/data www@$NginxServer:/tmp/ost_home/    &>/dev/null
scp -r webroot/fonts www@$NginxServer:/tmp/ost_home/   &>/dev/null
scp -r webroot/certs www@$NginxServer:/tmp/ost_home/   &>/dev/null
scp -r webroot/pdf2 www@$NginxServer:/tmp/ost_home/    &>/dev/null
scp -r webroot/modules/foreignDoor/*.html www@$NginxServer:/tmp/ost_home/   &>/dev/null

ssh -t www@$NginxServer sudo /usr/bin/scp -r /tmp/ost_home/ /usr/local/nginx/
ssh -t www@$NginxServer sudo /bin/sh /scripts/deploy/backup.sh deploy
sleep 3
deploy_code=`ssh www@$NginxServer cat /tmp/backup_status.log`
if [[ $deploy_code == "0" ]]
then
    echo "$NginxServer reload failed! "
    exit 3
else
    echo "host $NginxServer  nginx reload successful! "
    
fi    

done

}

main () {
deploy_init
remote_bak
deploy_files

}
main

