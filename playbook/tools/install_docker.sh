#!/bin/bash
# centos7 docker 1.12.x install
# for openshift origin
args2=$2
docker_version=${args2:='1.12.6'}

create_docker_storage(){
    set -e
    pvcreate $1
    vgcreate docker $1
    lvcreate --wipesignatures y -n thinpool docker -l 95%VG
    lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG
    lvconvert -y \
    --zero n \
    -c 512K \
    --thinpool docker/thinpool \
    --poolmetadata docker/thinpoolmeta

    cat > /etc/lvm/profile/docker-thinpool.profile<<EOF
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
    }
EOF

    lvchange --metadataprofile docker-thinpool docker/thinpool
    lvs -o+seg_monitor
    set +e
}


docker_config(){

#     cat >/etc/docker/daemon.json <<'EOF'
# {
#     "registry-mirrors": ["https://o9a5ub50.mirror.aliyuncs.com"],
#     "selinux-enabled": true,
#     "log-driver": "journald",
#     "insecure-registries": ["172.30.0.0/16"],
#     "storage-driver": "devicemapper",
#     "storage-opts": [
#     "dm.thinpooldev=/dev/mapper/docker-thinpool",
#     "dm.use_deferred_removal=true",
#     "dm.use_deferred_deletion=true"
#     ]
# }
# EOF

    cat >/etc/docker/daemon.json <<'EOF'
{
    "registry-mirrors": ["https://o9a5ub50.mirror.aliyuncs.com"]
}
EOF



# ---------------
    if [ ! -f /etc/sysconfig/docker ];then
        cat > /etc/sysconfig/docker <<'EOF'
OPTIONS="--log-driver=journald"

if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
EOF
    else
        t1=$(ls -l /etc/sysconfig/docker | awk '{print $5}')
        if [ ${t1} -eq 0 ];then
            rm -rf /etc/sysconfig/docker
            cat > /etc/sysconfig/docker <<'EOF'
OPTIONS="--log-driver=journald"

if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
EOF
        else
            sed -i '/OPTIONS=.*/c\OPTIONS="--log-driver=journald"' /etc/sysconfig/docker
        fi
    fi

    cat >/etc/sysconfig/docker-storage<<EOF
DOCKER_STORAGE_OPTIONS="--storage-driver devicemapper --storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt dm.use_deferred_removal=true --storage-opt dm.use_deferred_deletion=true"
EOF
# ------------
    systemctl restart docker && systemctl enable docker
}

install_docker(){

    rpm_install(){
        # yum-config-manager \
        # --add-repo \
        # https://docs.docker.com/v1.13/engine/installation/linux/repo_files/centos/docker.repo
        # yum makecache fast
        yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct 
        yum install -y device-mapper-persistent-data lvm2
        yum -y install docker-1.12.6
    }

    rpm -qa | grep  "docker-${docker_version}" -q
    if [ $? -ne 0 ];then
        rpm -qa | grep docker | xargs rpm -e
        rpm_install
    fi

}

if [ -z "$1" ];then
    echo "need disk device"
    echo "eg: /dev/sdb"
    exit 1
fi

install_docker

if [ -b /dev/mapper/docker-thinpool ];then
    echo installed
else
    create_docker_storage $1
fi

docker_config
