---
tags: [tier/low]
type: experiment
date: 2026-06-28
status: planned
source: mj_rl source/tasks/graph_centroidal
related_papers: AI-Sessions/wiki/research/papers/2013-orin-centroidal-dynamics.md, AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md, AI-Sessions/wiki/research/papers/2025-luo-gcnt.md, AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl.md
related_sources: AI-Sessions/wiki/research/sources/mj-rl.md, AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md, AI-Sessions/wiki/research/sources/body-transformer-code.md, AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code.md
---

# Experiment: G1 Centroidal — CMM-conditioned Transformer vs Topology/BoT/GCNT

## Question

동일한 `graph_centroidal` task(reward·obs·PPO 고정)에서 actor/critic architecture만 바꿀 때, **CMM A_G(q)을 node에 주입한 Transformer(v0)** 가 Topology/BoT/GCNT baseline 대비 (a) whole-body balance/CAM 성능, (b) sample efficiency, (c) CAM reward 의존도를 개선하는가? 설계 정본: `AI-Sessions/wiki/research/idea-physical-feature-graph.md` "확정 v0 스펙".

## Repository Boundary

- `/home/frlab/mj_rl`: train script, config, TensorBoard event, checkpoint.
- `/home/frlab/research-wiki`: 의도·재현 명령·config digest·핵심 metric·해석만. raw event/ckpt는 복사하지 않는다.

## Inherited Task (source 검증, mj_rl)

- task: `source/tasks/graph_centroidal/` — `graph_centroidal_env_cfg.py`가 `centroidal` MDP(`g1_whole_body_env_cfg`)를 재사용, leg+arm obs term을 단일 actor/critic으로 merge(100-D, `_assert_term_order`로 model 슬라이스와 커플링).
- obs에 이미 aggregate CAM(`cam_xy_b`+`cam_z_w`=3)·CAM_des 존재. **per-joint CMM 열은 없음(v0가 추가)**.
- reward(`centroidal/mdp/rewards.py`)에 **CAM 항 존재**: `tracking_CAM`, `dCAM_xy_penalty`, 회전-게이팅 `arm_joint_position_penalty`(= Lee arm-CAM 논문 포팅). CMM 캐시는 이미 `CM_leg/CM_arm`로 2그룹 분해.
- 기존 모델 cfg: `g1_graph_centroidal_*`(Topology) · `g1_body_transformer_*`(BoT) · `g1_gcnt_limb_*`(GCNT). v0 = `g1_cmm_transformer_*` 추가.

## Hypotheses & Comparison

4-way(Topology / BoT / GCNT / **CMM-v0**), actor·critic만 교체, task/reward/motion/PPO 고정.

- **H1 — limb attention 활성화**: `GCNTLimbModel.last_attention_maps` 계열로 centroidal token이 **idle 고-leverage 관절(정지한 반대팔)에 attend**하는지 확인. CMM→q/k + hub soft-bias의 직접 효과이며 BoT/GCNT엔 그 신호가 없어야 한다.
- **H2 — representation vs reward (핵심)**: CAM reward(`tracking_CAM`+`dCAM_xy_penalty`+arm gate)를 **full vs 축소/제거**로 ablation. CMM-v0가 CAM reward 제거 시 balance/CAM 저하가 baseline보다 **작으면**, "CAM coupling을 reward→representation으로 옮긴다"는 thesis 지지.
- **H3 — sample efficiency / 최종 성능**: 동일 reward에서 학습곡선·CAM 추종오차·tracking 성능.

## Metrics

- `Train/mean_reward`, `Train/mean_episode_length`
- `Episode_Reward/tracking_CAM`, `Episode_Reward/dCAM_xy_penalty`, `Episode_Reward/arm_joint_position_penalty`
- CAM 추종오차(CM vs CM_des), base tracking 오차
- PPO health(`Loss/value`,`Loss/surrogate`,`Policy/mean_std`)
- attention map snapshot(H1)

## Reproducibility (skeleton — 구현 후 확정)

```bash
cd /home/frlab/mj_rl
# smoke → sanity → full, 4개 runner cfg(g1_graph/body_transformer/gcnt_limb/cmm_transformer)
# scripts/train.py 경유(best-ckpt export hook). 동일 task id·reward·num-envs로 actor만 교체.
```

## Status / Next

- status: **planned** (모델 미구현). 선행: plan `구현 로드맵` Part 1–3.
- 1) v0 모델·obs 확장·cfg 구현 → 2) smoke로 forward/shape 검증 → 3) sanity 4-way → 4) full + H1–H3 분석 → run record 추가.

## Links

- idea: AI-Sessions/wiki/research/idea-physical-feature-graph.md
- sources: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] · [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]
- 비교 baseline 선행 실험: [[AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline|2026-06-25-g1-tracking-baseline]]
