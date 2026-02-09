#!/bin/bash

echo "=== Тестирование PodSecurity Admission ==="


# Создаем namespace
kubectl apply -f ../01-create-namespace.yaml

echo "1. Пробуем создать привилегированный под..."
kubectl apply -f ../insecure-manifests/01-privileged-pod.yaml 2>&1 | grep -E "(denied|error|Error)"

echo "2. Пробуем создать под с hostPath..."
kubectl apply -f ../insecure-manifests/02-hostpath-pod.yaml 2>&1 | grep -E "(denied|error|Error)"

echo "3. Пробуем создать под с root пользователем..."
kubectl apply -f ../insecure-manifests/03-root-user-pod.yaml 2>&1 | grep -E "(denied|error|Error)"

echo "4. Проверяем статус namespace..."
kubectl get ns audit-zone -o jsonpath='{.metadata.labels}'

echo "=== Тестирование безопасных подов ==="

echo "5. Создаем безопасные поды..."
for file in ../secure-manifests/*.yaml; do
    echo "Применяем $file"
    kubectl apply -f "$file"
done

echo "6. Проверяем статус подов..."
kubectl get pods -n audit-zone