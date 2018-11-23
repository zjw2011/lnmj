#!/bin/bash

Install_Openresty_Openssl()
{
    if [ "${Install_Openresty_Openssl}" = 'y' ]; then
        # Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
        [[ -d "${cur_dir}/src/${Openssl_Ver}" ]] && RM_Safe ${cur_dir}/src/${Openssl_Ver}
        tar zxf ${Openssl_Ver}.tar.gz
        Openresty_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_Ver}"
    fi
}

Install_Openresty()
{
    Echo_Blue "[+] Installing ${Openresty_Ver}... "

    groupadd www
    useradd -s /sbin/nologin -g www www

	cd ${cur_dir}/src
    Install_Openresty_Openssl
    Tar_Cd ${Openresty_Ver}.tar.gz ${Openresty_Ver}
    ./configure --user=www --group=www --prefix=${App_Home}/openresty --with-http_stub_status_module --with-luajit --with-pcre-jit --with-ipv6 --with-http_iconv_module ${Openresty_With_Openssl} ${Openresty_Modules_Options} -j`grep 'processor' /proc/cpuinfo | wc -l`
    Make_Install
    cd ../

    ln -sf ${App_Home}/openresty/nginx/sbin/nginx /usr/bin/nginx
    ln -sf ${App_Home}/openresty/bin/resty /usr/bin/resty
    ln -sf ${App_Home}/openresty/luajit/bin/luajit /usr/bin/luajit

	RM_Safe ${App_Home}/openresty/nginx/conf/nginx.conf
    cd ${cur_dir}
    \cp conf/openresty.conf ${App_Home}/openresty/nginx/conf/nginx.conf
    sed -i "s#{{App_Home}}#${App_Home}/openresty#g" ${App_Home}/openresty/nginx/conf/nginx.conf

    mkdir -p ${Default_Website_Dir}
    chmod +w ${Default_Website_Dir}
    mkdir -p /home/wwwlogs
    chmod 777 /home/wwwlogs

    chown -R www:www ${Default_Website_Dir}

    mkdir ${App_Home}/openresty/nginx/conf/vhost

    if [ "${Default_Website_Dir}" != "/home/wwwroot/default" ]; then
        sed -i "s#/home/wwwroot/default#${Default_Website_Dir}#g" ${App_Home}/openresty/nginx/conf/nginx.conf
    fi

#     cat > /etc/ld.so.conf.d/luajit.conf<<EOF
# ${App_Home}/openresty/luajit/lib
# EOF
#     if [ "${Is_64bit}" = "y" ]; then
#         ln -sf ${App_Home}/openresty/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
#     else
#         ln -sf ${App_Home}/openresty/luajit/lib/libluajit-5.1.so.2 /usr/lib/libluajit-5.1.so.2
#     fi
#     ldconfig

    cd ${cur_dir}

    \cp init.d/init.d.nginx /etc/init.d/nginx
    sed -i "s#{{App_Home}}#${App_Home}/openresty#g" /etc/init.d/nginx
    chmod +x /etc/init.d/nginx

}
