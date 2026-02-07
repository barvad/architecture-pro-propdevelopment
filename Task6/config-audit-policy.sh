#!/bin/bash



minikube start --force \
  --driver=none \
  --container-runtime=docker \
  --kubernetes-version=v1.29.4 \
  --extra-config=kubelet.cgroup-driver=cgroupfs \
  --mount \
  --mount-string="$(pwd):/etc/kubernetes/audit" \
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/etc/kubernetes/audit/udit.log \
  --extra-config=apiserver.audit-log-maxage=7 \
  --extra-config=apiserver.audit-log-maxbackup=10 \
  --extra-config=apiserver.audit-log-maxsize=100
