#!/bin/bash

Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

CentOS_InstallNTP()
{
    Echo_Blue "[+] Installing ntp..."
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
    start_time=$(date +%s)
}

Deb_InstallNTP()
{
    apt-get update -y
    Echo_Blue "[+] Installing ntp..."
    apt-get install -y ntpdate
    ntpdate -u pool.ntp.org
    date
    start_time=$(date +%s)
}

CentOS_RemoveAMP()
{
    Echo_Blue "[-] Yum remove packages..."
    # rpm -qa|grep httpd
    # rpm -e httpd httpd-tools --nodeps
    # rpm -qa|grep mysql
    # rpm -e mysql mysql-libs --nodeps
    # rpm -qa|grep php
    # rpm -e php-mysql php-cli php-gd php-common php --nodeps

    # Remove_Error_Libcurl

    # yum -y remove httpd*
    # yum -y remove mysql-server mysql mysql-libs
    # yum -y remove php*
    # yum clean all
}

Deb_RemoveAMP()
{
    Echo_Blue "[-] apt-get remove packages..."
    # apt-get update -y
    # for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd;
    # do apt-get purge -y $removepackages; done
    # killall apache2
    # dpkg -l |grep apache
    # dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
    # dpkg -l |grep mysql
    # dpkg -P mysql-server mysql-common libmysqlclient15off libmysqlclient15-dev
    # dpkg -l |grep php
    # dpkg -P php5 php5-common php5-cli php5-cgi php5-mysql php5-curl php5-gd
    # apt-get autoremove -y && apt-get clean
}

CentOS_Dependent()
{
    if [ -s /etc/yum.conf ]; then
        \cp /etc/yum.conf /etc/yum.conf.lnmj
        sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
    fi

    Echo_Blue "[+] Yum installing dependent packages..."
    for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libzip-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-devel libaio-devel rpcgen libtirpc-devel perl ruby rubygems;
    do yum -y install $packages; done

    if [ -s /etc/yum.conf.lnmj ]; then
        mv -f /etc/yum.conf.lnmj /etc/yum.conf
    fi
}

Deb_Dependent()
{
    Echo_Blue "[+] Apt-get installing dependent packages..."
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get --no-install-recommends install -y build-essential gcc g++ make
    for packages in debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev bison file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libpng12-dev libxml2-dev libcap-dev ca-certificates libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libc-client-dev xz-utils libexpat1-dev libaio-dev libtirpc-dev;
    do apt-get --no-install-recommends install -y $packages; done
}

Xen_Hwcap_Setting()
{
    if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
        sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
    fi
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Check_Hosts()
{
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo "Hosts: ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    pingresult=`ping -c1 www.baidu.com 2>&1`
    echo "${pingresult}"
    if echo "${pingresult}" | grep -q "unknown host"; then
        echo "DNS...fail"
        echo "Writing nameserver to /etc/resolv.conf ..."
        echo -e "nameserver 208.67.220.220\nnameserver 114.114.114.114" > /etc/resolv.conf
    else
        echo "DNS...ok"
    fi
}

RHEL_Modify_Source()
{
    Get_RHEL_Version
    \cp ${cur_dir}/conf/CentOS-Base-163.repo /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/\$releasever/${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    yum clean all
    yum makecache
}

CentOS_Modify_Source()
{
	if [ ! -s /etc/yum.repos.d/CentOS-Base-163.repo ]; then
	    Get_CentOS_Version
	    \cp ${cur_dir}/conf/CentOS-Base-163.repo /etc/yum.repos.d/CentOS-Base-163.repo
	    sed -i "s/\$releasever/${CentOS_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
	    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${CentOS_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
	    if [ -s /etc/yum.repos.d/CentOS-Base.repo ]; then
	        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.bak
	    fi
	    yum clean all
	    yum makecache
	fi
}

Ubuntu_Modify_Source()
{
    if [ "${country}" = "CN" ]; then
        OldReleasesURL='http://mirrors.ustc.edu.cn/ubuntu-old-releases/ubuntu/'
    else
        OldReleasesURL='http://old-releases.ubuntu.com/ubuntu/'
    fi
    CodeName=''
    if grep -Eqi "10.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.10'; then
        CodeName='maverick'
    elif grep -Eqi "11.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.04'; then
        CodeName='natty'
    elif  grep -Eqi "11.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.10'; then
        CodeName='oneiric'
    elif grep -Eqi "12.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.10'; then
        CodeName='quantal'
    elif grep -Eqi "13.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.04'; then
        CodeName='raring'
    elif grep -Eqi "13.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.10'; then
        CodeName='saucy'
    elif grep -Eqi "10.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.04'; then
        CodeName='lucid'
    elif grep -Eqi "14.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.10'; then
        CodeName='utopic'
    elif grep -Eqi "15.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.04'; then
        CodeName='vivid'
    elif grep -Eqi "12.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.04'; then
        CodeName='precise'
    elif grep -Eqi "15.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.10'; then
        CodeName='wily'
    elif grep -Eqi "16.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.10'; then
        CodeName='yakkety'
    elif grep -Eqi "14.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.04'; then
        Ubuntu_Deadline trusty
    elif grep -Eqi "17.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^17.04'; then
        CodeName='zesty'
    elif grep -Eqi "17.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^17.10'; then
        Ubuntu_Deadline artful
    elif grep -Eqi "16.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.04'; then
        Ubuntu_Deadline xenial
    fi
    if [ "${CodeName}" != "" ]; then
        \cp /etc/apt/sources.list /etc/apt/sources.list.$(date +"%Y%m%d")
        cat > /etc/apt/sources.list<<EOF
deb ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
EOF
    fi
}

Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
}

