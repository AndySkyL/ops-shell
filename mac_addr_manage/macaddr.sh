#!/bin/bash


MAC_METHOD="$1"
USER_NAME="$2"
DEVICE_TYPE="$3"
MAC_ADDR="$4"
array=()
LOCK_FILE="/tmp/macaddr.lock"

usage(){
  echo "USAGE: $0 { add|del|list } USERNAME { pc|moblie|pad_kindle|other } MAC_ADDR"

}

add() {
CNUM=`mysql -uroot -p654321 -e "use mac_list; select * from maclist where name='$USER_NAME';"|wc -l `
	if [ $CNUM -eq 2  ];then
    MAC_CONT=`mysql -uroot -p654321 -e "use mac_list; select * from maclist where name='$USER_NAME';"|sed -n 2p`
		for n in {2..11}
          do
            array[$n]=`echo ${MAC_CONT}|awk '{print $'$n'}'`
#     	  [ -z ${array[$n]} ]&& array[$n]="NULL"
#	  echo "the array is ${array[${n}]}"
		done

case $DEVICE_TYPE in
   pc)
   j=0
   for i in {3..4} ;do
	j=$[j+1] 
#	  echo ${array[$i]}	
	   [ -z ${array[$i]} ]||[ ${array[$i]} == "NULL" ]&& `mysql -uroot -p654321 -e "use mac_list; update maclist set computer$j='$MAC_ADDR' where name='$USER_NAME';"`&&exit
   done
	   error;
   ;;   

   mobile)
    x=0
   for m in {5..9};do
	   x=$[x+1]
#		   echo $x
#		   echo ${array[$m]}
      [ -z ${array[${m}]} ]||[ ${array[${m}]} == "NULL" ] && `mysql -uroot -p654321 -e "use mac_list; update maclist set mobile$x='$MAC_ADDR' where name='$USER_NAME';"`&&exit 
	done
	  error;
   ;;

   kindle_pad)
	 [ -z ${array[10]} ]||[ ${array[10]} == "NULL" ] && `mysql -uroot -p654321 -e "use mac_list; update maclist set kindle_pad='$MAC_ADDR' where name='$USER_NAME';"`&&exit
	 error;

	 ;;

   other)
	   [ -z ${array[10]} ]||[ ${array[10]} -eq "NULL" ] &&`mysql -uroot -p654321 -e "use mac_list; update maclist set vm_other='$MAC_ADDR' where name='$USER_NAME';"`&&exit
	   error;

	;;

   *)
	   usage;

   esac

	   else

		   case  $DEVICE_TYPE in
			   pc)
		  `mysql -uroot -p654321 -e "use mac_list;insert maclist (name,computer1) values ('$USER_NAME','$MAC_ADDR');"`
			   ;;

	           mobile)

		  `mysql -uroot -p654321 -e "use mac_list; insert maclist (name,mobile1) values ('$USER_NAME','$MAC_ADDR');"`

			  ;;

			   kindle_pad)
		  `mysql -uroot -p654321 -e "use mac_list; insert maclist (name,kindle_pad) values ('$USER_NAME','$MAC_ADDR');"`
		      ;;
               other)

		  `mysql -uroot -p654321 -e "use mac_list; insert maclist (name,vm_other) values ('$USER_NAME','$MAC_ADDR');"`
              ;;

			   *)
				   usage;

          esac
fi			  

}


del() {

CNUM=`mysql -uroot -p654321 -e "use mac_list; select * from maclist where name='$USER_NAME';"|wc -l `
if [ $CNUM -eq 0 ];then
  echo "the user not exist!" 
  exit 2;

else 
	case $DEVICE_TYPE in
		all)
		`mysql -uroot -p654321 -e "use mac_list; delete from maclist where name='$USER_NAME';"`
		;;

		computer*)
		`mysql -uroot -p654321 -e "use mac_list; update maclist set $DEVICE_TYPE=NULL where name='$USER_NAME';"`
	    ;;

	    mobile*)
		`mysql -uroot -p654321 -e "use mac_list; update maclist set $DEVICE_TYPE=NULL where name='$USER_NAME';"`
	    ;;


	    kindle_pad)
		`mysql -uroot -p654321 -e "use mac_list; update maclist set $DEVICE_TYPE=NULL where name='$USER_NAME';"`
	    ;;


	    vm_other)
		`mysql -uroot -p654321 -e "use mac_list; update maclist set $DEVICE_TYPE=NULL where name='$USER_NAME';"`
	    ;;

		*)
			echo "USAGE: $0 del USER_NAME { all| [ computer1|computer2|mobile1|mobile2|...|kindle_pad|vm_other ]} MAC_ADDR"
	 esac
fi	 
}


error(){
	   echo "cann't add the mac address to db! "
}



main(){
	if [ -f $LOCK_FILE ];then
		echo "this script is running!" && exit 1;
	fi
#    MAC_METHOD="$1"
#    USER_NAME="$2"
#	DEVICE_TYPE="$3"
#	MAC_ADDR="$4"
    
	case $MAC_METHOD in 
	  add)
		  add;
	      ;;
      del)
		  del;
	      ;;

        list)
		[ -z $USER_NAME ]&&usage &&exit	
    	mysql -uroot -p654321 -e "use mac_list; select * from maclist where name='$USER_NAME';"
		;;

      *)
		  usage;
	      
	esac

}
main






