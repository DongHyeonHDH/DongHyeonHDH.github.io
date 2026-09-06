---
title: "GitHub Actions로 시작하는 CI 파이프라인"
tags:
    - github-actions
    - ci
    - gradle
date: "2026-06-12"
thumbnail: "/assets/img/thumbnail/github_actions.png"
bookmark: true
---

## CI가 필요한 이유

Pull Request 화면에서는 코드 변경점을 확인할 수 있지만 개발 환경의 차이까지 비교하기는 어렵다. 변경 파일이 많으면 사람이 모든 내용을 확인하는 데에도 시간이 많이 든다. 여러 개발자의 코드를 하나로 합칠 때 빌드와 테스트를 자동으로 실행하면 문제가 있는지 빠르게 확인할 수 있다.

GitHub Actions는 GitHub에서 발생하는 `push`, `pull_request`, `release` 등의 이벤트를 기준으로 작업을 실행한다. 저장소의 `.github/workflows` 디렉터리에 YAML 파일을 두면 정의한 절차대로 워크플로가 실행된다.

## 워크플로 구성 요소

워크플로에는 `job`과 `step`이 있다.

- `job`은 하나의 작업 단위이며 기본적으로 서로 병렬 실행된다.
- `step`은 한 job 안에서 순서대로 실행되는 세부 과정이다.
- 작업 사이에 의존 관계를 설정하면 앞 작업의 결과를 다음 작업의 입력으로 연결할 수 있다.
- `on`에는 워크플로를 시작할 이벤트를 정의한다.
- `runs-on`에는 작업이 실행될 환경을 지정한다.

외부 시스템이 GitHub 이벤트를 받아 작업해야 한다면 Webhook을 이용할 수 있다. 특정 이벤트가 발생하면 지정한 URL로 JSON 데이터를 전송하며, Slack 알림이나 Jenkins 기반 배포 같은 흐름에 활용할 수 있다.

## Spring 프로젝트 테스트 워크플로

GitHub가 제공하는 실행 환경에는 저장소의 소스 코드와 프로젝트에 필요한 JDK가 자동으로 준비되어 있지 않다. 따라서 저장소 체크아웃, JDK 설치, Gradle 테스트를 각각 step으로 정의한다.

```yaml
name: ci-workflow

on:
  pull_request:

jobs:
  code-test:
    name: 코드 테스트
    runs-on: ubuntu-latest
    steps:
      - name: 브랜치 체크아웃
        uses: actions/checkout@v6

      - name: JDK 설치
        uses: actions/setup-java@v5
        with:
          distribution: "temurin"
          java-version: "25"

      - name: 테스트 실행
        run: ./gradlew test --no-daemon
```

Linux 실행 환경에서 `gradlew`에 실행 권한이 없다면 권한을 부여하는 step이 추가로 필요할 수 있다.

```yaml
- name: Gradle Wrapper 실행 권한 부여
  run: chmod +x gradlew
```

## 배운 점

CI는 Pull Request에 올라온 코드를 사람이 읽는 작업을 대체하지 않는다. 반복 가능한 빌드와 테스트를 자동으로 수행해 통합 위험을 일찍 드러내는 장치다. GitHub Actions에서는 이벤트, job, step과 실행 환경의 관계를 이해해야 한다. 워크플로를 작성할 때는 소스 코드 체크아웃, JDK 준비, 실행 권한과 테스트 명령까지 실행 환경 관점에서 빠짐없이 정의해야 한다.
