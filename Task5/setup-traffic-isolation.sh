#!/bin/bash

echo "=== Настройка изоляции трафика в кластере Kubernetes ==="
echo ""

# Шаг 1: Создание сервисов
echo "Шаг 1: Создание сервисов с метками..."
chmod +x create-services.sh
./create-services.sh

echo ""
echo "---"

# Шаг 2: Применение сетевых политик
echo "Шаг 2: Применение сетевых политик..."
chmod +x apply-network-policies.sh
./apply-network-policies.sh

echo ""
echo "---"

# Шаг 3: Тестирование
echo "Шаг 3: Тестирование сетевого трафика..."
echo "Подождите 30 секунд для стабилизации сервисов..."
sleep 30
chmod +x test-traffic.sh
./test-traffic.sh

echo ""
echo "Для ручного тестирования используйте команду:"
echo "kubectl run test-\$RANDOM --namespace=traffic-isolation --labels=role=front-end --rm -i -t --image=alpine -- sh"
echo "Затем внутри контейнера: wget -qO- --timeout=2 http://back-end-api-app"