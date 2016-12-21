#!/bin/sh
#数据库密码这里为654321

mac_add=`./ip_check.exp $1 |tail -2|head -1|awk '{print $2}'`
mac_sta=`echo "${mac_add:0:2}-${mac_add:2:5}-${mac_add:7:5}-${mac_add:12:2}"`
# echo $mac_sta

device_type="computer1 computer2 mobile1 mobile2 mobile3 mobile4 mobile5 kindle_pad vm_other" 
for n in $device_type; do
mysql -uroot -p654321 -e "use mac_list;select name,$n from maclist where $n='$mac_sta';"
done
#echo "name		pc_mac_addr		mobile_mac_addr"
#sed -n '1p' mac-list.txt
#grep --color=auto "$mac_sta" mac-list.txt
