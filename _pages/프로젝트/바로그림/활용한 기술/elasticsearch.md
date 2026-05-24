---
title: ELK스택 활용
tags:   
    - web
    - project
    - 프로젝트
    - elasticsearch
    - elk    
date: "2026-05-18"
thumbnail: "/assets/img/thumbnail/elk-stack.png"
bookmark: true
---

# Elasticsearch 로컬 설치
로컬 서버 컴퓨터에 포트를 열고 서버 컴퓨터에 설치된 elasticsearch에 연결시 
https 관련 인증서 문제가 발생한다.

> kibana 설치
    server.host는 0.0.0.0 으로 설정

# 검색 알고리즘 설계
---
## 이미지 프롬프트 사용
검색에 사용하는 attribute 종류들
- positive_prompt
- negative_prompt
- model_hash
- cfg_scale
- denoising_strength
- sampler

## match_phrase문 분석

```python
#검색 쿼리를 위한 match_pharse문 생성
    def match_phrase(self,positive,phrase):
        actions = {
            "match_phrase": {
                positive: {
                    "query": phrase,
                    "slop": 1
                }
            }
        }
        if phrase == "":
           actions = {
            "match_phrase": {
                positive: {
                    "query": "blank",
                    "slop": 1
                }
            }
        }
           
        if phrase == 0:
           actions = {
            "match_phrase": {
                positive: {
                    "query": "blank",
                    "slop": 1
                }
            }
        }
        return actions
    
```

## mtermvectors 도입

```python
# mtermvectors API 실행
    response = self.es.mtermvectors(
        index=self.index_name,
        body={
            "docs": [
                {
                    "_id": doc_id,
                    "fields": [str(prompt)]
                }
                for doc_id in recent_ids
            ]
        }
    )
```
elasticsearch의 mtermvectors API를 도입

```python
# Elasticsearch에 mtermvectors 실행
if 'docs' in response:
    for doc in response['docs']:
        if 'term_vectors' in doc:
            term_vectors = doc['term_vectors']
            if str(prompt) in term_vectors:
                # 역색인 정보를 사용하여 원하는 작업을 수행합니다.
                for term, info in term_vectors[str(prompt)]['terms'].items():                                                                  
                    if term in term_freq_dic:
                        temp = term_freq_dic.get(term)
                        term_freq_dic[term] = temp + info['term_freq']
                    else:
                        if isinstance(term,float) == True:
                            continue
                        elif isinstance(term, int) == True:
                            continue
                        else:                                
                            term_freq_dic[term] = info['term_freq']                                             
                                            
        else:
            print(f"No term vectors found for Document ID: {doc['_id']}")        
else:
    print("No documents found.")
```


```python
no_dic = ['detailed','and','best','a','the','of','in','detail','masterpiece','with','at','up','by','very','perfect','to','is','on','quality','realistic',]
        data_list = []
        # 상위 100개의 아이템을 출력합니다.
        n = 20
        count = 0
        i = 0

        while count < n and i < len(sorted_frequency):
            sf = sorted_frequency[i]
            if sf[0] in no_dic:
                i += 1
                continue

            try:
                float(sf[0])
            except:
                data_list.append(sf)
                count += 1
            i += 1

```

tf-idf 알고리즘을 도입하는데 detail, best, a 와 같은 자주 사용하지만 검색에 큰 영향을 끼치지 못하는 단어를 dictionary에서 제외하고자 한다.

