---
title: "Django 학습 핵심 정리: 모델, 요청 처리, 템플릿"
tags:
    - project
    - 바로그림
    - django
date: "2026-09-06"
bookmark: false
---

바로그림 프로젝트를 준비하며 Django 강의 1~20강을 따라 학습했다. 이 글은 당시 강의 노트에서 프로젝트와 연결되는 개념만 모아 다시 확인한 정리다. 강의에서 사용한 특정 환경 설정값, 개인 개발 경로, 인증 관련 예시는 포함하지 않았다.

## 데이터 모델과 화면에 전달할 데이터

프로젝트에서는 이미지, 프롬프트, 태그처럼 저장할 대상을 먼저 나누고 관계를 고민했다. Django에서 모델은 저장할 데이터의 필드와 동작을 정의하는 Python 클래스이며, 일반적으로 하나의 모델은 데이터베이스 테이블 하나에 대응한다. 모델의 필드는 데이터베이스 컬럼으로 연결되고 Django는 이를 바탕으로 데이터 접근 API를 제공한다. [Django Models 문서](https://docs.djangoproject.com/en/6.0/topics/db/models/)

따라서 바로그림에서 이미지 정보와 프롬프트 정보를 어떤 단위로 저장할지, 태그 정보를 별도 데이터로 둘지 검토한 기록은 모델 설계 전에 필요한 고민이었다. 다만 당시 노트는 설계 검토와 학습 과정이며, 해당 구조가 최종 구현되었다는 뜻은 아니다.

## URL, View, Template의 역할

강의에서는 URL 설정, view 함수, 템플릿 작성, 템플릿에서 반복문으로 데이터를 출력하는 흐름을 다뤘다. Django의 URL dispatcher는 요청 URL과 view를 연결하고, view는 요청을 받아 필요한 데이터를 준비해 응답을 만든다. 템플릿은 동적으로 넣을 데이터와 정적 HTML을 함께 표현하는 방식이다. [Django HTTP 요청 처리 문서](https://docs.djangoproject.com/en/6.0/topics/http/), [Django Templates 문서](https://docs.djangoproject.com/en/6.0/topics/templates/)

이 흐름을 기준으로 하면 목록 화면은 view에서 데이터를 가져오고, template에서 반복해 보여 주는 형태로 구성할 수 있다. 강의 노트에 있던 `for` 문과 `base.html`, header, footer 분리 기록은 이 역할을 나누는 연습이었다.

## 폼과 GET·POST

강의 후반에는 HTML form으로 값을 보내고 view에서 `POST` 데이터를 처리해 저장하는 실습을 했다. Django 공식 문서는 시스템 상태를 바꾸는 요청에는 `POST`를, 상태를 바꾸지 않는 조회·검색에는 `GET`을 사용하도록 안내한다. 내부 URL로 보내는 POST form에는 CSRF 보호도 필요하다. [Django Forms 문서](https://docs.djangoproject.com/en/6.0/topics/forms/), [Django CSRF 문서](https://docs.djangoproject.com/en/4.2/ref/csrf/)

바로그림의 검색처럼 URL로 조건을 공유해도 되는 기능과, 게시물·정보를 저장하는 기능은 같은 방식으로 처리하지 않아야 한다는 점을 학습 범위에서 확인했다.

## 정적 파일과 공통 화면

CSS, JavaScript, 이미지는 Django에서 static files로 관리할 수 있다. `django.contrib.staticfiles`를 사용하고 `STATIC_URL`을 설정한 뒤, 템플릿에서는 `static` 태그로 URL을 만들 수 있다. 개발 서버에서의 정적 파일 제공 방식은 운영 환경용 설정이 아니다. [Django Static files 문서](https://docs.djangoproject.com/en/6.0/howto/static-files/)

강의 노트의 CSS 분리, `base.html`, header·footer 구성은 화면 공통 요소와 정적 자원을 나누는 연습으로 남겼다. 특정 폰트·스타일 값이나 강의 예제 코드는 이 글에서 반복하지 않았다.

## Class-Based View

함수 기반 view를 학습한 뒤 Class-Based View와 CRUD를 살폈다. Django의 generic class-based views는 목록·상세·생성·수정처럼 반복되는 패턴을 줄이기 위한 기반을 제공한다. 예를 들어 `CreateView`, `UpdateView`, `DeleteView`는 편집 흐름에 사용할 수 있지만, 모델과 권한·검증 규칙을 프로젝트에 맞게 정해야 한다. [Django Generic editing views 문서](https://docs.djangoproject.com/en/6.0/ref/class-based-views/generic-editing/)

이 글은 강의 학습 내용을 정리한 것이며, 강의 예제의 코드나 설정을 바로그림의 실제 운영 코드로 주장하지 않는다.
