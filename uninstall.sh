#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

cur_dir=$(pwd)
Stack=$1

LNMP_Ver='0.0.1'

. lnmj.conf
. include/main.sh

shopt -s extglob

# Check_DB
Get_Dist_Name

clear
echo "+------------------------------------------------------------------------+"
echo "|          LNMJ V${LNMP_Ver} for ${DISTRO} Linux Server, Written by jiawei          |"
echo "+------------------------------------------------------------------------+"
echo "|        A tool to auto-compile & install Nginx+MySQL+PHP on Linux       |"
echo "+------------------------------------------------------------------------+"
echo "|           For more information please visit https://lnmj.org           |"
echo "+------------------------------------------------------------------------+"

Dele_Iptables_Rules()
{
    if [ -s /usr/sbin/firewalld ]; then
        firewall-cmd --permanent --zone=public --remove-port=22/tcp
        firewall-cmd --permanent --zone=public --remove-port=80/tcp
        firewall-cmd --permanent --zone=public --remove-port=443/tcp
        firewall-cmd --reload
        # firewall-cmd --permanent --add-icmp-block=echo-request
        # firewall-cmd --permanent --add-rich-rule='rule protocol value=icmp drop'
        systemctl restart firewalld
    elif [ -s /sbin/iptables ]; then
        /sbin/iptables -D INPUT -i lo -j ACCEPT
        /sbin/iptables -D INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 22 -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 80 -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 443 -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 3306 -j DROP
        /sbin/iptables -D INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
    fi
}

Sleep_Sec()
{
    seconds=$1
    while [ "${seconds}" -ge "0" ];do
      echo -ne "\r     \r"
      echo -n ${seconds}
      seconds=$(($seconds - 1))
      sleep 1
    done
    echo -ne "\r"
}

Uninstall_LNMJ()
{
    echo "Stoping LNMJ..."
    lnmj kill
    lnmj stop

    echo "Deleting iptables rules..."
    Dele_Iptables_Rules

    rm -rf ${App_Home}/java
    rm -rf /etc/profile.d/java.sh
    # Remove_StartUp nginx
    # Remove_StartUp php-fpm
    # if [ ${DB_Name} != "None" ]; then
    #     Remove_StartUp ${DB_Name}
    #     echo "Backup ${DB_Name} databases directory to /root/databases_backup_$(date +"%Y%m%d%H%M%S")"
    #     if [ ${DB_Name} == "mysql" ]; then
    #         mv ${MySQL_Data_Dir} /root/databases_backup_$(date +"%Y%m%d%H%M%S")
    #     elif [ ${DB_Name} == "mariadb" ]; then
    #         mv ${MariaDB_Data_Dir} /root/databases_backup_$(date +"%Y%m%d%H%M%S")
    #     fi
    # fi
    # chattr -i ${Default_Website_Dir}/.user.ini
    echo "Deleting LNMJ files..."
    # rm -rf /usr/local/nginx
    # rm -rf /usr/local/php
    # rm -rf /usr/local/zend

    # if [ ${DB_Name} != "None" ]; then
    #     rm -rf /usr/local/${DB_Name}
    #     rm -f /etc/my.cnf
    #     rm -f /etc/init.d/${DB_Name}
    # fi

    # for mphp in /usr/local/php[5,7].[0-9]; do
    #     mphp_ver=`echo $mphp|sed 's#/usr/local/php##'`
    #     if [ -s /etc/init.d/php-fpm${mphp_ver} ]; then
    #         /etc/init.d/php-fpm${mphp_ver} stop
    #         Remove_StartUp php-fpm${mphp_ver}
    #         rm -f /etc/init.d/php-fpm${mphp_ver}
    #     fi
    #     if [ -d ${mphp} ]; then
    #         rm -rf ${mphp}
    #     fi
    # done

    if [ -s /usr/local/acme.sh/acme.sh ]; then
        /usr/local/acme.sh/acme.sh --uninstall
        rm -rf /usr/local/acme.sh
    fi

    # rm -f /etc/init.d/nginx
    # rm -f /etc/init.d/php-fpm
    rm -f /bin/lnmj
    echo "LNMJ Uninstall completed."
}

    Check_Stack
    echo "Current Stack: ${Get_Stack}"

    action=""
    echo "Enter 1 to uninstall LNMJ"
    read -p "(Please input 1): " action

    case "$action" in
    1|[lL][nN][nM][pP])
        echo "You will uninstall LNMJ"
        Echo_Red "Please backup your configure files and mysql data!!!!!!"
        Echo_Red "The following directory or files will be remove!"
# /usr/local/nginx
# ${MySQL_Dir}
# /usr/local/php
# /etc/init.d/nginx
# /etc/init.d/${DB_Name}
# /etc/init.d/php-fpm
# /usr/local/zend
# /etc/my.cnf
        cat << EOF
${App_Home}/java
/etc/profile.d/java.sh
/bin/lnmj
EOF
        Sleep_Sec 3
        Press_Start
        Uninstall_LNMJ
    ;;
    esac
