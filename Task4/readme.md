##Инструкция по запуску

```bash
# Запуск Minikube
minikube start

# Проверка статуса
kubectl cluster-info

# Даем права на выполнение
chmod +x create-users.sh create-roles.sh bind-roles.sh

# 1. Создаем пользователей
./create-users.sh

# 2. Создаем роли и namespace
./create-roles.sh

# 3. Связываем пользователей с ролями
./bind-roles.sh
```