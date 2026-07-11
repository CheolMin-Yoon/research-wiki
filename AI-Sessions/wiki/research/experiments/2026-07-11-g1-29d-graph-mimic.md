---
tags: [tier/low]
type: experiment
date: 2026-07-11
status: active
source: /home/frlab/mj_rl
related_sources: AI-Sessions/wiki/research/sources/mj-rl.md
related_experiments: AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md
---

# Experiment: G1 29-DOF Split Morphology GCN Mimic

## Question

MjLab 기본 G1 29-DOF motion tracking의 물리·motion command·DR·termination·reward
계수·PPO를 유지하면서, 전신 MLP를 lower/upper link-node GCN으로 분리하면 단일
motion 추종을 안정적으로 학습할 수 있는가? 순수 kinematic graph만으로 부족하면
그때 pelvis→knee/ankle shortcut을 추가할 근거가 생기는가?

## Implementation State

- repository: `/home/frlab/mj_rl`
- branch: `refactor/mj-rl-v2`
- checked commit: `cf81c31` + 2026-07-12 uncommitted graph-mimic/MAPPO fast-path working tree
- task ID: `G1-GRAPH-MIMIC-29D`
- task source: `source/tasks/graph_mimic_29d/`
- design source: `docs/design/graph-mimic-29d.md`
- motion data는 vendoring하지 않고 실행 시 local NPZ를 명시한다.

## Fixed Baseline Axes

- robot/control: MjLab Asset Zoo 기본 G1 29-DOF actuator와 action scale
- motion/RSI/DR/termination/simulation: MjLab 기본 tracking task
- PPO: rollout 24, epochs 5, minibatches 4, LR `1e-3`, clip `0.2`, gamma
  `0.99`, lambda `0.95`, entropy `0.005`, adaptive KL, initial std `1.0`
- graph width/depth: actor·critic 모두 `128 × 4` GCN
- 비교 목적상 첫 full run에서는 motion, reward coefficient, PPO를 바꾸지 않는다.

## Graph and Action Contract

| Domain | Nodes | Action |
| --- | --- | ---: |
| lower | pelvis, waist, left/right hip-knee-ankle | 15D |
| upper | torso, left/right shoulder-elbow-wrist | 14D |

- node identity는 link 단위지만 node 입력/출력은 해당 link를 구동하는 joint 묶음이다.
  예: `hip actuator/state 3 → hip token → hip action 3`.
- pelvis와 torso는 action 없는 context node다.
- topology는 undirected kinematic edge만 사용한다. mirror/dense/shortcut edge는 없다.
- 각 undirected edge는 양방향 공유 positive scalar weight를 학습한다. 네 GCN layer가
  동일 adjacency를 공유하고 topology 밖 pair는 계속 0이다.

## Observation Split

기본 MjLab actor/critic은 각각 160D/286D다. graph task는 전역 15D를 base node에만
두고 joint별 `reference q/dq`, `current q/dq`, `previous action` 5개를 해당 node
tokenizer에 배정한다.

| Group | Width | 구성 |
| --- | ---: | --- |
| lower actor | 90D | global 15 + lower 15DoF × 5 |
| upper actor | 85D | global 15 + upper 14DoF × 5 |
| lower critic | 162D | lower actor + 8 body nodes × pose 9 |
| upper critic | 148D | upper actor + 7 body nodes × pose 9 |

Actor node raw width는 base/3DoF node 15D, 1DoF node 5D, ankle 10D다. Critic은
각 node에 anchor-frame body position 3D와 orientation 6D를 더해 각각 24D, 14D,
19D가 된다. Ragged 입력은 node별 tokenizer가 공통 128D token으로 투영한다.

## Reward and Value Routing

- lower value: global anchor pose, pelvis·torso·다리 body pose/velocity, lower
  action rate, lower joint limit
