#!/bin/bash

echo "Создание пользователей для кластера Kubernetes PropDevelopment"
echo "================================================================"

# Создаем директорию для сертификатов пользователей
mkdir -p ./k8s-users/certs
cd ./k8s-users/certs

# 1. Создаем пользователя для DevOps инженера (полные права)
echo "Создаем пользователя: devops-engineer"
openssl genrsa -out devops-engineer.key 2048
openssl req -new -key devops-engineer.key -out devops-engineer.csr -subj "/CN=devops-engineer/O=cluster-admin"
openssl x509 -req -in devops-engineer.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out devops-engineer.crt -days 365

# 2. Создаем пользователя для разработчика (разработчик в домене продаж)
echo "Создаем пользователя: sales-developer"
openssl genrsa -out sales-developer.key 2048
openssl req -new -key sales-developer.key -out sales-developer.csr -subj "/CN=sales-developer/O=developer/O=sales-domain"
openssl x509 -req -in sales-developer.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out sales-developer.crt -days 365

# 3. Создаем пользователя для бизнес-аналитика (только просмотр)
echo "Создаем пользователя: business-analyst"
openssl genrsa -out business-analyst.key 2048
openssl req -new -key business-analyst.key -out business-analyst.csr -subj "/CN=business-analyst/O=viewer"
openssl x509 -req -in business-analyst.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out business-analyst.crt -days 365

# 4. Создаем пользователя для специалиста по ИБ (аудитор)
echo "Создаем пользователя: security-auditor"
openssl genrsa -out security-auditor.key 2048
openssl req -new -key security-auditor.key -out security-auditor.csr -subj "/CN=security-auditor/O=auditor"
openssl x509 -req -in security-auditor.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out security-auditor.crt -days 365

# 5. Создаем пользователя для CI/CD системы
echo "Создаем пользователя: ci-cd-bot"
openssl genrsa -out ci-cd-bot.key 2048
openssl req -new -key ci-cd-bot.key -out ci-cd-bot.csr -subj "/CN=ci-cd-bot/O=ci-cd-bot"
openssl x509 -req -in ci-cd-bot.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ci-cd-bot.crt -days 365

# Создаем kubeconfig файлы для каждого пользователя
echo "Создаем kubeconfig файлы..."

# kubeconfig для devops-engineer
kubectl config set-credentials devops-engineer \
  --client-certificate=devops-engineer.crt \
  --client-key=devops-engineer.key \
  --embed-certs=true

kubectl config set-context devops-engineer-context \
  --cluster=minikube \
  --user=devops-engineer

# kubeconfig для sales-developer
kubectl config set-credentials sales-developer \
  --client-certificate=sales-developer.crt \
  --client-key=sales-developer.key \
  --embed-certs=true

kubectl config set-context sales-developer-context \
  --cluster=minikube \
  --user=sales-developer

# kubeconfig для business-analyst
kubectl config set-credentials business-analyst \
  --client-certificate=business-analyst.crt \
  --client-key=business-analyst.key \
  --embed-certs=true

kubectl config set-context business-analyst-context \
  --cluster=minikube \
  --user=business-analyst

# kubeconfig для security-auditor
kubectl config set-credentials security-auditor \
  --client-certificate=security-auditor.crt \
  --client-key=security-auditor.key \
  --embed-certs=true

kubectl config set-context security-auditor-context \
  --cluster=minikube \
  --user=security-auditor

# kubeconfig для ci-cd-bot
kubectl config set-credentials ci-cd-bot \
  --client-certificate=ci-cd-bot.crt \
  --client-key=ci-cd-bot.key \
  --embed-certs=true

kubectl config set-context ci-cd-bot-context \
  --cluster=minikube \
  --user=ci-cd-bot

echo "Пользователи созданы успешно!"
echo "Файлы сертификатов находятся в: $(pwd)"
echo ""
echo "Для переключения контекстов используйте:"
echo "  kubectl config use-context devops-engineer-context"
echo "  kubectl config use-context sales-developer-context"
echo "  kubectl config use-context business-analyst-context"
echo "  kubectl config use-context security-auditor-context"
echo "  kubectl config use-context ci-cd-bot-context"

cd ../..