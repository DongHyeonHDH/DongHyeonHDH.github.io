---
title: "2026-04-15 정리본"
tags:
    - git
    - java
date: "2026-04-15"
thumbnail: "/assets/img/thumbnail/grapaduck.jpg"
bookmark: true
---

# Follow the guidance
---

**Fill the image path to the 'thumbnail' attribute, if you want a main image to be displayed on the post header image.**

```
---
title: "Example Post: thumbnail exists"
date: "2023-12-02"
thumbnail: "/assets/img/thumbnail/bricks.webp"
---
```

The rest content is just meaningless dummy text.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

# Git 다루기
---
**git으로 처음 작성하는 코드.** 

Git
- 버전 제어 체계(vcs)
- 버전 : 특정 상태에 대한 일정한 규칙에 따른 일련번호
- 형상 관리 시스템

s/w 생명주기

기획 설계 구현 (기능 추가, 성능개선, 버그 수정) , 검사, 배포, 유지보수

여기서 버전 관리도 되게 중요하다.

 

호스팅

어떠한 서비스를 고객들에게 제공해주는 행위

git을 호스팅하는 프로그램들 예시

- Bitbucket
- Github
- Gitlab


### 지역 저장소(local Repository)

내 컴퓨터

프로젝트 폴더

- git.init, 저장할 로컬 리포지토리가 프로젝트 디렉토리 안에 생긴다.
- 프로젝트 폴더 내에서 실행을 해야한다.
    - 바로는 안보인다. 숨김파일로 생성이 되기 때문
    - 실수로 삭제하지 말라고 숨김파일로 생성이 된다.

프로젝트 파일

<aside>
💡

git commit 시 업로드 되는 파일을 적절하게 조절하는 것도 하나의 과정이다.

</aside>

#### 로컬에서의 Commit

git은 commit을 받아 스테이지에 저장 → 하나의 버전이 생긴다. 

이때 git은 원격 리포지토리에 저장하는 것이 아니고 로컬 repository에 저장을 하게 된다.


- 버전 저장하기

```java
git commit -m "MESSAGE"
```

<aside>
💡

협업을 할때 처음 결정하는 것

**커밋 메세지 어떻게 작성을 할 것인지?**

—> 커밋 컨벤션 참고하는 편이 좋다.

—> 커밋 규칙을 세워두고 시작하자

</aside>

EX) feat, 회원 가입가능, fix, bug, chore과 같이 앞에 어떤 말을 정해서 알려주는 것이 좋다.

- jira 툴 → 현업에서 많이 쓰이는 협업도구

로컬 리포지토리에 커밋 히스토리가 기록된다.

커밋 하나당 커밋 메시지가 생기게 된다. 

커밋 내역을 확인하고 이전 버전으로 돌아간다.


#### Branch

![image.png](attachment:bd617741-8e90-4a4c-948b-fc589f9db23b:image.png)

```java
git branch <branch name>
```

![image.png](attachment:4cfcdfa0-bf1b-4e4d-aaf5-a4e186ad3637:image.png)

```java
git checkout <branch name>
```

![image.png](attachment:d914b017-df95-4b9c-9136-1dd00fa5d3a5:image.png)

### 원격 저장소

![image.png](attachment:76374307-c6fa-4bfb-a644-f302a84c2270:image.png)

로컬을 업로드 할 원격지 레포지토리를 만든다.

![image.png](attachment:ebe990e1-a7e6-4141-a626-b2a9c8b585c8:image.png)

로컬을 업로드할 원격지 레포지토리

origin 대신에 [별칭][URL] 을 사용할 수가 있는데 이 이유는 하나의 로컬 레포지토리에 여러 원격지 레포지토리를 두는 것이 가능하기 때문이다.

<aside>
💡

자주나오는 실수

원격 레포지토리와 로컬 레포지토리의 히스토리가 다른 경우

충돌이 발생할 수가 있다.

</aside>

 

![image.png](attachment:c1513123-e603-4ca6-b345-94602707910c:image.png)

```java
git push [별칭] [브랜치이름]
```

- push를 할 때 현재 head가 가리키고 있는 브랜치에 시도를 해야한다.
- 로컬 레포지토리에 작성되어 있는 버전을 원격 레포지토리에 업로드를 하는 것

```java
#branch 생성하기
git branch

#branch 변경하기
git checkout -b branch
```

**git clone**

![image.png](attachment:f4210871-706f-4fa0-8ee4-d8203b2c4d71:image.png)

**git merge**

<aside>
💡

markdown → 잘 정리되어 있고 흥미를 돋구는 내용으로 작성할 것

참고

>표시 : 인용구라는 의미  

</aside>

![image.png](attachment:bf5fcf83-d0da-413b-a79c-7c52534173db:image.png)

 git 자체는 뭐가 최신인지 이전 것인지를 구분하지 못한다(ambigious) →  사용자가 정해줄 필요가 있다.

이것을 못 푸는 경우 일어나는 것이 충돌(conflict)



![image.png](attachment:6a693dd1-8b24-4926-962e-412da75bc472:image.png)

