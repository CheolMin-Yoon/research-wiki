# Research Wiki Architecture

이 문서는 vault 구조와 읽기 순서를 복원하는 시작점이다. `research`는 재사용 가능한 연구 지식, `harness`는 작업 규칙과 실패 방지, `state`는 현재 진행 상태, `evals`는 품질 검사를 담당한다.

## Start Here

1. 자동 context: `CLAUDE.md`, `AGENTS.md`
2. init: 이 문서 → `AI-Sessions/wiki/harness/state/brief.md` → 필요하면 `handoff.md`
3. 영역 라우터: 연구 작업은 `research.md`, 운용 작업은 `harness.md`
4. detail: 라우터가 가리키는 정책·노트 또는 `prompts/<command>.md`

`log.md`는 최근 변화가 필요할 때만 읽는다.

## Vault Structure

- `AI-Sessions/raw/`: 원본 paper, repo snapshot, idea 자료. 기본 읽기 전용
- `AI-Sessions/conversations/`: 세션 인수인계 보조 자료
- `AI-Sessions/wiki/maps/`: graph와 조회 진입점
- `AI-Sessions/wiki/research/`: `concepts`, `methods`, `tasks`, `papers`, `sources`, `comparisons`, `ideas`, `experiments`
- `AI-Sessions/wiki/harness/`: state, decisions, errors, patterns, policies, templates, evals, archive
- `prompts/`: save, reference, query, ingest, lint, reflect, archive 실행 규칙

구조 계약은 `vault-manifest.yaml`, topic 계약은 `schema/research-topics.json`, 자동 검증의 단일 진입점은 `scripts/wiki_doctor.sh`다.

## Research Domain

연구 분류는 디렉터리 타입과 통제된 `topics` property로 표현한다. concept/method/task/paper/source/comparison/idea/experiment는 서로 독립 객체이며, idea는 paper의 부모나 등록 조건이 아니다. 의미 있는 관계만 각 노트의 `## Relations`에 전체 경로 wikilink로 기록한다.

Obsidian의 기본 global graph는 stable research 타입(concept, method, task, paper, source, comparison)과 `research-map`만 표시한다. topic별 전수 조회와 draft 검토는 `research-library.base`가 담당한다. ideas와 experiments는 local graph 또는 Bases에서 조회한다.

## Commands

명령은 `save`, `reference`, `query`, `ingest`, `lint`, `reflect`, `archive` 일곱 개다. 실행 규칙은 `prompts/prompts.md`에서 라우팅한다.

## Harness

운용 지식은 `harness.md`가 라우팅한다. 구조·graph 변경은 obsidian-policy, 연구 schema와 ingest는 research-policy, 현재 상태는 brief/handoff/tasks를 읽는다.
