---
tags: [tier/low]
type: experiment
date: 2026-07-08
status: active
source: mj_rl source/tasks (planned independent task package)
related_papers: AI-Sessions/wiki/research/papers/2025-liu-mash.md, AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md
related_sources: AI-Sessions/wiki/research/sources/mj-rl.md
---

# Experiment: G1 22-DOF Limb-MARL — GCN limb actors + BoT token-group critic

## Question

MASH식 limb=agent MARL 분해에 **morphology-explicit GCN actor**(joint=node)를 결합하면, MLP limb actor(MASH 원본) 또는 기존 leg/arm 2-policy modular 구성 대비 locomotion 협응·수렴·smoothness가 개선되는가? critic은 BoT-style centralized `TokenGroupCritic`으로 limb별 value를 낸다.

## Design (2026-07-08 확정)

새 task는 **독립 패키지**로 만든다 — centroidal env factory를 재사용하지 않고 자기 env_cfg/mdp/mapping/agent를 소유한다 (구현: 사용자).

### Env (22-DOF waist-locked)

- robot: `build_g1_waist_locked_spec` (waist는 torso로 weld, leg 12 + arm 10).
- action term 4개(limb별 joint_pos): left_leg(6) / right_leg(6) / left_arm(5) / right_arm(5). `MultiAgentRlCfg` action은 dict 순서대로 cat되어 env로 가므로 env action term 순서와 actor unit 순서를 일치시킨다.
- reward: MASH식 **shared reward**가 기본 — reward routing 계약상 prefix 없는 term은 모든 value key에 공유된다(`modules/rl/reward_routing.py`). limb별 shaping(smoothness 등)만 `left_leg/` 등 prefix로 라우팅.
- phase: 기존 centroidal 계열 `phase_sin`/`phase_cos` 재사용 (MASH temporal director $\sin(2\pi(kt+\Delta_i))$의 등가물; limb별 offset을 줄지는 열린 항목).

### Actors — 4× 독립 GCNActor (limb-local obs, MASH-faithful CTDE)

- `ActorUnitCfg` 4개, 각각 model=`modules/models/gcn_actor.py:GCNActor`, actor unit 1개 = action term 1개 = value key 1개.
- **obs는 limb-local**: 자기 limb joint pos/vel/last action(joint token) + base token(torso 상태·velocity command·phase). limb ID one-hot은 불필요 — mapping/actor가 limb별로 분리되어 있다.
- joint=node, limb 내 kinematic chain adjacency.
- **base 주입 결정 개정 (2026-07-08 후반, 구현 완료)**: broadcast(add) 대신 **per-limb core node** — base token(base context로 초기화)을 limb GCN에 node로 편입하고 core↔전 joint star edge + joint chain으로 전파("base context → core node → joint nodes"). 구현: `GCNActor core_node=True` + `build_g1_limb_core_gcn_bank`(bias `kinematic`+`core`), `broadcast_global_to_joints=False`. 에이전트당 GCN node 수: 다리 7(core 1+joint 6), 팔 6(core 1+joint 5). tokenizer는 node별 2층 MLP(`GroupedMLP`, cfg key `node_mlp_layers=2`).
- **공유 base node(1개를 4 GCN이 공유) 기각 근거**: 공유 encoder 파라미터가 4 unit optimizer에 동시 등록되어 leg/arm의 서로 다른 lr·clip으로 중복 업데이트됨(정의 불가), decentralized execution 훼손, limb별로 필요한 base context projection이 다름(다리=command/gravity, 팔=CAM error). base obs 중복 제공은 MASH와 동일한 decentralized observation 표준.
- **obs 분배 방식 개정 (2026-07-08 후반, 사용자 결정)**: limb별 obs term ×4가 아니라 **전신 term 1벌 + mapping에서 limb slice**로 확정. obs term은 전신 폭(joint_pos/vel/last_action/cam_c/cam_d 각 22)만 정의하고, actor obs group은 4 unit이 **공유 1개**(`wb_actor`), critic은 `token_critic` 1개(분리 이유는 limb이 아니라 noise/privileged 정책). limb 분배는 각 limb Mapping의 `create_observation()`이 `flat[:, TERM_SLICES[term]][:, LEFT_LEG_COLS]`로 수행. slice가 학습 레이어보다 앞이라 policy는 자기 limb+base에만 함수적으로 의존 — CTDE limb-local 주장 유지. 소유 경계: `TERM_SLICES`(obs 벡터 내 term 위치)=mapping.py, `LEFT_LEG_COLS` 등 limb slice·`limb_part()`(22-joint 내 limb 위치)=`assets/unitree/g1.py`.
- 필요한 신규 코드: **limb-scoped graph tensors + limb mapping** (현재 `build_waist_locked_graph_tensors`는 22-joint 전체용). task 패키지가 소유하고 모델 코드는 수정하지 않는다.

