1.
Take a backup of the etcd cluster and save it to /tmp/etcd-backup.db

export ETCDCTL_API=3

etcdctl version

vi /etc/kubernetes/manifests/etcd.yaml

etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /tmp/etcd-backup.db
    
etcdctl --endpoints=https://[127.0.0.1]:2379 \
	--cacert=/etc/kubernetes/pki/etcd/ca.crt\
	 --cert=/etc/kubernetes/pki/etcd/server.crt \
	 --key=/etc/kubernetes/pki/etcd/server.key \
	 snapshot status -w table /tmp/etcd-backup.db

2.
Create a Pod called redis-storage with image: redis:alpine with a Volume of type emptyDir that lasts for the life of the Pod. Specs on the right.
Pod named 'redis-storage' created
Pod 'redis-storage' uses Volume type of emptyDir
Pod 'redis-storage' uses volumeMount with mountPath = /data/redis


vi e.yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis-storage
spec:
  containers:
  - image: redis:alpine
    name: redis-container
    volumeMounts:
    - mountPath: /data/redis
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}

kubectl apply -f e.yaml


3.
Create a new pod called super-user-pod with image busybox:1.28. Allow the pod to be able to set system_time
The container should sleep for 4800 seconds
Pod: super-user-pod
Container Image: busybox:1.28
SYS_TIME capabilities for the conatiner?

vi i.yaml

apiVersion: v1
kind: Pod
metadata:
  name: super-user-pod
spec:
  containers:
  - name: sec-ctx-4
    image: busybox:1.28
    command: ['sleep', "4800"]
    securityContext:
      capabilities:
        add: ["SYS_TIME"]

kubectl apply -f i.yaml


4.
A pod definition file is created at /root/use-pv.yaml. Make use of this manifest file and mount the persistent volume called pv-1. Ensure the pod is running and the PV is bound.
mountPath: /data persistentVolumeClaim Name: my-pvc
persistentVolume Claim configured correctly
pod using the correct mountPath
pod using the persistent volume claim?


kubectl get pv

vi use-pvc.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
      
kubectl apply -f use-pvc.yaml 
kubectl get pvc

vi use-pv.yaml
apiVersion: v1
kind: Pod
metadata:
  name: use-pv
  labels:
    run: use-pv
spec:
  containers:
    - name: use-pv
      image: nginx
      volumeMounts:
      - mountPath: "/data"
        name: pv-1
  volumes:
    - name: pv-1
      persistentVolumeClaim:
        claimName: my-pvc
 kubectl apply -f use-pv.yaml       


5.
Create a new deployment called nginx-deploy, with image nginx:1.16 and 1 replica. Record the version. Next upgrade the deployment to version 1.17 using rolling update. Make sure that the version upgrade is recorded in the resource annotation.
Deployment : nginx-deploy. Image: nginx:1.16
Image: nginx:1.16
Task: Upgrade the version of the deployment to 1:17
Task: Record the changes for the image upgrade

kubectl create deployment nginx-deploy --image=nginx:1.16
kubectl get deployment.
kubectl scale --replicas=1 deployment nginx-deploy --record
kubectl rollout history deployment nginx-deploy
kubectl set image deployment nginx-deploy nginx=nginx:1.17 --record
kubectl rollout history deployment nginx-deploy

6.
Create a new user called john. Grant him access to the cluster. John should have permission to create, list, get, update and delete pods in the development namespace . The private key exists in the location: /root/john.key and csr at /root/john.csr
CSR: john-developer Status:Approved
Role Name: developer, namespace: development, Resource: Pods
Access: User 'john' has appropriate permissions

kubectl api-versions | grep certifi

vi c.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: john-developer
spec:
  request: $(cat john.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth

kubectl apply -f c.yaml

kubectl get csr
kubectl certificate approve john-developer


kubectl create role developer --verb=get,create,list,update,delete --resource=pods -n development
kubectl create rolebinding developer-rb --role=developer --user=john -n development

kubectl describe -n development rolebindings developer-rb

kubectl auth can-i update pods --as=john -n development
kubectl auth can-i watch pods --as=john -n development


7.
Create an nginx pod called nginx-resolver using image nginx, expose it internally with a service called nginx-resolver-service. Test that you are able to look up the service and pod names from within the cluster. Use the image: busybox:1.28 for dns lookup. Record results in /root/nginx.svc and /root/nginx.pod
Pod: nginx-resolver created
Service DNS Resolution recorded correctly
Pod DNS resolution recorded correctly

kubectl run --generator=run-pod/v1 nginx-resolver --image=nginx 
kubectl expose pod/nginx-resolver --name=nginx-resolver-service --port=80 --type=ClusterIP 

kubectl run --generator=run-pod/v1 nginx-resolver-test --image=busybox:1.28 --rm -it -- nslookup nginx-resolver-service > /root/nginx.svc
kubectl get pod -o wide
kubectl run --generator=run-pod/v1 nginx-resolver-test --image=busybox:1.28 --rm -it -- nslookup 10-244-1-10-default.pod > /root/nginx.pod


8. Create a static pod on node01 called nginx-critical with image nginx. Create this pod on node01 and make sure that it is recreated/restarted automatically in case of a failure.
Use /etc/kubernetes/manifests as the Static Pod path for example.
Kubelet Configured for Static Pods
Pod nginx-critical-node01 is Up and running


systemctl status kubelet
--config=/var/lib/kubelet/config.yaml

cat /var/lib/kubelet/config.yaml | grep staticPodPath

kubectl run nginx-critical --image=nginx --generator=run-pod/v1 --dry-run=client -o yaml > static-1.yaml

cat static-1.yaml

ssh node01

mkdir -p /etc/kubernetes/manifests
vi /etc/kubernetes/manifests/static-1.yaml

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx-critical
  name: nginx-critical
spec:
  containers:
  - image: nginx
    name: nginx-critical

docker ps | grep nginx-critical

ssh master

kubectl get pods