첫번째는 없던 문장이 추가되는 것이니 큰 문제가 아니지만 branch가 여러 개일 때 똑같은 코드를 여러명이 만질때 해결(resolve)를 해줘야 한다.

**git rebase**

![image.png](attachment:cb38929d-1f0e-4d6d-88ac-4336095ae736:image.png)

로컬과 원격이 버전이 많이 차이나는 경우

리베이스는 → 두 개로 나눈 브랜치를 하나로 뭉게서 합치는 것, 시간 순서로 계산한다.

단점 : 잘못된 병합에서 잘못된 점을 해결하기 힘들 수가 있다.

장점 : 히스토리를 하나로 합칠 수가 있다.

 

![image.png](attachment:86ba10bf-a74d-4734-a262-82837ca80d44:image.png)

이 경우 히스토리가 일렬로 맞춰지기 때문에 merge를 할 수가 있다.

일단은 보편적인 3way merge로 합병 연습을 할 것

 

<aside>
💡

참고 (기술 면접이나 알고있다고 어필하면 좋은 것)

MSA 마이크로 서비스 아키텍쳐

여러 개의 작은 서비스로 구성되고 각 서비스가 독립적으로 개발되고 배포되는 구조

![image.png](attachment:7e3e6a2e-96f3-4b8a-979c-5d80f755041c:image.png)

- 장점
    - 서비스 간 독립성으로 확장성과 유연성이 올라간다
    - 기능 독립성이라는 특징 때문에 일부 서비스가 실패해도 전체 시스템에 영향을 미치지 않는다
- 단점
    - 서비스간 통신이 필요, 서로 간의 연결 구축이니 관리의 복잡성이 증가
    - 초기 개발 및 통신 등에 시간이 소모

출처: https://mozzi-devlog.tistory.com/34

</aside>

파일의 위치를 표시하는 법

1. 절대경로법
2. 상대경로법
    1. . → 내가있는곳
    2. .. → 내가 있는 곳 상위 디렉터리

```java
#스테이지의 현재상태 확인
git status
```

→ git을 시작했는데 등록을 안했다고 오류가 뜨는 경우 → git config 

![image.png](attachment:a648ce63-2482-496d-90d7-7de7834c715b:image.png)

<aside>
💡

참고

로그와 출력의 차이 (로깅을 해야하는 이유)

로그는 출력한 것을 파일로 뽑는 것이 가능하다. → 추후 elasticsearch와 같은 툴로 활용가능하다.

</aside>

**git log**

현재 head위치와 commit message를 보내는 시간이나 정보가 나오게 된다.

debug, info, error ,fatal

→ fatal은 시스템에 치명적인 오류

![image.png](attachment:6595505f-ee67-434b-89a2-eb2afefbfe73:image.png)

github 블로그를 만드는데 히스토리 관련오류가 발생

## JDBC(Java Database Connectivity)

API

→ 우리가 프로그램을 통해 소통할 수 있는 인터페이스

jdbc도 API이다. 

구체클래스 concrete class 

드라이버 → 연결되어 result set이라는 형태의 타입이 존재하는데 애플리케이션에서 

사용가능 할 수 있도록 반환

요즘은 JDBC를 기반으로 하는 툴, JDBC 기술을 가지는 툴을 반환해준다.

```java
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
} catch (ClassNotFoundException e) {
		throw new RuntimeException(e);
}

```

```java
//기본적인 JDBC연결
static void main() {
        final String PORT = "3306";
        final String URL =  "jdbc://mysql://localhost:%s/jdbc_shop".formatted(PORT);
        final String USERNAME = "rapa_jdbc";
        final String PASSWORD = "pwd1!";

        try (Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD)){

            System.out.println("데이터베이스 연결 성공");
            System.out.println("사용된 드라이버 이름: " + connection.getMetaData().getDriverName());
            System.out.println("연결된 url:" + connection.getMetaData().getURL());
//            connection.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }
```

하지만 여러 데이터베이스를 다루고 다른 메인 코드에서 손쉽게 접속하기 위해서는 클래스 화가 필요한데 이때 추상메서드로 지정해서 가져오는 것이 좋다. 다른 코드에서 조작하지 못하게 static final로 변수를 지정해주자.

```java
public abstract class ConnectionUtil {

    public static abstract class H2{

        private static final String URL = "jdbc.h2:mem:test_db";
        private static final String USER = "sa";
        private static final String PASSWORD = "";

        public static Connection getConnection(){
            try{
                return DriverManager.getConnection(URL, USER, PASSWORD);
            }catch (Exception e){
                System.out.println("데이터베이스와의 연결에 실패하였습니다.");
                throw new RuntimeException(e);
            }
        }

    }

    public static abstract class MySQL{

        private static final String URL = "jdbc.mysql://localhost:3306/jdbc_shop";
        private static final String USER = "rapa_jdbc";
        private static final String PASSWORD = "pwd1!";

        public static Connection getConnection(){
            try{
                return DriverManager.getConnection(URL, USER, PASSWORD);
            }catch (Exception e){
                System.out.println("데이터베이스와의 연결에 실패하였습니다.");
                throw new RuntimeException(e);
            }
        }

    }

}
```