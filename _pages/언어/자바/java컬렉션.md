---
title: java 컬렉션
tags:
    - java
    - OOP    
date: "2026-07-29"
thumbnail: "/assets/img/thumbnail/javaLogo.png"
bookmark: true
---
## List 계열

---

자료구조란?

컴퓨터 과학에서 효율적인 접근, 수정을 가능케 하는 자료의 조직, 관리, 저장

데이터 값의 모임, 또 데이터 간의 관계, 데이터에 적용할 수 있는 함수나 명령을 의미

가장 기본적인 자료구조 : 배열

homogeneous collection(동일한 데이터 타입만 관리가능)

Polymorphism: Object를 이용하면 모든 객체 참조가능

- 넣을 때는 편하지만 빼낼 때는 번거로움
- Generic을 이용한 타입 한정
    - 컴파일 타임에 저장하려는 타입 제한 → 형변환의 번거로움 제거

Collection Framework

java.util → 다수의 데이터를 쉽게 처리하는 방법 제공

#### Collection framework 핵심 인터페이스

1. List

   입력 순서가 있는 데이터 집합, 순서가 있으니까 데이터의 중복을 허락

2. Set

   입력 순서를 유지하지 않는 데이터 집합, 중복 허락 x

3. Map

   Key와 value 쌍으로 데이터를 관리하는 집합, 순서는 없고 key의 중복 불가, value는 가능


#### Collection interface

1. 추가
    - add
    - addAll
2. 조회
    - contains()
    - equals()
    - isEmpty()
    - iterator()
    - size()
3. 삭제
    - clear()
    - remove()
4. 기타
    - toArray()

#### 데이터 추가과정

add, addAll → grow

0→ 10→15→ 22> 33 이렇게 늘어난다.

```java
if(oldCapacity >0 || elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA){
	int newCapacity = ArraysSupport.newLength(oldCapacity,
																						minCapacity - oldCapacity,
																						oldCapacity >> 1)	
}
```

이러한 과정을 이해해야지 성능이 좋은 코드를 짤 수 있다.

#### ArrayList의 장단점

- 배열 기반이므로 배열의 장단점을 가진다
- 장점
    - 동일한 크기의 데이터가 연속되어 접근속도가 빠름
- 단점
    - 크기를 변경할수 없어 추가 데이터를 위해 새로운 배열을 만들고 복사해야 한다.
    - 비 순차적 데이터의 추가 및 삭제에 많은 시간이 걸린다.

#### LinkedList

데이터의 삭제 및 추가에 유리

- 각 요소가 다음 요소의 링크 정보를 가지고 메모리에 연속적으로 구성될 필요가 있다
- 삭제 및 추가
    - 각 요소가 가지고 있는 링크만 변경하면 완료


고정 사이즈의 리스트 생성

- Arrays.asList()
    - 고정 크기, add/remove 불가
    - 요소의 수정 가능, null 가능

## Set 계열

---

#### hash 충돌

hash 코드에 관한 압축이 필요

index = (hashcode % 배열의 크기) → 결국 hash는 충돌이 불가피하다.

내부적으로 linkedList를 사용하여 데이터를 관리한다.

## Map 계열

---

hashmap을 사용하는 것을 권장

#### hashMap

- 특징
    - 내부적으로 node<K,V>[]로 데이터 관리
        - 배열의 index는 hash
        - key는 데이터 중복 불가, value는 데이터 중복가능
    - hashset도 내부적으로는 hashMap에 데이터 저장
        - key에 value를 넣고 value에는 dummy 값을 사용

map interface

- 추가
    - put(key, value)
- 조회
- 삭제
- 수정
    - put(key, value)

## 정렬

---

특정 **기준에** 따라 요소의 크기를 비교하여 내림차순, 오름차순으로 배치하는 것

- 정렬 가능한 Collenction
    - 배열, List
    - set에서 SortedSet 계열
    - Map에서 SortedMap 계열

- List<T> 정렬
    - **Collections.sort(List<T> list)**

#### Comparable interface

정렬을 하기 위해서는 위치를 바꿀 기준이 필요하다. 이때 비교를 하기위해 제공 가능한 인터페이스가 Comparable interface이다.

```java
pubic interface Comparable<T>{
	pubic int compareTo(T,O)
}
```

#### Comparator 활용

- 1회성 객체 사용시 anonymous inner class 사용
    - 클래스 정의, 객체 생성을 한번에 처리

    ```java
    Collections.sort(names, new Comparator<String>(){
    	@Override
    	public int compare(String o1, String o2){
    		return Integer.compare(o1.length(), o2.length());
    	}
    });
    ```

    - 람다 표현식 이용

    ```java
    Collections.sort(names,(o1,o2)->{
    	return Integer.compare(o1.length(), o2.length());
    });
    ```


## Lambda

---

- 람다식이란?
    - 함수적 프로그래밍 형태로 재사용 가능한 코드블록
    - 기존의 anonymous inner class를 이용한 처리방식으로 간결하게 처

타겟 타입과 @Functionalnterface

