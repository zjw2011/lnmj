#!/bin/bash

DB_Info=('MySQL 5.1.73' 'MySQL 5.5.60' 'MySQL 5.6.40' 'MySQL 5.7.22' 'MySQL 8.0.11' 'MariaDB 5.5.60' 'MariaDB 10.0.35' 'MariaDB 10.1.33' 'MariaDB 10.2.14')
Apache_Info=('Apache 2.2.34' 'Apache 2.4.33')

Database_Selection()
{
#which MySQL Version do you want to install?
    if [ -z ${DBSelect} ]; then
        DBSelect="2"
        Echo_Yellow "You have 10 options for your DataBase install."
        echo "1: Install ${DB_Info[0]}"
        echo "2: Install ${DB_Info[1]} (Default)"
        echo "3: Install ${DB_Info[2]}"
        echo "4: Install ${DB_Info[3]}"
        echo "5: Install ${DB_Info[4]}"
        echo "6: Install ${DB_Info[5]}"
        echo "7: Install ${DB_Info[6]}"
        echo "8: Install ${DB_Info[7]}"
        echo "9: Install ${DB_Info[8]}"
        echo "0: DO NOT Install MySQL/MariaDB"
        read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9 or 0): " DBSelect
    fi

    case "${DBSelect}" in
    1)
        echo "You will install ${DB_Info[0]}"
        ;;
    2)
        echo "You will install ${DB_Info[1]}"
        ;;
    3)
        echo "You will Install ${DB_Info[2]}"
        ;;
    4)
        echo "You will install ${DB_Info[3]}"
        ;;
    5)
        echo "You will install ${DB_Info[4]}"
        ;;
    6)
        echo "You will install ${DB_Info[5]}"
        ;;
    7)
        echo "You will install ${DB_Info[6]}"
        ;;
    8)
        echo "You will install ${DB_Info[7]}"
        ;;
    9)
        echo "You will install ${DB_Info[8]}"
        ;;
    0)
        echo "Do not install MySQL/MariaDB!"
        ;;
    *)
        echo "No input,You will install ${DB_Info[1]}"
        DBSelect="2"
    esac

    if [[ "${DBSelect}" =~ ^[345789]$ ]] && [ `free -m | grep Mem | awk '{print  $2}'` -le 1024 ]; then
        echo "Memory less than 1GB, can't install MySQL 5.6+ or MairaDB 10+!"
        exit 1
    fi

    if [[ "${DBSelect}" =~ ^[6789]$ ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
    fi

    if [[ "${DBSelect}" != "0" ]]; then
        #set mysql root password
        if [ -z ${DB_Root_Password} ]; then
            echo "==========================="
            DB_Root_Password="root"
            Echo_Yellow "Please setup root password of MySQL."
            read -p "Please enter: " DB_Root_Password
            if [ "${DB_Root_Password}" = "" ]; then
                echo "NO input,password will be generated randomly."
                DB_Root_Password="lnmp.org#$RANDOM"
            fi
        fi
        echo "MySQL root password: ${DB_Root_Password}"

        #do you want to enable or disable the InnoDB Storage Engine?
        echo "==========================="

        if [ -z ${InstallInnodb} ]; then
            InstallInnodb="y"
            Echo_Yellow "Do you want to enable or disable the InnoDB Storage Engine?"
            read -p "Default enable,Enter your choice [Y/n]: " InstallInnodb
        fi

        case "${InstallInnodb}" in
        [yY][eE][sS]|[yY])
            echo "You will enable the InnoDB Storage Engine"
            InstallInnodb="y"
            ;;
        [nN][oO]|[nN])
            echo "You will disable the InnoDB Storage Engine!"
            InstallInnodb="n"
            ;;
        *)
            echo "No input,The InnoDB Storage Engine will enable."
            InstallInnodb="y"
        esac
    fi
}

