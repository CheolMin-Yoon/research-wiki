---
tags: [tier/mid]
type: map
date: 2026-06-24
status: active
---

# Evals

## Summary

wiki 품질 게이트를 담는 evals 폴더 hub다. 기계 검증 정본은 `scripts/wiki_doctor.sh`이며 write 뒤 자동 품질 검사가 그 출력을 기준으로 보고한다.

의미 판단이 필요한 probe(요약 충실도, 노트가 핵심 질문에 실제로 답하는지 등)는 정적 파일로 미리 늘리지 않고, 필요할 때 이 hub 아래에 on demand로 추가한다.
