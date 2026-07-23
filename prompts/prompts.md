---
tags: [tier/upper]
---

# Prompts

## Graph

- [[prompts/query|query]]
- [[prompts/ingest|ingest]]
- [[prompts/reflect|reflect]]

## Summary

세 공개 명령의 prompt graph 중심 노드다. 개별 prompt 파일끼리는 직접 연결하지 않고, 이 노드를 통해서만 묶는다.

## Command Routing Table

공개 명령은 세 개만 유지한다. 새 동작이 필요하면 우선 이 인터페이스 뒤의 자동 수명주기로 구현한다.

| 명령 | 언제 | 모드 | 경계 |
|---|---|---|---|
| `query` | 단일 질문·사실 확인 | 읽기 전용 | 필요한 정본만 읽고 근거와 함께 답함 |
| `ingest` | raw/source를 wiki로 | 쓰기 | 중복을 피하며 typed research object와 canonical topics로 컴파일 |
| `reflect` | 실험·구현·ingest 후 배운 점 | 쓰기 | durable filter를 통과한 내용을 canonical home으로 분류·승격 |

작업 재개, 선별 저장, write 후 품질 검사, archive 정리는 `agent-policy`의 Automatic Lifecycle을 따른다.