MemoryAllocator_Selection()
{
#which Memory Allocator do you want to install?
    if [ -z ${SelectMalloc} ]; then
        echo "==========================="

        SelectMalloc="1"
        Echo_Yellow "You have 3 options for your Memory Allocator install."
        echo "1: Don't install Memory Allocator. (Default)"
        echo "2: Install Jemalloc"
        echo "3: Install TCMalloc"
        read -p "Enter your choice (1, 2 or 3): " SelectMalloc
    fi

    case "${SelectMalloc}" in
    1)
        echo "You will install not install Memory Allocator."
        ;;
    2)
        echo "You will install JeMalloc"
        ;;
    3)
        echo "You will Install TCMalloc"
        ;;
    *)
        echo "No input,You will not install Memory Allocator."
        SelectMalloc="1"
    esac

    if [ "${SelectMalloc}" =  "1" ]; then
        MySQL51MAOpt=''
        MySQLMAOpt=''
        NginxMAOpt=''
    elif [ "${SelectMalloc}" =  "2" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ljemalloc'
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libjemalloc.so'
        NginxMAOpt="--with-ld-opt='-ljemalloc'"
    elif [ "${SelectMalloc}" =  "3" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ltcmalloc'
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libtcmalloc.so'
        NginxMAOpt='--with-google_perftools_module'
    fi
}

Kill_PM()
{
    if ps aux | grep "yum" | grep -qv "grep"; then
        if [ -s /usr/bin/killall ]; then
            killall yum
        else
            kill `pidof yum`
        fi
    elif ps aux | grep "apt-get" | grep -qv "grep"; then
        if [ -s /usr/bin/killall ]; then
            killall apt-get
        else
            kill `pidof apt-get`
        fi
    fi
}

Press_Install()
{
    if [ -z ${LNMJ_Auto} ]; then
        echo ""
        Echo_Green "Press any key to install...or Press Ctrl+c to cancel"
        OLDCONFIG=`stty -g`
        stty -icanon -echo min 1 time 0
        dd count=1 2>/dev/null
        stty ${OLDCONFIG}
    fi
    . include/version.sh
    Kill_PM
}

Print_APP_Ver()
{
    echo "You will install ${Stack} stack."
    if [ "${Stack}" != "lamj" ]; then
        echo "${Nginx_Ver}"
    fi

    if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        echo "${Mysql_Ver}"
    elif [[ "${DBSelect}" =~ ^[6789]$ ]]; then
        echo "${Mariadb_Ver}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi

    # echo "${Php_Ver}"

    # if [ "${Stack}" != "lnmj" ]; then
    #     echo "${Apache_Ver}"
    # fi

    if [ "${SelectMalloc}" = "2" ]; then
        echo "${Jemalloc_Ver}"
    elif [ "${SelectMalloc}" = "3" ]; then
        echo "${TCMalloc_Ver}"
    fi
    echo "Enable InnoDB: ${InstallInnodb}"
    echo "Print lnmj.conf infomation..."
    echo "Download Mirror: ${Download_Mirror}"
    echo "Nginx Additional Modules: ${Nginx_Modules_Options}"
    # echo "PHP Additional Modules: ${PHP_Modules_Options}"
    # if [ "${Enable_PHP_Fileinfo}" = "y" ]; then
    #     echo "enable PHP fileinfo."
    # fi
    if [ "${Enable_Nginx_Lua}" = "y" ]; then
        echo "enable Nginx Lua."
    fi
    if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        echo "Database Directory: ${MySQL_Data_Dir}"
    elif [[ "${DBSelect}" =~ ^[6789]$ ]]; then
        echo "Database Directory: ${MariaDB_Data_Dir}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi
    echo "Default Website Directory: ${Default_Website_Dir}"
}

Install_LSB()
{
    echo "[+] Installing lsb..."
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get --no-install-recommends install -y lsb-release
    fi
}

Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1])'`
    elif [ -s /usr/bin/python2 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1]'`
    fi
    if [ $? -ne 0 ]; then
        Install_LSB
        eval ${DISTRO}_Version=`lsb_release -rs`
    fi
}

Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_RHEL_Version()
{
    Get_Dist_Name
    if [ "${DISTRO}" = "RHEL" ]; then
        if grep -Eqi "release 5." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 5"
            RHEL_Ver='5'
        elif grep -Eqi "release 6." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 6"
            RHEL_Ver='6'
        elif grep -Eqi "release 7." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 7"
            RHEL_Ver='7'
        fi
    fi
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}

Get_ARM()
{
    if uname -m | grep -Eqi "arm|aarch64"; then
        Is_ARM='y'
    fi
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}

Tar_Cd()
{
    local FileName=$1
    local DirName=$2
    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar zxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}

Tarj_Cd()
{
    local FileName=$1
    local DirName=$2
    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar jxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}