### Feasibility (2026-07-08 코드 검증 완료 — `modules/` 무수정으로 가능)

- `MultiAgentPPO`/`MultiAgentRunner`는 actor/critic을 name-keyed dict로 다루고 unit 수 하드코딩이 없다. value key별 gamma/lam도 소유 actor cfg에서 동적 해석 → 2→4 actor는 cfg 나열만.
- `modules/primitives/graph_tensors.py:build_g1_limb_gcn_bank`가 이미 left_leg/right_leg/left_arm/right_arm group과 limb별 adjacency를 제공한다.
- `HumanoidBuilder`는 `controlled_joint_patterns` 임의 regex를 받는다 — limb 하나짜리 regex로 limb 6/5-joint + pelvis base subgraph가 나온다(waist-locked와 동일 메커니즘).
- 주의: limb mapping의 `matches_part`는 기존 `joint_part()`(좌우 미구분) 대신 side-aware 매칭(`left_`/`right_` prefix)을 직접 구현해야 `_validate_action_node_order`를 통과한다.
- 남는 실제 리스크는 엔지니어링이 아니라 학습 동역학: shared reward에서 4-limb credit 분할 시 arm 안정성(완충: arm conservative 세팅 + MASH 수렴 선례).

### Node feature 확장 — CAM-error alignment $(c_j, d_j)$ (2026-07-08 설계)

MASH-faithful obs(pos/vel/last_action) 위에 CMM 기반 구조 feature 2개를 joint token에 추가한다. reward가 아니라 **관측**이라 [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|per-joint credit 아이디어]]의 reward-hacking 위험이 없다.

- $k_j=A_G^{ang}[:,j]$ (CMM angular column, dq 없음): joint $j$가 단위속도로 움직일 때 CAM에 주는 방향 — **구조적 잠재력**.
- $\dot k_j=\dot A_G^{ang}[:,j]$: 같은 열의 시간미분(전신 운동까지 반영된 값, pure partial 아님).
- $\hat e_k$: CAM error $e=k_G-k_{des}$(base frame, angular)의 단위벡터.
- $c_j=k_j^\top\hat e_k$ — "지금 이 joint가 CAM error 방향으로 기여할 잠재력이 있는가".
- $d_j=\dot k_j^\top\hat e_k$ — "그 잠재력이 앞으로 커지는가/줄어드는가".

**이미 있는 재료**: `assets/cuda/_casadi_pinocchio_base.py:64-65`의 `self.CMM`·`self.dCMM` (N,6,NV)이 GPU 커널에서 매 스텝 이미 나온다(`gen_casadi_fns.py:124` `computeCentroidalMapTimeVariation`). `tasks/centroidal/mdp/centroidal.py`의 `CentroidalCache`는 현재 합산형(`cm_leg_w`/`cm_arm_w`)만 뽑으므로 per-joint column 노출은 신규.

**계산 (task-local `mdp/centroidal.py`, frame은 `cm_b`/`cm_des_b`와 동일하게 base로 맞춘다)**:

```python
actuated = torch.cat([
    torch.arange(CasadiPinocchio.LEG_COLS.start, CasadiPinocchio.LEG_COLS.stop),
    torch.arange(CasadiPinocchio.ARM_COLS.start, CasadiPinocchio.ARM_COLS.stop),
])  # 22 cols, leg(12)+arm(10), waist 제외 — mapping/graph의 joint 순서와 반드시 일치

CMM_ang = self.pinocchio.CMM[:, 3:6, actuated]    # (N,3,22) world frame
dCMM_ang = self.pinocchio.dCMM[:, 3:6, actuated]  # (N,3,22) world frame

k_j    = torch.einsum("nij,nja->nia", R, CMM_ang)   # (N,3,22) base frame — R = R_BW(quat), cm_b와 같은 R 재사용
kdot_j = torch.einsum("nij,nja->nia", R, dCMM_ang)  # (N,3,22)

e = self.cm_b[:, 3:] - self.cm_des_b[:, 3:]                     # (N,3) angular CAM error
e_hat = e / e.norm(dim=-1, keepdim=True).clamp_min(1e-6)

self.c_j = torch.einsum("nia,ni->na", k_j, e_hat)     # (N,22)
self.d_j = torch.einsum("nia,ni->na", kdot_j, e_hat)  # (N,22)
```

