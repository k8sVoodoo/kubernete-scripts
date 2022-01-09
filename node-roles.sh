#!/bin/bash
set -e

echo "Getting nodes from each cluster and putting them in a file called nodes"

for cluster in $(kubectx)
do
	kubectx $cluster
	kubectl get node
done > nodes

echo "nodes file saved"

FILE="nodes"
STATUS="$(echo $(grep -c "<none>" $FILE))"

if [ $STATUS -gt 1 ]
then
   for node in $(cat nodes | grep "<none>" | awk '{print $1}')
     do
	     echo "This node has no role: " $node
    done
else
    echo "All nodes have assigned roles"
fi