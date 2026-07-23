---
tags: [tier/low]
type: decision
date: 2026-07-24
status: active
---

# Research Decisions

## Typed knowledge and multi-topic metadata

연구 구조를 `idea → category → paper` 트리에서 concept, method, task, paper, source, comparison, idea, experiment의 독립 타입으로 전환한다. 한 논문을 하나의 category에 강제로 배정하면 아이디어 변경이 전체 graph를 재배치하고 다중 소속을 잃기 때문에, 소속은 큐레이터가 승인한 다중값 `topics`로 표현하고 graph에는 설명 가치가 있는 strong relation만 남긴다.

### Considered options

- 단일 primary category: graph는 단순하지만 연구 내용의 다중 소속을 왜곡한다.
- 자유 입력 tag: 빠르지만 동의어와 철자 drift를 통제할 수 없다.
- 자동 community를 정본으로 기록: 탐색에는 유용하지만 링크 변화가 지식 의미를 덮어쓴다.

### Consequences

- category 파일과 `primary_category`는 삭제하며 Git 이력만 복구 수단으로 사용한다.
- ideas와 experiments는 paper 등록 경로를 소유하지 않는다.
- Louvain community는 추적 가능한 진단 결과지만 노트 metadata를 수정하지 않는다.
- concept/method/task는 독립 근거 두 개 이상 또는 큐레이터 승인 때만 승격한다.
