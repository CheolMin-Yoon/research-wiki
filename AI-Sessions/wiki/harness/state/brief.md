---
tags: [tier/low]
type: state
date: 2026-07-11
status: active
---

# Brief

## Current Focus

research-wiki는 휴머노이드 RL 장기 연구를 위한 Research Agent Harness Wiki다. active 구현 레포는 `/home/frlab/mj_rl`이고, 2026-07-10부터 `/home/frlab/isaac_humanoid`(mj_rl의 morphology GCN을 RAL2025 MIT Humanoid IsaacLab baseline에 이식하는 실험 레포)도 병행 진행 중이다. wiki에는 granular 작업 로그가 아니라 current contract, 증류된 해석, 다음 포인터만 남긴다.

## Active Research Direction

Humanoid locomotion RL, centroidal/CAM, LIPM/eICP, graph/transformer policy를 중심으로 논문·source·idea·experiment를 축적한다. 2026-07-18부터 메인 인사이트는 model-based critic(신체 분할 multi-critic CTDE의 per-critic 평가 신호를 MPC/QP로 생성/대체, AI-Sessions/wiki/research/idea-model-based-critic.md)이고, CMM-conditioned graph/Transformer policy(표현 축)와 per-joint CAM credit(계산된 credit 축)은 그 하위 축으로 재배치됐다.

## Current Canonical Pointers

- 메인 인사이트(model-based critic): `AI-Sessions/wiki/research/idea-model-based-critic.md` (raw: `AI-Sessions/raw/ideas/model-based-critic.md`)
- 구현 source current digest: `AI-Sessions/wiki/research/sources/mj-rl.md`
- 구현 source history archive: `AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03.md`
- CMM-conditioned graph Transformer 설계: `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit 설계: `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- notebook/shape 검증: `AI-Sessions/wiki/research/sources/graph-transformer-code.md`
- CasADi-on-GPU backend: `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`
- Body Transformer 정본: `AI-Sessions/wiki/research/sources/body-transformer-code.md`, `AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md`
- isaac_humanoid(RAL2025 MIT Humanoid + GCN CTDE 이식) 구현 digest: `AI-Sessions/wiki/research/sources/isaac-humanoid-code.md`

## Current mj_rl State

- 2026-07-11: commit `fbf2ece`까지 `G1-FALCON` parity 보류 검증을 자동화하고 실제 friction 결합 결함을 수정했다. 현재 계약과 진행 중인 장기 run은 `mj-rl.md` 및 handoff를 본다.

- `/home/frlab/mj_rl`은 branch `refactor/mj-rl-v2`의 `source/{assets,models,rl,tasks,utils}` 구조이며 active task는 `mlp_ctde`, `falcon`, `graph_mimic_29d`다. 새 graph mimic의 정본은 `AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic.md`, v1 상세는 `archived-mj-rl-v1-2026-07-11.md`를 본다.
- 2026-07-12 세션 작업: graph mimic의 GCN/MAPPO 병목 점검과 benchmark를 완료했다. 구현/벤치 정본은 `mj-rl.md`와 `2026-07-11-g1-29d-graph-mimic.md`를 본다.
- 2026-07-12 이어서: graph_29/graph에 `body_name`(link 시각화 anchor) 계약을 추가하고 graph_mimic_29d에 node-edge debug overlay를 구현, g1_tracking 대비 iteration-matched interim 비교를 수행했다. mjlab EventManager의 재발 가능 함정(class-based event는 `reset` 없이 `debug_vis`가 안 불림)을 발견해 `mjlab-errors.md`에 승격했다. 상세는 `mj-rl.md`/`2026-07-11-g1-29d-graph-mimic.md`/`mjlab-errors.md`/`mjlab-patterns.md`를 본다.
- 자세한 현재 계약(검증 범위 명시)은 `mj-rl.md`, 일반화 원칙은 `mjlab-patterns.md`("one token per domain concept"), CasADi backend 계약은 `casadi-on-gpu-code.md`를 본다.
- v1 시절 caution(Centroidal debug viz 기본 off 등)은 v2에서 아직 재확인되지 않았다 — archive history를 본다.

## Current isaac_humanoid State

- `/home/frlab/isaac_humanoid` current branch is `main`; checked commit `4351ffb`("init") + 2026-07-10 uncommitted 작업. `gcn_ctde` task(`MorphologyGCNActor`/`Critic`, leg/arm)가 진행 중 실험이다.
- 2026-07-10에 baseline(RAL2025 modular MLP)과의 관측 parity를 점검해 실제 버그 2건을 발견·수정했다: (1) GCN leg/arm이 obs group을 공유해 baseline에 없던 정보(예: arm이 velocity_commands/phase)가 새고 있었음, (2) C2 mirror sign 코드가 18-wide term에 축 부호 3개만 채우고 관절 permutation을 빠뜨림. 둘 다 테스트로 고정(`isaac_humanoid/tests/test_gcn_baseline_parity.py`, `test_gcn_mapping.py`).
- 같은 세션에서 CAM 관련 per-joint 관측 term을 오차/목표 projection(`cam_projection`/`cam_des_projection`)에서 raw capacity + 코사인 정렬(`cam_capacity_x/y/z` + `cam_des_alignment`)로 재설계했다 — 근거와 대안은 `isaac-humanoid-code.md`와 repo-local `docs/decisions/2026-07-10-node-obs-features.md`.
- 자세한 계약은 `isaac-humanoid-code.md`. mirror-sign 유도의 일반 원칙은 `research-patterns.md`의 "좌우 대칭(C2) GCN 관절 관측을 mirror-safe하게 설계하기" 항목.
- obs 폭이 148로 바뀌어 이전 체크포인트/정규화 통계와 호환 안 됨 — 재설계 직후 학습을 처음부터 다시 시작하는 단계.
- jacobian early-screen 5-run 중 마지막 3개(gcn64x6 + 2 follow-up)가 `assets/graph` 삭제로
  전부 죽었다가 복구·재시도 중 — 실험 결과는 `isaac-mit-gcn-jacobian-early-screen.md`,
  에이전트 실수 2건(git checkout 사고, nohup/setsid 재발)은 `agent-patterns.md` 사례 6/7.

## Scope & Constraints

- `AI-Sessions/raw/`는 source of truth이며 기본 읽기 전용이다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 증류된 research/harness 지식만 둔다.
- 반복 실패는 `harness/errors/`, 일반화된 접근은 `harness/patterns/`, 설계 원칙은 `harness/decisions/`로 승격한다.
- 같은 사실은 정본 한 곳에 두고 다른 문서는 링크한다. state에는 코드 디테일을 길게 넣지 않는다.

## Operating Pointers

- Start: `architecture.md` → 이 brief → 필요 시 `handoff.md` → 작업별 `harness.md` 또는 `research.md`.
- 구조·link·map/index·archive·prompt routing 변경 후 `scripts/wiki_doctor.sh`를 실행한다.
- relation 정본은 본문 `## Links`의 `[[wikilink]]`; source provenance는 `checked commit:`로 쓴다.

## Current Risks

- `.obsidian/graph.json`은 Obsidian 실행 중 외부 수정하면 덮어써질 수 있다.
- `brief.md`와 `handoff.md`는 append history가 아니라 compact current pointer로 유지한다.
- Centroidal/waist momentum debug viz는 GPU CasADi all-kernel artifact를 전제로 한다. BoT-only 환경에서는 못 켠다.

## Read Next

- architecture.md → (운용) harness.md / (연구) research.md
- AI-Sessions/wiki/harness/state/handoff.md
- prompts/<command>.md
