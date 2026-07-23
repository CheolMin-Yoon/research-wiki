---
type: experiment
date: 2026-06-29
status: planned
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - morphology-aware-policy
  - graph-policy
source: mj_rl source/tasks/graph_transformer + mjlab Unitree-G1 29-DOF task surface
related_papers: AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md, AI-Sessions/wiki/research/papers/2025-mjlab.md, AI-Sessions/wiki/research/papers/2017-schulman-ppo.md
related_sources: AI-Sessions/wiki/research/sources/mj-rl.md, AI-Sessions/wiki/research/sources/body-transformer-code.md, AI-Sessions/wiki/research/sources/mjlab-code.md
---

# Experiment: G1 29-DOF Vanilla BoT Gate

## Question

`mjlab`의 default Unitree-G1 29-DOF velocity/locomotion task surface에서 **Vanilla Body Transformer**가 MLP baseline 대비 유의미한 policy architecture인가?

이 실험은 CMM/centroidal-root 확장 전에 통과해야 하는 gate다. Vanilla BoT가 29-DOF mjlab task에서 reward를 풀지 못하면, CMM feature·centroidal token·contact redistribution 연구로 넘어가기 전에 tokenization/action readout/optimization 문제를 먼저 해결해야 한다.

## Definition: Vanilla BoT

여기서 Vanilla BoT는 CMM 없이 morphology만 쓰는 BoT다.

- allowed: BoT tokenizer → body/joint tokens → BoT hard or BoT-Mix masked Transformer → detokenizer
- allowed: official RL size 유지(`d_model=64`, `heads=2`, `ff=128`, `layers=10` in current `mj_rl`)
- not allowed: CMM column, CMM contribution, centroidal virtual/root token, contact/site token, hub soft-bias
- ablation allowed: hard vs mix, global/base broadcast, shared vs per-token action head, pre-norm vs post-norm

## Repository Boundary

- `/home/frlab/mj_rl`: task alias, runner cfg, training, TensorBoard events, checkpoints.
- `/home/frlab/research-wiki`: experiment intent, command skeleton, config digest, result table, interpretation.
- raw event/checkpoint files stay in `/home/frlab/mj_rl/outputs`.

## Current Implementation Facts

- `mj_rl` checked source note: `AI-Sessions/wiki/research/sources/mj-rl.md`.
- 29-DOF mapping contract exists in `modules.common.mapping` as `mjlab_g1_velocity`:
  - actor `99 = base(9) + q(29) + dq(29) + last_action(29) + command(3)`
  - critic `111 = actor + foot extras(12)`
  - action output `29`
- 29-DOF graph contract exists as `g1_full`, including waist yaw/roll/pitch.
- Current registered `G1-BodyTransformer-*` graph aliases are still primarily the graph_transformer 26-DOF surface. A dedicated 29-DOF alias must attach `mapping={"name": "mjlab_g1_velocity"}` and `graph={"name": "g1_full"}` before full experiment.

## Hypotheses

- **H0 — viability gate**: Vanilla BoT should reach nontrivial locomotion reward and episode length on the 29-DOF task. If not, CMM extensions are premature.
- **H1 — BoT-Mix over hard**: mixed masked/unmasked layers should outperform hard-only BoT because global/base context must reach all action tokens.
- **H2 — readout bottleneck**: per-token action head or base/global broadcast may matter more than CMM at this stage if failure is due to token routing/readout, not physical coupling.
- **H3 — 29-DOF waist stress test**: including waist exposes whether morphology tokenization scales from no-waist 26-DOF graph policy to full G1 action surface.

## Comparison Set

Keep environment, reward, observation surface, action space, PPO budget, seed, and command curriculum fixed.

1. **MLP baseline**: mjlab default 29-DOF policy for the same velocity/locomotion task.
2. **BoT-Hard 29DOF**: `body_transformer`, `is_mixed=False`, `g1_full`, `mjlab_g1_velocity`.
3. **BoT-Mix 29DOF**: `is_mixed=True`, `first_hard_layer=0`.
4. **BoT-MixBroadcast 29DOF**: mix + `broadcast_global_to_joints=True`.
5. **BoT-MixBroadcastPerToken 29DOF**: mix + broadcast + `action_head_type="per_token"`.
6. **PostNorm 29DOF**: baseline size + `norm_first=False`.

## Metrics

- `Train/mean_reward`
- `Train/mean_episode_length`
- termination histogram: `time_out`, `base_tilted`, `base_too_low`, `bad_contact`, velocity limits
- action health: `Policy/mean_std`, sampled action norm, deterministic action norm
- reward terms: tracking velocity, posture, torque/velocity/action smoothness, termination penalties
- runtime: GPU memory, steps/sec, collection time, learning time
- final play sanity: stable standing/walking, waist behavior, arm/leg coordination

## Reproducibility Skeleton

Implementation prerequisite: add 29-DOF runner aliases that reuse the mjlab/default G1 velocity task surface while setting:

```python
cnn_cfg = {
  "variant": "body_transformer",
  "graph": {"name": "g1_full"},
  "mapping": {"name": "mjlab_g1_velocity"},
}
```

Smoke:

```bash
cd /home/frlab/mj_rl
conda run --no-capture-output -n mjlab_env \
  python scripts/train.py G1-BodyTransformer-29DOF-Locomotion \
  --env.scene.num-envs 128 \
  --agent.max-iterations 1 \
  --agent.logger tensorboard \
  --agent.run-name bot29_smoke_128
```

Sanity:

```bash
conda run --no-capture-output -n mjlab_env \
  python scripts/train.py G1-BodyTransformer-29DOF-MixBroadcastPerToken-Locomotion \
  --env.scene.num-envs 512 \
  --agent.max-iterations 100 \
  --agent.save-interval 25 \
  --agent.logger tensorboard \
  --agent.run-name bot29_mix_broadcast_per_token_sanity_100
```

Full 96GB run:

```bash
conda run --no-capture-output -n mjlab_env \
  python scripts/train.py <29DOF_ALIAS> \
  --env.scene.num-envs 4096 \
  --agent.max-iterations <budget> \
  --agent.save-interval 200 \
  --agent.logger tensorboard \
  --agent.run-name <run-name>
```

## Decision Rule

- If Vanilla BoT variants cannot beat random/early-termination behavior, stop CMM architecture work and debug 29-DOF tokenization/readout/optimization.
- If BoT-Mix or MixBroadcastPerToken reaches a meaningful fraction of MLP baseline, proceed to centroidal-root/CMM integration.
- If MLP learns but all BoT variants fail, the failure is likely architecture-tokenization/readout rather than reward/task feasibility.
- If BoT learns but is worse than MLP, CMM/centroidal-root can be justified as a dynamics prior rather than a task rescue patch.

## Relations

- source: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- BoT source: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]
- idea gate: [[AI-Sessions/wiki/research/ideas/idea-physical-feature-graph|idea-physical-feature-graph]]
- downstream CMM experiment: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]]
