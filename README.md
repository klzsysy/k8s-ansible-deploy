# Ansible Install k8s

施工基本完成，待完善...


### 安装流程

1. 修改主机名  `hostname.yaml`
2. 安装基本依赖 `system_base.yaml`
3. 关闭防火墙 `firewalld.yaml`
4. 安装安装机器依赖 `control.yaml`
    1. go
    2. cfssl
    3. ntp
    4. unzip bind-utils
5. 下载二进制文件 `download_bin.yaml`
6. 安装 docker `install_docker.yaml`
7. 创建证书 `cert.yaml`
8. 安装etcd `install-etcd-cluster.yaml`
9. 安装 kube-apiserver `install-kube-apiserver.yaml`
10. 配置高可用虚拟ip `conf-lb-vip.yaml`
11. 配置kubectl访问apiserver `conf-kube-kubectl.yaml`
12. 配置kube-controller-manager `install-kube-controller-manager.yaml`
13. 配置kube-scheduler `install-kube-scheduler.yaml`
14. 配置kubelet kube-proxy `install-kube-node.yaml`
15. 配置flannel网络插件 `install-flannel-network.yaml`
16. 配置kube-dns `install-kube-dns.yaml`


## 必要准备

- 至少准备三个以上节点，并且能相互正确解析主机名， dns或者host文件均可
- 一个虚拟ip，作为apiserver高可用ip，可以是硬件负载器提供，也可以是由两台以上机器提供，自动安装keepalived + haproxy
- 所有的机器需要可以访问互联网(下载rpm、sync time、下载k8s二进制文件)

###  开始运行

`ansible-playbook -i inventory playbook/command/install-k8s-cluster.yaml -vv`

> 也可以单独运行流程中单个的playbook

## 注意事项
- 已测试的ansible版本`2.4`

## issue
- 每次运行均会重启docker
- 离线安装未完成
