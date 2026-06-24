---
tags: [tier/low]
type: policy
date: 2026-06-24
status: active
---

# Error Policy

에러 노트 작성·생명주기 규칙이다. 에러를 기록/조회하는 작업일 때 읽는다.

## Status

- `active`: 아직 재발 가능성이 높고 현재도 주의해야 함
- `resolved`: 해결책이 검증되었으나 여전히 참고 가치 있음
- `obsolete`: 환경 변화 또는 더 좋은 규칙으로 대체되어 현재는 직접 적용하지 않음

## Error vs Pattern

- error: 특정 실패 사례와 root cause (`{domain}-errors`)
- pattern: 여러 error/experiment에서 일반화된 접근 방식 (`patterns/{domain}-patterns`)

## Required Fields

Error note는 symptom, root cause, trigger, fix, prevention rule, related experiments, links를 포함한다. 파일명은 `{domain}-errors`(예: mjlab-errors, obsidian-errors)로 도메인별 통합한다.