주의: `rotate_vec`(`utils/math_utils.py`)는 마지막 축이 3-vector인 형태(`...,3`)만 받으므로 (N,3,22) 컬럼 텐서엔 그대로 못 쓴다 — 위처럼 직접 `einsum`으로 회전한다. $d_j$는 순수 partial이 아니라 현재 $\dot q$까지 반영된 값이라 "joint $j$ 혼자 유발한 변화"가 아니라 "전신 운동이 만드는 coupling 회전의 joint $j$ 성분"으로 해석한다.

**연결 지점**: `mapping.py`의 limb joint token(현재 pos/vel/last_action 3-D)에 $c_j, d_j$를 붙여 5-D로 확장. `Tokenizer`/`GCNActor`는 node feature 폭만 맞으면 무수정으로 그대로 동작.

### Critic — shared TokenGroupCritic (기존 코드 그대로)

- `modules/models/token_group_critic.py:TokenGroupCritic`, obs group은 전신 `token_critic`(22 joint token + base token).
- **joint 순서가 limb별 연속 블록**(XML 확인: left_leg 0–5, right_leg 6–11, left_arm 12–16, right_arm 17–21)이라 연속 slice 계약이 그대로 성립:
  `value_groups={"left_leg": (0,6), "right_leg": (6,12), "left_arm": (12,17), "right_arm": (17,22)}`, `value_keys` 4개. critic 코드 수정 불필요.

### MASH 원본과의 의도적 차이

| 항목 | MASH | 이 task |
|---|---|---|
| actor 네트워크 | MLP + one-hot ID | limb GCN (joint=node) |
| 좌/우 parameter sharing | pair당 shared actor | 없음 — 현 `MultiAgentRlCfg`는 unit 간 공유 미지원(CTDE: unit=value key 1개). 추후 인프라 확장 항목 |
| critic | 전신 MLP global critic | BoT-style token-group Transformer critic |
| action | torque | joint position (mjlab 계약) |

## Task 패키지 네이밍 계획 (2026-07-08, `네이밍.md` §6 준수)

`네이밍.md` §6: "Task directories are behavior names"(`eicp`, `centroidal`, `bot_velocity`), §1: "task별 MDP는 공유하지 않는다 — 같은 이름을 쓰더라도 각 task 내부 구현으로 둔다". 이 task는 `centroidal` factory를 재사용하지 않는 독립 패키지이므로 `_token_group_critic`류 파생 접미사가 필요 없다. RL 정식화(behavior)가 headline이고 GCN/token-critic은 그 안의 architecture 선택이므로, `bot_velocity`가 아니라 `centroidal`/`eicp` 쪽 네이밍(순수 behavior명)을 따른다.

- **task 폴더**: `source/tasks/wbc_momentum/` — 2026-07-08 사용자가 실제 생성한 이름. momentum 중심 whole-body coordination이 behavior headline (초안 후보였던 `limb_marl`은 미사용).

```
source/tasks/wbc_momentum/
  __init__.py                        # register(): task id 등록, MultiAgentRlCfg 연결
  wbc_momentum_env_cfg.py            # scene(waist-locked 22-DOF) + action term 4개
                                      #   (left_leg_joint_pos/right_leg_joint_pos/
                                      #    left_arm_joint_pos/right_arm_joint_pos) +
                                      #   obs group 2개(공유 wb_actor + token_critic)
  mapping.py                         # TERM_SLICES(전신 obs 배치표, 공용 1벌) +
                                      #   limb Mapping(limb 파라미터화 4 인스턴스, 전신 obs에서
                                      #   자기 limb slice) + whole-body Mapping(critic 전용)
  agent/
    __init__.py
    rsl_rl_wbc_momentum_ppo_cfg.py   # MultiAgentRlCfg: ActorUnitCfg 4개(GCNActor) +
                                      #   CriticUnitCfg 1개(TokenGroupCritic, value_keys 4개)
  mdp/
    __init__.py
    commands.py                      # twist velocity command (task-local copy, §1 규칙)
    observations.py                  # 전신 obs term 1벌(joint_pos/vel/last_action 각 22 +
                                      #   cam_c/cam_d 각 22 + base terms) — limb 분배는 mapping 소관
    rewards.py                       # prefix 없는 shared term(MASH식) + left_leg//right_leg//
                                      #   left_arm//right_arm/ prefixed shaping term
    terminations.py                  # fall/timeout
    centroidal.py                    # CentroidalCache(task-local) — CMM/dCMM per-joint column +
                                      #   c_j/d_j (N,22) 계산. 위 "Node feature 확장" 절 소유
```

