#!/bin/bash

for cluster in $(kubectx)
do
kubectx $cluster
kubectl rollout restart deployment -n kiam kiam-server
sleep 10
kubectl rollout restart daemonset -n kiam kiam-agent
done