---
tags: [tier/low]
type: source
date: 2026-06-27
status: active
source: AI-Sessions/raw/repos/mpc-rl.md
---

# 구현 분석: mpc-rl push-box loco-manipulation

## Summary

`mpc-rl`은 THEMIS 휴머노이드의 mjlab 기반 MPC-guided locomotion / loco-manipulation repo다. 현재 사용자 목표인 "무거운 박스를 미는 G1 whole-body RL"에는 arm-only 조작보다 훨씬 직접적인 환경 레퍼런스다. 다만 사용자의 본 방향은 MPC-guided RL이 아니라 **Physical Feature Graph 기반 policy**이므로, `mpc-rl`에서는 **push-box task scaffold만** 참고하고 MPC solver/guidance는 이식하지 않는다.

checked commit: `97e37648d19b635f9b233c7146c28e68a8d672eb`

local clone: `/home/frlab/mpc-rl`

## 핵심 결론

- 바로 가져올 것: pushable box entity, push-mode forward-only command, hand-box / leg-box contact sensors, box relative/object obs, push rewards, box reset/mass/friction randomization, box failure terminations.
- 가져오지 않을 것: `LocoManipMPC`, hand force reference, MPC box reference trajectory tracking, JAX/PiMPC solver path.
- 그대로 복사하면 안 되는 것: THEMIS robot config, THEMIS hand geom/site names, mjlab 1.2.0-pinned API assumptions.
- `mj_rl` 쪽 첫 landing zone은 새 task 계층 `source/tasks/push_box/`가 가장 깔끔하다. `GCNTLimbModel`은 limb-only baseline/backbone으로 남기고, 메인 policy는 object/contact/centroidal token을 추가한 Physical Feature Graph 계열로 확장한다.

## mpc-rl 구조

### Task registration

`src/themis_training/__init__.py`는 두 task를 등록한다.

- `Mjlab-MPC-Guided-Locomotion-Themis`
- `Mjlab-MPC-Guided-Loco-manipulation-Themis`

loco-manipulation task는 `themis_loco_manip_mpc_push_box_flat_env_cfg()`와 `VelocityOnPolicyRunner`를 쓴다. README도 이 task를 "walking and pushing a box"로 설명한다.

### Push-box scene scaffold

`src/themis_training/env_cfgs.py`의 `_themis_mpc_push_box_base()`가 이식 가치가 가장 높은 부분이다.

- 기존 MPC-GRF locomotion base env 위에 `box` entity를 추가한다.
- twist command를 push-mode forward-only로 제한한다: `vx in [0, 0.75]`, `vy=0`, `wz=0`.
- `lhand_box_contact`, `rhand_box_contact`, `leg_box_contact` 센서를 추가한다.
- critic privileged obs로 `box_pose_rel`, `box_lin_vel`, `box_size`, `hand_box_contact`를 추가한다.
- push reward로 hand contact, box velocity tracking, robot-box velocity match, robot-box distance/yaw, leg-box collision, hand slip을 추가한다.
- reset event로 box pose/mass/friction을 randomize한다.
- termination으로 robot-box distance, box topple/pitch를 둔다.

`themis_loco_manip_mpc_push_box_flat_env_cfg()`는 그 위에서 MPC command를 `LocoManipMPCCommandCfg`로 교체하고, 50/50 push/walk split, arm pose constraint, box stall termination, hand-force tracking reward를 추가한다.

### Push-box MDP

`src/themis_training/push_box_mdp.py`는 task MDP를 거의 독립적으로 제공한다.

- `ModeGatedVelocityCommand`: push env에서는 command resample 후 `vy/wz`를 0으로 만들고 forward `vx`만 샘플한다.
- `get_push_box_spec()`: free-joint MuJoCo box를 만든다. 기본은 box geom + mass + friction.
- observation helpers: box pose in robot frame, box velocity in robot frame, box size, hand-box contact flags.
- rewards: `hand_box_contact`, `push_velocity_match`, `robot_box_velocity_match`, `robot_box_xy_distance_cost`, `robot_box_yaw_cost`, `leg_box_collision_cost`, `HandSlipPenalty`.
- reset/curriculum: box pose/mass reset, box size/friction randomization, mass-size-friction curriculum.
- terminations: robot too far, box toppled, box pitched, box velocity stall.

