# Инструкция для проверяющего

## Предварительные требования
1. Kubernetes кластер версии 1.25+
2. Включен PodSecurity Admission Controller
3. Установлен OPA Gatekeeper 

## Установка и проверка

### 1. Установка Gatekeeper (опционально)
```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```
### 2. Применение всех конфигураций
```bash
# Создаем namespace
kubectl apply -f 01-create-namespace.yaml

# Устанавливаем Constraint Templates
kubectl apply -f gatekeeper/constraint-templates/

# Устанавливаем Constraints
kubectl apply -f gatekeeper/constraints/

# Проверяем, что политики блокируют небезопасные поды
chmod +x verify/verify-admission.sh
./verify/verify-admission.sh

# Проверяем безопасные поды
for file in secure-manifests/*.yaml; do
    kubectl apply -f "$file"
done
```

### 3. Ожидаемый результат
Небезопасные поды должны быть отклонены:
- Привилегированный под: "Privileged containers are not allowed"
- Под с hostPath: "hostPath volumes are not allowed"
- Под с root пользователем: "Containers must run as non-root"

Безопасные поды должны успешно создаться:
`kubectl get pods -n audit-zone`
Политики Gatekeeper должны быть активны:
```bash
kubectl get constrainttemplates
kubectl get constraints
```
### 4. Проверка аудита
Если включен аудит:
`kubectl logs -n kube-system kube-apiserver-kind-control-plane | grep -i "audit"`


### Команды для проверки

```bash
# 1. Создаем namespace
kubectl apply -f 01-create-namespace.yaml

# 2. Пробуем создать небезопасные поды (должны быть отклонены)
kubectl apply -f insecure-manifests/01-privileged-pod.yaml
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml
kubectl apply -f insecure-manifests/03-root-user-pod.yaml

# 3. Создаем безопасные поды (должны успешно развернуться)
kubectl apply -f secure-manifests/01-secure.yaml
kubectl apply -f secure-manifests/02-secure.yaml
kubectl apply -f secure-manifests/03-secure.yaml

# 4. Проверяем результат
kubectl get pods -n audit-zone
kubectl describe ns audit-zone
```