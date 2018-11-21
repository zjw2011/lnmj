#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmj"
    exit 1
fi

cur_dir=$(pwd)
Stack=$1
if [ "${Stack}" = "" ]; then
    Stack="lnmj"
else
    Stack=$1
fi

LNMJ_Ver='0.0.1'
. lnmj.conf
. include/main.sh
. include/init.sh
. include/mysql.sh

Get_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

if [[ "${Stack}" = "lnmj" ]]; then
    if [ -f /bin/lnmj ]; then
        Echo_Red "You have installed LNMJ!"
        echo -e "If you want to reinstall LNMJ, please BACKUP your data.\nand run uninstall script: ./uninstall.sh before you install."
        exit 1
    fi
fi

Check_LNMJConf

clear
echo "+------------------------------------------------------------------------+"
echo "|          LNMJ V${LNMJ_Ver} for ${DISTRO} Linux Server, Written by jiawei          |"
echo "+------------------------------------------------------------------------+"
echo "|        A tool to auto-compile & install LNMJ on Linux                    |"
echo "+------------------------------------------------------------------------+"
echo "|           For more information please visit xxx                          |"
echo "+------------------------------------------------------------------------+"

Init_Install()
{
    Press_Install
    Print_APP_Ver
    Get_Dist_Version
    Print_Sys_Info
    Check_Hosts
    Check_Mirror
    if [ "${DISTRO}" = "RHEL" ]; then
        RHEL_Modify_Source
    fi
    if [ "${DISTRO}" = "Ubuntu" ]; then
        Ubuntu_Modify_Source
    fi
    Set_Timezone
    if [ "$PM" = "yum" ]; then
        CentOS_InstallNTP
        CentOS_RemoveAMP
        CentOS_Dependent
    elif [ "$PM" = "apt" ]; then
        Deb_InstallNTP
        Xen_Hwcap_Setting
        Deb_RemoveAMP
        Deb_Dependent
    fi
    Disable_Selinux
    Check_Download
    Install_Libiconv
    Install_Libmcrypt
    Install_Mhash
    Install_Mcrypt
    Install_Freetype
    Install_Pcre
    Install_Icu4c
    if [ "${SelectMalloc}" = "2" ]; then
        Install_Jemalloc
    elif [ "${SelectMalloc}" = "3" ]; then
        Install_TCMalloc
    fi
    if [ "$PM" = "yum" ]; then
        CentOS_Lib_Opt
    elif [ "$PM" = "apt" ]; then
        Deb_Lib_Opt
        Deb_Check_MySQL
    fi
    if [ "${DBSelect}" = "1" ]; then
        Install_MySQL_51
    elif [ "${DBSelect}" = "2" ]; then
        Install_MySQL_55
    elif [ "${DBSelect}" = "3" ]; then
        Install_MySQL_56
    elif [ "${DBSelect}" = "4" ]; then
        Install_MySQL_57
    elif [ "${DBSelect}" = "5" ]; then
        Install_MySQL_80
    elif [ "${DBSelect}" = "6" ]; then
        Install_MariaDB_5
    elif [ "${DBSelect}" = "7" ]; then
        Install_MariaDB_10
    elif [ "${DBSelect}" = "8" ]; then
        Install_MariaDB_101
    elif [ "${DBSelect}" = "9" ]; then
        Install_MariaDB_102
    fi
    TempMycnf_Clean
    # Check_PHP_Option
}

LNMJ_Stack()
{
    Init_Install
    # Install_PHP
    # LNMP_PHP_Opt
    Install_Nginx
    Creat_PHP_Tools
    Add_Iptables_Rules
    Add_LNMP_Startup
    Check_LNMP_Install
}

case "${Stack}" in
    lnmj)
        Dispaly_Selection
        LNMJ_Stack 2>&1 | tee /root/lnmj-install.log
        ;;
    nginx)
        Install_Only_Nginx 2>&1 | tee /root/nginx-install.log
        ;;
    db)
        Install_Only_Database
        ;;
    *)
        Echo_Red "Usage: $0 {lnmj}"
        Echo_Red "Usage: $0 {nginx|db}"
        ;;
esac

exit


