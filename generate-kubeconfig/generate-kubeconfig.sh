#!/bin/bash

set -eu

if ! command -v kubectl > /dev/null; then
    echo -e "\nERROR: The kubectl CLI is required to run this helper script. Exiting."
    exit 1
fi

echo -e "\nINFO: Checking the current Kubernetes context..."
CONTEXT=$(kubectl config current-context)
CLUSTER_NAME=$(kubectl config view --minify --output=jsonpath='{.clusters[].name}')
echo "INFO: Current context is set to: ${CONTEXT}."

# No error checking at present. Just do the thing.
if [[ "${#}" -ne 1 ]]; then
    echo -en "\nPlease enter the service account name [ENTER]: "
    read SERVICE_ACCOUNT
else
    SERVICE_ACCOUNT="${1}"
fi

# Generally speaking, if you're using this script, the service account will be the same as the namespace
# This is largely to cover limited scope service accounts for TBS image builds and application namespaces
NAMESPACE="${2:-$SERVICE_ACCOUNT}"
SERVER=$(kubectl config view --minify --output=jsonpath='{.clusters[?(@.name == '\"${CLUSTER_NAME}\"')].cluster.server}')
SECRET=$(kubectl get secrets --namespace "${NAMESPACE}" | awk "/${SERVICE_ACCOUNT}-sa/"'{print $1}')
CA_CERT=$(kubectl get --namespace "${NAMESPACE}" "secret/${SECRET}" -o jsonpath='{.data.ca\.crt}')
TOKEN=$(kubectl get --namespace "${NAMESPACE}" "secret/${SECRET}" -o jsonpath='{.data.token}' | base64 --decode)
OUTPUT_FILE="${SERVICE_ACCOUNT}-kubeconfig.yaml"

echo -e "\nINFO: I'm writing out your new kubeconfig to: $(pwd)/${OUTPUT_FILE}"

cat << EOF > "${OUTPUT_FILE}"
---
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${SERVER}
contexts:
- name: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${SERVICE_ACCOUNT}
current-context: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${TOKEN}
EOF

echo -e "INFO: Dunzo."