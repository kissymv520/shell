#!/bin/bash
#version 1.0

Dir=`pwd`
#初始化端口数据
DB=$Dir/netdefault.db
#日志
LogFile=$Dir/netscan.log

TmpDir=/tmp
#端口列表临时文件
TmpFile=$TmpDir/netscan.tmp
#本地监听端口进程临时数据
TmpDB=$TmpDir/NetScan.tmp.DB

LockFile=0

BaseName=$0
#pid文件
PidFile=$TmpDir/netscan.pid

NOW () {
date +%Y%m%d-%H:%M:%S
}

Log () {
echo "`NOW` $1 $2" >> $LogFile
}

#脚本如果已经运行就就不执行
IsRuning () {
pid=`cat $PidFile`
pidstat=`ps aux|awk -v pid=${pid:-0} '{if($2 == pid)print 0}'`
if [ ${pidstat:-1} -ne 1 ];then
        log error  "netscan is running"
        exit 1
fi
}
#检测端口和历史数据对比
CheckPort () {
portstatus=(`awk  -v hisdb=$DB -v logfile=$LogFile 'BEGIN{while ((getline < hisdb ) > 0) HisDB[$1]=$2 }/WARING/{if( $2 == HisDB[$1] ){print $1":"0;print $1,$2" CheckPort OK" >> logfile;} else {print $1":"1;print $1,$2" historyport",HisDB[$1]," CheckPort ERROR" >> logfile;}}' $TmpDB`)
}
#生成初始数据文件
NetDefaultDB () {
if [ ! -f ${DB} ];then
        grep "WARING" $TmpDB > $DB
#sed -i 's/LockFile=0/LockFile=1/'  $BaseName
else
        CheckPort
fi
}

echo "$$" >$PidFile
netstat -ltnp >$TmpFile
>$TmpDB

while read line
do
        echo $line|awk  -v db=$TmpDB '/^tcp/{split($4,port,":");split($7,pid,"/"); if(port[length(port)-1] == "127.0.0.1" || pid[2] == "java")print port[length(port)],pid[1],"OK" >> db ;else print port[length(port)],pid[length(pid)],"WARING" >> db; }'
done <$TmpFile

NetDefaultDB

if [ -f ${DB} ];then

        for status in ${portstatus[@]}
        do
                port=${status%:*}
                stat=${status#*:}

                if [ ${stat:-99} -eq 1 ];then
                        ERROR=$ERROR:$port
                        LockFile=2
                fi
        done
fi

        if [ $LockFile -eq 2 ];then
		echo 1
                Log error "${ERROR}"
	else
		echo 0
		Log INFO  "OK"
        fi

> $PidFile

exit 0
