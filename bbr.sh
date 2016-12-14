#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check If You Are Root
if [[ $EUID -ne 0 ]]; then
    clear
    echo -e "\033[31m错误: 你必须以ROOT权限运行此脚本! \033[0m"
    exit 1
fi

clear
echo "+------------------------------------------------------------------------+"
echo "|                     Google TCP BBR auto-compile                        |"
echo "+------------------------------------------------------------------------+"
echo "|                       This script For CentOS 6                         |"
echo "+------------------------------------------------------------------------+"
echo "|                 Welcome to  http://github.com/viagram                  |"
echo "+------------------------------------------------------------------------+"
echo

Get_Sys_Ver(){
    SysVersion='';
    if egrep -i "release 5." /etc/redhat-release >/dev/null 2>&1; then
        SysVersion='5'
    elif egrep -i "release 6." /etc/redhat-release >/dev/null 2>&1; then
        SysVersion='6'
    elif gerep -i "release 7." /etc/redhat-release >/dev/null 2>&1; then
        SysVersion='7'
    fi
}

Get_Sys_Ver
if [ $SysVersion -ne "6" ]; then
    echo -e "\033[41;37m错误: 本脚本仅支持CentOS 6\033[0m"
    exit
fi

Get_OS_Bit()
{
    if [[ $(getconf WORD_BIT) -eq '32' && $(getconf LONG_BIT) -eq '64' ]] ; then
        OS_Bit='64'
    else
        OS_Bit='32'
    fi
}

Install_BBR()
{
    Get_OS_Bit
    if uname -r | egrep -i "4.9." >/dev/null 2>&1; then
        if lsmod | egrep -i "bbr" >/dev/null 2>&1; then
            echo "提示: 您已经成功安装过BBR了."
            exit
        else
            if egrep -i "net.core.default_qdisc=fq" /etc/sysctl.conf >/dev/null 2>&1; then
                echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            fi
            if egrep -i "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf >/dev/null 2>&1; then
                echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            fi
            sysctl -p
        fi
    else
        if [ ! -f "/boot/grub/grub.conf" ];then
            echo -e "\033[41;37m错误: 不支持当前系统!\033[0m"
            exit
        fi
        
        echo -n "内核不一致，即将替换内核 [ y/n ]："
        read is_yesno
        if [ $is_yesno = "y" -o $is_yesno = "Y" ]; then
		    echo -n "正在替换内核："
            if [ $OS_Bit = "64" ]; then
                rpm -ivh http://elrepo.org/linux/kernel/el6/x86_64/RPMS/kernel-ml-4.9.0-1.el6.elrepo.x86_64.rpm --force
            fi
            if [ $OS_Bit = "32" ]; then
                rpm -ivh http://elrepo.org/linux/kernel/el6/i386/RPMS/kernel-ml-4.9.0-1.el6.elrepo.i686.rpm --force
            fi
            
            kernel_default=`grep '^title ' /boot/grub/grub.conf | awk -F'title ' '{print i++ " : " $2}' | grep "4.9." | grep -v debug | cut -d' ' -f1`
            sed -i "s/^default.*/default=${kernel_default}/" /boot/grub/grub.conf
            
            if [ ! `cat /etc/sysctl.conf | grep -i -E "net.core.default_qdisc=fq"` ]; then
                echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            fi
            if [ ! `cat /etc/sysctl.conf | grep -i -E "net.ipv4.tcp_congestion_control=bbr"` ]; then
                echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            fi
            sysctl -p >/dev/null 2>&1
        
            rm -f $0
            echo -n "重启后生效，是否重启？[y]："
            read is_reboot
            if [ $is_reboot = "y" -o $is_reboot = "Y" ]; then
                reboot
            else
                exit
            fi
        else
            echo "用户退出安装."
            exit
        fi
    fi
}
 
Install_BBR
