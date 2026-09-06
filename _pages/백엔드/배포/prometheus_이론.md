---
title: "Spring Boot Actuator와 Prometheus로 애플리케이션 관찰하기"
tags:
    - spring-boot
    - actuator
    - prometheus
    - grafana
date: "2026-06-23"
thumbnail: "/assets/img/thumbnail/prometheus_grafana.png"
bookmark: true
---

## 관찰 가능성이 필요한 이유

MSA에서는 요청이 서비스 A에서 B와 C로 이어질 수 있다. 이때 요청이 어느 서비스와 프로세스를 거쳤는지 추적할 수 있어야 한다. 분산 추적에는 OpenTelemetry와 Zipkin을 사용할 수 있고, 애플리케이션 상태와 JVM 지표를 수집할 때는 Spring Boot Actuator와 Prometheus를 사용할 수 있다.

## Spring Boot Actuator

Actuator는 애플리케이션의 운영 정보를 엔드포인트로 제공한다. `health` 엔드포인트에서는 서버가 정상적으로 동작하는지 확인할 수 있다. Blue-Green 배포에서도 새 환경이 준비되었는지 검사하는 데 이 상태 정보가 필요하다.

Actuator는 CPU와 JVM처럼 민감할 수 있는 운영 정보도 다루므로 외부에 그대로 공개하지 않아야 한다. 필요한 엔드포인트만 제한적으로 노출하고 접근을 보호해야 한다. Swagger, Kibana, Grafana 같은 운영 도구도 외부에 직접 노출하지 않는 편이 좋다.

## Prometheus로 메트릭 수집하기

Prometheus는 시계열 데이터를 저장하고 조회하며, 지정한 엔드포인트에서 메트릭을 주기적으로 가져온다. 수집 주기를 지나치게 짧게 잡으면 대상 애플리케이션에 부담을 줄 수 있다.

```yaml
scrape_configs:
  - job_name: "service-a"
    scrape_interval: 15s
    metrics_path: /actuator/prometheus
    static_configs:
      - targets: ["host.docker.internal:8080"]
```

Prometheus를 컨테이너에서 실행할 때 `localhost`는 호스트가 아니라 해당 컨테이너의 `127.0.0.1`을 가리킨다. 호스트에서 실행 중인 애플리케이션을 수집하려면 환경에 맞는 호스트 주소를 사용해야 한다. 같은 Docker Compose 네트워크에서 실행한다면 서비스 이름으로 접근할 수 있다.

JVM 힙 메모리 사용 비율은 다음과 같은 PromQL로 계산할 수 있다.

```promql
sum(jvm_memory_used_bytes{area="heap"}) by (instance)
/
sum(jvm_memory_max_bytes{area="heap"}) by (instance)
```

## Grafana 대시보드 연결

메트릭을 확인할 때마다 PromQL을 직접 입력하는 대신 Grafana 대시보드로 시각화할 수 있다. Docker Compose로 Prometheus와 Grafana를 함께 실행한다면 Grafana 데이터 소스에 같은 네트워크의 Prometheus 서비스 주소를 등록한다.

```text
http://prometheus:9090
```

패널을 직접 구성하거나 공개된 Grafana 대시보드 템플릿에서 시작할 수 있다. 학습 당시 확인한 Spring 관련 템플릿의 ID는 `11892`였다.

Docker Compose의 `depends_on`은 컨테이너 시작 순서를 표현할 수 있지만 애플리케이션이 실제 요청을 받을 준비가 끝났다는 것까지 보장하지는 않는다. 준비 상태까지 확인하려면 health check를 함께 설계해야 한다.

## 배운 점

운영 상태를 파악하기에는 로그만으로 부족하다. Actuator가 애플리케이션 상태와 메트릭을 노출하고, Prometheus가 이를 수집하며, Grafana가 조회 결과를 대시보드로 보여주는 구조를 만들 수 있다. 운영 엔드포인트와 대시보드에는 민감한 정보가 포함될 수 있으므로 접근 제어가 필요하다. 컨테이너 환경에서는 `localhost`의 의미와 서비스 준비 상태도 별도로 고려해야 한다.
