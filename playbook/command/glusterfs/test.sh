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


kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-f48vw -- heketi-cli -s http://localhost:8080 --user admin --secret '' setup-openshift-heketi-storage --listfile=/tmp/heketi-storage.json

kubectl -n glusterfs exec -i deploy-heketi-7c4898d9cd-f48vw -- cat /tmp/heketi-storage.json | kubectl -n glusterfs create -f -

# wait

kubectl -n glusterfs label --overwrite svc heketi-storage-endpoints glusterfs=heketi-storage-endpoints heketi=storage-endpoints
kubectl -n glusterfs delete all,service,jobs,deployment,secret --selector="deploy-heketi"

kubectl -n ${ns}  create -f heketi-deployment.yaml
# ---

heketi_pod=$(kubectl -n ${ns} get pod --no-headers --show-all --selector="heketi" | awk '{print $1}')
heketi_service=$(kubectl -n ${ns}  describe svc/heketi | grep "Endpoints:" | awk '{print $2}')

s=$(kubectl -n ${ns} exec -i "${heketi_pod}" -- curl http://${heketi_service}/hello)
[ ${s} != "Hello from Heketi" ] && exit

kubectl create -f glusterfs-storageclass.yaml