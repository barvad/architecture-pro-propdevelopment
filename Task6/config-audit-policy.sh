#!/bin/bash

minikube delete

minikube start --force \
  --driver=docker \
  --container-runtime=docker \
  --extra-config=kubelet.cgroup-driver=cgroupfs \
  --mount \
  --mount-string="$(pwd):/etc/kubernetes/audit" \
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/var/log/kubernetes/audit/audit.log \
  --extra-config=apiserver.audit-log-maxage=7 \
  --extra-config=apiserver.audit-log-maxbackup=10 \
  --extra-config=apiserver.audit-log-maxsize=100
