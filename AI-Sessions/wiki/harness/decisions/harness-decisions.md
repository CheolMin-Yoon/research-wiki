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

반복 실수 방지 지식은 두 경로로 발화시킨다. (1) **항상 로드되는 트리거**: 상세는 harness deep 노트에 두되 "언제 무엇을 읽/검사하라"는 짧은 트리거만 CLAUDE.md/AGENTS.md(+`agent-policy`)에 둔다. (2) **실행 메커니즘**: 기계로 검증 가능한 규칙은 `scripts/wiki_doctor.sh`(=lint)나 hook으로 옮긴다.

### Reason

- vault 깊은 곳 .md는 명시적 Read 없이는 context에 안 들어와 "검증 없는 장식"이 된다.
- 정적 추론은 stale 스냅샷·잘못된 시스템 모델로 조용히 틀린다(→ [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]).
- 실제 사례: wiki_doctor 실행 후에야 검사기 자체의 오류(Obsidian basename 해석 누락)가 드러남.

## records → harness 리팩토링

기존 `AI-Sessions/wiki/records/`(decisions/errors/dev-tasks)를 active 구조에서 제거하고 `AI-Sessions/wiki/harness/` 운영 계층으로 리팩토링했다. records/decisions→harness/decisions, records/errors→harness/errors. dev-tasks는 이후 폐기(granular 작업은 프로젝트 레포에서 관리, 증류 결과만 source 노트로 승격). `architecture.md`(구 index.md)는 maps/research/harness/prompts 구조를 반영한다.

## 운용 레이아웃: 부모 워크스페이스 + 형제 레포

`research-wiki`와 구현 코드 레포를 **공통 부모 폴더 아래 형제(sibling)**로 두고 VSCode 멀티루트로 연다. 에이전트는 **부모 디렉터리에서 실행**한다. wiki를 구현 레포 안에 클론하는 중첩 방식은 기각 — 이 wiki는 여러 레포·프로젝트를 가로지르는 장기 자산이라 단일 구현물에 종속시키면 안 된다.

## Links

- [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]
- [[AI-Sessions/wiki/harness/decisions/obsidian-decisions|obsidian-decisions]]
- scripts/wiki_doctor.sh
