#### 基础信息
- 软件版本：
  CentOS7.2.1511 Keepalived v1.3.4      Redis3.2.4
- IP信息：
  - master: 192.168.56.11
  - slave: 192.168.56.12
  - vip: 192.168.56.100
- Redis配置：
  - 安装目录：/usr/local/redis
  - 数据目录：/data4/redisdata
  - 配置文件：/usr/local/redis/redis.conf 
- Keepalived配置：
  - 安装目录：/usr/local/keepalived
  - 配置文件：/etc/keepalived/keepalived.conf

#### 初始环境配置(master和slave上都进行操作)
1. 关闭防火墙，SeLinux,配置yum源。
2. 安装必要的软件：
 
   ```
   yum -y install gcc gcc+ openssl openssl-devel  tcl wget -y
   ```
   
3. 安装redis
   
   ```
   cd /home
   wget http://download.redis.io/releases/redis-3.2.4.tar.gz
   tar -xf ./redis-3.2.4.tar.gz
   mv redis-3.2.4 /usr/local/
   cd /usr/local/redis-3.2.4/deps/
   make hiredis lua jemalloc linenoise
   cd ..
   make test
   make 
   make install
   mkdir -p /usr/local/redis/bin
   mkdir -p /data4/redisdata
   cd /usr/local/redis-3.2.4/src
   cp redis-benchmark redis-check-aof redis-cli redis-server mkreleasehdr.sh /usr/local/redis/bin/
   cd /usr/local/redis-3.2.4
   cp redis.conf /usr/local/redis/
   cp /usr/local/bin/redis-cli  /usr/bin/

4. 安装keepalived
   
   ```
   cd /home
   wget http://www.keepalived.org/software/keepalived-1.3.4.tar.gz
   tar xf keepalived-1.3.4.tar.gz 
   cd keepalived-1.3.4
   ./configure 
   make
   make install
   ```
    
#### Redis主从配置
1. 在master上修改配置文件`/usr/local/redis/redis.conf `参数
   
   ```
   bind 0.0.0.0
   daemonize yes
   dir /data4/redisdata
   ```
   slave 上修改相同的信息，并添加slaveof的配置：
   
   ```
   bind 0.0.0.0
   daemonize yes
   dir /data4/redisdata
   slaveof 192.168.56.11 6379
   ```
   
2. master和slave上为redis配置单独用户并启动服务
   
   ```
   useradd redisuser
   passwd redisuser
   chown -R redisuser:redisuser /usr/local/redis/redis.conf
   chown -R redisuser:redisuser /usr/local/redis/bin/redis-server
   chown redisuser /data4/redisdata
   su - redisuser
   cd /usr/local/redis
   ./bin/redis-server ./redis.conf
   ```
3. Redis口令信息：
   > username: redisuaer   
   > password: redi13%&
   
#### Keepalived 主备配置
1. 在master节点修改`/etc/keepalived/keepalived.conf`为如下配置：

   ```
   global_defs {
       lvs_id LVS_redis
   }
   vrrp_script chk_redis { 
        script "/etc/keepalived/scripts/redis_check.sh"
        weight -20
        interval 2                                     
   } 

    vrrp_instance VI_1 { 
        state backup                            
        interface eth0                          
        virtual_router_id 51
        nopreempt
        priority 200      
        advert_int 5                      
        track_script { 
            chk_redis                     
        } 
        virtual_ipaddress { 
             192.168.56.100
        }
        notify_master /etc/keepalived/scripts/redis_master.sh
        notify_backup /etc/keepalived/scripts/redis_backup.sh
        notify_fault  /etc/keepalived/scripts/redis_fault.sh
        notify_stop   /etc/keepalived/scripts/redis_stop.sh 
    }
    ```
    
2. Keepalived 的Backup节点修改`/etc/keepalived/keepalived.conf`配置文件内容为如下配置：
   
   ```
   global_defs {
      lvs_id LVS_redis
    }

    vrrp_script chk_redis { 
        script "/etc/keepalived/scripts/redis_check.sh"   
        weight  -20 
        interval 2                                       
    } 
    vrrp_instance VI_1 { 
        state backup                                
        interface eth0                              
        virtual_router_id 51 
        priority 190    
        advert_int  5                            
        track_script { 
             chk_redis                   
        } 
        virtual_ipaddress { 
             192.168.56.100                    
        } 
        notify_master /etc/keepalived/scripts/redis_master.sh
        notify_backup /etc/keepalived/scripts/redis_backup.sh
        notify_fault  /etc/keepalived/scripts/redis_fault.sh
        notify_stop   /etc/keepalived/scripts/redis_stop.sh 
    }

3. 添加主备keepalived状态脚本文件
   - 上传脚本压缩包到`/etc/keepalived/`目录下，解压到scripts目录，并添加脚本执行权限。
   - 创建日志记录目录：
     ```
     mkdir /var/log/keepalived/
     ```
4. 启动keepalived
  > 先启动主节点keepalved,再启动slave节点
   
   ```
   systemctl start keepalived
   ```
5. 查看keepalived和redis工作状态
   - 主节点上查看有vip,从节点上无vip
   
   ```
   ip a|grep gl
   ```
   - 主redis为master状态，从节点为slave状态
   ```
   redis-cli  info replication
   ```
   
6. 测试redis+keepalived主从是否正常
   - 分别依次关闭master上的redis和keepalived，查看主从状态和vip飘移情况。
   - 查看master和slave上的各项日志情况：
   
   ```
   tail -f /var/log/keepalived/redis-state.log 
   tail -f /var/log/messages
   ```
   
 #### 故障处理
 当redis-master出现问题停机或者应用终止后，需要对进行故障排查，正确的恢复启动顺序如下：
 1. 使用redisuser 启动masrer,并与当前的slave(此时已经切换为master)进行数据同步：
    
	```
	 su - redisuser 
     cd /usr/local/redis
     ./bin/redis-server ./redis.conf  #启动redis
     netstat -lntp
     sh /etc/keepalived/scripts/redis_backup.sh # 使用脚本同步redis
     redis-cli  info replication  #查看同步状态
	```
 2. 同步完成之后切换为root,启动keepalived，此时由于是不抢占模式，VIP仍然在slave上。
    
	```
	[root@ost-redis1 ~]# systemctl start keepalived
	[root@ost-redis1 ~]# redis-cli  INFO replication
	```
 3. 重启备用节点的keepalived,脚本自动完成主备切换
    
	```
	[root@ost-redis2 ~]# systemctl restart keepalived
	[root@ost-redis2 ~]# redis-cli  INFO replication
    ```
