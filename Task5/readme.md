#Запуск применение политик + тесты
- `minikube start --cni=calico` что бы работали политики
- `./setup-traffic-isolation.sh` запускает применение политик, поды и тесты
- `minikube delete` 

#Результаты выполнения
Тестирование сетевого трафика между сервисами

Тест: front-end → back-end-api
Из: front-end → В: back-end-api-app

✓ ПРОШЕЛ: РАБОТАЕТ (ожидалось: РАБОТАЕТ)

Тест: admin-front-end → admin-back-end-api
Из: admin-front-end → В: admin-back-end-api-app

✓ ПРОШЕЛ: РАБОТАЕТ (ожидалось: РАБОТАЕТ)

Тест: front-end → admin-back-end-api
Из: front-end → В: admin-back-end-api-app

✓ ПРОШЕЛ: НЕ РАБОТАЕТ (ожидалось: НЕ РАБОТАЕТ)

Тест: admin-front-end → back-end-api
Из: admin-front-end → В: back-end-api-app

✓ ПРОШЕЛ: НЕ РАБОТАЕТ (ожидалось: НЕ РАБОТАЕТ)

Тест: back-end-api → front-end
Из: back-end-api → В: front-end-app

✓ ПРОШЕЛ: НЕ РАБОТАЕТ (ожидалось: НЕ РАБОТАЕТ)

Тест: admin-back-end-api → admin-front-end
Из: admin-back-end-api → В: admin-front-end-app

✓ ПРОШЕЛ: НЕ РАБОТАЕТ (ожидалось: НЕ РАБОТАЕТ)

Тестирование завершено!

=== Задание выполнено! ===

Для ручного тестирования используйте команду:
kubectl run test-$RANDOM --namespace=traffic-isolation --labels=role=front-end --rm -i -t --image=alpine -- sh
Затем внутри контейнера: wget -qO- --timeout=2 http://back-end-api-app