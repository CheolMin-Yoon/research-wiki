---
tags: [tier/low]
type: handoff
date: 2026-06-28
status: active
last_agent: Codex
suggested_next_agent:
mode: implementation
---

# Handoff

## Current Goal

CMM-conditioned Transformer v0의 notebook scaffold와 state-token schema 결정은 완료됐다. `/home/frlab/mj_rl` 구현은 `graph_transformer` task와 `source/modules/common` graph-policy contract, top-level policy wrappers 기준으로 이동했고 CUDA smoke까지 통과했다. BoT 정보전파/readout ablation aliases도 구현됐다. `mj_rl` checked commit은 `4735c7d1ecb5e1843816fdd5a1c2336fb943f682`이다. 다음 작업은 96GB 머신에서 BoT ablation 학습 결과를 비교해 reward/optimization과 architecture-tokenization 원인을 분리하는 것이다.

## Next Implementation

먼저 읽을 정본:

- 설계 정본: `AI-Sessions/wiki/research/idea-physical-feature-graph.md` ("확정 v0 스펙")
- 노트북/shape 검증 정본: `AI-Sessions/wiki/research/sources/graph-transformer-code.md` (`cmm_transformer_v0/`)
- mj_rl 구현 현상태와 학습 실패 가설: `AI-Sessions/wiki/research/sources/mj-rl.md`
- CMM source: `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

바로 할 일:

1. BodyTransformer baseline hard, mix, mix+broadcast, mix+broadcast+per-token, post-norm을 96GB 머신에서 같은 seed/iteration budget으로 비교한다.
2. 초기 rollout에서 deterministic action, sampled action norm, termination reason histogram, episode length 분포를 함께 기록한다.
3. reward 변경은 최소화하되, termination penalty 강화와 metric logging으로 early termination loophole인지 optimization instability인지 분리한다.
4. CMM 모델 평가는 BodyTransformer ablation 중 최소한 하나가 살아나는지 확인한 뒤 진행한다.

## Current Facts

- `/home/frlab/Graph_Transformer/cmm_transformer_v0/`에는 7개 notebook만 있다. `lib/`, runner cfg, checkpoint/export, rsl_rl mock은 제외됐다.
- `mjlab_env`에는 PyTorch/CUDA가 있고, notebook `03`에서 `assets.cuda.pinocchio.Pinocchio` import와 real `CMM [B,6,35]` shape 확인이 가능했다.
- active schema: joint feature 15D `[q,dq,prev_action,A_G,A_G*dq]`, centroidal/state token 9D `[projected_gravity,l_G,k_G]`.
- 2026-06-28 reflect: smoke 기준 import/shape wiring은 통과했고, 현재 실패 가설은 wiring bug보다 reward/optimization + architecture-tokenization pathology 쪽이 유력하다. 자세한 근거와 해석은 `AI-Sessions/wiki/research/sources/mj-rl.md`의 "2026-06-28 Reflect: 학습 실패 가설"을 본다.
- 2026-06-28 reflect: graph modules modularization은 `modules.common` + `modules.{body_transformer,gcnt_limb,cmm_transformer}` 공개 wrapper 구조로 정리됐고, 26/29-DOF Mapping/Graph contract와 CUDA smoke 근거는 `AI-Sessions/wiki/research/sources/mj-rl.md`의 "2026-06-28 Reflect: graph module modularization + GPU smoke"를 본다.
- 2026-06-29 reflect: BoT baseline은 공식 RL 포팅으로 유지하고, 정보 전파/readout ablation을 `Mix`, `MixBroadcast`, `MixBroadcastPerToken`, `PostNorm` alias로 분리했다. 자세한 근거와 검증은 `AI-Sessions/wiki/research/sources/mj-rl.md`의 "2026-06-29 Reflect: BoT ablation design"을 본다.
- `command`는 state token이 아니라 task condition이라 필요 시 별도 command conditioning/token으로 분리한다. `base_ang_vel`, foot/contact geometry는 ablation 후보로 남겼다.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,obsidian,research,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/{agent-patterns,research-patterns}.md
