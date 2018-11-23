#!/bin/bash

Install_Nginx_Openssl()
{
    if [ "${Enable_Nginx_Openssl}" = 'y' ]; then
        # Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
        [[ -d "${cur_dir}/src/${Openssl_Ver}" ]] && RM_Safe ${cur_dir}/src/${Openssl_Ver}
        tar zxf ${Openssl_Ver}.tar.gz
        Nginx_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_Ver}"
    fi
}

Install_Nginx_Lua()
{
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        echo "Installing Lua for Nginx..."
        cd ${cur_dir}/src
        # Download_Files ${Download_Mirror}/lib/lua/${Luajit_Ver}.tar.gz ${Luajit_Ver}.tar.gz
        # Download_Files ${Download_Mirror}/lib/lua/${LuaNginxModule}.tar.gz ${LuaNginxModule}.tar.gz
        # Download_Files ${Download_Mirror}/lib/lua/${NgxDevelKit}.tar.gz ${NgxDevelKit}.tar.gz

        Echo_Blue "[+] Installing ${Luajit_Ver}... "
        tar zxf ${LuaNginxModule}.tar.gz
        tar zxf ${NgxDevelKit}.tar.gz
        if [[ ! -s ${App_Home}/luajit/bin/luajit || ! -s ${App_Home}/luajit/include/luajit-2.0/luajit.h || ! -s ${App_Home}/luajit/lib/libluajit-5.1.so ]]; then
            Tar_Cd ${Luajit_Ver}.tar.gz ${Luajit_Ver}
            make
            make install PREFIX=${App_Home}/luajit
            cd ${cur_dir}/src
            RM_Safe ${cur_dir}/src/${Luajit_Ver}
        fi

        cat > /etc/ld.so.conf.d/luajit.conf<<EOF
/usr/local/luajit/lib
EOF
        if [ "${Is_64bit}" = "y" ]; then
            ln -sf ${App_Home}/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
        else
            ln -sf ${App_Home}/luajit/lib/libluajit-5.1.so.2 /usr/lib/libluajit-5.1.so.2
        fi
        ldconfig

        cat >/etc/profile.d/luajit.sh<<EOF
export LUAJIT_LIB=${App_Home}/luajit/lib
export LUAJIT_INC=${App_Home}/luajit/include/luajit-2.0
EOF

        source /etc/profile.d/luajit.sh

        Nginx_Module_Lua="--with-ld-opt=-Wl,-rpath,${App_Home}/luajit/lib --add-module=${cur_dir}/src/${LuaNginxModule} --add-module=${cur_dir}/src/${NgxDevelKit}"
    fi
}

Install_Nginx()
{
    Echo_Blue "[+] Installing ${Nginx_Ver}... "
    groupadd www
    useradd -s /sbin/nologin -g www www

    cd ${cur_dir}/src
    Install_Nginx_Openssl
    Install_Nginx_Lua
    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
    if [[ "${DISTRO}" = "Fedora" && "${Fedora_Version}" = "28" ]]; then
        patch -p1 < ${cur_dir}/src/patch/nginx-libxcrypt.patch
    fi
    if gcc -dumpversion|grep -q "^[8]"; then
        patch -p1 < ${cur_dir}/src/patch/nginx-gcc8.patch
    fi
    if echo ${Nginx_Ver} | grep -Eqi 'nginx-[0-1].[5-8].[0-9]' || echo ${Nginx_Ver} | grep -Eqi 'nginx-1.9.[1-4]$'; then
        ./configure --user=www --group=www --prefix=${App_Home}/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module ${Nginx_With_Openssl} ${Nginx_Module_Lua} ${NginxMAOpt} ${Nginx_Modules_Options}
    else
        ./configure --user=www --group=www --prefix=${App_Home}/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module ${Nginx_With_Openssl} ${Nginx_Module_Lua} ${NginxMAOpt} ${Nginx_Modules_Options}
    fi
    Make_Install
    cd ../

    ln -sf ${App_Home}/nginx/sbin/nginx /usr/bin/nginx

    RM_Safe ${App_Home}/nginx/conf/nginx.conf
    cd ${cur_dir}
    # if [ "${Stack}" = "lnmpa" ]; then
    #     \cp conf/nginx_a.conf ${App_Home}/nginx/conf/nginx.conf
    #     \cp conf/proxy.conf ${App_Home}/nginx/conf/proxy.conf
    #     \cp conf/proxy-pass-php.conf ${App_Home}/nginx/conf/proxy-pass-php.conf
    # else
    #     \cp conf/nginx.conf ${App_Home}/nginx/conf/nginx.conf
    # fi
    \cp conf/nginx.conf ${App_Home}/nginx/conf/nginx.conf
    
    # \cp -ra conf/rewrite ${App_Home}/nginx/conf/
    # \cp conf/pathinfo.conf ${App_Home}/nginx/conf/pathinfo.conf
    # \cp conf/enable-php.conf ${App_Home}/nginx/conf/enable-php.conf
    # \cp conf/enable-php-pathinfo.conf ${App_Home}/nginx/conf/enable-php-pathinfo.conf
    # \cp conf/enable-ssl-example.conf ${App_Home}/nginx/conf/enable-ssl-example.conf
    # \cp conf/magento2-example.conf ${App_Home}/nginx/conf/magento2-example.conf
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        sed -i "/location \/nginx_status/i\        location /lua\n        {\n            default_type text/html;\n            content_by_lua 'ngx.say\(\"hello world\"\)';\n        }\n" ${App_Home}/nginx/conf/nginx.conf
    fi

    mkdir -p ${Default_Website_Dir}
    chmod +w ${Default_Website_Dir}
    mkdir -p /home/wwwlogs
    chmod 777 /home/wwwlogs

    chown -R www:www ${Default_Website_Dir}

    mkdir ${App_Home}/nginx/conf/vhost

    if [ "${Default_Website_Dir}" != "/home/wwwroot/default" ]; then
        sed -i "s#/home/wwwroot/default#${Default_Website_Dir}#g" /usr/local/nginx/conf/nginx.conf
    fi

    if [ "${Stack}" = "lnmp" ]; then
        cat >${Default_Website_Dir}/.user.ini<<EOF
open_basedir=${Default_Website_Dir}:/tmp/:/proc/
EOF
        chmod 644 ${Default_Website_Dir}/.user.ini
        chattr +i ${Default_Website_Dir}/.user.ini
        cat >>${App_Home}/nginx/conf/fastcgi.conf<<EOF
fastcgi_param PHP_ADMIN_VALUE "open_basedir=\$document_root/:/tmp/:/proc/";
EOF
    fi

    \cp init.d/init.d.nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx

    if [ "${SelectMalloc}" = "3" ]; then
        mkdir /tmp/tcmalloc
        chown -R www:www /tmp/tcmalloc
        sed -i '/nginx.pid/a\
google_perftools_profiles /tmp/tcmalloc;' ${App_Home}/nginx/conf/nginx.conf
    fi
}
