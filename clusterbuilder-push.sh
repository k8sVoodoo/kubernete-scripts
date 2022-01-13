#!/bin/bash

# This script does a vendir sync on a bundle directory (in this example we are bundling 
# clusterbuilder). This is imgpkg a bundle NOT from upstream. This is an example of packaging
# your own code into a bundle rather than pulling from upstream. The fake-values.yaml is only 
# if your environment has a VPC level that looks for git credentials when building clusters

# REPLACE everything with URL and URL2 with your own URLs
printf "\n What is the new tag? "
read TAG

vendir sync
ytt -f bundle/clusterbuilder/deploy --ignore-unknown-comments -f sample/fake-values.yaml \
| kbld -f - --imgpkg-lock-output bundle/.imgpkg/images.yml -f bundle/clusterbuilder/deploy/aws/clusters/common/_ytt_lib > sample/cluster-builder-${TAG}.yaml


printf "\n  1. Push to <URL>\n  2. Push to <URL2>\n\nPlease enter the number for which location you wish to push to:  "
read SELECT

if [[ $SELECT == 1 ]]; then
    printf "Pushing to <some URL>...\n\n"
    imgpkg push -b <URL>/imgpkg/charts/clusterbuilder:${TAG} -f bundle
elif [[ $SELECT == 2 ]]; then
    printf "Pushing to <some URL2...\n\n"
    imgpkg push -b <URL2>/imgpkg/charts/clusterbuilder:${TAG} -f bundle
else
    printf "Invalid selection.  Exiting.\n"
    return;
fi