---
type: source
date: 2026-07-11
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
  - model-predictive-control
  - jax-solver
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. branch `refactor/mj-rl-v2`에서 `tasks.mlp_ctde`, `tasks.falcon`, `tasks.graph_mimic_29d` 실행 task를 가진다. FALCON task는 MJLab Asset Zoo의 physical/policy 29-DOF G1, ACCAD upper-body reference, lower 15D/upper 14D MAPPO를 MuJoCo Warp에서 실행한다. graph mimic task는 MjLab 기본 29D tracking을 lower/upper link-node GCN으로 분리한 실험이다. v1 상세는 [[AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11|archived-mj-rl-v1-2026-07-11]]에 보존한다.

이 digest는 **2026-07-12 세션에서 직접 다룬 범위만 검증**했다: `source/assets/{layout,layout_29,graph,graph_29,g1,dynamics}.py`, `source/models/gcn/`, `source/rl/{config,mappo}.py`, `source/tasks/{mlp_ctde,falcon,graph_mimic_29d}/`, `source/utils/{math_utils,graph_viz}.py`, `tests/`의 관련 MAPPO/FALCON/GCN/graph/math coverage. 전체 v2 구조 중 이 밖의 파일은 필요 시 다음 reflect에서 재확인한다.

## Project Docs Boundary

- repo-local canonical contract: `docs/design/`, `docs/tasks/`, `docs/handoff.md`, source code, `tests/`, CI와 실행 artifact
- wiki migration target: `docs/research/`의 조사 본문, `docs/experiments.md`의 조건·측정·판정, `docs/errors.md`의 재사용할 원인·예방
- migration 뒤 repo에는 exact wiki revision, 저장소별 적용 차이, 실행 script/artifact와 named regression test pointer만 남긴다.

## Current Implementation Surface (검증됨)

