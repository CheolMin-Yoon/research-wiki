---
tags: [tier/low]
type: decision
date: 2026-06-24
status: active
---

# Harness Decisions

하네스 자체의 설계·운용 결정 로그.

## 반복 실수 방지는 정적 문서가 아니라 실행 메커니즘으로

### Decision

반복 실수 방지 지식은 두 경로로 발화시킨다. (1) **항상 로드되는 트리거**: 상세는 harness deep 노트에 두되 "언제 무엇을 읽/검사하라"는 짧은 트리거만 CLAUDE.md/AGENTS.md(+`agent-policy`)에 둔다. (2) **실행 메커니즘**: 기계로 검증 가능한 규칙은 `scripts/wiki_doctor.sh` 같은 post-write gate나 hook으로 옮긴다.

### Reason

- vault 깊은 곳 .md는 명시적 Read 없이는 context에 안 들어와 "검증 없는 장식"이 된다.
- 정적 추론은 stale 스냅샷·잘못된 시스템 모델로 조용히 틀린다(→ [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]).
- 실제 사례: wiki_doctor 실행 후에야 검사기 자체의 오류(Obsidian basename 해석 누락)가 드러남.

## records → harness 리팩토링

기존 `AI-Sessions/wiki/records/`(decisions/errors/dev-tasks)를 active 구조에서 제거하고 `AI-Sessions/wiki/harness/` 운영 계층으로 리팩토링했다. records/decisions→harness/decisions, records/errors→harness/errors. dev-tasks는 이후 폐기(granular 작업은 프로젝트 레포에서 관리, 증류 결과만 source 노트로 승격). `architecture.md`(구 index.md)는 maps/research/harness/prompts 구조를 반영한다.

## 운용 레이아웃: 부모 워크스페이스 + 형제 레포

`research-wiki`와 구현 코드 레포를 **공통 부모 폴더 아래 형제(sibling)**로 두고 VSCode 멀티루트로 연다. 에이전트는 **부모 디렉터리에서 실행**한다. wiki를 구현 레포 안에 클론하는 중첩 방식은 기각 — 이 wiki는 여러 레포·프로젝트를 가로지르는 장기 자산이라 단일 구현물에 종속시키면 안 된다.

## 공개 명령은 세 개, 나머지는 자동 수명주기

사용자가 고를 인터페이스는 `query`, `ingest`, `reflect`만 둔다. 작업 재개, durable capture 판단, write 후 검사, archive 정리는 별도 명령이 아니라 agent-policy의 자동 수명주기로 실행한다. 사용자의 의도보다 내부 구현 단계를 먼저 고르게 하지 않기 위한 결정이다.

## Wiki, repo docs, skills의 정본 경계

- wiki: 프로젝트를 가로질러 재사용할 개념·방법·근거·비교·실험과 source portal
- repo docs: 코드와 같은 revision에서 바뀌는 API·설정·실행·테스트 계약과 artifact
- `.agents/skills/`: 위 둘을 읽고 반복 작업을 수행하는 짧은 절차와 필요한 reference/script

동일 본문을 세 위치에 복제하지 않는다. `mj_rl`/`mj_mpc` docs를 wiki에서 찾게 만들되, 코드 결합 문서는 repo-local 링크로 관리한다.

## Links

- [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]
- [[AI-Sessions/wiki/harness/decisions/obsidian-decisions|obsidian-decisions]]
- scripts/wiki_doctor.sh
