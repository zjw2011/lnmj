#!/bin/bash

Safe_Remove_Files="/usr/app \
${cur_dir}/src \
/etc/profile.d/java.sh \
"

RM_Safe() {
	local FileName=$1
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

