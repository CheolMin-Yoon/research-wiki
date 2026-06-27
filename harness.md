# Harness Index

harness 운용 지식의 읽기 라우터다. **harness 작업이 필요할 때만** 이 파일을 읽고, 여기서 가리키는 필요한 detail만 추가로 연다. (context 절약 Tier 2 — 자세한 계층은 `architecture.md` 참조)

## init에 함께 읽는 것 (`agent-*`)

- `AI-Sessions/wiki/harness/policies/agent-policy.md` — 에이전트 운용 규칙, reading order, loading trigger
- `AI-Sessions/wiki/harness/patterns/agent-patterns.md` — 반복 실수 방지 (실제 상태 검증 등)

## 작업할 때만 읽는 것 (`{domain}-*`)

| 이런 작업이면 | 읽어라 |
|---|---|
| graph/구조/map/prompt routing 변경, migration | `policies/obsidian-policy.md`, `decisions/obsidian-decisions.md` |
| 에러 기록·조회 | `policies/error-policy.md`, `errors/{domain}-errors.md` (mjlab/obsidian…) |
| 연구 category 추가·ingest 규칙 | `policies/research-policy.md` |
| 문서 archive/정리 | `policies/archive-policy.md`, `archive/obsolete-index.md` |
| 하네스 설계 의도 확인 | `decisions/harness-decisions.md` |
| 새 노트 양식 | `templates/{type}-template.md` |
| wiki 품질 검사 | `evals/evals.md` + `scripts/wiki_doctor.sh` |

## 현재 상태

- 현재 맥락: `AI-Sessions/wiki/harness/state/brief.md`
- 인수인계: `AI-Sessions/wiki/harness/state/handoff.md`
- 작업 큐: `AI-Sessions/wiki/harness/state/tasks.md`

## 명명 규칙

파일명은 `{도메인}-{타입}` (상위 레이어를 맨 앞에). `agent-`는 init 로드, `{domain}-`은 그 도메인 task 때 로드. 문장형 슬러그 금지.
