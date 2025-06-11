#!/bin/bash

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.config.allow-snippet-annotations="true" \
  --version 4.9.1 \
  -f nginx-values.yaml

# kubectl edit configmap ingress-nginx-controller -n ingress-nginx

# apiVersion: v1
# data:
#   allow-snippet-annotations: "true"
#   hsts: "false"
# kind: ConfigMap

# kubectl delete po -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--allow-snippet-annotations=true"}]'

# kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args/5", "value": "--validating-webhook=false"}]'

# kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