- upper value: 양팔 body pose/velocity, upper action rate, upper joint limit
- `shared/self_collisions`는 lower/upper value가 함께 소비한다.
- torso는 upper graph의 context node지만 torso를 직접 움직이는 waist 3DoF가 lower
  소유이므로 torso tracking reward는 lower에 둔다.

## Smoke Verification

2026-07-11에 다음을 확인했다.

- 전체 repository unit test: **87 tests OK**
- CPU 2-env reset + 4-step rollout: actor/critic observation과 reward finite
- CPU 2-env MAPPO 1 update: lower/upper actor와 critic 네 loss 모두 생성
- checkpoint의 네 `gcn.raw_edge_weights`가 초기값에서 최대 약
  `6.67e-4` 변해 actor/critic edge parameter update를 확인
- output directory:
  `/home/frlab/mj_rl/logs/rsl_rl/graph_mimic_29d/2026-07-11_22-45-47/`
- GPU 4-env smoke는 기존 `G1-FALCON`이 8GB GPU에서 약 5.8GB를 점유하고 있어
  실행하지 않았다. 이는 기능 실패가 아니라 동시 실행 자원 제약이다.
- MjLab tracking runner의 ONNX export는 multi-actor joint inference policy에
  `as_onnx`가 없어 warning을 냈지만 학습과 checkpoint 저장은 완료됐다. 추후 배포
  범위에서 별도 exporter가 필요하다.

Smoke command:

```bash
cd /home/frlab/mj_rl
PYTHONPATH=source /home/frlab/anaconda3/envs/mjlab_env/bin/python \
  scripts/train.py G1-GRAPH-MIMIC-29D \
  --gpu-ids None \
  --env.scene.num-envs 2 \
  --agent.max-iterations 1 \
  --agent.num-steps-per-env 4 \
  --agent.algorithm.num-mini-batches 1 \
  --agent.algorithm.num-learning-epochs 1 \
  --env.commands.motion.motion-file \
  /home/frlab/unitree_rl_mjlab/deploy/robots/g1/config/policy/mimic/dance1_subject2/params/dance1_subject2.npz
```

## MAPPO/GCN Runtime Check

2026-07-12에 graph mimic이 너무 느린 원인을 보기 위해 RSL-RL 5.4.0 PPO 의미론을
바꾸지 않는 eager fast path만 적용했다.

적용한 것은 다음 범위다.

- MAPPO loss logging을 GPU tensor로 누적하고 update 종료 시 한 번만 host scalar로 변환
- actor 하나가 logical agent 하나만 소유할 때 action `torch.cat()` 생략
- critic 하나가 value 하나만 담당할 때 value column slice/copy 사용
- GCN observation group이 하나뿐이면 flat observation `torch.cat()` 생략
- action node order가 flat action order와 같으면 detokenizer의 zero allocation/scatter 생략

바꾸지 않은 것은 PPO sample cadence, 5 epochs, 4 minibatches, FP32, adaptive-KL 갱신
시점, actor/critic optimizer step 순서, gradient clipping이다. 두 actor의 adaptive-KL
host transfer를 한 번으로 묶는 시도는 autograd graph lifetime을 늘리고 RSL-RL식
lower→upper 즉시 update 순서를 흐리므로 폐기했다.

검증:

- 전체 repository unit test: **92 tests OK**
- `git diff --check`: OK
- GPU 4-env graph mimic MAPPO 1 update: finite, checkpoint 저장 OK
- 기존 checkpoint와 fast-path smoke checkpoint의 lower/upper actor·critic state dict key 동일

4096-env benchmark(첫 2 iteration 제외):

| Run | Iter | Learning | Collection | FPS |
| --- | ---: | ---: | ---: | ---: |
| eager fast path | 50 | 6.0669s | 1.5129s | 12977.8 |
| strict sequential recheck | 20 | 6.0877s | 1.4810s | 12991.9 |
| `torch_compile_mode=default` | 10 | 6.0955s | 1.4457s | 13043.0 |

