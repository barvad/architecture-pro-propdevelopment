#!/bin/bash
# Фильтрация подозрительных событий из Kubernetes Audit Log
# Учитывает префиксы kube-apiserver, убирает control plane noise
# и сохраняет цепочку атаки из simulate-incident.sh

LOG_FILE="audit.log"
OUTPUT_FILE="audit-extract.json"

jq -R '
  fromjson? |
  select(. != null) |

  # ❌ Исключаем системный шум control plane
  select(
    (.user.username | startswith("system:") | not)
    and (.userAgent // "" | test("kube-controller-manager|kube-scheduler|kube-apiserver|kubelet|kube-proxy") | not)
    and (.verb != "watch")
    and (.verb != "list")
  ) |

  # ✅ Оставляем значимые события
  select(

    # 1. Доступ к secrets
    (
      .objectRef.resource == "secrets"
      and .verb == "get"
    )

    # 2. kubectl exec в pod
    or (
      .objectRef.resource == "pods"
      and .objectRef.subresource == "exec"
      and .verb == "create"
    )

    # 3. Создание pod через kubectl (инициация атаки)
    or (
      .objectRef.resource == "pods"
      and .verb == "create"
      and (.userAgent // "" | test("kubectl"))
    )

    # 4. Создание privileged pod (эскалация)
    or (
      .objectRef.resource == "pods"
      and .verb == "create"
      and (
        .requestObject?.spec?.containers[]?.securityContext?.privileged == true
      )
    )

    # 5. Создание RoleBinding / ClusterRoleBinding
    or (
      .objectRef.resource == "rolebindings"
      or .objectRef.resource == "clusterrolebindings"
    )

    # 6. Удаление / попытка изменить audit policy
    or (
      (.objectRef.name // "") | test("audit-policy")
    )
  )
' "$LOG_FILE" | jq -s '.' > "$OUTPUT_FILE"

echo "✔ Подозрительные события сохранены в $OUTPUT_FILE"
