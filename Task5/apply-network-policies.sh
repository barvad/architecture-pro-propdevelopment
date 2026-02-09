#!/bin/bash

echo "Применение сетевых политик для изоляции трафика"
echo "================================================"

# Применяем политики по очереди
echo "1. Применяем политику 'deny-all-by-default'..."
kubectl apply -f deny-all-by-default.yaml

echo "2. Применяем политику 'non-admin-api-allow'..."
kubectl apply -f non-admin-api-allow.yaml

echo "3. Применяем политику 'admin-api-allow'..."
kubectl apply -f admin-api-allow.yaml

# Проверяем примененные политики
echo ""
echo "Проверка примененных сетевых политик:"
kubectl get networkpolicies -n traffic-isolation

echo ""
echo "Политики созданы и применены успешно!"