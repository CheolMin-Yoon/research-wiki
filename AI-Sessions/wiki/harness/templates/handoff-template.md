---
tags: [tier/low]
type: template
date: 2026-06-24
status: active
target_type: handoff
---

# Handoff Template

```markdown
---
type: handoff
date: YYYY-MM-DD
status: active
last_agent:
suggested_next_agent:
mode: planning | implementation | verification | reference | ingest | lint | archive
---

# Handoff

## Current Goal

## Last Completed

## Next Action

## Dirty / Sensitive Files

## Do Not Touch

## Open Questions

## Relevant Files

## Notes

## Context Compaction Checklist

컨텍스트 압축 직전 handoff에 보존할 항목 확인.

보존 필수:
- [ ] 현재 목표 (Current Goal)
- [ ] 사용자 제약·금지 사항 (Do Not Touch)
- [ ] 로드된 정책 파일 목록 (agent-policy, 해당 domain-policy)
- [ ] 활성 계획 또는 진행 중인 작업 단계
- [ ] 미완료 Open Questions

버려도 됨:
- 완료된 subtask 상세 탐색 기록
- stale 중간 로그 / 이미 반영된 결과
```
