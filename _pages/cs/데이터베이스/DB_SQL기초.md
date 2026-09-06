---
title: "DB와 SQL 기초: Java 개발자의 관점에서 이해하기"
tags:
    - database
    - mysql
    - sql
date: "2026-04-13"
thumbnail: "/assets/img/thumbnail/grapaduk.jpg"
bookmark: true
---

## 학습 목표

Java 프로그램에서 메모리나 파일에 데이터를 저장하는 방식은 규모가 커질수록 한계가 생긴다. 회원이 10만 명인 파일에서 특정 회원을 빠르게 찾고, 여러 사용자가 동시에 같은 파일을 수정하며, 계좌 이체 도중 프로그램이 중단되는 상황까지 안정적으로 처리해야 하기 때문이다.

이런 문제를 전문적으로 다루는 소프트웨어가 DBMS(Database Management System)이며, 그 안에 저장된 구조화된 데이터가 데이터베이스다. Java 애플리케이션의 관점에서는 DB를 네트워크를 통해 사용하는 외부 저장소로 볼 수 있다.

## 데이터베이스와 DBMS

데이터베이스는 여러 사람이 공유할 목적으로 구조화한 데이터의 모음이다. 관계형 데이터베이스에서는 일반적으로 테이블 형태로 데이터를 표현한다.

| 용어 | 의미 |
| --- | --- |
| 행(Row, Record) | 데이터 한 건 |
| 열(Column, Attribute) | 데이터의 속성 |
| Entity | 설계 단계에서 표현하는 현실 세계의 대상이나 개념 |
| Table | 데이터가 DB에 저장되는 물리적인 형태 |
| Schema | 테이블 구조와 제약조건을 정의한 설계도 |

DBMS는 데이터베이스의 제어, 모니터링, 튜닝, 백업과 복구를 담당하는 서버 소프트웨어다. Java 프로그램은 클라이언트로서 SQL을 보내고 DBMS가 처리한 결과를 받는다.

## 데이터베이스의 종류

| 종류 | 특징 | 대표 제품 |
| --- | --- | --- |
| 관계형 DB | 테이블과 SQL을 사용하고 일관성과 무결성을 중시 | MySQL, PostgreSQL, Oracle |
| NoSQL | 비정형·대용량 데이터와 유연한 스키마에 적합 | MongoDB, Redis, Cassandra |
| 객체지향 DB | 객체 단위 저장과 상속·다형성 지원 | db4o |
| 그래프 DB | Node-Edge-Property 구조로 관계를 표현 | Neo4j |
| 분산 DB | 여러 서버에 데이터를 분산 저장 | Google Spanner |

NoSQL은 SQL을 전혀 사용하지 않는다는 뜻이 아니라 `Not Only SQL`이라는 의미에 가깝다.

## SQL은 선언형 언어다

Java에서는 원하는 결과를 얻기 위한 과정을 단계별로 작성한다.

```java
List<Member> result = new ArrayList<>();
for (Member member : members) {
    if (member.getAge() >= 30) {
        result.add(member);
    }
}
```

SQL에서는 원하는 결과를 선언하고, 실제 실행 방법은 DB 옵티마이저가 결정한다.

```sql
SELECT * FROM members WHERE age >= 30;
```

SQL은 역할에 따라 네 종류로 나눌 수 있다.

| 분류 | 역할 | 대표 명령어 |
| --- | --- | --- |
| DDL | 구조 정의 | `CREATE`, `DROP`, `ALTER`, `TRUNCATE` |
| DML | 데이터 조회와 변경 | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| DCL | 접근 권한 제어 | `GRANT`, `REVOKE` |
| TCL | 트랜잭션 제어 | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

애플리케이션용 DB 계정에는 모든 DB와 테이블에 대한 권한을 부여하기보다 최소 권한 원칙을 적용한다.

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON my_app.*
TO 'app_user'@'%';
```

## SELECT문의 작성 순서와 실행 순서

SELECT문은 작성 순서와 DB 내부 실행 순서가 다르다.

```text
작성: SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
실행: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

`SELECT`에서 만든 별칭을 `WHERE`에서 사용할 수 없는 이유도 여기에 있다. `WHERE`가 `SELECT`보다 먼저 실행되기 때문이다.

```sql
-- final_price가 아직 만들어지지 않았으므로 오류
SELECT price * 1.1 AS final_price
FROM product
WHERE final_price > 1000;

-- 원본 표현식을 사용
SELECT price * 1.1 AS final_price
FROM product
WHERE price * 1.1 > 1000;
```

## 키와 제약조건

| 제약조건 | 의미 |
| --- | --- |
| `PRIMARY KEY` | 각 행을 고유하게 식별하며 NULL과 중복을 허용하지 않음 |
| `FOREIGN KEY` | 다른 테이블의 기본 키를 참조 |
| `NOT NULL` | NULL을 허용하지 않음 |
| `UNIQUE` | 중복을 허용하지 않음 |
| `DEFAULT` | 값이 없을 때 사용할 기본값 |
| `CHECK` | 입력값이 조건을 만족하는지 검사 |

일대다 관계에서는 일반적으로 N쪽 테이블에 외래 키를 둔다. 다대다 관계는 중간 테이블을 만들어 두 개의 일대다 관계로 분해한다.

```sql
CREATE TABLE member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    age INT CHECK (age >= 0),
    grade VARCHAR(10) DEFAULT 'BRONZE'
);
```

## 배운 점

DBMS는 단순히 데이터를 오래 보관하는 도구가 아니다. 동시성, 검색, 권한과 트랜잭션을 다루는 서버 소프트웨어다. SQL의 분류와 SELECT문의 실제 실행 순서를 이해하면 쿼리 오류의 원인을 더 정확히 찾을 수 있다. 테이블을 설계할 때는 키와 제약조건으로 데이터의 무결성을 명시하고, 애플리케이션 계정에는 필요한 권한만 부여해야 한다.
