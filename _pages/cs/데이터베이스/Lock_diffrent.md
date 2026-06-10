---
title: "동시성 제어를 위한 Lock 차이"
tags:
    - database        
date: "2026-06-10"
thumbnail: "/assets/img/thumbnail/spring-security.png"
bookmark: true
---
# 서론
---
프로젝트를 진행하던 와중 한 도메인의 데이터에 대해 여러 유저가 적용하는 경우 AI가 추천하는 대로 pessimistic lock 즉 비관적 락을 걸어 lock을 제어했더니 강사님이 
비관적 락은 은행과 같이 보안이 치명적인 곳에서 주로 사용하고 적용한 데이터에 대한 읽기도 막혀서 lock을 걸어놓아서 
# 낙관적 lock
