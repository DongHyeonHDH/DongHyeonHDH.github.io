---
title: java 인터페이스
tags:
    - java
    - OOP    
date: "2026-07-23"
thumbnail: "/assets/img/thumbnail/javaLogo.png"
bookmark: true
---

## 인터페이스

---

### abstact class

- 상속 전용의 클래스이다.
- 클래스에 구현부가 없는 메서드가 있으므로 객체를 생성할 수 없다.
- 상위 클래스 타입으로써 자식을 참조하는 것은 가능하다.(다형성을 적용하는 것이 가능)

추상클래스를 사용하는 이유

- abstract 클래스는 구현의 강제를 통해 프로그램의 안정성을 향상시키는 것이 가능하다.
  - 필요한 메서드의 생성을 강요해서 프로그램의 안정성을 높일 수가 있다.
- 인터페이스에 있는 메서드중 구현할 수 있는 메서드 구현 → 이것은 요즘 인터페이스의 버전 향상으로 애매해졌다(인터페이스의 default method의 도입).

### 인터페이스란?

서로 다른 두 시스템을 이어주는 장치

usb c와 같이 충전 케이블과 휴대폰을 이어주는 것과 같은 장치도 인터페이스라고 할 수가 있다.

인터페이스 작성하기

- 일반메서드는 abstract 형태 jdk8에서 default method, static method 추가
- interface 선언
  - 모든 멤버 변수는 public static final 이며 생략 가능
  - 모든 메서드는 public abstract이고 생략이 가능하다.
- 다중 상속이 가능하다.
- implements 키워드를 통해 인터페이스 구현
  - 모든 abstract 메서드를 override하여 구현하거나 하지 않을 경우에는 abstract 클래스로 표시를 해야한다.
- interface와의 관계도 is a 관계이지만 세부적으로는 is able to라고 한다.
  - Serializable, Cloneable, Comparable


### 인터페이스의 필요성

- 구현의 강제로 표준화를 시킬 수 있다.
- 인터페이스를 통해 손쉬운 모듈 교체를 가능하게 한다.
- 상속관계가 없는 클래스들에게 인터페이스를 통한 관계 부여로 다형성 확장
- 모듈간 독립적 프로그래밍 가능

#### default method

인터페이스에 선언된 구현부가 있는 일반 메서드

```java
default void defaultMethod(){
	System.out.println("이것은 기본 메서드");
}
```

필요한 이유?

- 기존에 interface 기반으로 동작하는 라이브러리의 interface에 추가하는 기능이 발생
- abstract 메서드는 모든 구현체들이 추가되는 메서드를 override를 해야한다.
- default 메서드는 abstract가 아니므로 반드시 구현할 필요는 없다.

우선순위

- **super class의 method를 우선**한다
- interface간 충돌 : 하나의 인터페이스에 default method를 제공하고 다른 interface에서 같은 이름의 메서드를 제공할 때 sub class는 반드시 override를 하여 충돌을 해결해야 한다.

#### static method

구현체 클래스 없이 인터페이스 이름으로 바로 메서드에 접근하여 사용하는 것이 가능하다.

#### private method

Interface에 default method, static method와 같이 body를 가지는 메서드가 등장하면서 공통적으로 처리할 모듈이 생겼다.

- 외부로 공개할 필요가 없는 메서드 지정을 위해 private method 추가
- default 키워드를 사용하지 않으며 static도 처리하는 것이 가능하다.

인터페이스 내부의 메서드를 처리해주기 위해서 사용한다고 볼 수가 있다.

## 보충

---
Q. object도 기능으로 따지면 추상클래스여야 하지 않는가?
- 개념으로 보면 추상클래스에 가까우나 generic 구현, collection에 적용등 java를 구현하는데 Object가 추상클래스로 되어있으면 오류가 생겨서 일반 객체로 구현되었다.

Q.인터페이스, 추상클래스가 필요한 이유?
- 가장 큰 이유는 표준화를 적용시키기 위함이다.