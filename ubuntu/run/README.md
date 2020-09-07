echo "1. check service"
kubectl describe service/nginx 
# IP:                       10.96.0.129
# NodePort:                 <unset>  31097/TCP
# Endpoints:                10.32.0.2:80

kubectl get all | grep service/nginx 
# service/nginx        NodePort    10.96.0.129   <none>        80:31097/TCP   13m

curl http://10.32.0.2:31097

echo "2. check pod"
kubectl get pod
kubectl describe pod/nginx-5c7588df-cszrz
kubectl logs pod/nginx-5c7588df-cszrz -f
kubectl logs pod/nginx-5c7588df-cszrz -f --previous

echo "3. control plane failure"
kubectl get nodes
kubectl get pods
kubectl get pods -n kube-system
service kube-apiserver status
service kube-controller-manager status
service kube-scheduler status
service kubelet status
service kube-proxy status
kubectl logs kube-apiserver-master -n kube-system
sudo journalctl -u kube-apiserver

echo "4. worker node"
kubectl get nodes
kubectl describe node worker-1
top
df -k
service kubelet status
sudo journalctl -u kubelet
openssl x509 -in /var/lib/kubelet/worker-1.crt -text

client-certi: /var/lib/kubelet/pki/kubelet-client-current.pem
client-key: /var/lib/kubelet/pki/kubelet-client-current.pem

Master Nodes
/var/log/kube-apiserver.log 
/var/log/kube-scheduler.log
/var/log/kube-controller-manager.log
Worker Nodes
/var/log/kubelet.log
/var/log/kube-proxy.log

https://kodekloud.com/courses/certified-kubernetes-administrator-with-practice-tests-labs/lectures/12038894

kubectl get nodes -o=jsonpath='{.items[*]}.metadata.name}{"\n"}{.items[*].status.capacity.cpu}'
=>
master  node01
4       4

kubectl get nodes -o=jsonpath='{range.items[*]}
    {.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}
{end}'
=>
master  4
node01  4

kubectl get nodes --sort-by=.status.capacity.cpu

kubectl get nodes -o=jsonpath='{.items[*].status.nodeInfo.osImage}'

kubectl config view --kubeconfig=/root/my-kube-config

kubectl config view --kubeconfig=/root/my-kube-config -o=jsonpath='{.users[*].name}'

kubectl get PersistentVolumes --sort-by=.spec.capacity.storage

kubectl get PersistentVolumes --sort-by=.spec.capacity.storage -o=custom-columns='NAME:metadata.name,CAPACITY:spec.capacity.storage'


--sort-by=.spec.capacity.storage -o=custom-columns='NAME:metadata.name,CAPACITY:spec.capacity.storage'


DEPLOYMENT CONTAINER_IMAGE READY_REPLICAS NAMESPACE


k get deployments -n admin2406 --sort-by=.metadata.name -o=custom-columns='NAME:metadata.name,CONTAINER_IMAGE:spec.template.spec.containers[*].image,READY_REPLICAS:status.availableReplicas,NAMESPACE:metadata.namespace' > /opt/admin2406_data

NAME:metadata.name,CONTAINER_IMAGE:spec.template.spec.containers[*].image,READY_REPLICAS:status.availableReplicas,NAMESPACE:metadata.namespace

items - name
status - availableRepricas

items - namespace
spec - template spec containers image

kubectl config view --kubeconfig=my-kube-config -o=jsonpath="{.users[*].name=='aws-user'}"

kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}"

