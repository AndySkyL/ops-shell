#!/bin/sh
cp files/mariadb.repo /etc/yum.repos.d/
yum makecache fast

yum install -y MariaDB-server MariaDB-client galera 

# install 
mkdir -p /data/mariadata && chown mysql:mysql /data/mariadata && cp -R -p /var/lib/mysql /data/mariadata/ && chmod 755 -R /data/mariadata && sed -i "N;$(grep -n 'echo "user=root" >>$config' /usr/bin/mysql_secure_installation|cut -b -3)a\echo 'socket=/data/mariadata/mysql/mysql.sock' >> \$config"  /usr/bin/mysql_secure_installation
cp files/server.cnf /etc/my.cnf.d/
cp files/mysql-clients.cnf /etc/my.cnf.d/

systemctl start mariadb
systemctl enable mariadb

# config
mysql -e "DROP USER ''@'localhost';" && mysql -e "DROP USER ''@'$(hostname)'" && mysql -e "DROP DATABASE test" && mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" && mysql -e "UPDATE mysql.user SET Password = PASSWORD('123456') WHERE User = 'root';" && mysql -e "FLUSH PRIVILEGES"



