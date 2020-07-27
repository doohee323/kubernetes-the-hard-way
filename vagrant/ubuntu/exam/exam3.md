1. 
Create a new service account with the name pvviewer. Grant this Service account access to list all PersistentVolumes in the cluster by creating an appropriate cluster role called pvviewer-role and ClusterRoleBinding called pvviewer-role-binding.
Next, create a pod called pvviewer with the image: redis and serviceAccount: pvviewer in the default namespace
ServiceAccount: pvviewer
ClusterRole: pvviewer-role
ClusterRoleBinding: pvviewer-role-binding
Pod: pvviewer
Pod configured to use ServiceAccount pvviewer ?

=>

kubectl create serviceaccount pvviewer

kubectl get serviceaccount pvviewer

kubectl create clusterrole pvviewer-role --resource=persistentVolumes --verb=list

kubectl create clusterrolebinding pvviewer-role-binding --clusterrole=pvviewer-role --serviceaccount=default:pvviewer

kubectl run --generator=run-pod/v1 pvviewer --image=redis --dry-run=client -o yaml > p.yaml

vi p.yaml
serviceAccountName: pvviewer

kubectl apply -f p.yaml

kubectl describe pod/pvviewer

2.
List the InternalIP of all nodes of the cluster. Save the result to a file /root/node_ips
Answer should be in the format: InternalIP of master<space>InternalIP of node1<space>InternalIP of node2<space>InternalIP of node3 (in a single line)

=>

kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' > /root/node_ips


3.
Create a pod called multi-pod with two containers.
Container 1, name: alpha, image: nginx
Container 2: beta, image: busybox, command sleep 4800.
Environment Variables:
container 1:
name: alpha
Container 2:
name: beta
Pod Name: multi-pod
Container 1: alpha
Container 2: beta
Container beta commands set correctly?
Container 1 Environment Value Set
Container 2 Environment Value Set

=> 

kubectl run multi-pod --image=nginx --dry-run=client -o yaml > m.yaml

apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
spec:
  containers:
  - name: alpha
    image: nginx
    env:
    - name: name
      value: alpha
  - name: beta
    image: busybox
    command: ['sleep', '4800']
    env:
    - name: name
      value: beta
      
kubectl apply -f m.yaml 

4.
Create a Pod called non-root-pod , image: redis:alpine
runAsUser: 1000
fsGroup: 2000
Pod `non-root-pod` fsGroup configured
Pod `non-root-pod` runAsUser configured

=>

vi a.yaml

apiVersion: v1
kind: Pod
metadata:
  name: non-root-pod
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: sec-ctx-demo
    image: redis:alpine
    securityContext:
      allowPrivilegeEscalation: false

kubectl apply -f a.yaml 

5.
We have deployed a new pod called np-test-1 and a service called np-test-service. Incoming connections to this service are not working. Troubleshoot and fix it.
Create NetworkPolicy, by the name ingress-to-nptest that allows incoming connections to the service over port 80
Important: Don't delete any current objects deployed
Important: Don't Alter Existing Objects!
NetworkPolicy: Applied to All sources (Incoming traffic from all pods)?
NetWorkPolicy: Correct Port?
NetWorkPolicy: Applied to correct Pod?

=>

kubectl run busybox --image=busybox --rm -it -- sh
nc -z -v -w 2 np-test-service 80
nc: np-test-service (10.98.245.52:80): Connection timed out

kubectl get netpol
NAME           POD-SELECTOR   AGE
default-deny   <none>         10m

kubectl describe netpol default-deny


vi i.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-to-nptest
spec:
  podSelector:
    matchLabels:
      run: np-test-1
  policyTypes:
  - Ingress
  ingress:
  - from:
    ports:
    - protocol: TCP
      port: 80
      
kubectl apply -f i.yaml

6.
Taint the worker node node01 to be Unschedulable. Once done, create a pod called dev-redis, image redis:alpine to ensure workloads are not scheduled to this worker node. Finally, create a new pod called prod-redis and image redis:alpine with toleration to be scheduled on node01.
key:env_type, value:production, operator: Equal and effect:NoSchedule
Key = env_type
Value = production
Effect = NoSchedule
pod 'dev-redis' (no tolerations) is not scheduled on node01?
Create a pod 'prod-redis' to run on node01

=>

kubectl taint node node01 env_type=production:NoSchedule

kubectl run dev-redis --image=redis:alpine

kubectl get nodes -o wide

vi t.yaml
apiVersion: v1
kind: Pod
metadata:
  name: prod-redis
spec:
  containers:
  - name: redis
    image: redis:alpine
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "env_type"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
    
kubectl apply -f t.yaml


7.
Create a pod called hr-pod in hr namespace belonging to the production environment and frontend tier .
image: redis:alpine
Use appropriate labels and create all the required objects if it does not exist in the system already.
hr-pod labeled with environment production?
hr-pod labeled with frontend tier?

=>

kubectl create ns hr
kubectl -n hr run hr-pod --image=redis:alpine -l environment=production,tier=frontend
kubectl -n hr get pods --show-labels


8.
A kubeconfig file called super.kubeconfig has been created in /root. There is something wrong with the configuration. Troubleshoot and fix it.
Fix /root/super.kubeconfig

=> 
vi .kube/config

172.17.0.59:6443

vi /root/super.kubeconfig

kubectl cluster-info --kubeconfig=super.kubeconfig

9.
We have created a new deployment called nginx-deploy. scale the deployment to 3 replicas. Has the replica's increased? Troubleshoot the issue and fix it.
deployment has 3 replicas

=>

kubectl scale --replicas=3 deployment/nginx-deploy


k describe pod/kube-contro1ler-manager-master -n kube-system

vi /etc/kubernetes/manifests/kube-contro1ler-manager-master.yaml
contro1ler => controller 










