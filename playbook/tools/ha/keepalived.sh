#!/bin/bash
# install keepalived in host group

inventory=${inventory:="../../../inventory"}


pre_check(){
    which nslookup &>/dev/null || yum install -y bind-utils
    if [ "${drect}" == "on" ];then
        return 0
    fi
    mkdir -p  rpm
    ls -l ./rpm/keepalived*.rpm &>/dev/null && return 0 || \
    yum install  -y keepalived --downloadonly --downloaddir=./rpm
    ls -l ./rpm/keepalived*.rpm &>/dev/null || exit 1
}

install_rpm_to_host_group(){
    if [ "${drect}" == "on" ];then
        ansible -i ${inventory} ${host_group} -m shell -a 'yum install -y keepalived'
    else
        ansible -i ${inventory}  ${host_group} -m copy -a 'src=./rpm dest=/tmp/'
        ansible -i ${inventory}  ${host_group} -m shell -a 'yum -y localinstall /tmp/rpm/*.rpm && rm -rf /tmp/rpm/'
    fi
    ansible -i ${inventory}  ${host_group} -m copy -a 'src=./check_haproxy.sh dest=/etc/keepalived/'
    ansible -i ${inventory}  ${host_group} -m shell -a 'chmod a+x /etc/keepalived/check_haproxy.sh'
}

configure_keepalived(){
    for host in $(ansible -i ${inventory}  ${host_group} --list-hosts | tail -n +2)
    do
        out=$(nslookup ${host})
        if [ $? -eq 0 ];then
            host_ip=$(echo "${out}" | tail -n 1 | tr -d "Address: ")
            cat "keepalived.conf" | sed "s/VIP/${vip}/g" | sed "s/INT/${interface}/g" | \
            ssh root@${host} 'cat > /etc/keepalived/keepalived.conf'
        else
            echo "Error! not nslookup ${host}"
            exit 1
        fi
    done
    ansible -i ${inventory}  ${host_group} -m shell -a 'systemctl restart keepalived && systemctl enable keepalived'
}

helper(){
    cat <<'EOF'
Usage:
    nstall:
    ./keepalived.sh install host    network interface       virtual ip      Direct rpm install
    ./keepalived.sh [host_group]    [interface]             [vip]             <on>
    ./keepalived.sh  masters        eth0                    10.0.0.1

    uninstall:
    ./keepalived.sh  CLEAR [host_group]
    
EOF
    exit 1
}

clear(){
    ansible -i ${inventory} $1 -m shell -a 'rpm -qa | grep keepalived | xargs rpm -e'
        ansible -i ${inventory} $1 -m shell -a 'rm -rf /etc/keepalived/'
    exit $?
}


start(){
    pre_check
    install_rpm_to_host_group
    configure_keepalived
}


host_group=$1
interface=$2
vip=$3
drect=$4

# 卸载
if [ "${host_group}" == "CLEAR" -a -n "${interface}" ];then
    clear "${interface}"
fi

# 参数检查
if [ -z "$host_group" -o -z "${vip}" -o -z "${interface}" ];then
    helper
fi



# 安装
start