- `source/assets/layout.py`: G1 23-DOF joint 이름·순서·인덱스의 단일 손-작성 원천. 손-작성은 `LEFT/RIGHT_LOWER_BODY_JOINTS`(6+6), `WAIST_JOINTS`(1), `LEFT/RIGHT_UPPER_BODY_JOINTS`(5+5) 좌/우 튜플과 SDK 모터 인덱스뿐이고, DOF/slice/NQ·NV/`qpos_slice`/`qvel_slice`/`joint_group_of`는 전부 파생이다. **leg/arm 어휘는 저장소 전체에서 제거됨**(2026-07-11) — 도메인 토큰은 `lower_body`/`upper_body`/`waist` 셋뿐이다.
- `source/assets/graph.py`: C2 sagittal-mirror 대칭 계약. `JOINT_REPRESENTATION`(전신 23-wide signed permutation) → `ACTION_REPRESENTATION`은 도메인별 block 제한으로 파생. `MorphologyNode`/`KINEMATIC_EDGES`(도메인당 7 node/6 edge)는 향후 GNN policy를 겨냥해 존재하되 현재 어떤 task도 쓰지 않는다. **`ACTION_DIM` 공개 dict는 삭제됨**(2026-07-11) — dim이 필요한 소비자는 `layout.LOWER_BODY_DOF`/`UPPER_BODY_DOF`를 직접 읽는다.
- `source/assets/g1.py`: MJLab entity 조립(actuator/모터/자세). 모듈 자체가 네임스페이스(`G1_` prefix 없음, `g1.ACTION_SCALE`처럼 접근).
- `source/assets/dynamics.py`: 설치된 `casadi_on_gpu` 커널 runtime adapter. `NQ/NV`, `LOWER_BODY_COLS`/`UPPER_BODY_COLS`/`WAIST_COLS`는 layout에서 파생, 자체 계약값 없음.
- `source/rl/config.py`: MAPPO 구조 dataclass — `AgentCfg`/`ValueCfg`/`ActorModelCfg`/`CriticModelCfg`/`MappoAlgorithmCfg`/`MappoRunnerCfg`. actor/critic별 `learning_rate`/`clip_param`/`entropy_coef`/`schedule`는 전부 동일 패턴: `X | None = None` → 미지정 시 전역 `algorithm` cfg로 fallback.
- `source/rl/mappo.py`: MAPPO 알고리즘. **logical agent(액션 소유)** × **named value(reward/advantage 라우팅)** 두 축이 actor/critic 모델 그룹핑과 독립이다. 1-agent/1-value 케이스는 RSL-RL PPO와 텐서 의미론이 정확히 일치하도록 테스트로 고정. 2026-07-11: actor별 `schedule`(adaptive/fixed) 오버라이드 추가 — critic lr 동기화는 그 critic이 소비하는 actor가 **전부** fixed일 때만 그 critic도 고정된 채로 둔다. 2026-07-12: RSL-RL 5.4.0 PPO 순서·FP32·epoch/minibatch·adaptive-KL semantics를 유지한 채 eager fast path만 추가했다(단일 actor cat 생략, 단일 value critic column path, loss logging GPU 누적 후 1회 host transfer).
- `source/tasks/mlp_ctde/`: 첫 실제 MAPPO task. Full-body G1(23-DOF, waist는 joint equality로 고정, DOF는 유지)을 `lower_body`(legs, 12)/`upper_body`(arms, 10) 두 decentralized actor + 두 centralized-obs critic(각 critic은 자기 actor의 부분 관측과 무관하게 전신을 봄)으로 분해한다. `agent_cfg.py`의 lr/clip/gamma/lam/schedule 하이퍼파라미터는 RAL2025 `humanoid_full_modular_runner_cfg.py`의 `leg_algorithm`/`arm_algorithm`을 직접 이식한 것으로 확인(대조는 아래 Research-Relevant Patterns) — hidden_dims와 upper_body entropy_coef만 사용자의 의도적 편차.
- `source/tasks/falcon/`: `8bfdca4`에서 원본 FALCON README 실행 override까지 포함한 첫 정밀 parity pass를 완료했고 `fbf2ece`에서 보류 검증을 자동화했다. ACCAD 252-motion reference, 15D/14D two-actor MAPPO, 575D actor/128D critic 계약을 유지하면서 reward/timeout, G1 pose·PD·limit, command/force/curriculum, train DR/noise를 원본 의미에 맞췄다. 상세 차이와 검증 결과는 repo-local `docs/design/falcon-parity-audit-2026-07-11.md`가 정본이다. 범용 point-force wrench 및 conservative force-bound tensor 연산은 `utils.math_utils`가 소유한다.
- FALCON optimizer는 원본과 같이 AdamW(decoupled weight decay `1e-2`)이며 empirical observation normalization과 std clamp를 사용하지 않는다.
- `source/tasks/graph_mimic_29d/`: MjLab 기본 G1 29D mimic 물리와 PPO를 유지하고 lower 15D/upper 14D actor·value로 분리한다. actor/critic은 각각 4-layer morphology GCN이며 pelvis/torso에만 전역 context를 둔다. GCN core는 topology를 고정한 채 선언된 undirected edge별 positive weight를 학습할 수 있다. 2026-07-12: `mdp/debug_vis.py`의 `GraphOverlayEvent`(class-based, `mode="startup"`)가 `assets.graph_29.MORPHOLOGY_NODES`/`KINEMATIC_EDGES`를 실제 로봇 body position에 투영해 native viewer에 node-edge overlay를 그린다 — `cfg.events["graph_viz"]`로 등록, play 시 자동 on. 실험 설계·관측 폭·smoke/benchmark 결과의 정본은 [[AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic|2026-07-11-g1-29d-graph-mimic]]이다.
- `source/models/gcn/{model,token,gcn}.py`: graph mimic 현재 구조에서는 이미 주요 eager path가 정리됐다. single observation group은 원본 tensor view를 그대로 쓰고, action node order가 flat action order와 같으면 detokenizer가 zero allocation/scatter 없이 concatenated head output을 반환한다. `GCNBlock`의 7/8-node dense adjacency와 shared learnable edge 계산은 현재 node 수에서 큰 병목으로 보지 않는다.
- `source/assets/layout_29.py`, `source/assets/graph_29.py`: `layout.py`/`graph.py`(23-DOF)와 동일 규약의 29-DOF 판. 2026-07-12: `MorphologyNode`(양쪽 파일 공유 dataclass)에 `body_name` 필드를 추가했다 — 마지막 joint 가 만드는 body(`{joint}_link` 기계적 유도 + 파일별 예외 1~2개: 23-DOF `waist_yaw→torso_link`/`wrist_roll→*_rubber_hand`, 29-DOF `waist_pitch→torso_link`)를 anchor로 쓰되, **hip/shoulder는 마지막이 아니라 첫 번째 joint**(`hip_pitch`/`shoulder_pitch`)를 쓴다 — proximal 노드를 distal 쪽(무릎/팔꿈치)으로 치우치지 않게 하기 위해서다. 일반 원칙은 [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]] "link-node 시각화 anchor"를 본다.
- `source/utils/graph_viz.py`: robot/task-independent 순수 node-edge 그리기(`draw_node_edge_graph`). position dict + edge name-pair만 받고 `assets`/`tasks`를 모른다. mj_rl_v1의 `source/visualization/graph_viz.py` "joint" 스타일(color/radius)을 그대로 이식했다(v1 자체는 v1 전용 `RobotGraph`/`Mapping` 클래스에 결합돼 있어 재사용 불가, 스타일 상수만 가져옴).

