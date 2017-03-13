#!/bin/bash
pass=dawanjia
pash=./user.log
[ -f /etc/init.d/functions ]&& . /etc/init.d/functions
judge(){
    if [ $? -ne 0 ]
        then
        action "$1 $2 add failure" /bin/false
        else
        action "$1 $2 add success" /bin/true
    fi
}
exec < $pash
while read line
do
    sta=1
    user=$(echo $line|awk '{print $1}')
    group=$(echo $line|awk '{print $2}')
    userexist=$(grep -w "$user" /etc/samba/smbpasswd|wc -l)
    [ $userexist -ne 0 ]&&continue
    useradd -g $group -s /sbin/nologin -M $user &&\
    echo $pass|passwd $user --stdin &>/dev/null &&\
    sta=0
    judge system $user
    [ $sta -eq 0 ]&&(echo $pass;echo $pass)|smbpasswd -s -a $user &>/dev/null
    judge smb $user
done
