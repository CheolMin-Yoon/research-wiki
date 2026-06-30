---
tags: [tier/low]
type: state
date: 2026-07-01
status: active
---

# Brief

## Current Focus

research-wiki는 휴머노이드 RL 장기 연구를 위한 Research Agent Harness Wiki다. active 구조는 raw, research, harness, maps, prompts로 분리되고, 구조 지도는 `architecture.md`, 연구 인벤토리는 `research.md`가 맡는다.

## Active Research Direction

Humanoid locomotion RL, centroidal/CAM, LIPM/eICP, graph/transformer policy를 중심으로 논문·source·idea·experiment를 축적한다.

## Active Implementation Source

`AI-Sessions/wiki/research/sources/mj-rl.md`가 active implementation source다. 실험 런타임과 raw artifact는 `/home/frlab/mj_rl`에 두고, wiki에는 digest와 해석만 남긴다.

## Active Study

- Body Transformer 코드/논문 정본: AI-Sessions/wiki/research/sources/body-transformer-code.md, AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md
- 사용자 노트북 source 정본: AI-Sessions/wiki/research/sources/graph-transformer-code.md
- GCN+Transformer 설계 참조: AI-Sessions/wiki/research/papers/2025-luo-gcnt.md (GCN+WL→q/k, full attention; "GCN+BoT" 질문의 multi-morphology 실현형, 단일 G1엔 GCN을 local bias로만 차용)
- v0 스펙 확정(2026-06-28): CMM-conditioned graph Transformer 정본 = AI-Sessions/wiki/research/idea-physical-feature-graph.md ("확정 v0 스펙"). 노트북/shape 검증 정본 = AI-Sessions/wiki/research/sources/graph-transformer-code.md (`cmm_transformer_v0/`). mj_rl 구현 현상태, 26/29-DOF graph policy contract, GPU smoke, 학습 실패 가설 정본 = AI-Sessions/wiki/research/sources/mj-rl.md. 실험 설계(planned, 4-way + H2=CAM reward ablation) = AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines.md.
- 다음 실험 포인터: `AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md`
- GPU 동역학 도구 비교 완료: AI-Sessions/wiki/research/experiments/2026-06-27-cusadi-vs-casadi-on-gpu-g1.md (casadi-on-gpu 채택 유지). 탐색용 cusadi/casadi 설치·clone은 모두 정리됨, env 원상복구.
- mj_rl `5d87ee3`에서 casadi-on-gpu production kernel 정리 완료. 정본은 AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md.
- per-joint CAM credit 갈래(2026-06-29): OPID(시간축·근사) → 공간축·CMM exact 분해로 joint token별 dense credit. 설계 정본 = AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md (physical-feature-graph E2 정식화; telescoping 함정·difference reward·per-joint PPO). mj_rl 구현 현상태(CM_joint/credit.py landing, rsl_rl no-fork cfg-swap 결정, reward 미연결) = mj-rl.md "2026-06-29 Reflect". 다음=S0 dispersion 로깅, 읽을것=COMA/GAE.
- CMM 커널 DOF/관성 검증(2026-07-01): CasADi/CMM 커널은 **23-DOF locked spec** 기준(legs 12 + waist_yaw 1 + arms 10)이고, lock은 질량 drop이 아니라 부모 바디로 **관성 lumping**(총질량 33.34kg 보존, 중립자세 고정). action surface DOF와 별개. 정본 = mj-rl.md "2026-07-01 Reflect". mj_rl main HEAD = `bbdcfed`.

## Scope & Constraints

- raw는 source of truth이며 기본 읽기 전용이다.
- category는 7개 whitelist(centroidal-wbc / rl-algorithms-frameworks / morphology-aware-policy / graph-transformer-rl / loco-manipulation / dynamics-guided-rl / novelty)만 active로 유지한다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 증류된 research/harness 지식만 둔다.
- 반복 실패는 `harness/errors/`, 일반화된 접근은 `harness/patterns/`, 설계 원칙은 `harness/decisions/`로 승격한다.

## Operating Pointers

- Start: `architecture.md` → 이 brief → 필요 시 `handoff.md` → 작업별 `harness.md` 또는 `research.md`.
- 구조·link·map/index·archive·prompt routing 변경 후 `scripts/wiki_doctor.sh`를 실행한다.
- 연구·노트북·실험 패턴은 `AI-Sessions/wiki/harness/patterns/research-patterns.md`를 on demand로 읽는다.
- relation 정본은 본문 `## Links`의 `[[wikilink]]`; source provenance는 `checked commit:`로 쓴다.

## Current Risks

- `.obsidian/graph.json`은 Obsidian 실행 중 외부 수정하면 덮어써질 수 있다.
- `brief.md`와 `handoff.md`는 append history가 아니라 compact current pointer로 유지한다.

## Read Next

- architecture.md → (운용) harness.md / (연구) research.md
- AI-Sessions/wiki/harness/state/handoff.md
- prompts/<command>.md
