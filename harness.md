# Harness Index

harness 운용 지식의 읽기 라우터다. 작업에 필요한 detail만 추가로 연다.

## Init

- `AI-Sessions/wiki/harness/policies/agent-policy.md` — reading order와 운용 규칙
- `AI-Sessions/wiki/harness/patterns/agent-patterns.md` — 반복 실수 방지

## 작업별 Routing

| 작업 | 읽을 정본 |
|---|---|
| graph, Bases, 구조, prompt routing, migration | `policies/obsidian-policy.md`, `decisions/obsidian-decisions.md` |
| typed research ingest, topic 승인, 관계 규칙 | `policies/research-policy.md`, `decisions/research-decisions.md` |
| 에러 기록·조회 | `policies/error-policy.md`, `errors/{domain}-errors.md` |
| `/home/frlab/mj_rl` 구현·리팩터 | `patterns/mjlab-patterns.md` |
| archive·정리 | `policies/archive-policy.md`, `archive/obsolete-index.md` |
| 하네스 설계 의도 | `decisions/harness-decisions.md` |
| 새 노트 양식 | `templates/{type}-template.md` |
| wiki 품질 검사 | `evals/evals.md`, `scripts/wiki_doctor.sh` |

## Current State

- 현재 맥락: `AI-Sessions/wiki/harness/state/brief.md`
- 인수인계: `AI-Sessions/wiki/harness/state/handoff.md`
- 작업 큐: `AI-Sessions/wiki/harness/state/tasks.md`
- research backlog: `AI-Sessions/wiki/harness/state/research-backlog.md`

## Naming

harness 파일은 `{domain}-{type}`을 기본으로 한다. `agent-*`는 init, `{domain}-*`는 해당 도메인 작업에서만 읽는다.
