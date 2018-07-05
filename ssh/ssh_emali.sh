#!/bin/bash
###################################################################
#Script Name    :                                                                                              
#Description    :                                                                                 
#Args           :                                                                                                   
#Author         :tby                                                               
#Email          :464891809@qq.com                                         
###################################################################
#//IP归属地查询接口
#$mid = 79482
#$oid = 16726
token='2c685341b699d185cc7a5a50dee4fe93'
#eval `curl -s "http://api.ip138.com/query/?ip=${SSH_CLIENT%% *}&datatype=jsonp&callback=find" -H "token:$token" | jq . | awk -F':|[ ]+|"' '$3~/^(country|area|region|city|isp)$/{print $3"="$7}'`
name=`curl -s "http://api.ip138.com/query/?ip=${SSH_CLIENT%% *}&datatype=jsonp&callback=find" -H "token:$token" | awk -F'"' '{print $12,$14,$16,$18,$20,$22}'`

#//邮件配置
EMAIL='/usr/local/sendEmail-v1.56/sendEmail'
FEMAIL="464891809@qq.com" #发件邮箱
MAILP="ilzipplwphffbghd" #发件邮箱密码
MAILSMTP="smtp.qq.com" #发件邮箱的SMTP
MAILT="464891809@qq.com" #收件邮箱
MAILmessage="登入者IP地址：${SSH_CLIENT%% *}\n\
用户名：$USER\n\
登陆时间：time=$(date +%Y-%m-%d_%H:%M:%S)\n\
IP归属地：$name\n\
服务器IP：hostname=$(hostname)"
#服务器IP：$(curl -s ip.cn| grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
#IP归属地：${country}_${area}_${region}_${city}_${isp}\n\

#//邮件发送
$EMAIL -q -f $FEMAIL -t $MAILT -u "警告!服务器有人登录SSH" -m "$MAILmessage" -s $MAILSMTP -o message-charset=utf-8 -xu $FEMAIL -xp $MAILP
