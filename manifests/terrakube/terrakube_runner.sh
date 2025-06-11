#!/bin/bash

helm upgrade --install terrakube terrakube-repo/terrakube \
  --namespace terrakube --create-namespace \
  -f terrakube-values-new.yaml



# helm uninstall terrakube -n terrakube