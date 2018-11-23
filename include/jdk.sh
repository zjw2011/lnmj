#!/bin/bash

# echo "nginx-1.6.7_qq" | grep -Ei 'nginx-[0-1].[5-8].[0-9]' | cut -d'.' -f1
# echo "jdk1.8.0_191" | grep -Ei '^jdk1\.8' | cut -d'.' -f1
# echo "jdk1.8.0_191" | grep -Ei '^jdk1' | cut -d'_' -f2
Get_TarName() {
	if echo ${JDK_Ver} | grep -Ei '^jdk1\.8.[0-9]*_[0-9]*$'; then
		JAVA_Version="8"
	else
		Echo_Red "[${JDK_Ver}] is not support!"
        exit 1
	fi
	local JAVA_Sequence=`echo ${JDK_Ver} | cut -d'_' -f2`
	JDK_Tar_Name="jdk-${JAVA_Version}u${JAVA_Sequence}-linux"
	# if [ "${JDK_Ver}" = "jdk1.8.0_191" ]; then
	# 	JDK_Tar_Name="jdk-8u191-linux"
	# 	JAVA_Version="8"
	# elif [[ "${JDK_Ver}" = "jdk1.8.0_192" ]]; then
	# 	JDK_Tar_Name="jdk-8u192-linux"
	# 	JAVA_Version="8"
	# else
	# 	Echo_Red "[${JDK_Ver}] is not support!"
 #        exit 1
	# fi
}

Install_JDK_Policy() {
	mkdir -p ${JAVA_HOME}/lib/security
	if [ "${JAVA_Version}" = "8" ]; then
	    \cp -rf UnlimitedJCEPolicyJDK8/local_policy.jar ${JAVA_HOME}/lib/security/
	    \cp -rf UnlimitedJCEPolicyJDK8/local_policy.jar ${JAVA_HOME}/jre/lib/security/

	    \cp -rf UnlimitedJCEPolicyJDK8/US_export_policy.jar ${JAVA_HOME}/lib/security/
	    \cp -rf UnlimitedJCEPolicyJDK8/US_export_policy.jar ${JAVA_HOME}/jre/lib/security/
	fi
}

Install_JDK()
{
    Echo_Blue "[+] Installing ${JDK_Ver} in ${App_Home}/java... "

    cd ${cur_dir}/src
    Get_TarName

    if [ "${Is_64bit}" = "y" ]; then
        Tar_Cd ${JDK_Tar_Name}-x64.tar.gz ${JDK_Ver}
    else
    	Tar_Cd ${JDK_Tar_Name}-i586.tar.gz ${JDK_Ver}
    fi

    JAVA_HOME=${App_Home}/java
    mkdir -p ${JAVA_HOME}
    \cp -rf * ${JAVA_HOME}

	cd ${cur_dir}/src

    if [ "${Enable_JDK_Policy}" = 'y' ]; then
    	echo "Installing Policy for JDK..."
    	Install_JDK_Policy
	fi
    

    RM_Safe /etc/profile.d/java.sh
	cat >/etc/profile.d/java.sh<<EOF
export JAVA_HOME=${JAVA_HOME}
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin
EOF
	source /etc/profile.d/java.sh
}
