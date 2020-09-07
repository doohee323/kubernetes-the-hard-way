kubectl get po nginx -o yaml --export

kubectl delete po nginx --grace-period=0 --force

kubectl get po nginx -w # watch it

# If pod crashed check the previous logs of the pod
kubectl logs busybox -p

kubectl run busybox --image=busybox -- /bin/sh -c "sleep 3600"

kubectl run busybox --image=busybox -it -- sh
kubectl run busybox --image=busybox --rm -it -- echo "How are you"

kubectl exec -it busybox -- wget -o- <IP Address>
kubectl exec -it busybox -- nc -z -v -w 2 10.1.1.1 80

kubectl get po -o=custom-columns="POD_NAME:.metadata.name, POD_STATUS:.status.containerStatuses[].state"

kubectl get pods --sort-by=.metadata.name

kubectl logs my-pod -c my-container

kubectl get pods -l env=dev --show-labels
kubectl get pods -l 'env in (dev,prod)' --show-labels


kubectl rollout undo deploy webapp --to-revision=3


kubectl rollout pause deploy webapp
kubectl rollout resume deploy webapp


kubectl autoscale deploy webapp --min=10 --max=20 --cpu-percent=85






