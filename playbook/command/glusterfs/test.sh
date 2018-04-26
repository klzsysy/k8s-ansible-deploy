ns=glusterfs
kubectl -n ${ns} create -f kube-templates/heketi-service-account.yaml

kubectl -n ${ns} create clusterrolebinding heketi-sa-view --clusterrole=edit --serviceaccount=${ns}:heketi-service-account

kubectl -n ${ns} label --overwrite clusterrolebinding heketi-sa-view glusterfs=heketi-sa-view heketi=sa-view

kubectl label nodes k8s-04.k8s.local storagenode=glusterfs --overwrite
kubectl label nodes k8s-05.k8s.local storagenode=glusterfs --overwrite
kubectl label nodes k8s-06.k8s.local storagenode=glusterfs --overwrite


kubectl -n ${ns} create -f  kube-templates/glusterfs-daemonset.yaml


kubectl -n ${ns} create secret generic heketi-config-secret --from-file=private_key=/dev/null --from-file=./heketi.json --from-file=topology.json=topology.json
kubectl -n ${ns} label --overwrite secret heketi-config-secret glusterfs=heketi-config-secret heketi=config-secret

# ----
kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-f48vw -- heketi-cli -s http://localhost:8080 --user admin --secret '' topology load --json=/etc/heketi/topology.json | tee status_file
 grep -q "Unable" status_file && exit 

### kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-f48vw -- heketi-cli -s http://localhost:8080 --user admin --secret '' setup-openshift-heketi-storage --listfile=/tmp/heketi-storage.json
kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-f48vw -- cat /tmp/heketi-storage.json | kubectl -n glusterfs create -f -

# wait

kubectl -n glusterfs label --overwrite svc heketi-storage-endpoints glusterfs=heketi-storage-endpoints heketi=storage-endpoints
kubectl -n glusterfs delete all,service,jobs,deployment,secret --selector="deploy-heketi"

echo kube-templates/deploy-heketi-deployment.yaml | kubectl -n ${ns} create -f - 2>&1
kubectl -n glusterfs get pods --no-headers --show-all --selector=deploy-heketi=pod

kubectl -n glusterfs describe svc/deploy-heketi
heketi_service=10.244.1.12:8080
heketi_pod=deploy-heketi-7c4898d9cd-72788

kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-72788 -- curl http://10.244.1.12:8080/hello

kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-72788 -- heketi-cli -s http://localhost:8080 --user admin --secret ''
kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-72788 -- heketi-cli -s http://localhost:8080 --user admin --secret '' topology load --json=/etc/heketi/topology.json





kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-qfs2g -- heketi-cli -s http://localhost:8080 --user admin --secret '' topology load --json=/etc/heketi/topology.json