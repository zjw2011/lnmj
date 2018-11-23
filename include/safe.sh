#!/bin/bash

Safe_Remove_Files="/usr/app \
/etc/profile.d/java.sh \
${cur_dir}/src/${JDK_Ver} \
${cur_dir}/src/${Pcre_Ver} \
${cur_dir}/src/${Openssl_Ver} \
${cur_dir}/src/${Luajit_Ver} \
${App_Home}/nginx/conf/nginx.conf
${App_Home}/nginx
"

RM_Safe() {
	local FileName=$1
	if [[ "${FileName}" = "" ]]; then
		Echo_Red "Can't get FileName!"
		exit 1
	fi
	if [[ "${FileName}" = "/" ]]; then
		Echo_Red "Can't remove /!"
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

