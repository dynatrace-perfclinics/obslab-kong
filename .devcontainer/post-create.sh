#!/bin/bash

CREATE_CLUSTER_WAIT=300s
OTEL_DEMO_VERSION=0.32.3

####################################
# Note:
# The following are "magic" env vars, set automatically by GitHub
# - $CODESPACE_NAME
# - $GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN
#
# The following are set as env vars when the user enters their "secret values" via the form when they spin up the codespace
# - $DT_ENDPOINT_OBSLAB_KONG
# - $DT_API_TOKEN__OBSLAB_KONG
#
# Use `printenv` to see all env vars.
# TODO: Move towards the user supplying a single API token (which has permissions to create other API tokens) to make codespace setup simpler
# Although the tradeoff here is clarity for the user as to what's actually happening (too much magic?) Will need to be explained in the docs.
####################################

# Replace placeholders in helm-values.yaml with realtime values
sed -i "s,CODESPACE_NAME_PLACEHOLDER,$CODESPACE_NAME," .devcontainer/otel-demo/helm-values.yaml
sed -i "s,GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN_PLACEHOLDER,$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN," .devcontainer/otel-demo/helm-values.yaml
# Replace placeholders in dynakube.yaml with realtime values
sed -i "s,CODESPACE_NAME_PLACEHOLDER,$CODESPACE_NAME," .devcontainer/dynatrace/dynakube.yaml
sed -i "s,DT_ENDPOINT_PLACEHOLDER,$DT_ENDPOINT_OBSLAB_KONG," .devcontainer/dynatrace/dynakube.yaml

# Create Cluster
kind create cluster --config .devcontainer/kind-cluster.yaml --wait $CREATE_CLUSTER_WAIT

# Store DT Details in a secret (used by OTEL collector for data ingest)
kubectl create secret generic dt-details --from-literal=DT_ENDPOINT_OBSLAB_KONG=$DT_ENDPOINT_OBSLAB_KONG --from-literal=DT_API_TOKEN_OBSLAB_KONG=$DT_API_TOKEN_OBSLAB_KONG

# Install Dynatrace Operator + ActiveGate
#   Note: Data Ingest token only has metrics.ingest permission
#     So re-use DT_API_TOKEN_OBSLAB_KONG instead of asking users for yet another token
kubectl create namespace dynatrace
kubectl -n dynatrace create secret generic $CODESPACE_NAME --from-literal=apiToken=$DT_OPERATOR_TOKEN_OBSLAB_KONG --from-literal=dataIngestToken=$DT_API_TOKEN_OBSLAB_KONG
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --namespace dynatrace --atomic
kubectl apply -f .devcontainer/dynatrace/dynakube.yaml

# Add OTEL demo using Helm
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm install my-otel-demo open-telemetry/opentelemetry-demo --values .devcontainer/otel-demo/helm-values.yaml --version $OTEL_DEMO_VERSION

# Install kong control plane
# Ref: https://docs.konghq.com/gateway/3.7.x/install/kubernetes/proxy/?install=oss
helm repo add kong https://charts.konghq.com
helm repo update
kubectl create namespace kong
kubectl create secret generic kong-enterprise-license --from-literal=license="'{}'" -n kong
openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout ./tls.key -out ./tls.crt -days 1095 -subj "/CN=kong_clustering"
kubectl create secret tls kong-cluster-cert --cert=./tls.crt --key=./tls.key -n kong
# Remove sensitive files - no longer needed
rm tls.crt tls.key
helm install kong-cp kong/kong -n kong --values /workspaces/obslab-kong/.devcontainer/kong/values-cp.yaml

# Install kong data plane
helm install kong-dp kong/kong -n kong --values /workspaces/obslab-kong/.devcontainer/kong/values-dp.yaml