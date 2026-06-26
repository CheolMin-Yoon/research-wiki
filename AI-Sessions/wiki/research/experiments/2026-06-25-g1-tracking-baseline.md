---
tags: [tier/low]
type: experiment
date: 2026-06-25
status: planned
source: mjlab_env installed mjlab package
related_papers: AI-Sessions/wiki/research/papers/2025-mjlab.md, AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md
related_sources: AI-Sessions/wiki/research/sources/mjlab-code.md, AI-Sessions/wiki/research/sources/body-transformer-code.md, AI-Sessions/wiki/research/sources/mj-rl.md
---

# Experiment: G1 Tracking Baseline before BoT

## Question

mjlab의 기본 Unitree G1 motion imitation/tracking PPO baseline을 먼저 재현하고, 이후 같은 task/reward/motion file에서 actor architecture만 Body Transformer로 바꾸면 tracking 성능이나 sample efficiency가 좋아지는가?

## Repository Boundary

이 실험의 실행과 기록은 역할을 분리한다.

- `/home/frlab/mj_rl`: training script, runtime config, TensorBoard events, checkpoints, exported `.pt` model을 둔다.
- `/home/frlab/research-wiki`: 실험 의도, 재현 명령어, config digest, 중요한 metric, 결과 해석, 다음 결정을 기록한다.
- raw TensorBoard event, full YAML, `.pt` checkpoint는 wiki로 복사하지 않는다. wiki에는 경로와 핵심 값만 남긴다.

## Current Fact

conda `mjlab_env`의 installed `mjlab` package를 직접 확인했다.

- registered task: `Mjlab-Tracking-Flat-Unitree-G1`
- no-state-estimation variant: `Mjlab-Tracking-Flat-Unitree-G1-No-State-Estimation`
- task는 built-in이지만 `cfg.commands["motion"].motion_file == ""`
- tracking train은 local `motion-file` 또는 W&B `registry-name`이 필요하다.
- demo script는 pretrained checkpoint와 default motion을 자동 다운로드한다.

Demo assets already cached during inspection:

```text
/tmp/mjlab_cache/demo_ckpt.pt
/tmp/mjlab_cache/lafan1_dance1_subject1_demo_motion.npz
```

## Reproducibility Variables

```bash
cd /home/frlab/mj_rl
conda activate mjlab_env
export MOTION=/tmp/mjlab_cache/lafan1_dance1_subject1_demo_motion.npz
```

Use `python scripts/train.py`, not `python -m mjlab.scripts.train`, because the local best-checkpoint export hook is attached to `mj_rl/scripts/train.py`.

Expected runtime artifacts:

```text
/home/frlab/mj_rl/outputs/g1_tracking/<timestamp>_<run-name>/
/home/frlab/mj_rl/outputs/g1_tracking/<timestamp>_<run-name>/params/env.yaml
/home/frlab/mj_rl/outputs/g1_tracking/<timestamp>_<run-name>/params/agent.yaml
/home/frlab/mj_rl/models/motion_tracking.<iter>.pt
/home/frlab/mj_rl/models/motion_tracking.best.pt
/home/frlab/mj_rl/models/motion_tracking.best.json
```

## Baseline Commands

Demo:

```bash
python -m mjlab.scripts.demo
```

Smoke training:

```bash
python scripts/train.py Mjlab-Tracking-Flat-Unitree-G1 \
  --env.commands.motion.motion-file "$MOTION" \
  --env.scene.num-envs 16 \
  --agent.max-iterations 1 \
  --agent.logger tensorboard \
  --agent.run-name g1_tracking_smoke
```

Sanity training:

```bash
python scripts/train.py Mjlab-Tracking-Flat-Unitree-G1 \
  --env.commands.motion.motion-file "$MOTION" \
  --env.scene.num-envs 256 \
  --agent.max-iterations 100 \
  --agent.save-interval 25 \
  --agent.logger tensorboard \
  --agent.run-name g1_tracking_mlp_sanity_100
```

Full baseline training:

```bash
python scripts/train.py Mjlab-Tracking-Flat-Unitree-G1 \
  --env.commands.motion.motion-file "$MOTION" \
  --env.scene.num-envs 4096 \
  --agent.max-iterations 30000 \
  --agent.save-interval 500 \
  --agent.logger tensorboard \
  --agent.run-name g1_tracking_mlp_baseline
```

Play / visualize a checkpoint (**학습과 동일 motion 필수** — tracking task는 motion이 환경 정의의 일부라 checkpoint만으론 복원 불가):

```bash
python scripts/play.py Mjlab-Tracking-Flat-Unitree-G1 \
  --checkpoint-file models/motion_tracking.best.pt \
  --motion-file "$MOTION"
```

`play.py`는 `--motion-file <local.npz>` 또는 `--wandb-run-path` 중 하나가 필요하다. checkpoint가 어떤 motion으로 학습됐는지 모르면 그 run의 `outputs/g1_tracking/<run>/params/env.yaml`의 `motion_file:`을 본다.

## Config Digest

Source of truth after each run is the generated YAML under the run directory:

```text
outputs/g1_tracking/<run>/params/env.yaml
outputs/g1_tracking/<run>/params/agent.yaml
```

Only the digest below should be copied into wiki run records.

