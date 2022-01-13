# kubernete-scripts
Repository for bash and python scripts in a kubernetes environment


## NODE-ROLES SCRIPT

Prerequisites:
  - kubectl installed where the script will be ran
  - kubectx installed for changing contexts

This script checks every cluster within your kubernetes environment for nodes that have no roles assigned to them. There will be instances where the nodes did not get assigned a role properly such as control-plane, master, or worker. This script helps identify which nodes have no assigned roles quickly.

- This script may be modified to print out nodes with specific roles by changing the grep commands from "none" to desired keyword such as worker. Then edit the echo command to state "This node has a worker role: " $node. 

OUTPUT if all the nodes have been properly assigned a role:
```
> ./node-roles.sh
Getting nodes from each cluster and putting them in a file called nodes
nodes file saved
All nodes have assigned roles
```

## KIAM KILLER SCRIPT

Prerequisites:
  - kubectl installed where the script will be ran
  - kubectx installed for changing contexts

This script loops through each cluster and does a rolling restart on each kiam deployment and daemonset. This gracefully restarts kiam server pods and kiam agent pods.

## KAPP-CONTROLLER & CALICO HEALTH SCRIPTS

Prerequisites:
  - kubectl installed where the script will be ran
  - kubectx installed for changing contexts

These scripts check for kapp-controller and calico pods that are *not* in a *Running* state respectfully. This allows to quickly identify which cluster has any of these pods in a bad state for troubleshooting.

## IMGPKG PATCH SCRIPT

This script is a template you can use to quickly patch the reference to a imgpkg bundle. In this example we are patching postgres statefulset reference to a new bundle with a tag of 8.0.0 

## BAD CONTOUR PODS SCRIPT

A simple script to check for contour/envoy pods in a bad state and if so it will restart those pods. 

## DELETE STALE GITLAB RUNNERS PYTHON SCRIPT

Prerequisites:
  - python3
  - import gitlab
  - import argparse
  - import datetime
  - update gl variable within the script to your gitlab URL

This script deletes stale unused Gitlab runners that can accumulate over time. 

Usage:
```
python3 delete-runners.py <your personal access token> -g <group id> --stale_date <example 2021-07-25>
```

# GENERATE KUBECONFIG AUTOMATION SCRIPT

Prerequisites:
  - kubectl installed where the script will be ran

Within the folder generate-kubeconfig you will find two scripts. The main one to run is kubeconfig-script.sh and the helper script is generate-kubeconfig.sh which runs through each namespace and creates a kubeconfig for each one. This is useful if you are trying to automate the process of getting an application into Production. Part of the path to production for an app team is generating their kubeconfig and automating this process saves valuable time. You can turn these into a CI job within your pipeline. 

## CLOUDFORMATION CLAMAV SCANNING S3 BUCKETS

Prerequisites:
  - AWS Console access
  - Cloudformation access
  - IAM admin access

There is two files in the cloudformation folder ( clamAV-S3-buckets.yaml & s3-buckets-to-scan.yaml ). This is Infrastructure as Code (IaC) to automate building AWS resources for clamAV bucket, lambda, IAM roles and policies along with a test bucket to test the the scanning policies. Use this as a template to get you started creating these resources. You will need additional zip files for the clamAV lambda to function properly which you can find within the clamAV documentation. This specific s3 testapp bucket will have a policy to scan for INFECTED files. You can set up Cloudwatch eventbridge and SNS for alerting. 

## SPIFFE FOLDER

Prerequisites:
  - Minikube (Mac Docker Desktop)
  - Kubectl

This folder is a simple script to quickly install SPIFFE server and agents in your local environment using minikube. This is strictly for you to install and play around with the configs if you decide to use it in a production environment in the future. SPIFFE is an identity framework and the provided script git clones the repo and changes directory to the directory needed to quick start. Then all the kubernetes resourses will be installed and ready to start playing around with!

## CLUSTERBUILDER PUSH SCRIPT

Prerequisites:
  - imgpkg installed
  - vendir installed
  - kbld installed

This script is a template if you want to imgpkg a bundle that does NOT pull from upstream but rather bundling a set of directories together into one single bundle that can be referenced in code somewhere else. This script will update your tag and give a couple options to push the image to image repositories (such as Harbor and AWS container registry). An example of a directory path you would want to bundle:
```
  - clusterbuilder/
    - bundle/
      - .imgpkg/images.yaml
      - clusterbuilder/
        - common/
          - global-values.yaml
          - kapp-config.yaml          
          - kbld-config.yaml
      - sample/fake-values.yaml
      - current-version.yaml
      - vendir.lock.yaml
      - vendir.yaml
```