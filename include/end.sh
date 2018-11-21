#!/bin/bash

Add_Iptables_Rules()
{
    #add iptables firewall rules
    if [ -s /usr/sbin/firewalld ]; then
    	firewall-cmd --permanent --zone=public --add-port=22/tcp
    	firewall-cmd --permanent --zone=public --add-port=80/tcp
    	firewall-cmd --permanent --zone=public --add-port=443/tcp
    	firewall-cmd --reload
    	# firewall-cmd --permanent --add-icmp-block=echo-request
    	# firewall-cmd --permanent --add-rich-rule='rule protocol value=icmp drop'
        systemctl restart firewalld
    elif [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 1 -i lo -j ACCEPT
        /sbin/iptables -I INPUT 2 -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -I INPUT 3 -p tcp --dport 22 -j ACCEPT
        /sbin/iptables -I INPUT 4 -p tcp --dport 80 -j ACCEPT
        /sbin/iptables -I INPUT 5 -p tcp --dport 443 -j ACCEPT
        /sbin/iptables -I INPUT 6 -p tcp --dport 3306 -j DROP
        /sbin/iptables -I INPUT 7 -p icmp -m icmp --icmp-type 8 -j ACCEPT
        if [ "$PM" = "yum" ]; then
            service iptables save
            if [ -s /usr/sbin/firewalld ]; then
                systemctl stop firewalld
                systemctl disable firewalld
            fi
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
            cat >/etc/network/if-post-down.d/iptables<<EOF
#!/bin/bash
iptables-save > /etc/iptables.rules
EOF
            chmod +x /etc/network/if-post-down.d/iptables
            cat >/etc/network/if-pre-up.d/iptables<<EOF
#!/bin/bash
iptables-restore < /etc/iptables.rules
EOF
            chmod +x /etc/network/if-pre-up.d/iptables
        fi
    fi
}

Check_JDK_Files()
{
    isJDK=""
    if [[ -s ${App_Home}/java/bin/java && -s ${App_Home}/java/jre/bin/java ]]; then
        Echo_Green "JDK: OK"
        isJDK="ok"
    else
        Echo_Red "Error: JDK install failed."
    fi
}

Add_LNMJ_Startup()
{
    echo "Add Startup and Starting LNMJ..."
    \cp ${cur_dir}/conf/lnmj /bin/lnmj
    chmod +x /bin/lnmj
    # StartUp nginx
    # /etc/init.d/nginx start
    # if [[ "${DBSelect}" =~ ^[6789]$ ]]; then
    #     StartUp mariadb
    #     /etc/init.d/mariadb start
    #     sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
    # elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
    #     StartUp mysql
    #     /etc/init.d/mysql start
    # elif [ "${DBSelect}" = "0" ]; then
    #     sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
    # fi
    # StartUp php-fpm
    # /etc/init.d/php-fpm start
    # if [ "${PHPSelect}" = "1" ]; then
    #     sed -i 's#/usr/local/php/var/run/php-fpm.pid#/usr/local/php/logs/php-fpm.pid#' /bin/lnmp
    # fi
}

Clean_Src_Dir()
{
    echo "Clean src directory..."
   	rm -rf ${cur_dir}/src/${JDK_Ver}
    # if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
    #     rm -rf ${cur_dir}/src/${Mysql_Ver}
    # elif [[ "${DBSelect}" =~ ^[6789]$ ]]; then
    #     rm -rf ${cur_dir}/src/${Mariadb_Ver}
    # fi
    # if [[ "${DBSelect}" = "4" ]]; then
    #     rm -rf ${cur_dir}/src/${Boost_Ver}
    # elif [[ "${DBSelect}" = "5" ]]; then
    #     rm -rf ${cur_dir}/src/${Boost_New_Ver}
    # fi
    # rm -rf ${cur_dir}/src/${Php_Ver}
    # if [ "${Stack}" = "lnmj" ]; then
    #     rm -rf ${cur_dir}/src/${Nginx_Ver}
    # elif [ "${Stack}" = "lnmpa" ]; then
    #     rm -rf ${cur_dir}/src/${Nginx_Ver}
    #     rm -rf ${cur_dir}/src/${Apache_Ver}
    # elif [ "${Stack}" = "lamp" ]; then
    #     rm -rf ${cur_dir}/src/${Apache_Ver}
    # fi
}

Print_Sucess_Info()
{
    Clean_Src_Dir
    echo "+------------------------------------------------------------------------+"
    echo "|          LNMJ V${LNMJ_Ver} for ${DISTRO} Linux Server, Written by jiawei          |"
    echo "+------------------------------------------------------------------------+"
    echo "|           For more information please visit https://lnmp.org           |"
    echo "+------------------------------------------------------------------------+"
    echo "|    lnmj status manage: lnmp {start|stop|reload|restart|kill|status}    |"
    echo "+------------------------------------------------------------------------+"
    echo "|  phpMyAdmin: http://IP/phpmyadmin/                                     |"
    echo "|  phpinfo: http://IP/phpinfo.php                                        |"
    echo "|  Prober:  http://IP/p.php                                              |"
    echo "+------------------------------------------------------------------------+"
    echo "|  Add VirtualHost: lnmj vhost add                                       |"
    echo "+------------------------------------------------------------------------+"
    echo "|  Default directory: ${Default_Website_Dir}                              |"
    # if [ "${DBSelect}" != "0" ]; then
    #     echo "+------------------------------------------------------------------------+"
    #     echo "|  MySQL/MariaDB root password: ${DB_Root_Password}                          |"
    # fi
    echo "+------------------------------------------------------------------------+"
    lnmj status
    if [ -s /bin/ss ]; then
        ss -ntl
    else
        netstat -ntl
    fi
    stop_time=$(date +%s)
    echo "Install lnmj takes $(((stop_time-start_time)/60)) minutes."
    Echo_Green "Install lnmj V${LNMP_Ver} completed! enjoy it."
}

Print_Failed_Info()
{
    if [ -s /bin/lnmj ]; then
        rm -f /bin/lnmj
    fi
    Echo_Red "Sorry, Failed to install LNMJ!"
    Echo_Red "Please visit https://bbs.vpser.net/forum-25-1.html feedback errors and logs."
    Echo_Red "You can download /root/lnmj-install.log from your server,and upload lnmj-install.log to LNMP Forum."
}

Check_LNMJ_Install()
{
	Print_Sucess_Info
	Check_JDK_Files
    # Check_Nginx_Files
    # Check_DB_Files
    # Check_PHP_Files
    if [[ "${isJDK}" = "ok" ]]; then
        Print_Sucess_Info
    else
        Print_Failed_Info
    fi
}

