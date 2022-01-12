#!/bin/bash

git clone https://github.com/spiffe/spire-tutorials
cd spire-tutorials/k8s/quickstart
minikube start \
    --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
    --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
    --extra-config=apiserver.service-account-issuer=api \
    --extra-config=apiserver.service-account-api-audiences=api,spire-server \
    --extra-config=apiserver.authorization-mode=Node,RBAC

echo "Are you running this within the quickstart folder?"

echo "Creating the spire namespace"
kubectl apply -f spire-namespace.yaml

echo "Configuring SPIRE Server"
kubectl apply \
    -f server-account.yaml \
    -f spire-bundle-configmap.yaml \
    -f server-cluster-role.yaml

echo "Creating Server ConfigMap"
kubectl apply \
    -f server-configmap.yaml \
    -f server-statefulset.yaml \
    -f server-service.yaml

echo "Configuring and deploying the SPIRE agent"
kubectl apply \
    -f agent-account.yaml \
    -f agent-cluster-role.yaml
sleep 5
kubectl apply \
    -f agent-configmap.yaml \
    -f agent-daemonset.yaml

echo "Registering Workloads"
# new registration entry for the node
kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s_sat:cluster:demo-cluster \
    -selector k8s_sat:agent_ns:spire \
    -selector k8s_sat:agent_sa:spire-agent \
    -node
# new registration for workload
kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/default/sa/default \
    -parentID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s:ns:default \
    -selector k8s:sa:default

echo "Configure container called client to access SPIRE in the default namespace"
kubectl apply -f client-deployment.yaml


# testing
echo "To test exec into the pod and run: kubectl exec -it $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' \
   -l app=client)  -- /bin/sh"

echo "Then: /opt/spire/bin/spire-agent api fetch -socketPath /run/spire/sockets/agent.sock"
echo "You should see a list of SVID if the agent is running"