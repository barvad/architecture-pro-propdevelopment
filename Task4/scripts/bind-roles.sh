#!/bin/bash

echo "Связывание пользователей с ролями в кластере Kubernetes PropDevelopment"
echo "========================================================================"

# Устанавливаем контекст администратора
kubectl config use-context minikube

# 1. Привязываем devops-engineer к cluster-admin-role (через группу cluster-admin)
echo "Привязываем devops-engineer к cluster-admin-role"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devops-engineer-admin-binding
subjects:
- kind: User
  name: devops-engineer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 2. Привязываем business-analyst к cluster-viewer-role (через группу viewer)
echo "Привязываем business-analyst к cluster-viewer-role"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: business-analyst-viewer-binding
subjects:
- kind: User
  name: business-analyst
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-viewer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 3. Привязываем security-auditor к cluster-auditor-role (через группу auditor)
echo "Привязываем security-auditor к cluster-auditor-role"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-auditor-audit-binding
subjects:
- kind: User
  name: security-auditor
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-auditor-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 4. Привязываем sales-developer к developer-role в sales-domain
echo "Привязываем sales-developer к developer-role в sales-domain"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sales-developer-binding
  namespace: sales-domain
subjects:
- kind: User
  name: sales-developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 5. Привязываем ci-cd-bot к ci-cd-role в sales-domain
echo "Привязываем ci-cd-bot к ci-cd-role в sales-domain"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ci-cd-bot-binding
  namespace: sales-domain
subjects:
- kind: User
  name: ci-cd-bot
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: ci-cd-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 6. Создаем примерного пользователя для housings-domain
echo "Создаем пример пользователя для housings-domain..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: housings-developer-binding
  namespace: housings-domain
subjects:
- kind: User
  name: sales-developer  # Тот же пользователь, но с правами в другом namespace
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 7. Создаем дополнительное RoleBinding для namespace администратора
echo "Создаем администратора для sales-domain..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sales-domain-admin-binding
  namespace: sales-domain
subjects:
- kind: User
  name: devops-engineer  # DevOps также может быть администратором домена
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: namespace-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Проверяем созданные привязки
echo ""
echo "Проверка созданных привязок:"
echo "============================"
echo "ClusterRoleBindings:"
kubectl get clusterrolebindings | grep -E "(devops-engineer|business-analyst|security-auditor)"
echo ""
echo "RoleBindings в sales-domain:"
kubectl get rolebindings -n sales-domain
echo ""
echo "RoleBindings в housings-domain:"
kubectl get rolebindings -n housings-domain

echo ""
echo "Все привязки созданы успешно!"
echo ""
echo "Для проверки прав пользователей используйте:"
echo "  kubectl auth can-i --as=devops-engineer create pods -n sales-domain"
echo "  kubectl auth can-i --as=sales-developer delete deployments -n sales-domain"
echo "  kubectl auth can-i --as=business-analyst get secrets -n sales-domain"
echo "  kubectl auth can-i --as=security-auditor get secrets -n sales-domain"