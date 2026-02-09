#!/bin/bash
set -euo pipefail

NAMESPACE="traffic-isolation"

echo "Тестирование сетевого трафика между сервисами"
echo "=============================================="
echo ""

# Функция для тестирования подключения
test_connection() {
    local from_label=$1
    local to_service=$2
    local expected_result=$3
    local test_name=$4

    echo "Тест: $test_name"

    pod_name="test-$(date +%s%N)"

    # Создаем тестовый pod
    kubectl run "$pod_name" \
      --namespace="$NAMESPACE" \
      --labels="role=$from_label" \
      --image=alpine \
      --restart=Never \
      --command -- \
      sh -c "sleep 3600" >/dev/null

    # Ждём, пока pod станет Ready
    kubectl wait \
      --namespace="$NAMESPACE" \
      --for=condition=Ready \
      pod/"$pod_name" \
      --timeout=60s >/dev/null

    # Выполняем тест запроса
    result=$(kubectl exec \
      --namespace="$NAMESPACE" \
      "$pod_name" \
      -c "$pod_name" -- \
      sh -c "wget -qO- --timeout=10 http://$to_service" 2>&1 || true)

    #echo "$result"
    echo ""

    # Удаляем pod 
    kubectl delete pod "$pod_name" \
      --namespace="$NAMESPACE" \
      --wait=false >/dev/null 2>&1

    # Анализ результата
    if [[ "$result" == *"index.html"* ]] \
       || [[ "$result" == *"200 OK"* ]] \
       || [[ "$result" == *"Welcome to nginx"* ]]; then
        actual_result="РАБОТАЕТ"
    else
        actual_result="НЕ РАБОТАЕТ"
    fi

    if [[ "$actual_result" == "$expected_result" ]]; then
        echo "✓ ПРОШЕЛ: $actual_result (ожидалось: $expected_result)"
    else
        echo "✗ НЕ ПРОШЕЛ: $actual_result (ожидалось: $expected_result)"
        echo "  Детали: $result"
    fi

    echo ""
}

# ---------------- ТЕСТЫ ----------------

test_connection "front-end" "back-end-api-app" "РАБОТАЕТ" \
  "front-end → back-end-api"

test_connection "admin-front-end" "admin-back-end-api-app" "РАБОТАЕТ" \
  "admin-front-end → admin-back-end-api"

test_connection "front-end" "admin-back-end-api-app" "НЕ РАБОТАЕТ" \
  "front-end → admin-back-end-api"

test_connection "admin-front-end" "back-end-api-app" "НЕ РАБОТАЕТ" \
  "admin-front-end → back-end-api"

test_connection "back-end-api" "front-end-app" "НЕ РАБОТАЕТ" \
  "back-end-api → front-end"

test_connection "admin-back-end-api" "admin-front-end-app" "НЕ РАБОТАЕТ" \
  "admin-back-end-api → admin-front-end"

echo "Тестирование завершено!"
