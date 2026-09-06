# Notion → Jekyll staging converter

Notion의 Markdown 본문을 고치지 않고, 현재 블로그의 기존 `_pages` 분류에 맞는 새 문서만 **별도 staging 폴더**에 준비한다. 로컬 이미지 링크만 staging asset 경로로 바꾼다. 외부 블로그 저장소에는 어떤 파일도 쓰지 않는다.

기본 실행은 dry-run이며 JSON 보고서만 출력한다.

```powershell
& .\tools\notion_blog_converter\Convert-NotionBlog.ps1 `
  -SourceRoot '.\notion_export_windows_compatible\개인 페이지 & 공유된 페이지' `
  -BlogRoot 'C:\Users\aaabb\Documents\GitHub\DongHyeonHDH.github.io' `
  > .\output\notion-blog-dry-run.json
```

검토 후 staging 파일을 새로 만들려면 `-Write`를 붙인다.

```powershell
& .\tools\notion_blog_converter\Convert-NotionBlog.ps1 `
  -SourceRoot '.\notion_export_windows_compatible\개인 페이지 & 공유된 페이지' `
  -BlogRoot 'C:\Users\aaabb\Documents\GitHub\DongHyeonHDH.github.io' `
  -StagingRoot '.\output\notion-blog-staging' `
  -Write
```

안전 정책:

- 대상 파일이나 manifest가 이미 있으면 덮어쓰지 않는다.
- 블로그의 기존 제목/본문과 export 내부의 중복 제목/본문을 제외한다.
- 비밀번호·토큰·private key 등 비밀정보 위험은 값 없이 경로와 사유만 보고하고 제외한다.
- 명확히 매핑되지 않는 주제는 임의 분류하지 않고 검토 대상으로 건너뛴다.
- CSV는 목록만 작성한다. Notion 데이터베이스 index 행을 게시물로 만들지 않는다.
- 날짜 속성이 없는 문서는 기본적으로 `date_missing`으로 건너뛴다. 임의 날짜를 만들지 않는다.
- `-DefaultYear 2026`처럼 연도를 명시한 경우에만 `6월 23일 ...` 형태의 파일명에서 날짜를 추론한다. 실제 달력에 없는 날짜는 오류로 처리한다.
- 경로 이탈, 잘못된 날짜, 깨진 front matter, 없는 이미지 참조는 오류로 보고한다.
- 생성 결과를 블로그로 옮기거나 커밋하는 단계는 의도적으로 포함하지 않는다.

테스트:

```powershell
& .\tools\notion_blog_converter\tests\Run-Tests.ps1
```