## Current Contracts

- **도메인 토큰 단일화**: `lower_body`/`upper_body`(+독립 그룹 `waist`) 세 토큰만 쓴다. 규칙: *한 파일·한 저장소 안에서 같은 개념을 가리키는 철자가 두 개 있으면 안 된다.* 2026-07-11에 이 규칙 위반을 두 번 발견·수정했다 — (1) task 레이어 reward 키가 `leg/`인데 상수는 `LOWER_BODY_REWARD_TERMS`라 import-time assert가 깨짐, (2) `layout.py` 자신이 손-작성 원천(`LEFT_LEG_JOINTS`)과 파생 상수(`LOWER_BODY_JOINTS`)에서 서로 다른 어휘를 씀(사용자가 직접 지적). 자세한 원칙은 [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]] "one token per domain concept".
- **layout ↔ graph 책임 분리**: 숫자·인덱스·dim은 layout, 대칭·그래프 구조는 graph. graph는 torch 의존이라 대칭/그래프 구조를 실제로 쓰는 task만 import해야 한다 — 안 그러면 "이 task가 그래프에 의존한다"는 거짓 신호가 된다. layout 사실을 재수출하는 공개 API(예: 이전 `graph.ACTION_DIM`)는 만들지 않는다.
- **per-model hyperparameter override 패턴**: `ActorModelCfg`/`CriticModelCfg`의 모든 개별 노브(`learning_rate`, `clip_param`, `entropy_coef`, `schedule`)는 `X | None = None` → 전역 fallback 패턴을 따른다. 새 per-model 노브를 추가할 때 이 패턴을 유지한다.
- **strict PPO parity fast path**: MAPPO/GCN 속도 최적화는 RSL-RL 5.4.0의 표본 사용량, loss 수식, adaptive-KL 갱신 시점, gradient clipping, optimizer step 순서를 바꾸지 않는 범위에서만 한다. host sync/logging, 불필요한 cat/scatter/index copy처럼 의미론이 없는 복사만 제거한다.

## Research-Relevant Patterns

- RAL2025(`LearningHumanoidArmMotion-RAL2025-Code`, `humanoid_full_modular`)와 mj_rl `agent_cfg.py`를 하이퍼파라미터 대조한 결과, **leg/arm(우리 lower_body/upper_body) 두 그룹 모두 `schedule="adaptive"`를 쓰며 arm 쪽 `learning_rate=1e-5`은 fixed가 아니라 adaptive 스케줄러의 시작점**이다. mj_rl의 현재 기본값(두 actor 모두 전역 adaptive 상속, `schedule='fixed'` 미사용)이 원 논문 설계와 일치함을 확인했다 — 상세 대조표는 [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]를 본다.
- (v1 시절 patterns: graph policy mapping/tokenizer/transformer 계약, per-joint CAM credit telescoping 위험, CasADi 23DOF/13DOF 공존 — v2에 아직 재이식되지 않았으므로 archive를 참고만 한다.)

## Verification Snapshot

