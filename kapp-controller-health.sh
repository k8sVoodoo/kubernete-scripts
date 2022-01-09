#!/bin/bash

# Checks if any kapp-controller pods are not in a Running state

for cluster in $(kubectx) 
do 
kubectx $cluster 
kubectl get po -n kapp-controller | grep kapp-controller | awk '$3 != "Running"'
done