#!/bin/bash

for cluster in $(kubectx)
do
kubectx $cluster
kubectl rollout restart deployment -n kiam kiam-server
sleep 10 #allows time for the kiam servers to come up before restarting the agents
kubectl rollout restart daemonset -n kiam kiam-agent
done