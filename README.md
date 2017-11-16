# 高可用kubernetes部署

```sh
./v1.8.2-kubernetes/server/bin/kubectl --server=https://192.168.40.10:6443 --certificate-authority=ca.pem --client-certificate=admin.pem --client-key=admin-key.pem get cs
