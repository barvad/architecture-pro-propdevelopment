#!/bin/bash

echo "=== Установка OPA Gatekeeper ==="

# Проверяем, установлен ли Gatekeeper
if ! kubectl get ns gatekeeper-system 2>/dev/null; then
    echo "Устанавливаем Gatekeeper..."
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
    echo "Ожидаем запуск Gatekeeper..."
    kubectl wait --for=condition=available --timeout=300s deployment/gatekeeper-controller-manager -n gatekeeper-system
fi

echo "=== Устанавливаем Constraint Templates ==="
for file in ./gatekeeper/constraint-templates/*.yaml; do
    echo "Применяем: $file"
    kubectl apply -f "$file"
done

echo "Ожидаем создание CRD..."
sleep 15

echo "=== Проверяем созданные CRD ==="
kubectl get crd | grep -i constraint

echo "=== Устанавливаем Constraints ==="
for file in ./gatekeeper/constraints/*.yaml; do
    echo "Применяем: $file"
    kubectl apply -f "$file"
done

echo "=== Проверяем установку ==="
kubectl get constrainttemplates
kubectl get constraints