### Loco-manip MPC

`src/themis_training/mpc_grf_mdp.py`의 `LocoManipMPCCommand`와 `src/themis_mpc/loco_manip_mpc.py`의 `LocoManipMPC`는 v2 이후 참조로 둔다.

- `LocoManipMPC`는 centroidal MPC를 `nu=18`로 확장한다: left/right foot force+torque 12D + left/right hand force 6D.
- 입력에는 hand pose, hand contact gate, non-hand body-box contact force, box resistance force가 포함된다.
- command term은 hand-box sensors와 body-box net-force sensor를 읽고, box mass/friction에서 box resistance를 추정한 뒤 MPC를 푼다.
- 출력은 GRF ref, hand force ref, box ref trajectory로 reward/critic에 쓰인다.

이 경로는 `mpc-rl` 논문의 핵심이지만 사용자 아이디어의 본선은 아니다. G1 push-box에서는 MPC reference 대신 object/contact/centroidal physical features를 policy representation에 넣는 방향을 우선한다.

## mj_rl 이식 계획

### Phase 0: 범위 고정

- 목표 task: `G1-PushBox-PhysicalGraph` 계열. `G1-PushBox-GCNT-Limb`는 limb-only baseline 이름으로만 둔다.
- push-only로 시작한다. 50/50 push/walk split은 locomotion 유지가 무너질 때만 추가한다.
- policy baseline은 기존 `tasks.graph_centroidal.rl.gcnt_limb_model:GCNTLimbModel`을 재사용할 수 있다.
- 메인 실험은 Physical Feature Graph 방향으로 object token, hand/foot contact or wrench token, centroidal/CAM hub token을 추가한다.

### Phase 1: push_box MDP 이식

새 파일 후보:

- `mj_rl/source/tasks/push_box/mdp/push_box_mdp.py`
- `mj_rl/source/tasks/push_box/push_box_env_cfg.py`
- `mj_rl/source/tasks/push_box/agent/rsl_rl_push_box_cfg.py`
- `mj_rl/source/tasks/push_box/__init__.py`

먼저 port할 함수:

- `ModeGatedVelocityCommandCfg`
- `get_push_box_spec`
- `box_pose_rel_priv`, `box_lin_vel_priv`, `box_size_priv`, `hand_box_contact_priv`
- `hand_box_contact`, `push_velocity_match`, `robot_box_velocity_match`, `robot_box_xy_distance_cost`, `robot_box_yaw_cost`, `leg_box_collision_cost`
- `reset_box_pose_and_mass`, `randomize_box_friction_curriculum`
- `robot_far_from_box`, `box_toppled`, `box_pitched`, `box_velocity_stall`

MPC-dependent 함수는 v1 제외:

- `box_com_tracking`
- `mpc_hand_force_tracking`
- `LocoManipMPCCommandCfg`
- `LocoManipMPC`

### Phase 2: G1-specific sensor mapping

THEMIS 이름은 버리고 G1 MJCF에서 확인한 이름으로 매핑한다.

- hand geoms: `left_hand_collision`, `right_hand_collision`
- optional hand/palm sites: `left_palm`, `right_palm`
- arm geoms: `left_elbow_yaw_collision`, `left_wrist_collision`, `right_elbow_yaw_collision`, `right_wrist_collision`
- leg/foot geoms: `left_hip_collision`, `left_thigh_collision`, `left_shin_collision`, `left_linkage_brace_collision`, `left_foot[1-7]_collision`, right side 대응 geoms
- torso/base geoms: `pelvis_collision`, `torso_collision`

v1 sensors:

- `lhand_box_contact`: primary `left_hand_collision`, secondary `box_geom`, fields `("found", "force")`, reduce `maxforce`.
- `rhand_box_contact`: primary `right_hand_collision`, secondary `box_geom`, fields `("found", "force")`, reduce `maxforce`.
- `leg_box_contact`: primary leg/foot collision geom regex, secondary `box_geom`, fields `("found",)`.

body-box net-force sensor는 MPC phase에서만 필요하다.

### Phase 3: env cfg

`g1_whole_body_env_cfg(play=False)`를 상속해서 push-box scene을 얹는다.

