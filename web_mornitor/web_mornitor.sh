#/bin/bash

#this script use to mornitor login page: http://www.xxxxx.com/ and http://www.xxxxxx.org.cn/.
web_url1="http://www.xxxxx.com"
web_url2="http://www.xxxxx.org.cn/"


web_status(){
web_url="$1"
echo $web_url
status_code=`curl -I $web_url|grep "HTTP"|awk '{print $2}'`

 wget -q  --output-document=index.txt  $web_url

web_code=`grep "主办单位" index.txt|wc -l` 

if [[ $status_code == "302" && $web_code == "1" ]]; then
   echo "$(date +%F' '%T) $web_url access normally" >> /var/log/web_page_status_$(date +%F).log && rm -f index.txt
   echo "$status_code $web_code"
else
  echo "[ERROR]  $(date +%F' '%T)  $web_url cannot access! " >> /var/log/web_page_status_$(date +%F).log
  echo "$web_url cannot access! "|mail -s "web page down! "  example@domain.com
  rm -f index.txt
fi
}

main(){


web_status $web_url1
web_status $web_url2

}

main

