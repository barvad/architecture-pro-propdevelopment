#!/bin/bash

mkdir -p ~/k8s-audit && cp audit-policy.yaml ~/k8s-audit/
cd ~/k8s-audit

minikube start \
  --mount \
  --mount-string="$HOME/k8s-audit:/etc/kubernetes/audit" \
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/var/log/audit.log \
  --extra-config=apiserver.audit-log-maxage=7 \
  --extra-config=apiserver.audit-log-maxbackup=10 \
  --extra-config=apiserver.audit-log-maxsize=100
