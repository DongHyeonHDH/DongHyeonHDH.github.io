---
title: "Elasticsearch 검색과 데이터 파이프라인 정리"
tags:
    - project
    - 바로그림
    - elasticsearch
    - logstash
date: "2026-09-06"
bookmark: false
---

바로그림 작업일지에는 MySQL의 이미지·프롬프트 정보를 Elasticsearch로 가져오고, 검색 로그를 바탕으로 트렌드를 살피려는 구상이 남아 있다. 이 글은 그 과정에서 반복된 개념을 하나로 묶고, 현재 공식 문서로 확인 가능한 내용만 남긴 정리다. 당시 메모의 배포·운영 설정과 미완료 계획은 결과로 표현하지 않았다.

## 검색용 필드 설계

프롬프트처럼 전문 검색할 내용과 태그처럼 정확히 분류·집계할 내용을 같은 필드 유형으로 다루지 않는 방향을 검토했다. Elasticsearch에서 `text`는 전문 검색에 쓰고, `keyword`는 정렬·집계·`term` 같은 term-level query에 주로 사용한다. `keyword` 필드를 전문 검색에 쓰는 것은 권장되지 않는다. [Elasticsearch keyword field 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html)

작업일지의 프롬프트, 부정 프롬프트, 태그와 검색 조건에 관한 기록은 이 구분을 어떤 데이터에 적용할지 고민한 메모다. 실제 매핑과 analyzer는 데이터 형태와 검색 요구를 확인한 뒤 결정해야 한다.

## 문구 검색과 term vectors

강의와 작업일지에서는 `match_phrase`와 term vectors를 살폈다. `match_phrase` query는 입력 텍스트를 분석한 뒤 phrase query를 만든다. 따라서 단어가 같은지만 보는 검색과 문구 순서·인접성을 고려해야 하는 검색은 구분해서 선택해야 한다. [Elasticsearch match phrase query 문서](https://www.elastic.co/docs/reference/query-languages/query-dsl/query-dsl-match-query-phrase)

Term vectors API는 특정 문서의 필드에 대해 term 정보와 통계를 조회할 수 있다. 이 API 결과를 활용해 빈도를 계산하는 방식은 작업일지에 있었지만, 그 값만으로 검색 품질이나 사용자 선호를 확정할 수는 없다. [Elasticsearch term vectors API 문서](https://www.elastic.co/docs/api/doc/elasticsearch/v8/operation/operation-termvectors)

## MySQL에서 Elasticsearch로 가져오는 구상

MySQL의 그림 정보 테이블을 검색용 인덱스로 가져오는 방법과, 마지막으로 수집한 시간 이후의 데이터만 가져오는 방법을 검토했다. Logstash JDBC input은 JDBC 인터페이스가 있는 데이터베이스에서 데이터를 읽어 올 수 있으며, 조회 결과의 각 행을 event로 만든다. 주기 실행은 `schedule`, `period`, `interval` 중 하나로 설정할 수 있다. [Logstash JDBC input 문서](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html)

증분 수집을 할 때는 마지막 실행 상태와 기준 열을 분리해 관리해야 한다. 여러 JDBC input이 `sql_last_value`를 쓴다면 각 input에 별도의 `last_run_metadata_path`가 필요하다. 이 점은 작업일지에서 파이프라인을 나누어 실행하려 했던 기록을 다시 확인하는 기준이 되었다.

## Kibana과 트렌드 메모

Kibana에서는 data view가 하나 이상의 index, data stream, alias를 가리킬 수 있고 Discover 같은 분석 기능은 보통 이를 통해 데이터에 접근한다. [Kibana Data views 문서](https://www.elastic.co/guide/en/kibana/current/data-views.html)

바로그림에서는 프롬프트 태그와 검색 로그를 시간 단위로 모아 순위·트렌드에 반영할 수 있을지 검토했다. 이는 구현 완료 결과가 아니라 데이터 기준, 기간 조건, 가중치가 더 필요했던 설계 메모다. 검색 로그를 쓴다고 해서 사용자 의도나 품질이 자동으로 보장되는 것은 아니므로, 실제 적용 전에는 수집 범위와 평가 기준을 따로 정해야 한다.
