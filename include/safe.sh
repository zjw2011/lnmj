#!/bin/bash

Get_Safe_Remove_Files() {
Safe_Remove_Files="\
${App_Home}/java \
/etc/profile.d/java.sh \
${cur_dir}/src/${JDK_Ver} \
${cur_dir}/src/${Pcre_Ver} \
${cur_dir}/src/${Openssl_Ver} \
${cur_dir}/src/${Luajit_Ver} \
${App_Home}/nginx/conf/nginx.conf \
${App_Home}/nginx \
/etc/init.d/nginx
/etc/ld.so.conf.d/luajit.conf \
/etc/profile.d/luajit.sh \
/lib64/libluajit-5.1.so.2 \
/usr/lib/libluajit-5.1.so.2 \
${App_Home}/openresty/nginx/conf/nginx.conf \
${App_Home}/openresty
"
}

RM_Safe() {
	local FileName=$1

	# Get_Safe_Remove_Files
	if [[ "${FileName}" = "" ]]; then
		Echo_Red "Can't get FileName!"
		exit 1
	fi
	local FoundFile='0'
	for ItFile in ${Safe_Remove_Files}
	do 
		if [ "${FileName}" = "${ItFile}" ]; then
			FoundFile='1'
			break
		fi
	done
	if [ "${FoundFile}" = "1" ]; then
		rm -rf ${FileName}
	else
		Echo_Red "Rwmove File ${FileName} Failed!"
		exit 1
	fi
}

Check_Remove_Files() {
	Get_Safe_Remove_Files

	Echo_Yellow "Enable safe remove files ${Safe_Remove_Files}"
	for ItFile in ${Safe_Remove_Files}
	do 
		if [ "${FileName}" = "/" ]; then
			Echo_Red "Can't remove /!"
			exit 1
		fi
	done
}


