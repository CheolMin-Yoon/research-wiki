---
tags: [tier/upper]
---

# Prompts

## Graph

- [[prompts/save|save]]
- [[prompts/reference|reference]]
- [[prompts/query|query]]
- [[prompts/ingest|ingest]]
- [[prompts/lint|lint]]
- [[prompts/reflect|reflect]]
- [[prompts/archive|archive]]

## Summary

명령어 prompt graph의 중심 노드다. 개별 prompt 파일끼리는 직접 연결하지 않고, 이 노드를 통해서만 묶는다.

## Command Routing Table

명령은 7개를 유지한다. 새 명령을 만들지 말고 아래 경계로 라우팅한다. `save`/`reflect`, `query`/`reference`는 통합하지 않는다.

| 명령 | 언제 | 모드 | 경계 |
|---|---|---|---|
| `query` | 단일 질문·사실 확인 | 읽기 전용 | 필요한 노트만 읽고 간결히 답함. 맥락 복원 아님 |
| `reference` | 작업 시작 전 맥락 복원·조언 | 읽기 전용 | index·log·brief·관련 노트로 결정/함정/패턴 복원 |
| `save` | 세션 산출물 저장 | 쓰기 | Save Filter 통과분만 저장 (저장 여부 판단) |
| `reflect` | 실험·구현·ingest 후 배운 점 | 쓰기 | experiment/error/anti-pattern/decision으로 분류·승격 |
| `ingest` | raw/source를 wiki로 | 쓰기 | 중복 회피하며 papers/sources/ideas로 컴파일 |
| `lint` | 문제 발견·보고 | 보고 | `wiki_doctor` 실행 + 의미 점검. 수정은 승인 후 |
| `archive` | obsolete/archive 실제 정리 | 쓰기 | 삭제 대신 보존·status 처리 |
