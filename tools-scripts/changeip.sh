#/bin/sh
#this script for change host IP 
ipaddr=$1
netmask=$2
gateway=$3

ip_static(){
sta=`grep -i "^IPADDR*" /etc/sysconfig/network-scripts/ifcfg-eth0|wc -l`
if [ $sta==1 ]
 then 
   sed -ir  "s/^IPADDR=.*/IPADDR=$ipaddr/g" /etc/sysconfig/network-scripts/ifcfg-eth0
   sed -ir   "s/^NETMASK/#NETMASK/g" /etc/sysconfig/network-scripts/ifcfg-eth0 &>/dev/null
   echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
   sed -ir   "s/^GATEWAY/#GATEWAY/g" /etc/sysconfig/network-scripts/ifcfg-eth0 &>/dev/null
   echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
else 
   sed -ir "s/BOOTPROTO=.*/BOOTPROTO=static/g" /etc/sysconfig/network-scripts/ifcfg-eth0 
   echo "IPADDR=$ipaddr" >> /etc/sysconfig/network-scripts/ifcfg-eth0
   echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-eth0
   echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-eth0
fi
}

judge(){

[ ! -f /etc/sysconfig/network-scripts/ifcfg-eth0 ]&& echo "interface eth0 not exist!" && exit 1
[ -z $ipaddr ]||[ -z $netmask ]||[ -z $gateway ]&& {
echo "USAGE: changeip ipaddr netmask gateway"
exit 2
} 

reguip="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"

regumask="\b(255)\.(255)\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\b"
regugateway="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
ckip=`echo $ipaddr | egrep "$reguip" | wc -l`
ckmask=`echo $netmask|egrep "$regumask" |wc -l`
ckgateway=`echo $gateway|egrep  "$regugateway"|wc -l`
#echo "$ckip  $ckmask $ckgateway"
NUM=$[${ckip}*${ckmask}*${ckgateway}]

#echo $NUM
if [ $NUM -eq 0 ]
then
       echo "The IP info $ipaddr is not correct,please check it again! "
       exit 3
else
    ip_static   
fi 

}

judge
