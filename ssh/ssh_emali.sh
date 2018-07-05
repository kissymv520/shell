#!/bin/bash
###################################################################
#Script Name    :ssh_emali.sh                                                                                              
#Description    :                                                                                 
#Args           :ssh登录sendmail告警                                                                                                   
#Author         :kissymv                                                              
#Email          :kissymv@gmail.com                                         
###################################################################
#//IP归属地查询接口
#$mid = 
#$oid = 
token=' '
#eval `curl -s "http://api.ip138.com/query/?ip=${SSH_CLIENT%% *}&datatype=jsonp&callback=find" -H "token:$token" | jq . | awk -F':|[ ]+|"' '$3~/^(country|area|region|city|isp)$/{print $3"="$7}'`
name=`curl -s "http://api.ip138.com/query/?ip=${SSH_CLIENT%% *}&datatype=jsonp&callback=find" -H "token:$token" | awk -F'"' '{print $12,$14,$16,$18,$20,$22}'`

#//邮件配置
EMAIL='/usr/local/sendEmail-v1.56/sendEmail'
FEMAIL=" " #发件邮箱
MAILP=" " #发件邮箱密码
MAILSMTP="smtp.qq.com" #发件邮箱的SMTP
MAILT=" " #收件邮箱
MAILmessage="登入者IP地址：${SSH_CLIENT%% *}\n\
用户名：$USER\n\
登陆时间：time=$(date +%Y-%m-%d_%H:%M:%S)\n\
IP归属地：$name\n\
服务器IP：hostname=$(hostname)"
#服务器IP：$(curl -s ip.cn| grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
#IP归属地：${country}_${area}_${region}_${city}_${isp}\n\

#//邮件发送
$EMAIL -q -f $FEMAIL -t $MAILT -u "警告!服务器有人登录SSH" -m "$MAILmessage" -s $MAILSMTP -o message-charset=utf-8 -xu $FEMAIL -xp $MAILP
