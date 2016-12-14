# Google-BBR 网络加速脚本

注意: 本脚本仅支持CentOS6

安装方法1:

    wget -O bbr.sh https://raw.githubusercontent.com/viagram/Google-BBR/master/bbr.sh && sh bbr.sh

安装方法2:

    curl -s https://raw.githubusercontent.com/viagram/Google-BBR/master/bbr.sh | sh

按提示操作后重启服务器
验证是否安装成功 

    执行 lsmod | grep bbr
   
如果结果显示bbr便安装成功
