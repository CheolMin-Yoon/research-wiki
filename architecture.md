# Research Wiki Architecture

이 문서는 vault 구조와 읽기 순서를 복원하는 시작점이다. `research`는 재사용 가능한 연구 지식, `harness`는 작업 규칙과 실패 방지, `state`는 현재 진행 상태, `evals`는 품질 검사를 담당한다.

## Start Here

1. 자동 context: `CLAUDE.md`, `AGENTS.md`
2. init: 이 문서 → `AI-Sessions/wiki/harness/state/brief.md` → 필요하면 `handoff.md`
3. 영역 라우터: 연구 작업은 `research.md`, 운용 작업은 `harness.md`
4. detail: 라우터가 가리키는 정책·노트 또는 공개 명령 `prompts/<command>.md`

`log.md`는 최근 변화가 필요할 때만 읽는다.

## Vault Structure

- `AI-Sessions/raw/`: 원본 paper, repo snapshot, idea 자료. 기본 읽기 전용
- `AI-Sessions/conversations/`: 세션 인수인계 보조 자료
- `AI-Sessions/wiki/maps/`: graph와 조회 진입점
- `AI-Sessions/wiki/research/`: `concepts`, `methods`, `tasks`, `papers`, `sources`, `comparisons`, `ideas`, `experiments`
- `AI-Sessions/wiki/harness/`: state, decisions, errors, patterns, policies, templates, evals, archive
- `.agents/skills/`: 반복 가능한 개인 에이전트 절차. `SKILL.md`와 필요한 reference/script만 둠
- `prompts/`: `query`, `ingest`, `reflect` 공개 실행 규칙

구조 계약은 `vault-manifest.yaml`, topic 계약은 `schema/research-topics.json`, 자동 검증의 단일 진입점은 `scripts/wiki_doctor.sh`다.

## Research Domain

연구 분류는 디렉터리 타입과 통제된 `topics` property로 표현한다. concept/method/task/paper/source/comparison/idea/experiment는 서로 독립 객체이며, idea는 paper의 부모나 등록 조건이 아니다. 의미 있는 관계만 각 노트의 `## Relations`에 전체 경로 wikilink로 기록한다.

Obsidian의 기본 global graph는 stable research 타입(concept, method, task, paper, source, comparison)과 `research-map`만 표시한다. topic별 전수 조회와 draft 검토는 `research-library.base`가 담당한다. ideas와 experiments는 local graph 또는 Bases에서 조회한다.

## Commands

공개 명령은 `query`, `ingest`, `reflect` 세 개다. 실행 규칙은 `prompts/prompts.md`에서 라우팅한다. 작업 재개, 저장 가치 판단, 사후 검사, archive 정리는 별도 명령이 아니라 `agent-policy`의 자동 수명주기다.

## Project Documentation Boundary

여러 프로젝트에 재사용되는 연구 지식과 저장소 분석은 이 wiki의 typed research note가 정본이다. 코드와 같은 commit에서 바뀌어야 하는 API·설정·실행·테스트 계약은 `mj_rl`과 `mj_mpc`에 남기고, wiki의 source portal에서 해당 문서를 연결한다. skill은 지식 문서가 아니라 이 둘을 읽고 작업하는 절차다. 같은 내용을 wiki, skill, repo docs에 복제하지 않는다.

## Harness

운용 지식은 `harness.md`가 라우팅한다. 구조·graph 변경은 obsidian-policy, 연구 schema와 ingest는 research-policy, 현재 상태는 brief/handoff/tasks를 읽는다.
