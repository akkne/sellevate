# Kubernetes

Чарт [sellevate-service](sellevate-service) создаёт Deployment и Service для одного процесса. В [values](values) есть настройки gateway, identity, learning, ai, gamification, social, analytics и notification. Для organization и company подготовьте собственные values с образом, конфигурацией, портом и зависимостями.

Параметры `envFromConfigMap` и `envFromSecret` ссылаются на заранее созданные объекты. Хранилища, Kafka и мониторинг устанавливаются отдельно. Проверка `/healthz` подтверждает работу процесса, `/readyz` участвует в допуске трафика.

```sh
cd infra/helm
helm lint ./sellevate-service -f values/gateway.yaml
helm template gateway ./sellevate-service -f values/gateway.yaml
helm upgrade --install gateway ./sellevate-service -f values/gateway.yaml
```
