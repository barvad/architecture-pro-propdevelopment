minikube start `
  --driver=hyperv `
  --hyperv-virtual-switch="Default Switch" `
  --kubernetes-version=v1.29.4 `
  --mount `
  --mount-string="C:\repos\architecture-pro-propdevelopment\Task6:/etc/kubernetes/audit" `
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml `
  --extra-config=apiserver.audit-log-path=/var/log/audit.log