#!/bin/bash 

# this script for init hjgp deploy package
project_name='hjgp'
ARG_NUM=$#
[ -f /tmp/${project_name}.tar.gz ] && rm -f /tmp/${project_name}.tar.gz

if [[ $ARG_NUM -gt 2 ]];then

    while getopts "v:j:s:" opt
      do
        case "$opt" in
          v)   version=$OPTARG ;; 
          j)   jarfile+=("$OPTARG") ;;
          s)   static_dir+=("$OPTARG") ;;
          \?)  echo "Usgae: init -v {version} -j {jarfile1} -j {jarfile2} -s {staticefile1} -s {staticefile2}"  ;;
        esac
    done
    shift $((OPTIND -1))
    echo $version
    [ -d /tmp/${version} ] && rm -fr /tmp/${version}
    mkdir /tmp/${version}
    if [[ ! -z $jarfile ]]; then
        mkdir /tmp/${version}/jars
  
        for jar in "${jarfile[@]}"; do
           scp -r -p ${version}/jars/${jar}  /tmp/${version}/jars/
        done
    fi

    if [[ ! -z $static_dir ]]; then

        for statdir in "${static_dir[@]}"; do
           scp -r -p ${version}/$statdir /tmp/${version}/
        done
    fi
    cd /tmp  && tar zcvf /tmp/${project_name}.tar.gz $version  
  
else

  version=$1
  cd $version
  dir_count=`ls -l |wc -l`
  [ $dir_count -lt 5 ] && echo "文件少于5个，请注意查看配置！" 
  sleep 1
  cd /home/jenkins/springboot/${project_name}/
  tar zcvf /tmp/${project_name}.tar.gz $version  
fi

scp -r -p -P 2211 /tmp/${project_name}.tar.gz  user@1.1.1.1:/tmp/ 
