#!/bin/bash
CONFIGURATION='{"link":{"host":"gov01.fedcloud.tenable.com","port":443,"key":"'$1'","name":"agent-name","groups":["agent-group"]}}'
SERVER='gov01.fedcloud.tenable.com:443'
RHPREFIX=el
FCVER=38
echo "** Beginning Nessus Agent installation process. **"

release=$(cat /etc/*release)
centos7=$(echo "$release" | grep -c "centos:7")
rhel9=$(echo "$release" | grep -c "enterprise_linux:9")
rhel8=$(echo "$release" | grep -c "enterprise_linux:8")
rhel7=$(echo "$release" | grep -c "enterprise_linux:7")
rhel6=$(echo "$release" | grep -c "Red Hat Enterprise Linux.*release 6")
oracle9=$(echo "$release" | grep -c "oracle:linux:9")
oracle8=$(echo "$release" | grep -c "oracle:linux:8")
oracle7=$(echo "$release" | grep -c "oracle:linux:7")
oracle6=$(echo "$release" | grep -c "oracle:linux:6")
suse15=$(echo "$release" | grep CPE_NAME | grep -Ec "suse:.*15")
suse12=$(echo "$release" | grep CPE_NAME | grep -Ec "suse:.*12")
ubuntu=$(echo "$release" | grep NAME | grep -c Ubuntu)
debian=$(echo "$release" | grep NAME | grep -c Debian)
fedora=$(echo "$release" | grep NAME | grep -c Fedora)
kali=$(echo "$release" | grep NAME | grep -c Kali)
al2=$(echo "$release" | grep PRETTY_NAME | grep -c "Amazon Linux 2")
alma8=$(echo "$release" | grep -c "almalinux:8")
alma9=$(echo "$release" | grep -c "almalinux:9")
rocky8=$(echo "$release" | grep -c "rocky:8")
rocky9=$(echo "$release" | grep -c "rocky:9")

aarch64=$(uname -p | grep -c aarch64)
is64bit=$(getconf LONG_BIT | grep -c 64)

version=
file=
cmd=
startcmd="/bin/systemctl restart nessusagent"

function populate_centos7 {
    version="CentOS 7"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}7.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}7.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_oracle9 {
    version="Oracle Linux 9"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}9.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}9.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_oracle8 {
    version="Oracle Linux 8"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}8.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}8.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_oracle7 {
    version="Oracle Linux 7"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}7.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}7.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_oracle6 {
    version="Oracle Linux 6"

    if [[ $is64bit -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}6.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
    startcmd="/sbin/service nessusagent start"
}

function populate_rhel9 {
    version="RedHat Enterprise Linux 9"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}9.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}9.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_rhel8 {
    version="RedHat Enterprise Linux 8"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}8.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}8.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_rhel7 {
    version="RedHat Enterprise Linux 7"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}7.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}7.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_rhel6 {
    version="RedHat Enterprise Linux 6"

    if [[ $is64bit -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}6.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
    startcmd="/sbin/service nessusagent start"
}

function populate_fedora {
    version="Fedora"
    file=NessusAgent-fc${FCVER}.x86_64.rpm
    cmd="rpm -Uvh --force $file"
}

function populate_ubuntu {
    version="Ubuntu"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-ubuntu1804_aarch64.deb
    elif [[ $is64bit -gt 0 ]]
    then
        file=NessusAgent-ubuntu1404_amd64.deb
    fi

    cmd="dpkg -i $file"

    if [[ ! -x /bin/systemctl ]]
    then
        startcmd="/etc/init.d/nessusagent start"
    fi
}

function populate_debian {
    version="Debian"

    if [[ $is64bit -gt 0 ]]
    then
        file=NessusAgent-debian10_amd64.deb
    else
        file=NessusAgent-debian10_i386.deb
    fi
    cmd="dpkg -i $file"

    if [[ ! -x /bin/systemctl ]]
    then
        startcmd="/etc/init.d/nessusagent start"
    fi
}

function populate_kali {
    version="Kali"

    if [[ $is64bit -gt 0 ]]
    then
        file=NessusAgent-debian10_amd64.deb
    else
        file=NessusAgent-debian10_i386.deb
    fi
    cmd="dpkg -i $file"

    if [[ ! -x /bin/systemctl ]]
    then
        startcmd="/etc/init.d/nessusagent start"
    fi
}

function populate_suse15 {
    version="SUSE Linux Enterprise 15"
    file=NessusAgent-suse15.x86_64.rpm
    cmd="rpm -Uvh --force $file"
}

function populate_suse12 {
    version="SUSE Linux Enterprise 12"
    file=NessusAgent-suse12.x86_64.rpm
    cmd="rpm -Uvh --force $file"
}

function populate_amazon_linux2 {
    version="Amazon Linux 2"

    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-amzn2.aarch64.rpm
    else
        file=NessusAgent-amzn2.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_alma_linux8 {
    version="AlmaLinux 8.6 (Sky Tiger)"
    
    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}8.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}8.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_alma_linux9 {
    version="AlmaLinux release 9.0 (Emerald Puma)"
    
    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}9.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}9.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_rocky_linux8 {
    version="Rocky Linux 8.6 (Green Obsidian)"
    
    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}8.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}8.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

function populate_rocky_linux9 {
    version="Rocky Linux 9.0 (Blue Onyx)"
    
    if [[ $aarch64 -gt 0 ]]
    then
        file=NessusAgent-${RHPREFIX}9.aarch64.rpm
    else
        file=NessusAgent-${RHPREFIX}9.x86_64.rpm
    fi

    cmd="rpm -Uvh --force $file"
}

if [[ $centos7 -gt 0 ]]
then
    populate_centos7
elif [[ $oracle9 -gt 0 ]]
then
    populate_oracle9
elif [[ $oracle8 -gt 0 ]]
then
    populate_oracle8
elif [[ $oracle7 -gt 0 ]]
then
    populate_oracle7
elif [[ $oracle6 -gt 0 ]]
then
    populate_oracle6
elif [[ $rhel9 -gt 0 ]]
then
    populate_rhel9
elif [[ $rhel8 -gt 0 ]]
then
    populate_rhel8
elif [[ $rhel7 -gt 0 ]]
then
    populate_rhel7
elif [[ $rhel6 -gt 0 ]]
then
    populate_rhel6
elif [[ $suse15 -gt 0 ]]
then
    populate_suse15
elif [[ $suse12 -gt 0 ]]
then
    populate_suse12
elif [[ $al2 -gt 0 ]]
then
    populate_amazon_linux2
elif [[ $fedora -gt 0 ]]
then
    populate_fedora
elif [[ $ubuntu -gt 0 ]]
then
    populate_ubuntu
elif [[ $debian -gt 0 ]]
then
    populate_debian
elif [[ $kali -gt 0 ]]
then
    populate_kali
elif [[ $alma8 -gt 0 ]]
then
    populate_alma_linux8
elif [[ $alma9 -gt 0 ]]
then
    populate_alma_linux9
elif [[ $rocky8 -gt 0 ]]
then
    populate_rocky_linux8
elif [[ $rocky9 -gt 0 ]]
then
    populate_rocky_linux9
fi

if [[ -z "$file" ]]
then
    echo "Unknown or unsupported OS."
    exit 1
fi

echo "Downloading Nessus Agent install package for $version."
response=$(curl -H "X-Key: $1" -s -w "%{http_code}" https://$SERVER/install/agent/installer/$file -o $file)

http_code=$(tail -n1 <<< "$response")
if [[ $http_code -ne 200 ]]
then
    echo "Could not download the installation package for Nessus Agent."
    exit 1
fi

echo "Installing Nessus Agent."
$cmd
RC=$?

rm -f $file

if [[ $RC -ne 0 ]]
then
    echo "Error installing Nessus Agent; exiting."
    exit 1
fi

echo "Applying auto-configuration."
echo $CONFIGURATION > /opt/nessus_agent/var/nessus/config.json

echo "Starting Nessus Agent."
output=$($startcmd 2>&1)

echo "Waiting for Nessus Agent to start and link..."
EFFECTIVE_CF=/opt/nessus_agent/var/nessus/.autoconfigure.json
ACF_ERRORS=/opt/nessus_agent/var/nessus/.autoconfigure.error
NESSUSCLI=/opt/nessus_agent/sbin/nessuscli

retries=50
tries=0
COMPLETE=0
ERRORS=0
while [ "$tries" -lt "$retries" ]
do
    if [ -e "$EFFECTIVE_CF" ]
    then
        echo
        echo "Auto-configuration complete."
        COMPLETE=1
        break
    fi

    echo -n "."
    tries=$(($tries+1))
    sleep 10
done

if [ -e "$ACF_ERRORS" ]
then
    ERRORS=1
fi

$NESSUSCLI fix --secure --get ms_server_ip 2>&1 1>/dev/null
RC=$?

if [ "$RC" -eq "0" ]
then
    echo "The Nessus Agent is now linked to $SERVER"
else
    echo "The Nessus Agent may have failed to link to $SERVER"
fi

if [ -e "$ACF_ERRORS" ]
then
    echo "There were errors during the autoconfiguration process: "
    cat $ACF_ERRORS
    echo
fi
