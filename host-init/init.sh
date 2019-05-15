#!/bin/sh
# close services

if [ $(getenforce) != 'Disabled' ];then
  setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

systemctl stop firewalld
systemctl disable firewalld
systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl stop postfix
systemctl disable postfix


# install pkgs
yum install wget -y


if [ ! -f /etc/yum.repo/epel.repo ];then
    wget https://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm && rpm -i epel-release-latest-7.noarch.rpm && yum makecache fast  && yum update -y
fi
yum install -y ntpdate
yum install -y net-tools
yum install -y lsof
yum install -y telnet
yum install -y lrzsz
yum install -y unzip


# config kernel args
cat <<EOF >  /etc/sysctl.d/pro.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_local_port_range = 10000 65000
fs.file-max = 2000000
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF
sysctl  -p

# config user command history
echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/profile