- `cfg.scene.entities = {"robot": get_g1_robot_cfg(), "box": EntityCfg(spec_fn=get_push_box_spec)}`
- 기존 foot/bad-ground sensors에 hand-box/leg-box sensors를 append한다.
- `twist` command range를 push-only로 제한한다: `lin_vel_x=(0.0, 0.75)`, `lin_vel_y=(0.0, 0.0)`, `ang_vel_z=(0.0, 0.0)`.
- actor observation은 v1에서 기존 graph-centroidal 100D를 유지한다. 현재 `GCNTLimbModel`은 obs dim 100을 hard-check하고 `_ACTOR_SLICES/_CRITIC_SLICES`에 의존한다.
- box privileged obs는 critic에 바로 붙이면 `GCNTLimbModel`도 수정해야 하므로, v1 smoke는 critic도 100D 유지한다. v1.1에서 critic wrapper 또는 object-aware critic으로 확장한다.
- rewards는 기존 locomotion/posture/smoothness reward를 유지하고, push reward를 추가한다.
- CAM rewards는 push-box baseline 평가에서는 혼선을 만들 수 있으므로 별도 ablation으로 끄는 config를 둔다.

v1 reward set:

- keep: locomotion velocity tracking, contact schedule, base stability, action smoothness, joint limits.
- add: hand-box contact, push velocity match, robot-box xy distance, robot-box yaw, leg-box collision.
- optional after smoke: robot-box velocity match, hand slip, box velocity stall.
- exclude: box_com_tracking and hand force tracking until MPC exists.

### Phase 4: registration and runner

Task registration 후보:

- `G1-PushBox-PhysicalGraph`
- `G1-PushBox-GCNT-Limb`

Runner cfg:

- baseline `experiment_name="g1_gcnt_limb_push_box"`
- main `experiment_name="g1_push_box_physical_graph"`
- baseline actor/critic `class_name="tasks.graph_centroidal.rl.gcnt_limb_model:GCNTLimbModel"`
- main actor/critic은 object/contact/centroidal token을 처리하는 새 model로 둔다.
- baseline obs groups initially match graph-centroidal single actor/critic.
- when critic box obs is added, either:
  - `GCNTLimbModel`에 `allow_extra_critic_obs=True`와 trailing box obs branch를 추가한다.
  - or actor는 `GCNTLimbModel`, critic은 simple MLP/MLP+box branch로 분리한다.

### Phase 5: smoke and ablation

Smoke checks:

- task import/registration
- env reset with `num_envs=2`
- contact sensors present and produce expected shapes
- one PPO iteration with `--env.scene.num-envs 8 --agent.max-iterations 1`

First experiments:

- G1 whole-body locomotion baseline checkpoint reuse 가능성 확인
- GCNT-limb push-box from scratch
- GCNT-limb push-box with fixed low mass
- GCNT-limb push-box with mass/friction curriculum
- BoT/MLP policy comparison after task is stable

## Risks

- `GCNTLimbModel` currently hard-requires 100D graph-centroidal obs. Object observation을 actor/critic에 추가하려면 model slice를 수정해야 한다.
- box spawn이 항상 정면이고 actor가 box pose를 못 보면 v1은 "고정 배치 push skill"에 가깝다. 랜덤 box pose를 넓히려면 object token 또는 actor box obs가 필요하다.
- hand contact reward만 강하면 손으로 밀기보다 기대거나 box를 걸치는 local optimum이 생길 수 있다. leg-box collision penalty와 robot-box yaw/distance reward가 같이 필요하다.
- `mpc-rl`은 mjlab 1.2.0에 pin되어 있고 현재 `mj_rl` env는 더 최신 MuJoCo/mjlab stack이므로 API는 반드시 현재 설치본으로 검증해야 한다.

## Links

- [[AI-Sessions/wiki/maps/resources-policy-refs|resources-policy-refs]]
- [[AI-Sessions/wiki/research/categories/loco-manipulation|loco-manipulation]]
- [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- repo URL: https://github.com/junhengl/mpc-rl.git
- checked commit: `97e37648d19b635f9b233c7146c28e68a8d672eb`
- local clone: `/home/frlab/mpc-rl`