Check_LNMJConf()
{
    if [ ! -s "${cur_dir}/lnmj.conf" ]; then
        Echo_Red "lnmj.conf was not exsit!"
        exit 1
    fi
    if [[ "${Download_Mirror}" = "" || "${MySQL_Data_Dir}" = "" || "${MariaDB_Data_Dir}" = "" || "${Default_Website_Dir}" = "" ]]; then
        Echo_Red "Can't get values from lnmj.conf!"
        exit 1
    fi
    if [[ "${MySQL_Data_Dir}" = "/" || "${MariaDB_Data_Dir}" = "/" || "${Default_Website_Dir}" = "/" ]]; then
        Echo_Red "Can't set MySQL/MariaDB/Website Directory to / !"
        exit 1
    fi
}

Print_Sys_Info()
{
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}

Check_Mirror()
{
    if [ ! -s /usr/bin/curl ]; then
        if [ "$PM" = "yum" ]; then
            yum install -y curl
        elif [ "$PM" = "apt" ]; then
            apt-get update
            apt-get install -y curl
        fi
    fi
    country=`curl -sSk --connect-timeout 30 -m 60 https://ip.vpser.net/country`
    echo "Server Location: ${country}"
    if [ "${Download_Mirror}" = "https://soft.vpser.net" ]; then
        echo "Try http://soft.vpser.net ..."
        mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft.vpser.net`
        if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
            echo "http://soft.vpser.net http code: ${mirror_code}"
            ping -c 3 soft.vpser.net
        else
            ping -c 3 soft.vpser.net
            if [ "${country}" = "CN" ]; then
                echo "Try http://soft1.vpser.net ..."
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft1.vpser.net`
                if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                    echo "Change to mirror http://soft1.vpser.net"
                    Download_Mirror='http://soft1.vpser.net'
                else
                    echo "Try http://soft2.vpser.net ..."
                    mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft2.vpser.net`
                    if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                        echo "Change to mirror http://soft2.vpser.net"
                        Download_Mirror='http://soft2.vpser.net'
                    else
                        echo "Can not connect to download mirror,Please modify lnmp.conf manually."
                        echo "More info,please visit https://lnmp.org/faq/download-url.html"
                        exit 1
                    fi
                fi
            else
                echo "Try http://soft2.vpser.net ..."
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft2.vpser.net`
                if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                    echo "Change to mirror http://soft2.vpser.net"
                    Download_Mirror='http://soft2.vpser.net'
                else
                    echo "Try http://soft1.vpser.net ..."
                    mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft1.vpser.net`
                    if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                        echo "Change to mirror http://soft1.vpser.net"
                        Download_Mirror='http://soft1.vpser.net'
                    else
                        echo "Can not connect to download mirror,Please modify lnmp.conf manually."
                        echo "More info,please visit https://lnmp.org/faq/download-url.html"
                        exit 1
                    fi
                fi
            fi
        fi
    fi
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

Dispaly_Selection()
{
    Database_Selection
    MemoryAllocator_Selection
}

Check_DB()
{
    if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
        Is_MySQL="n"
        DB_Name="mariadb"
    elif [[ -s /usr/local/mysql/bin/mysql && -s /usr/local/mysql/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
        Is_MySQL="y"
        DB_Name="mysql"
    else
        Is_MySQL="None"
        DB_Name="None"
    fi
}

Do_Query()
{
    echo "$1" >/tmp/.mysql.tmp
    Check_DB
    ${MySQL_Bin} --defaults-file=~/.my.cnf </tmp/.mysql.tmp
    return $?
}

Make_TempMycnf()
{
    cat >~/.my.cnf<<EOF
[client]
user=root
password='$1'
EOF
    chmod 600 ~/.my.cnf
}

Verify_DB_Password()
{
    Check_DB
    status=1
    while [ $status -eq 1 ]; do
        read -s -p "Enter current root password of Database (Password will not shown): " DB_Root_Password
        Make_TempMycnf "${DB_Root_Password}"
        Do_Query ""
        status=$?
    done
    echo "OK, MySQL root password correct."
}

TempMycnf_Clean()
{
    if [ -s ~/.my.cnf ]; then
        rm -f ~/.my.cnf
    fi
    if [ -s /tmp/.mysql.tmp ]; then
        rm -f /tmp/.mysql.tmp
    fi
}



