#!/bin/bash

echo "Создание сервисов с метками для изоляции трафика"
echo "=================================================="

# Создаем namespace для изоляции трафика
kubectl create namespace traffic-isolation

# 1. Создаем front-end сервис
echo "Создаем front-end сервис..."
kubectl run front-end-app --image=nginx --labels=role=front-end --namespace=traffic-isolation --expose --port=80

# 2. Создаем back-end-api сервис
echo "Создаем back-end-api сервис..."
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api --namespace=traffic-isolation --expose --port=80

# 3. Создаем admin-front-end сервис
echo "Создаем admin-front-end сервис..."
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end --namespace=traffic-isolation --expose --port=80

# 4. Создаем admin-back-end-api сервис
echo "Создаем admin-back-end-api сервис..."
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api --namespace=traffic-isolation --expose --port=80

# Проверяем созданные сервисы
echo ""
echo "Проверка созданных сервисов:"
kubectl get pods -n traffic-isolation --show-labels
echo ""
echo "Сервисы:"
kubectl get services -n traffic-isolation