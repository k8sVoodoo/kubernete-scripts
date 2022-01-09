#!/bin/bash

# checks on calico pods and if any are not in a Running state

for cluster in $(kubectx)
do 
kubectx $cluster
kubectl get po -n kube-system | grep calico | awk '$3 != "Running"'
done