---
tags: [tier/low]
---

# Ingest Prompt

```text
AI-Sessions/raw/에 추가된 자료를 ingest 해줘.

먼저 architecture.md, research.md, research-policy, schema/research-topics.json, AI-Sessions/wiki/harness/state/brief.md를 확인해줘.

raw 원본은 읽기 전용으로 취급하고 수정·삭제하지 마. Research Library와 관련 노트를 확인해 중복을 피하고, 같은 객체가 있으면 새 문서보다 기존 노트 갱신을 우선해. 상충하는 내용은 덮어쓰지 말고 근거별로 분리해.

- 논문: research/papers의 검증 가능한 paper 근거 노트
- 코드·GitHub 저장소: research/sources의 실제 구현 분석
- 정의·원리: promotion gate를 통과할 때 concept 또는 method
- 로봇 문제 설정: task
- 여러 근거의 선택 기준·종합: comparison
- 사용자 가설: 반증 조건이 있는 idea
- 실행 사실: experiment
- 결정·실패·anti-pattern: harness의 decision/error/pattern
- granular 구현 작업: wiki가 아니라 프로젝트 저장소

모든 research note는 type/date/status/topics/source 계약을 따르고 canonical topic만 사용해. alias, unknown, pending topic을 note에 쓰지 마. 새 후보는 pending queue에 추가해 큐레이터에게 승인을 요청해. category, primary_category, 단일 소속 규칙은 사용하지 마.

topic membership은 graph edge가 아니다. 설명 가치가 있는 관계만 ## Relations에 전체 경로 wikilink로 기록하고, raw는 source property/plain path로만 남겨. idea 변경은 paper 등록·이동을 유발하지 않는다. 수동 paper/source inventory와 자동 backlink를 만들지 말고 Bases를 사용해.

큰 ingest나 운용 규칙 변화만 log.md에 한 줄 남겨. 마지막에 scripts/wiki_doctor.sh와 unit tests를 실행해 ERROR=0, WARN=0을 확인해줘.

저장 전 durable capture gate를 적용해. 다른 세션·프로젝트에서 재사용할 지식, 추적할 결정 근거, 반복될 실패 위험, 공유할 규칙만 wiki에 남긴다. 단순 진행 상황이나 코드에서 바로 재구성할 수 있는 설명은 저장하지 않는다. 구조나 stable wikilink graph가 바뀌면 Louvain --check도 실행해.
```