- 타겟 타입은 abstract 메서드가 반드시 하나만 존재해야 한다.
- 타겟 타입은 **abstract 메서드가 반드시 하나만 존재**해야 한다.
- FunctionalInterface
    - 컴파일러가 재정의해야 하는 abstract method가 하나만 있음을 체크한다.
        - 안정적인 programming을 위한 옵션

#### 메서드 참조

- 람다 실행문 내부에서 **다른 함수 하나만**을 실행하는 경우 ::연산자를 이용해 기존 메서드 참조
    - <소유자>::<파라미터 사용하는 소유자의 메서드>
- 파라미터 인스턴스 메서드 참조
    - 객체::인스턴스 메서드
        - 첫번째 파라미터는 메서드의 소유자 나머지 파라미터는 메서드의 파라미터로 순서대로 전달된다.
    - 특정 객체의 instance 메서드 참조
        - 객체의 메서드가 호출되며 파라미터는 메서드에 그대로 전달된다.

        ```java
        names.forEach(item)-> names.add(item)
        names.forEach(names:add)
        ```


#### 함수형 프로그래밍

#### 표준 API 종류

- Runnable 계열
    - 단순 실행처리, return x
- Consumer 계열
    - 소비자, void로 반환, return x
- Supplier
- Function
    - parameter을 return으로 매핑, 새로운 타입으로 변환시켜 리턴
    - Bifunction<T,U,R> :T와 U 타입의 파라미터를 받고 R타입으로 리턴
    - 주로 파라미터를 연산한 뒤 원하는 형태로 반환
- Operation
    - 동일한 타입으로 연산 결과를 리턴

#### Optional<T>

- T타입에 관한 wrapper
- 객체가 있을 수 있고 없을 수 있는 null 상태를 나타내는 객체
- **nullpointException에 적극적인 대처가능**

관련 메서드

- get()
    - 값을 리턴 , null인 경우 NullpointerExcepion 발생
- ifPresent
    - public void ifPresendt( Consumer<? super T> consumer)
    - consumer을 통해 값을 소비, 없으면 동작하지 않는다.
- orElse
    - public T orElse(T other)
    - Optional의 값이 있으면 그값을 소비, 만약 값이 null인경우 Supplier인 other을 통해 공급받은 값 리턴

## Stream API

---

stream이란?

- jdk8에서 추가되었다.
- 배열 및 collection의 요소를 하나씩 참조해서 처리하는 목적
- 람다와 내부 반복자를 이용해 요소를 다루는 코드를 간결화

역할 및 특징

- 컬렉션, 배열 등 데이터 소스에 대한 공통된 접근 방식 제공
- 손쉬운 병렬 처리

Map/Reduce 모델 지원

- 맵: 데이터를 작은 단위로 나누어 지정된 함수를 적용 처리
- 리듀스: 결과를 모아서 최종 결과를 생성

중간 처리들과 최종 처리를 조합해서 사용한다.

- 중간 처리: 매핑, 필터링, 정렬 등 가공 처리 → n개 산출된다.
    - 필터링
        - distinct(), filter()
    - 자르기
        - skip(),limit()
    - 조회
        - peek() → 디버깅을 위해 갔다 오는 것을 의미
    - 매핑
- 최종 처리: 반복, 카운팅, 평균, 총합 등의 집계 처리 → 1개 산출
    - 매칭
        - allMatch(), anyMatch(), noneMatch()
    - 수집
        - collect()
    - 루핑
        - forEach()

중간 처리는 최종 처리가 진행될 때까지 지연된다.

→ 최종처리를 붙여야지 중간 처리의 출력을 실행한다.

각각의 중간 처리는 새로운 스트림을 리턴하여 chaining 패턴을 적용한다.

- 한번 최종 처리가 끝난 스트림은 재사용 불가

Collection, 배열, File, Random 및 스트림 클래스의 static or default method로 생성한다.

## 보충

---

remove, put에는(int index) Generic<T>, (Object o) boolean 이런 식으로 overloading으로 기능은 같지만 매개변수에 따라 다른 결과가 나오는 메서드가 존재한다.

of 메서드

list, map 과 같은 것을 쉽게 만들 수가 있다.

자료삭제시 주의사항 → 테스트에 나올 수도 있다.

일반 상용화 코드를 짤 때 null safe 한지 점검해주는 코드를 넣어야 한다.

NullPointerException이 발생하면 안된다.

```java
if(this.no == null){
	return -1;
}else if(o.no == null){
	return 1;
}
return no.compareTo(o.no);
```

이너클래스(공식적으로는 Nested Class) outer Class

```java
//C.class
//C$Inter1
public class C{
	C(){
	}
	class Inter1{
	
	}
	void m1(Inter inter){}
	interface Inter1{
	
	}
	void m2(int a){
		new Thread (new Runnable() {
			@Override
			public void run(){
			
			}
		}).start();
	}
	public static void main(){
		new C();
	}
}
```

시간복잡도 관련 Math.max를 사용할 때의 주의점