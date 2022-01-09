#!/bin/bash

# script for patching imgpkg image tags within your statefulsets
# this example uses Postgres imgpkg as the example
# remember to replace with your registry URL the path to your imgpkg bundles
# you can find the path by describing the statefulset 

for ns in $(kubectl get ns)
do 
kubectl delete -n $ns $(kubectl get statefulsets -n $ns -o name | grep "postgres") && 
kubectl patch -n $ns --type='merge' -p 
"{\"spec\":{\"fetch\":[{\"imgpkgBundle\":{\"image\":\"<replace-me-registry-url/imgpkg/charts/postgresql-ha:8.0.0\"}}]}}" 
$(kubectl get -n $ns app -o name | grep postgresql)
done