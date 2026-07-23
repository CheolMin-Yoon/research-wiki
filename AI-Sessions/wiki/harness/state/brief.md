---
tags: [tier/low]
type: state
date: 2026-07-24
status: active
---

# Brief

## Current Focus

research-wiki는 휴머노이드 RL 장기 연구용 Research Agent Harness Wiki다. 2026-07-24부터 연구 지식은 idea 기반 분류 트리가 아니라 concept, method, task, paper, source, comparison, idea, experiment의 독립 타입으로 관리한다.

## Active Domain Contract

- 타입/용어: `CONTEXT.md`, `AI-Sessions/wiki/harness/policies/research-policy.md`
- canonical topics와 alias/pending queue: `schema/research-topics.json`
- 연구 조회: `AI-Sessions/wiki/research/research-library.base`
- stable graph entry: `AI-Sessions/wiki/maps/research-map.md`
- 자동 검사: `scripts/wiki_doctor.sh`
- graph 진단: `exports/research-communities.json`

idea는 paper의 부모가 아니며 idea 변경은 paper의 경로나 topic을 바꾸지 않는다. topic membership은 graph edge가 아니다. 설명 가치가 있는 관계만 `## Relations`에서 전체 경로 wikilink로 기록한다.

## Current Research Anchors

- model-based critic: `AI-Sessions/wiki/research/ideas/idea-model-based-critic.md`
- physical feature graph: `AI-Sessions/wiki/research/ideas/idea-physical-feature-graph.md`
- centroidal dynamics: `AI-Sessions/wiki/research/concepts/centroidal-dynamics.md`
- credit assignment: `AI-Sessions/wiki/research/concepts/credit-assignment.md`
- MPC-guided RL taxonomy: `AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures.md`
- humanoid teacher integration: `AI-Sessions/wiki/research/comparisons/humanoid-mbc-teacher-integration.md`
- un-ingested candidates: `AI-Sessions/wiki/harness/state/research-backlog.md`

## Repository Ownership

- 재사용 가능한 조사 결과와 프로젝트별 source portal의 정본은 `research-wiki`다.
- `/home/frlab/mj_rl`, `/home/frlab/mj_mpc`에는 코드와 같은 revision에서 바뀌는 API·변수·설정·실행 계약, tests와 artifact를 둔다. 실험 결과와 재사용 error는 wiki가 소유하고 source portal에서 양쪽을 연결한다.
- `.agents/skills/`에는 반복 가능한 개인 에이전트 절차만 둔다. `jax-mpc`는 현재 자동 인식되는 repo-local skill이다.
- `AI-Sessions/raw/`는 source of truth이며 기본 읽기 전용이다.

## Active Implementations

- `/home/frlab/mj_rl`: humanoid RL/MBC 구현 저장소. 현재 구현 계약은 repo-local docs와 `research/sources/mj-rl.md`를 함께 본다.
- `/home/frlab/mj_mpc`: G1 NIPFM/SQP 구현 저장소. 코드 계약은 repo-local docs, 재사용 가능한 digest와 문서 portal은 `research/sources/mj-mpc-code.md`를 본다.
- `/home/frlab/isaac_humanoid`: RAL2025 MIT Humanoid baseline 위 morphology GCN 실험. 정본 digest는 `research/sources/isaac-humanoid-code.md`다.

## Operating Pointers

- 시작: `architecture.md` → 이 brief → 필요하면 `handoff.md` → `research.md` 또는 `harness.md`.
- 새 topic은 pending에 넣고 큐레이터 승인 전 note에 사용하지 않는다.
- 구조·schema·link·Bases·graph·prompt 변경 후 doctor와 unit tests를 실행한다.
- 공개 명령은 query/ingest/reflect뿐이며 재개·저장 판단·검사·정리는 자동 수명주기다.
- Obsidian 설정은 앱을 종료한 상태에서 수정한다.
