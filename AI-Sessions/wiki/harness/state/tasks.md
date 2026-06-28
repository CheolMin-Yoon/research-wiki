---
tags: [tier/low]
type: state
date: 2026-06-24
status: active
---

# Active Tasks

## High

- mj_rl graph policy는 smoke를 넘어 장기 학습 안정화로 넘어간다. 먼저 BodyTransformer baseline에서 reward/optimization과 tokenization failure mode를 분리한다.

## Medium

- `AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines.md` 설계를 실제 run 기록으로 갱신한다.

## Low

- 오래된 setup/graph 상세 이력은 필요할 때만 GC archive에서 확인한다.

## Blocked

- 없음.

## Review Queue

검토·승격 대기 항목을 둔다. 별도 폴더를 만들지 않고 이 섹션이 review queue 역할을 한다.

- 없음.

## Done Recently

- dev-tasks를 wiki에서 제거하고 granular 구현 작업은 프로젝트 레포로 분리했다.
- anti-pattern(폴더 이름 기반 분류)을 CLAUDE.md/AGENTS.md Core Rules와 wiki_doctor 검사로 승격했다.
- records를 harness로 리팩토링했다.
- entry 문서를 경량화하고 세부 규칙을 prompts/policies/templates로 분리했다.
- mj_rl graph modules를 `modules.common` contract + public wrappers로 정리했고, 자세한 구현 사실은 `research/sources/mj-rl.md`로 승격했다.
