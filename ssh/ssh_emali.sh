#!/bin/bash
#########################################################################
# File Name: WarringLoging.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: Wed 22 Jul 2015 01:41:09 AM CST
#########################################################################

eval `curl -s "http://ip.taobao.com/service/getIpInfo.php?ip=${SSH_CLIENT%% *}" | jq . | awk -F':|[ ]+|"' '$3~/^(country|area|region|city|isp)$/{print $3"="$7}'`

EMAIL=`which sendEmail`
FEMAIL="admin#dwhd.org" #发件邮箱
MAILP="MzU0ODZjOWI0MWU3" #发件邮箱密码
MAILSMTP="smtp.dwhd.org" #发件邮箱的SMTP
MAILT="393411264#qq.com" #收件邮箱
MAILmessage="登入者IP地址：${SSH_CLIENT%% *}\n\
IP归属地：${country}_${area}_${region}_${city}_${isp}\n\
被登录服务器IP：$(curl -s ip.cn| grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"

$EMAIL -q -f $FEMAIL -t $MAILT -u "您服务器有人登录SSH" -m "$MAILmessage" -s $MAILSMTP -o message-charset=utf-8 -xu $FEMAIL -xp $MAILP
