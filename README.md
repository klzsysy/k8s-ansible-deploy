# Ansible Install k8s

使用ansible部署基于二进制安装的kubernetes集群

当前已测试k8s版本 `v1.9.7`

### 安装流程

1. 修改主机名  `hostname.yaml`
2. 安装基本依赖 `system_base.yaml`
3. 关闭防火墙 `firewalld.yaml`
4. 安装安装机器依赖 `control.yaml`
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
17. 部署k8s dashboard和Kong Api Gateway `deploy-kubernetes-dashboard.yaml` `deploy-kong-api-gateway.yaml`


## 必要准备

- 至少准备三个以上节点，并且能相互正确解析主机名， dns或者host文件均可
- 安装机器能ssh免密登录各主机
- 一个虚拟ip，作为apiserver高可用ip，可以是硬件负载器提供，也可以是由两台以上机器提供，自动安装keepalived + haproxy
- 所有的机器需要可以访问互联网(下载rpm、sync time、下载k8s二进制文件)
- 修改inventory文件以匹配自己的环境，该文件内有详细说明

###  开始运行

`ansible-playbook -i inventory playbook/command/install-k8s-cluster.yaml -vv`

> 也可以单独运行流程中的单个playbook

## 注意事项
- 已测试的ansible版本`2.5`
- inventory文件的变量不可缺失，因为没有单独设定默认值
- 控制机器与目标机器要相同的系统版本
- 仅支持redhat系列操作系统
- 所有镜像已换成国内可以直接访问的地址，其中二进制文件可能会下载失败，具体解决参考inventory文件

## issue

- 离线安装未完成
