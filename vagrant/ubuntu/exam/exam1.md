1 / 12
Deploy a pod named nginx-pod using the nginx:alpine image.

kubectl run nginx-pod --image=nginx:alpine

2 / 12
Deploy a messaging pod using the redis:alpine image with the labels set to tier=msg.

kubectl run messaging --image=redis:alpine -l tier=msg


3 / 12
Create a namespace named apx-x9984574

vi n.yaml
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "apx-x9984574",
    "labels": {
      "name": "apx-x9984574"
    }
  }
}

kubectl apply -f n.yaml

4 / 12
Get the list of nodes in JSON format and store it in a file at /opt/outputs/nodes-z3444kd9.json

kubectl get nodes -o json > /opt/outputs/nodes-z3444kd9.json


5 / 12
Create a service messaging-service to expose the messaging application within the cluster on port 6379.

kubectl expose pod messaging --type=ClusterIP --name=messaging-service --port=6379

6 / 12
Create a deployment named hr-web-app using the image kodekloud/webapp-color with 2 replicas

kubectl create deployment hr-web-app --image=kodekloud/webapp-color
kubectl scale --replicas=2 deployment hr-web-app


vi d.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hr-web-app
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: kodekloud/webapp-color
        ports:
        - containerPort: 80

kubectl -f d.yaml


7 / 12
Create a static pod named static-busybox on the master node that uses the busybox image and the command sleep 1000

vi /etc/kubernetes/manifests/static-busybox.yaml

apiVersion: v1
kind: Pod
metadata:
  name: static-busybox
  labels:
    app: busybox
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 1000']

kubectl apply -f /etc/kubernetes/manifests/static-busybox.yaml

$ kubectl run static-busybox --image=busybox --generator=run-pod/v1 --dry-run -o yaml --command -- sleep 1000 > static-busybox.yaml


8 / 12
Create a POD in the finance namespace named temp-bus with the image redis:alpine.

vi n1.yaml
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "finance",
    "labels": {
      "name": "finance"
    }
  }
}

kubectl apply -f n1.yaml

kubectl run temp-bus --image=redis:alpine -n finance
kubectl run temp-bus --image=edis:alpine --generator=run-pod/v1 -n finance


9 / 12
A new application orange is deployed. There is something wrong with it. Identify and fix the issue.



10 / 12
Expose the hr-web-app as service hr-web-app-service application on port 30082 on the nodes on the cluster
Name: hr-web-app-service
Type: NodePort
Endpoints: 2
Port: 8080
NodePort: 30082

kubectl expose deployment hr-web-app --type=NodePort --port=8080 --name=hr-web-app-service --dry-run=client -o yaml > s3.yaml
vi s3.yaml
Then edit the nodeport in it and create a service
kubectl apply -f s3.yaml

11 / 12
Use JSON PATH query to retrieve the osImages of all the nodes and store it in a file /opt/outputs/nodes_os_x43kj56.txt

kubectl get nodes -o=jsonpath='{.items[*].status.nodeInfo.osImage}' > /opt/outputs/nodes_os_x43kj56.txt

12 / 12
Create a Persistent Volume with the given specification.
* Volume Name: pv-log   
* Storage: 100Mi   
* Access modes: ReadWriteMany   
* Host Path: /pv/log   

vi pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-analytics
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /pv/log  

k apply -f pv.yaml


