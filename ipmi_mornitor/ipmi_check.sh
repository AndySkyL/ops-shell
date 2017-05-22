#!/bin/bash

# check EasyStack cluster hardware status.
node1=ip_1
node2=ip_2
node3=ip_3
node4=ip_4
node5=ip_5
node6=ip_6

check_status() {

 for node in $node1 $node2 $node3 $node4 $node5 $node6 
 do
    status_count=$(ipmitool -I lanplus -H $node -U root -P calvin -v sdr list|egrep "^ Status"|grep "ok"|wc -l)
    if [ $status_count -eq 17 ];then
       
       echo "normally!"
    else

      alert_mail $node
      echo "error"
    fi
 done
}

alert_mail() {

 echo "物理机故障"|mail -s "$1 error status,please check!"   andytang@example.com
}

main(){

check_status

}
main