- task id: `Mjlab-Tracking-Flat-Unitree-G1`
- motion file: `$MOTION`
- actor: MLP, hidden dims `(512, 256, 128)`, activation `elu`, obs normalization on, Gaussian distribution with scalar std
- critic: MLP, hidden dims `(512, 256, 128)`, activation `elu`, obs normalization on
- PPO: learning rate `1e-3`, gamma `0.99`, lambda `0.95`, entropy coef `0.005`, clip `0.2`, desired KL `0.01`, max grad norm `1.0`
- runner defaults: `num_steps_per_env=24`, `save_interval=500`, `max_iterations=30000`, `experiment_name=g1_tracking`
- reward terms: `motion_global_root_pos`, `motion_global_root_ori`, `motion_body_pos`, `motion_body_ori`, `motion_body_lin_vel`, `motion_body_ang_vel`, `action_rate_l2`, `joint_limit`, `self_collisions`
- termination terms: `time_out`, `anchor_pos`, `anchor_ori`, `ee_body_pos`

## How This Differs from the BoT Paper

| Axis | Current baseline | Body Transformer paper direction |
| --- | --- | --- |
| Main purpose | Reproduce mjlab G1 PPO motion tracking baseline | Compare robot-body-aware Transformer policy to MLP/Transformer baselines |
| Learning setup | PPO-based motion imitation/tracking | Both imitation learning and reinforcement learning experiments |
| Robot/task | Unitree G1 tracking in `mjlab` | MoCapAct/Adroit/A1 and other BoT benchmark settings |
| Architecture | Default MLP actor/critic | `Mapping -> Tokenizer -> masked self-attention -> Detokenizer` |
| Graph use | No graph inductive bias yet | Body graph mask from `MAPS` and `SP_MATRICES` |
| Fair comparison goal | Establish same task/reward/motion baseline | Later swap only actor architecture to BoT-style model |

This is not pure behavior cloning IL. It is mjlab's default PPO-based motion imitation/tracking task. A later pure BC experiment can be built by saving expert rollouts as `(obs, action)` and comparing MLP BC vs BoT BC.

## Logging and Plot Plan

Raw TensorBoard events stay in `mj_rl/outputs`. Wiki records should include the run directory, important final values, and selected plot paths if plots are exported later.

Primary learning curves:

- final episodic return
- `Train/mean_reward`
- `Train/mean_episode_length`

PPO health curves:

- `Loss/value`
- `Loss/surrogate`
- `Loss/entropy`
- `Loss/learning_rate`
- `Policy/mean_std`
- `Perf/total_fps`
- `Perf/collection_time`
- `Perf/learning_time`

Reward breakdown:

- `Episode_Reward/motion_global_root_pos`
- `Episode_Reward/motion_global_root_ori`
- `Episode_Reward/motion_body_pos`
- `Episode_Reward/motion_body_ori`
- `Episode_Reward/motion_body_lin_vel`
- `Episode_Reward/motion_body_ang_vel`
- `Episode_Reward/action_rate_l2`
- `Episode_Reward/joint_limit`
- `Episode_Reward/self_collisions`

Tracking error curves:

- `Episode/error_anchor_pos`
- `Episode/error_anchor_rot`
- `Episode/error_body_pos`
- `Episode/error_body_rot`
- `Episode/error_joint_pos`
- `Episode/error_joint_vel`

Termination and success proxy:

- `Episode_Termination/time_out`
- `Episode_Termination/anchor_pos`
- `Episode_Termination/anchor_ori`
- `Episode_Termination/ee_body_pos`

Post-training evaluation table:

- `success_rate`
- `mpkpe`
- `r_mpkpe`
- `joint_vel_error`
- `ee_pos_error`
- `ee_ori_error`

## Run Record Template

Copy this block for each meaningful run.

```markdown
### Run: <run-name>

- date:
- command:
- task id: `Mjlab-Tracking-Flat-Unitree-G1`
- motion file: `/tmp/mjlab_cache/lafan1_dance1_subject1_demo_motion.npz`
- output dir: `/home/frlab/mj_rl/outputs/g1_tracking/<timestamp>_<run-name>/`
- config source:
  - `/home/frlab/mj_rl/outputs/g1_tracking/<run>/params/env.yaml`
  - `/home/frlab/mj_rl/outputs/g1_tracking/<run>/params/agent.yaml`
- best checkpoint:
- best metric:
- plot paths:
- result summary:
- failure notes:
- next decision:
```

## Next

1. Run demo to confirm viewer and cached assets.
2. Run smoke training with `$MOTION`.
3. Run sanity training and verify `motion_tracking.best.pt` export.
4. Record the run using the template above.
5. Only after baseline runs, replace the policy actor (and optionally critic) with BoT while keeping task, motion file, observations, actions, rewards, and PPO settings fixed.
   - 논문 §5.2 기준 **BoT-Mix(`is_mixed=True`)부터** 시도한다. BoT-Hard는 hard-exploration task에서 정보 전파 병목으로 열세였다(Humanoid-Board/Hill). 근거: [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]].
   - critic도 BoT로 갈 경우 detokenizer는 node별 value → body part 평균(scalar). actor만 교체하고 critic은 MLP 유지하는 변형도 비교 대상이 될 수 있다.

## Local Model Export

`mj_rl/scripts/train.py` now exports the best saved tracking checkpoint after training. Best is selected by `Train/mean_reward` among saved `model_<iter>.pt` checkpoints, with latest-checkpoint fallback if the metric is unavailable.

```text
/home/frlab/mj_rl/models/motion_tracking.<iter>.pt
/home/frlab/mj_rl/models/motion_tracking.best.pt
/home/frlab/mj_rl/models/motion_tracking.best.json
```

## Links

- papers: [[AI-Sessions/wiki/research/papers/2025-mjlab|2025-mjlab]], [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]]
- sources: [[AI-Sessions/wiki/research/sources/mjlab-code|mjlab-code]], [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]], [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
