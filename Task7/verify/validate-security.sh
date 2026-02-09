#!/bin/bash

echo "=== Проверка безопасности контейнеров ==="

# Проверяем, что Gatekeeper установлен
kubectl get deployment -n gatekeeper-system 2>/dev/null || echo "Gatekeeper не установлен"

echo "1. Проверяем constraint templates..."
kubectl get constrainttemplates

echo "2. Проверяем constraints..."
kubectl get constraints

echo "3. Проверяем существующие нарушения..."
kubectl get NoPrivilegedContainers.constraints.gatekeeper.sh -o yaml
kubectl get NoHostPathVolumes.constraints.gatekeeper.sh -o yaml
kubectl get NoRootContainers.constraints.gatekeeper.sh -o yaml