결론: 이번 fast path는 checkpoint/API/PPO parity를 지키는 정리로 남길 수 있지만,
학습 시간이 10% 이상 줄었다고 볼 근거는 없다. 현재 큰 비용은 중복 복사보다 네 개의
128x4 GCN(actor 2 + critic 2)을 20개 PPO minibatch에서 forward/backward하는 계산량이다.
`torch.compile(default)`도 이 조건에서는 이득이 없고, 이전 smoke에서 Dynamo recompile-limit
경고가 관찰됐으므로 권장 명령에는 넣지 않는다.

## Interim Baseline Comparison (같은 iteration, 완주 전)

2026-07-12: 4096-env `G1-GRAPH-MIMIC-29D` 풀런(iter 1002/3000, 사용자가 play.py 테스트를 위해 일시 중단)과 기존 `g1_tracking`(MjLab 기본 MLP, 같은 dance1_subject2 NPZ, iter 3672/30000까지 진행 후 중단) 로그를 **같은 iteration(~1000) 지점**으로 맞춰 비교했다. `g1_tracking`이 절대 iteration에서 3.7배 앞서 있어 raw 최종값 비교는 불공정하므로, `g1_tracking`의 iter~1000 구간 값을 따로 뽑았다.

| metric (iter~1000) | graph mimic | g1_tracking(MLP) | 우위 |
| --- | ---: | ---: | --- |
| mean_reward | 28.4 | 7.9 | graph (reward 스케일 다를 수 있어 참고용) |
| episode length | 339 | 260 | graph |
| error_body_pos | 0.121 | 0.148 | graph |
| error_body_rot | 0.438 | 0.617 | graph |
| error_joint_pos | 1.27 | 1.80 | graph |
| error_joint_vel | 13.8 | 16.9 | graph |
| error_anchor_pos | 1.01 | 0.80 | tracking |
| error_anchor_rot | 0.40 | 0.21 | tracking |
| ee_body_pos 조기종료 횟수 | 5.0 | 9.5 | graph(덜 넘어짐) |
| time_out 도달 횟수 | 6.75 | 5.5 | graph |
| FPS | 17,150 | 95,500 | tracking(5.6배) |

같은 학습량 기준 graph mimic이 body/joint 전반 tracking과 생존에서 뚜렷이 앞서지만, **anchor(pelvis/root) position·rotation tracking만 tracking(MLP)이 명확히 낫다**(rotation은 약 2배). pelvis가 lower graph의 root node라 command/orientation 정보는 있지만, "이 순간 root를 정확히 어디에 둘지"를 결정하는 신호가 flat MLP보다 약할 수 있다는 가설과 일치한다 — flat MLP는 root state와 나머지 관절 정보를 무차별하게 섞어 바로 최적화하기 때문. 확실한 비용은 위 Runtime Check와 같은 방향인 **FPS 5.6배 차이**로, 같은 iteration에 도달하려면 벽시계 기준 graph mimic이 5.6배 더 걸린다.

양쪽 다 NaN/Inf 없음(전체 히스토리 스캔 확인).

## Planned Runs and Decision Rule

1. 기본 MjLab MLP mimic과 graph mimic을 동일 motion/4096 env/30k iteration으로
   비교한다.
2. primary metric은 tracking error와 termination/success, secondary metric은
   sample efficiency와 FPS로 둔다.
3. graph mimic이 수렴하지 않거나 distal joint 추종이 체계적으로 약할 때만
   `pelvis→knee`, `pelvis→ankle` shortcut을 추가한다. 첫 baseline에는 넣지 않는다.

Full graph run:

```bash
python scripts/train.py G1-GRAPH-MIMIC-29D \
  --env.commands.motion.motion-file \
  /home/frlab/unitree_rl_mjlab/deploy/robots/g1/config/policy/mimic/dance1_subject2/params/dance1_subject2.npz \
  --env.scene.num-envs 4096 \
  --agent.run-name graph_mimic_29d_kinematic
```

## Links

- implementation digest: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- MjLab MLP tracking baseline: [[AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline|2026-06-25-g1-tracking-baseline]]
