---
tags: [tier/low]
type: experiment
date: 2026-07-10
status: active
source: isaac_humanoid source/tasks/ral2025_mit
related_sources: AI-Sessions/wiki/research/sources/isaac-humanoid-code.md, AI-Sessions/wiki/research/sources/mj-rl.md, AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code.md
---

# Experiment: Isaac MIT Humanoid — Jacobian Baseline vs GCN Early Screen

## Question

RAL2025 MIT Humanoid baseline과 동일한 reward·disturbance·domain randomization·PPO
파라미터에서, RAL2025 원본의 leg actuator Jacobian coupling까지 맞춘 뒤에도
`morphology GCN CTDE`가 baseline MLP보다 빨리 좋아지는 구간이 있는가?

사용자가 reward별 분해를 보며 판단한 현재 가설은 **0–200 iter, 넓게는 400 iter
이전 early curve에서 사실상 방향이 결정된다**는 것이다. 따라서 이번 스크린은
각 조건을 1000 iter 목표로 시작하되, wall-clock 1시간이 지나면 현재 학습을
interrupt하고 다음 조건으로 넘어간다.

## Fixed Contract

비교에서 고정하는 것:

- task/env: `RAL2025MitHumanoidEnvCfg` 계열
- reward, termination, command, DR, external disturbance
- PPO hyperparameter, seed, `max_iterations=1000`
- log root: `/home/frlab/isaac_humanoid/logs/rsl_rl/Humanoid_GCN_CTDE`
- RAL2025 fork의 `apply_humanoid_jacobian=True` 효과를 로컬 custom leg actuator로
  포팅한 상태

의도적으로 바꾸는 것:

- baseline MLP vs GCN actor/critic 구조
- GCN 내부 ablation: decoder context, token MLP depth, GCN layer count

## Run Set

자동 스케줄러:

```bash
cd /home/frlab/isaac_humanoid
nohup bash scripts/experiments/run_jacobian_early_5x1h.sh \
  > logs/scheduled_experiments/jacobian_early_5x1h.nohup.log 2>&1 &
```

공통 실행 조건:

```text
RUN_SECONDS=3600
MAX_ITERATIONS=1000
LOGGER=wandb
TRAIN_EXTRA_ARGS=--headless
CONDA_ENV=env_isaaclab
```

5개 run 순서:

| # | label | task | run_name / variant | purpose |
|---:|---|---|---|---|
| 1 | baseline-mlp-jacobian | `RAL2025-MIT-Humanoid` | `baseline-mlp-jacobian` | actuator parity 이후 새 baseline |
| 2 | current-arm-wbc-learned-jacobian | `gcn_ctde` | `gcn64x4-token64x2-arm-wbc-cam-dcam-bias-learned-jacobian` | 현재 기본 GCN |
| 3 | dec-basecat-jacobian | `gcn_ctde` | decoder `base` context concat | base token을 decoder에도 직접 주입 |
| 4 | token64x1-jacobian | `gcn_ctde` | node/token MLP 1층 | token encoder depth 축소 |
| 5 | gcn64x6-jacobian | `gcn_ctde` | GCN layer 6 | message passing depth 증가 |

## Metrics to Compare

우선순위:

1. `Episode_Reward/leg_tracking_lin_vel_xy`
2. `Metrics/base_velocity/error_vel_xy`
3. `Episode_Reward/tracking_ang_vel_z` 또는 yaw 관련 항목
4. `Episode_Termination/time_out`, `Episode_Termination/base`
5. arm CAM 관련 reward: `tracking_CAM`, `dCAM_xy` 계열
6. PPO health: value loss, surrogate loss, mean std, NaN 여부

현재 관찰상 GCN은 symmetry/bias 덕분에 yaw·angular 쪽은 유리할 수 있으나,
baseline 대비 `lin_vel_xy`가 약하면 최종 locomotion 품질에서 밀릴 수 있다. 이
스크린의 핵심은 "GCN depth/dim을 무작정 키울 문제인가, 아니면 base/global 정보를
joint action readout으로 전달하는 병목인가"를 빠르게 가르는 것이다.

## Interpretation Rules

- 1시간 컷오프 때문에 **최종 1000-iter 성능 비교가 아니라 early sample-efficiency
  스크린**으로 해석한다.
- baseline이 actuator parity 이후에도 강하면, GCN은 단순 dim/layer 조정보다
  base context routing(decoder concat, global token, GT-TD3식 query/key bias)을 먼저 본다.
- `token64x1`이 큰 손실 없이 비슷하면 node/token MLP 2층은 과한 bottleneck일 수 있다.
- `gcn64x6`이 개선되지 않으면 GCN layer depth를 늘리는 방향은 우선순위를 낮춘다.
- NaN이 나면 해당 조건은 성능 실패와 별도로 obs/action normalization 또는 env
  instability로 분리 기록한다.

## Result

5-run 스크린 중 1~4번은 완료됐고, step≤400 동일-iteration 비교에서 baseline이
아직 GCN 변형들보다 우세하다(reward 61.40 vs 55.05~57.76). 5번(`gcn64x6-jacobian`)과
큐잉된 두 follow-up(`gcn128x4-2048env`, mj_rl-matched hypers)은 실행 도중
`source/assets/graph/__init__.py`가 삭제되면서 전부 `ModuleNotFoundError: No
module named 'assets.graph'`로 죽었다 — 세부 원인·복구는 [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]
사례 6/7 참고, repo-local 기록은 `/home/frlab/isaac_humanoid/docs/experiments/2026-07-10-jacobian-early-screen-errors.md`.

`assets/graph` 복구 후 남은 3개를 40분 컷오프로 재시도했고, 재시도 과정에서
`mj_rl-matched hypers` 조건이 `test_gcn_ctde_agent_cfg`의 baseline-parity 계약(GCN
actor의 algorithm/distribution_cfg가 baseline과 구조적으로 같아야 함)과 정면충돌한다는
걸 발견했다 — `std_range` 필드 추가와 arm `clip_param=0.05`/`entropy_coef=0.0`(baseline은
0.2/0.01) 둘 다 이 계약을 깬다. 사용자 결정으로 두 값 모두 baseline과 동일하게 맞춰
parity 테스트를 유지했고, 그 결과 3번째 run은 원래 의도했던 "mj_rl hyperparameter
자체를 테스트"가 아니라 "`node_mlp_layers=1` + uniform(unlearned) bias만 테스트"로
범위가 좁혀졌다(`node1-uniform-bias-jacobian`).

```text
/home/frlab/isaac_humanoid/logs/scheduled_experiments/
/home/frlab/isaac_humanoid/logs/rsl_rl/Humanoid_GCN_CTDE/
```

## Links

- pattern: [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]] (사례 6/7 — git checkout 사고, nohup/setsid 재발)
- source: [[AI-Sessions/wiki/research/sources/isaac-humanoid-code|isaac-humanoid-code]]
- source: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- source: [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]
- related idea: [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]]
- related idea: [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]]
- repo-local details: `/home/frlab/isaac_humanoid/docs/experiments/2026-07-10-gcn-ctde.md`
