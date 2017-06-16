#!/bin/bash

#正常状态的磁盘数量

normal_disk_num(){
  NUM=`/usr/bin/MegaCli  -cfgdsply -aALL | grep "Online" | wc -l`
  echo "Normal disk number: ${NUM}" >> /tmp/raid_check.log
}

#故障的磁盘数量
faild_disk_num(){
  NUM=`/usr/bin/MegaCli  -AdpAllInfo -aALL   | grep "Failed Disks" | awk '{print $4}'`
  echo "Failed disk number: ${NUM}" >> /tmp/raid_check.log

}

#Riad 状态是否正常
check_raid_status(){
  NUM=`/usr/bin/MegaCli   -LDInfo -Lall -aALL  | grep 'State' | awk -F':' '{print $2}'| sed -e "s/^[ ]*//"`
  if test $NUM == "Optimal";then
    echo "raid status: $NUM" >> /tmp/raid_check.log
  else
    echo "raid status: error" >> /tmp/raid_check.log
  fi
}

#获取Riad 级别
raid_level(){
R1=`sudo /usr/bin/MegaCli -cfgdsply -aALL  | grep "RAID Level" |awk -F: '{print $2}' | sed -e"s/^[ ]*//" | grep -c "Primary-1, Secondary-0, RAID Level Qualifier-0"`
R0=`sudo /usr/bin/MegaCli -cfgdsply -aALL  | grep "RAID Level" |awk -F: '{print $2}' | sed -e"s/^[ ]*//" | grep -c "Primary-0, Secondary-0, RAID Level Qualifier-0"`
R5=`sudo /usr/bin/MegaCli -cfgdsply -aALL  | grep "RAID Level" |awk -F: '{print $2}' | sed -e"s/^[ ]*//" | grep -c "Primary-5, Secondary-0, RAID Level Qualifier-3"`
R10=`sudo /usr/bin/MegaCli -cfgdsply -aALL | grep "RAID Level" |awk -F: '{print $2}' | sed -e"s/^[ ]*//" | grep -c "Primary-1, Secondary-3, RAID Level Qualifier-0"`
if [ $R1 -ge 2 ];then
  echo "raid level: 10" >> /tmp/raid_check.log
elif [ $R1 -eq 1 ];then
  echo "raid level: 1" >> /tmp/raid_check.log
fi
if [ $R0 -ne 0 ];then
  echo "raid level: 0" >> /tmp/raid_check.log
fi
if [ $R5 -ne 0 ];then
  echo "raid level: 5" >> /tmp/raid_check.log
fi
if [ $R10 -ne 0 ];then
  echo "raid level: 10" >> /tmp/raid_check.log
fi
}

raid_check_all() {
echo -e "\nnode2:\n" >> /tmp/raid_check.log
ssh node-2 cat /tmp/raid_check.log >> /tmp/raid_check.log
echo -e "\nnode3:\n" >> /tmp/raid_check.log
ssh node-3 cat /tmp/raid_check.log >> /tmp/raid_check.log
echo -e "\nnode4:\n" >> /tmp/raid_check.log
ssh node-4 cat /tmp/raid_check.log >> /tmp/raid_check.log
echo -e "\nnode5:\n" >> /tmp/raid_check.log
ssh node-5 cat /tmp/raid_check.log >> /tmp/raid_check.log
echo -e "\nnode6:\n" >> /tmp/raid_check.log
ssh node-6 cat /tmp/raid_check.log >> /tmp/raid_check.log

}

main(){
       
       > /scripts/CmdTool.log
       > /scripts/MegaSAS.log
       echo -e "node-1:\n" > /tmp/raid_check.log
       normal_disk_num;
       faild_disk_num;
       check_raid_status;
       raid_level;
       raid_check_all;
}

main 