- **assets 레벨 추가**(task-specific 아님 — robot 구조라 `assets/`가 소유, §6 "Shared reusable modules live under source/modules or source/utils; task-specific logic stays under source/tasks/<task>/"와 대칭):
  - `assets/unitree/g1.py`: `LEFT_LEG_JOINTS`/`RIGHT_LEG_JOINTS`/`LEFT_ARM_JOINTS`/`RIGHT_ARM_JOINTS` regex 상수 4개 추가 — 기존 `LEG_JOINTS`/`ARM_JOINTS`/`WAIST_JOINTS` 네이밍과 동일 스타일.
  - `assets/graph/builder.py`: `G1WaistLockedGraphBuilder` 옆에 `G1LimbGraphBuilder`(limb 파라미터화) 또는 `build_g1_limb_graph(limb: Literal["left_leg","right_leg","left_arm","right_arm"]) -> RobotGraph` 추가 — limb 6/5-joint + pelvis base subgraph.
  - `modules/primitives/graph_tensors.py`: `build_g1_limb_graph_tensors(limb: str, *, device=None) -> GraphTensors` — `build_waist_locked_graph_tensors`와 동형, limb마다 다른 그래프를 반환(actor 4개가 각자 다른 `graph=` cnn_cfg를 받음).

- **agent cfg 파일 확장 여지**: baseline 비교(Open Items의 "MLP 4-limb")는 같은 `limb_marl` env를 재사용하고 `agent/rsl_rl_limb_marl_mlp_cfg.py`를 별도 추가해 actor `model.class_name`만 MLP로 바꾸는 형태로 계획한다(새 task 폴더 불필요 — `centroidal_token_group_critic`처럼 파생 접미사를 만들 필요가 없는 이유이기도 하다).

## Hyperparameter 출발점

- leg unit: 기존 centroidal leg 세팅 (lr=4.1e-4, clip≈0.121, γ≈0.975, std_range=(0.05,2.0)).
- arm unit: conservative 세팅 condition B (init_std=0.5, std_range=(0.05,1.0), clip=0.05, lr=1e-5, entropy=0.0, zero_init_last_layer) — 근거: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]] 2026-07-05 ablation.

## Open Items

- limb별 phase offset(temporal director) 주입 여부.
- 좌/우 shared-parameter actor 지원 여부 — 지원하려면 `MultiAgentPPO`/`ActorUnitCfg` 계약 확장 필요.
- ~~critic `include_base_token`~~ → **True로 확정** (2026-07-08): limb value head가 BoT 인코딩된 base+limb token을 함께 pooling — "critic 헤드 4개가 base node + limb node를 묶어 advantage 산출" 의도의 구현.
- ~~explicit base node ablation~~ → **core node가 v0로 승격** (위 "base 주입 결정 개정"). 반대 방향 ablation(broadcast 버전, core star 대신 chain-only)이 이제 후속 항목.
- baseline 비교 대상: MLP 4-limb(MASH-faithful) vs GCN 4-limb vs 기존 leg/arm 2-policy.

## Status / Next

- status: **planned** (설계 확정, task 패키지 미구현 — 사용자 구현 예정).
- 1) task 패키지(env_cfg+mdp+mapping+agent) 구현 → 2) smoke(forward/shape) → 3) 2-policy modular 대비 sanity → 4) baseline 비교.

## Links

- paper: [[AI-Sessions/wiki/research/papers/2025-liu-mash|2025-liu-mash]] (limb=agent MARL 원형)
- source: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] (GCNActor·TokenGroupCritic·MultiAgentRlCfg 계약)
- category: [[AI-Sessions/wiki/research/categories/morphology-aware-policy|morphology-aware-policy]]
- 선행 hyperparameter 근거: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]]
