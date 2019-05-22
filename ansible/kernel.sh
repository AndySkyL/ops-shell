#!/bin/sh
grub2-set-default "$(cat /boot/grub2/grub.cfg |grep 'CentOS Linux'|awk -F "'" '{print $2}'|grep elrepo)"
