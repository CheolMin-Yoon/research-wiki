---
tags: [tier/mid]
type: map
date: 2026-06-24
status: active
---

# Evals

## Summary

wiki 품질 게이트를 담는 evals 폴더 hub다. 기계 검증 가능한 항목은 모두 `scripts/wiki_doctor.sh`로 흡수되어 있다(lint이 호출):

- C6 ingest coverage (raw paper/repo -> wiki 컴파일)
- C7 source provenance (source 노트의 `source:`가 실재 raw 가리킴)
- C8 concept orphan (참조 없는 concept 탐지)
- C11 index coverage (research 노트가 architecture.md에 등재)

의미 판단이 필요한 probe(요약 충실도, 노트가 핵심 질문에 실제로 답하는지 등)는 별도 정적 파일로 두지 않고, 필요할 때 이 hub 아래에 on demand로 추가한다. 과거의 check hub/probe 비계는 wiki_doctor로 흡수되어 제거했다.
