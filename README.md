# Use ansible install k8s

施工中，未完成....

## 主流程

| 顺序 | 简单描述     | yaml             | 范围      | 说明                               |
| ---- | ------------ | ---------------- | --------- | ---------------------------------- |
| 1    | 主机名       | hostname.yaml    | cluster   | 修改主机名为清单内配置主机名       |
| 2    | 系统参数     | system_base.yaml | cluster   | 配置转发参数、关闭selinux、安装ntp |
| 3    | 防火墙       | firewalld.yaml   | cluster   | 关闭防火墙                         |
| 4    | 控制机器依赖 | control.yaml     | localhost | 安装`go` `cfssl` `ntp`             |
|      |              |                  |           |                                    |


### 当前进度

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
9. 安装 apiservice `install-kube-apiserver`
10. 配置kubectl访问apiserver


## 注意事项

- `playbook/tools` 目录下`py` `sh`文件需要有可执行权限
- 已测试的ansible版本`2.4`
- ./v1.8.2-kubernetes/server/bin/kubectl --server=https://192.168.40.10:6443 --certificate-authority=ca.pem --client-certificate=admin.pem --client-key=admin-key.pem get cs