- 2026-07-11 `8bfdca4`: 전체 **67 tests OK**. FALCON CPU 2-env finite rollout, GPU 4-env MAPPO 1 update, GPU 16-env 2 update에서 lower/upper actor·critic이 모두 갱신되고 observation/reward가 finite함을 확인했다.
- 2026-07-11 `fbf2ece`: 전체 **71 tests OK**. 49 reward의 원본 YAML name/group/weight와 고위험 tensor golden을 고정했다. ACCAD는 원본과 byte-identical(SHA-256 `28be2c6e...e562`), Asset Zoo wrist는 0.17 kg rubber hand를 이미 fixed-body fusion한 0.254576 kg 말단임을 확인했다. MuJoCo가 동일 priority contact friction을 element-wise max로 결합해 terrain 1.0이 실효 하한을 올리는 문제를 발견해 terrain에도 같은 sampled friction을 쓰도록 수정했다. 사용자 4096-env run은 iteration 1002(약 9,850만 env steps), 39분까지 생존해 이전 11분 overflow 지점을 통과했고 계속 실행 중이다.
- 2026-07-11 `cf81c31` + uncommitted graph-mimic working tree: 전체 **87 tests OK**, CPU 2-env finite rollout과 MAPPO 1 update 완료. 네 actor/critic graph의 learnable edge parameter update를 checkpoint에서 확인했다. GPU smoke는 진행 중 FALCON run과 8GB GPU를 공유하지 않기 위해 보류했다.
- 2026-07-12 `cf81c31` + uncommitted graph-mimic/MAPPO fast-path working tree: 전체 **92 tests OK**, `git diff --check` OK, GPU 4-env graph mimic MAPPO 1 update 완료. 기존 graph checkpoint와 새 smoke checkpoint의 actor/critic state dict key가 동일함을 확인했다. 4096-env benchmark에서는 strict PPO eager fast path가 의미 있는 10% learning-time 개선을 보이지 않았고, `torch_compile_mode=default`도 eager보다 빠르지 않았다. 병목은 불필요 복사보다 네 개의 128x4 GCN actor/critic을 5 epoch x 4 minibatch로 forward/backward하는 구조적 계산량에 가깝다. 상세 수치는 graph mimic experiment에 둔다.
- 2026-07-12 (이어서, body_name/debug_vis 추가분): `layout_29`/`graph_29`/`layout`/`graph` 4개 파일 수정 + `utils/graph_viz.py`/`tasks/graph_mimic_29d/mdp/debug_vis.py` 신규 후에도 전체 **92 tests OK**(net 0 — 기존 assert 갱신 + 신규 assert 상쇄). `env.update_visualizers()`(실제 뷰어 dispatch 경로)로 15 sphere + 13 cylinder가 CPU에서 정확히 그려짐을 확인했다. 처음에 `EventManager`가 `debug_vis`를 안 부르는 버그를 겪었는데, 원인과 수정은 [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]] "class-based event term에 reset이 없으면 debug_vis가 조용히 안 불림"에 있다.
- 이전 v1 검증 스냅샷은 archive를 본다(더 이상 유효하지 않은 구조 기준).

## Next

1. graph mimic은 strict PPO parity baseline을 유지한 채 동일 motion MLP 대비 full run을 비교한다.
2. 속도 개선이 더 필요하면 PPO semantics가 바뀌지 않는 미세 조정은 더 살피되, 큰 개선은 GCN 폭/깊이, actor/critic 통합, minibatch/epoch 등 별도 ablation으로 분리해야 한다.
3. 실제 IsaacGym 전용 환경이 준비되면 tensor oracle을 cross-simulator state replay로 보강한다.

## Cautions

- repo가 branch `refactor/mj-rl-v2`로 전면 재작성됨. 이 digest 이전 구조(모듈 3분할, `tasks.bot_velocity` 등)는 더 이상 존재하지 않는다 — archive를 봐야 한다.
- v1 시절 `네이밍.md`(single-quote 아닌 v1 스타일)는 v2에 그대로 적용되지 않는다. v2 lint 스타일(single-quote/4-space/79자/docstring 필수)은 [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]]를 본다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 current contract와 증류된 해석만 남긴다.

## History

- v1(pre-rewrite) 구현 상세: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11|archived-mj-rl-v1-2026-07-11]]
- v1 이전 reflect 이력: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]
- 삭제 오판 교훈(구조 변경 이후에도 원칙은 유효): [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]

## Relations

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: cf81c31 + 2026-07-12 uncommitted graph-mimic/MAPPO fast-path working tree (branch `refactor/mj-rl-v2`)
- previous checked commit (v1, pre-rewrite): ffbb2c3 (`master`)
- related RAL2025 reference (hyperparameter parity 확인): [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
