#!/bin/bash
###################################################################
#Script Name    :                                                                                              
#Description    :                                                                                 
#Args           :                                                                                                   
#Author         :tby                                                               
#Email          :464891809@qq.com                                         
###################################################################
# this scripts is test 
. /etc/init.d/functions

check_count=0
url_list=(
	https://www.baidu.com
	https://127.0.0.1
)

function wait ()
{
	echo -n '3秒后，执行检查url操作 .';
	for ((i=0;i<3;i++))
	do
		echo -n ".";sleep 1
	done	
	echo
}
function check_url (){
	wait 
	for ((i=0 ; i<`echo ${#url_list[*]}`; i++))
	do
	wget -o /dev/null -T 3 --tries=1 --spider ${url_list[$i]} >/dev/null 2>&1
	if [ $? -eq 0 ];then
		action "${url_list[$i]}" /bin/true
	else
		action  "${url_list[$i]}" /bin/false

	fi
	done
	((check_count++))	

}

main (){
	while true
	do
		check_url
		echo "--------check count: ${check_count}--------------------"
		sleep 10
	done

}
main
