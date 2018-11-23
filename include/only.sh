#!/bin/bash

Nginx_Dependent()
{
    if [ "$PM" = "yum" ]; then
        rpm -e httpd httpd-tools --nodeps
        yum -y remove httpd*
        for packages in make gcc gcc-c++ gcc-g77 wget crontabs zlib zlib-devel openssl openssl-devel perl patch;
        do yum -y install $packages; done
    elif [ "$PM" = "apt" ]; then
        apt-get update -y
        dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
        for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker;
        do apt-get purge -y $removepackages; done
        for packages in debian-keyring debian-archive-keyring build-essential gcc g++ make autoconf automake wget cron openssl libssl-dev zlib1g zlib1g-dev ;
        do apt-get --no-install-recommends install -y $packages; done
    fi
}

Install_Only_Nginx()
{
    clear
    echo "+-----------------------------------------------------------------------+"
    echo "|              Install Nginx for LNMJ, Written by jiawei                |"
    echo "+-----------------------------------------------------------------------+"
    echo "|                     A tool to only install Nginx.                     |"
    echo "+-----------------------------------------------------------------------+"
    echo "|           For more information please visit https://lnmj.org          |"
    echo "+-----------------------------------------------------------------------+"
    Press_Install
    Echo_Blue "Install dependent packages..."
    cd ${cur_dir}/src
    Get_Dist_Version
    Nginx_Dependent
    cd ${cur_dir}/src
    # Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.bz2 ${Pcre_Ver}.tar.bz2
    Install_Pcre
    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi
    ldconfig
    # Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    Install_Nginx
    StartUp nginx
    /etc/init.d/nginx start
    Add_Iptables_Rules
    \cp ${cur_dir}/conf/index.html ${Default_Website_Dir}/index.html
    Check_Nginx_Files
}
