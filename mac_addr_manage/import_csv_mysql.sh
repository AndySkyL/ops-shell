#!/bin/sh
# csv的文件名为mac-list.txt,默认以","分隔
count=`cat mac-mysql.txt|wc -l`
for ((n=1;n<=$count;n++))
  do
    for i in {1..9}
	  do
	   arry[$i]=`sed -n "$n"p mac-mysql.txt|cut -d , -f $i`
	   echo ${arry[$i]}
	  done
   mysql -uroot -p654321 -e "use mac_list;insert into maclist(name,computer1,computer2,mobile1,mobile2,mobile3,mobile4,mobile5,kindle_pad,vm_other) values('${arry[1]}','${arry[2]}','${arry[3]}','${arry[4]}','${arry[5]}','${arry[6]}','${arry[7]}','${arry[8]}','${arry[9]}','${arry[10]}');"
   done
