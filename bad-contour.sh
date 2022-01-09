#!/bin/bash

# Checking to see if there are any bad contour/envoy pods and if so delete those pods

for cluster in $(kubectx)
do
kubectx $cluster
    for bad_contour in $(kubectl get pods -n contour --no-headers | grep envoy | awk '{print $1}')
    do
        kubectl delete pod -n contour $bad_contour --now
    done
done