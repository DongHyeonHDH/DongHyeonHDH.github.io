---
title: java 예외
tags:
- java
- OOP    
date: "2026-07-27"
thumbnail: "/assets/img/thumbnail/javaLogo.png"
bookmark: true
---
 
## try catch문

```java
try{

// 예외 발생가능 코드

}catch(Exception e){

// 예외가 발생했을 때 처리할 코드

}
```

#### 주요 메서드

- public String getMessage
    - 발생된 예외에 대한 구체적인 메시지를 반환
- public Throwable getCause()
    - 예외의 원인이 되는 Throwable 객체 or null 반환
- public void printStackTrace()
    - 예외가 발생된 메서드가 호출될 때까지의 메서드 호출 스택을 반환

      디버깅의 수단으로 주로 사용


흐름

try 블록에서 예외가 발생하면 JVM이 Exception 클래스의 객체를 생성한 다음 던짐 throw

catch 블록에서 던진 exception에서 처리

#### 계층을 이루는 예외처리

하나의 try 블록에 여러 개의 catch 블록을 추가하는 것이 가능하다

처리될 catch 문장을 찾을 때는 다형성이 적용된다.

주의사항

- 상위 타입의 예외가 먼저 선언되는 경우 뒤의 catch 블록은 동작기회가 없음
- 상속관계에서 작은 범위에서 큰 범위 순으로 정의

→ 발생하는 예외들을 하나로 처리

```java
try{

}catch(Exception e){
	System.out.printf("예외발생 %s%n", e.getMessage());
}
```

#### try ~ catch ~ finally

- finally는 예외 발생 여부와 상관없이 언제나 실행
    - 중간에 return을 만나도 finally 블록을 먼저 실행 후 리턴 실행


<aside>
💡

finally대신 아래 따로 코드를 적으면 안될까?

유지 보수 측면에서 try ~catch 문과 연관이 있다는 것을 보여줄 필요가 있어서 finally를 사용하는 것이 권장된다.

- try 블록에서 사용한 리소스 반납도 고려해야 한다.
    - 하지만 finally에서 관련 코드를 구현하면 코드가 지저분해진다.

      → 이를 위한 것이 try with resource 구문

</aside>

#### try with resources

- 리소스의 자동 close 처리
- try 선언문에 선언된 객체들에 대해 자동 close 호출
    - 단 해당 객체들이 AutoCloseable interface를 구현해놓았을 때
    - I/O stream, socket, connection

- **close 시점 주의**
    - try with resources 문장은 nested try 블록을 구성한다.


## throws

#### throws 키워드를 통한 처리 위임

method에서 처리해야 할 하나 이상의 예외를 호출할 곳으로 전달

- 예외가 없어지는 것이 아니라 단순히 전달된다
- 예외를 전달받은 메서드는 다시 예외 처리의 책임이 발생한다.

checked exception은 반드시 try~catch, throws를 필요로 한다

unchecked exception은 throws 하지 않아도 전달되지만 결국에는 try~catch로 처리해야 한다.

#### 로그 분석과 예외의 추적

throwable의 printStackTrace는 메서드 호출 스택 정보 조회 가능

- 꼭 확인해야 하는 정보
    - 어떤 예외인가? - 예외종류
    - 예외 객체의 메시지는 무엇인가? - 예외 원인
    - 어디서 발생했는가? - 디버깅 출발점
        - **직접 작성한 코드를 디버깅 대상으로 삼을 것**
        - 참조하는 라이브러리는 뛰어넘어서 볼 필요가 있다.

API 제공하는 메서드들은 사전에 예외가 발생할 수 있음을 명시하고 프로그래머가 예외에 대처하도록 한다.

JAVA API는 예외 발생 → 예외 전파를 통해 개발자가 상황을 인지하고 적절한 예외를 처리하도록 위임한다.

#### 예외 변환과 Exception Chaining

하위계층에서 발생한 예외는 상위 계층에 맞는 예외로 바꾸어서 던져야 한다.

## 사용자 정의 예외

---

#### 사용자 정의 예외란?

- API에 정의된 exception 이외에 필요에 따라 사용자 정의 예외 클래스 작성
- 대부분 Exception or RuntimeException 클래스를 상속받아 작성을 한다.
    - checked exception 활용 : 명시적 예외 처리 or throws 필요하다
    - unchecked exception 활용 : 묵시적 예외 처리 가능
- 사용자 정의 예외를 만들어 처리하는 장점
    - 객체의 활용 - 필요한 추가정보, 기능 활용
    - 코드의 재사용 가능 - 동일한 상황에서 예외 객체 재사용 가능
    - throws 메커니즘이용 - 중간에 return 불필요

## 보충

---

오류의 최상위에는 throwable 인터페이스가 있다.

상위에는 error, exception 이렇게 두개가 나누게 된다. jvm을 항상 생각해야 한다.

exception에는 checked, unchecked로 나뉘는데 checked는 이를 해결해야지 컴파일이 되는 것이고 unchecked는 해결하지 않아도 컴파일이 된다.

unchecked인 → runtime은 개발자의 로직으로 잡아야 하는 것이다.

checked 관련 exception은 코드가 아닌 외부적 영향에 의해 오류가 발생할 수 있는 것이다.

file block은 무지막지하게 느리다. 명령문을 쓰는데 try catch 구문을 사용하면 많이 느려진다. 이때문에 알고리즘 문제에서는 main함수에 throws를 사용하지만 이는 내부의 모든 코드에 try 구문을 사용하는 것이므로 고려를 할 필요가 있다.

exception 객체를 인스턴스화 시킨 것을 던져 Exception e 와 같은 형태로 던져서 확인하는 편이 좋다.

```java
int num = Integer.parseInt("1000");
-> parseInt는 명시적으로 throws NumberFormatException을 포함한다.

```

runtime 계열들은 안해도 던져진다.

왠만하면 try ~ catch로 오류를 잡아서 진행 하는 것을 추천한다.

```java
try{
	num = Ingeter.parseInt(args[0])
}catch(NumberFormatException e) { 
	num =99;
}
```

어떤 곳에서는 throws, try~catch 를 구분해서 사용하게 될까?

1. 우리가 책임질 수 있는 작은 단위 → try ~ catch로 처리
2. 시스템에서의 **큰 중요도와 업무단위** → throws로 위임 or 관련된 처리하고 보고

try ~ resources

try를 하면 그곳 밖에서 관련 자원에 접근할 수는 없다. **자원의 접근도를 고려하여 사용해야 한다.**

→ autoclosable Interface 를 가지고 있어야 한다.

system.exit()

→ finally 사용하지 않아도 강제로 종료를 시켜버린다.

try 에서 사용한 자원을 반납하거나 닫을 때 finally를 사용하게 된다.