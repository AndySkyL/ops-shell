#!/bin/bash
jarfile='jarfile'
profile='init-profile'
version='0.0.1-SNAPSHOT'

while getopts a:p:v: opt   # 参数后有: 表示参数后一定要有参数值，无 : 表示可以不用指定参数值
do
  case "$opt" in
    a)
        jarfile=$OPTARG    # $OPTARG 表示参数的值  
        jarfile_account=$OPTIND  #  $OPTIND 表示参数值的长度
    #    echo "-a value $jarfile"
        
        ;;
    p) 
        profile=$OPTARG
    #    echo "-p value $OPTARG"
        ;;
    v)  
        version=$OPTARG
    #    echo "-v value $OPTARG"
        ;;
    \?)                # 当指定参数不指定参数值时，传一个 “？”，匹配此选项
        echo "Usgae: startbootapp -a {jarfile}  -p {profile} [-v {version default 0.0.1-SNAPSHOT}]"
        ;;
  esac
done



if [[ $profile == "init-profile" && $jarfile == "jarfile" ]]
  then
    echo "must use -a {jarfile}  -p {profile} option!"
    exit 1
#    chmod 775 ./xnk-service-main-0.0.1-SNAPSHOT.jar
else
    echo "授予当前用户权限"
    chmod 775 ./$jarfile-${version}.jar
#    echo "chmod 775 ./$jarfile-${version}.jar"
    echo "执行....."
    nohup java -jar $jarfile-${version}.jar --spring.profiles.active=$profile > ${jarfile}.log 2>&1 & 
#    echo "nohup java -jar $jarfile-${version}.jar > xnk-service-main.log 2>&1 & "
    echo "********************** xnk-service-main started *************************"
fi








