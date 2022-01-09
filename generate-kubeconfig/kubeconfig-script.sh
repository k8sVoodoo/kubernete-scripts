#!/bin/bash

for x in $( kubectl get ns  --no-headers -o custom-columns=":metadata.name")
do
bash generate-kubeconfigs.sh $x
done