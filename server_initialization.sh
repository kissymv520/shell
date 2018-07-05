#!/bin/bash
#服务器初始化脚本
#version 1.0 
check () {
        if [ $? -eq 0 ]
        then
                echo "$1   [OK]"
        else
                echo "$1    [失败]"
        fi
        }

help () {
        if [ $# -ne 1 ];then
                cat <<eof
                        $0:      参数
                        default  仅做系统初始化
                        java     添加java环境
eof
                exit 1
        fi
        }

#判断初始化环境类型
case $1 in
        def)
                        pro_type=1;;
        java)
                        pro_type=2;;
        *)
                        help;;
esac


if [ ${pro_type} -eq 1 ];then

#修改主机hostname

host_ip=`ip a|awk '/inet .*eth0/{split($2,IP,"/");print IP[1]}'`
sed -i "/HOSTNAME=/c\HOSTNAME=${host_ip}" /etc/sysconfig/network && hostname $host_ip

yum -y install expect ntp wget make gcc gcc-c++ mtr telnet curl iotop traceroute bind-utils sysstat tar  iftop awk sed rpm iptraf openssh-clients unzip lsof  strace tcpdump  man

#用户文件描述符，进程数

ulimit_num=`cat /etc/security/limits.conf|grep -v "[#|^$]"|grep -c "[nproc|nofile]"`
if [ $ulimit_num -ne 4 ];then
echo -e "*      soft    nproc   65535\n\
*      hard    nproc  65535\n\
*      soft    nofile         65536\n\
*      hard  nofile         65536" >> /etc/security/limits.conf
sed -i "s/1024/65535/g" /etc/security/limits.d/90-nproc.conf
fi
check 用户文件描述符初始化
#关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disable/' /etc/selinux/config
check selinux关闭
#默认启动级别


fi

if [ ${pro_type} -eq 2 ];then

#新建启动用户tomcat 
groupadd -g 510 tomcat;useradd -g 510 -u 510 tomcat
check 新建启动用户tomcat 

#新建log日志查看用户
groupadd -g 503 log  && useradd -u 503 -g 503 log &&  echo 'log:log@12dw3'|chpasswd 

#约定cache目录
cache_dir=`awk -F: '$1~/tomcat/{print $6}' /etc/passwd`
mkdir -p $cache_dir/appdata/{profile,tmp} && chown -R tomcat.tomcat $cache_dir/appdata ||echo "cache缓存目录建立失败" >&2

#常用目录初始化
mkdir -p /home/tomcat/BACKUP /var/log/webapps ||echo "常用目录初始化失败" >&2

#jdk 环境

cat >>/etc/profile <<eof

export JAVA_HOME=/usr/local/jdk1.8.0_91
export JRE_HOME=\${JAVA_HOME}/jre
export CLASSPATH=.:\${JAVA_HOME}/lib:/lib
export PATH=\${JAVA_HOME}/bin:\${PATH}/
eof


fi
