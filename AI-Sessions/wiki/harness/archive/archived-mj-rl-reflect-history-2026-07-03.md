---
tags: [tier/low]
type: archive
date: 2026-07-03
status: archived
source: AI-Sessions/wiki/research/sources/mj-rl.md pre-compaction reflect sections
---

# Archived mj_rl Reflect History (2026-06-28~2026-07-03)

`AI-Sessions/wiki/research/sources/mj-rl.md`를 current source note로 압축하면서 오래된 reflect 상세를 이력용으로 보존한다. active 구현 상태와 다음 작업은 source note와 state 문서를 본다.

## 2026-06-28 — 학습 실패 가설

- graph Transformer 계열 task는 registration/class path/shape smoke를 통과했지만, 초반 episode length가 매우 짧고 reward가 낮았다.
- 실패 원인은 wiring bug보다 reward/optimization + architecture-tokenization pathology 쪽이 유력하다고 봤다.
- 특히 `obs -> token -> graph/attention -> action token` 경로가 flat MLP와 다르므로, 같은 reward라도 global/base/CAM/command/phase 정보가 joint action token으로 충분히 전달되는지가 학습 난이도를 좌우한다.
- 다음 확인은 BodyTransformer baseline 안정화, deterministic/sampled action norm, termination reason histogram, node/token feature ablation 순서로 잡았다.

## 2026-06-28 — graph module modularization + GPU smoke

- `/home/frlab/mj_rl/source/modules`는 top-level policy wrapper와 `modules.common` 공통 구현으로 정리됐다.
- `modules.common`은 mapping, graph, tokenizer, transformer, detokenizer, model 계약을 소유한다.
- task cfg는 공개 class path `modules.body_transformer:BodyTransformer`, `modules.gcnt_limb:GCNTLimb`, `modules.cmm_transformer:CMMTransformer`를 사용한다.
- graph/mapping specs는 eICP leg-only, centroidal leg/arm, mjlab 기본 G1 velocity, whole-body graph task 등 action/obs surface 차이를 명시적으로 가진다.
- GPU smoke는 `mjlab_env` CUDA에서 여러 graph/centroidal/eICP task alias가 import/shape를 통과했다.
- `cnn_cfg` 필드명은 mjlab/rsl_rl adapter 경계 때문에 유지하되, repo-local 의미는 graph module config carrier로 해석한다.

## 2026-06-29 — BoT ablation design

- BoT baseline은 공식 Body Transformer 스타일을 유지하면서 `is_mixed`, `first_hard_layer`, `norm_first`, `broadcast_global_to_joints`, `action_head_type` ablation 축을 추가했다.
- 목적은 sparse FLOPs 재현이 아니라 정보 전파와 readout 표현력을 분리해서 보는 것이다.
- 새 aliases: `Mix`, `MixBroadcast`, `MixBroadcastPerToken`, `PostNorm`.
- 비교 우선순위는 hard/mix/mix+broadcast/mix+broadcast+per-token/post-norm을 같은 seed와 iteration budget으로 보는 것이다.

## 2026-06-29 — per-joint CAM credit S0

- `CentroidalCache.CM_joint`로 per-joint `A_G[:,j] * dq_j` credit surface를 추가하는 방향을 설계했다.
- frame 계약은 observation path와 reward path를 맞추기 위해 base frame으로 두는 것이 중요하다고 판단했다.
- `cam_joint_difference_reward`와 `cam_credit_dispersion`은 S0 진단용이며, reward cfg에 연결하지 않아 학습 거동을 바꾸지 않는 방향이었다.
- per-joint credit을 scalar reward로 합치면 global CAM penalty로 telescope되므로, spatial credit은 advantage 수준까지 가야 한다는 함정을 기록했다.

## 2026-07-01 — CMM 커널 DOF/관성 검증

- CasADi-on-GPU centroidal/dynamics kernel은 23-DOF locked G1 spec 기준이다: floating base 6 + legs 12 + waist_yaw 1 + arms 10.
- lock은 질량 drop이 아니라 부모 바디로 관성 lumping된다. pinocchio 모델에서 총질량은 23-DOF와 29-DOF 모두 33.3411kg로 동일했다.
- 손목 pitch/yaw와 waist roll/pitch의 독립 자유도는 사라지지만, distal mass/inertia 자체는 보존된다.
- 재사용 패턴: pinocchio 모델의 `*_fixed` frame 존재와 총질량 대조로 lock이 lump인지 drop인지 확인한다.

## 2026-07-01 — BoT master cleanup + graph/token visualization review

- `scripts/play.py`는 upstream mjlab에 가까운 thin wrapper로 유지하고, local teleop/diagnostic overlay는 `scripts/play_keyboard.py`에 모으기로 했다.
- `--graph-viz`는 live body/site graph overlay, `--token-viz`는 observation token diagnostic이다.
- token 색은 policy attention/importance가 아니라 heuristic이므로 saliency로 해석하면 안 된다.
- active BoT task에서 import되지 않는다는 이유로 `source/assets/cuda`와 `scripts/casadi_on_gpu`를 dead code로 삭제하면 안 된다는 교훈을 남겼다.

## 2026-07-03 — NOTES compression, play shutdown, K1 actuator wrapping

- `NOTES.md`를 압축하고, native MuJoCo viewer Ctrl-C 종료 edge case를 repo-local patch로 보정했다.
- K1 Rev.1 actuator 상수를 G1과 같은 `ElectricActuator` wrapper 형태로 정리했고, 기존 PD/effort/armature 수치는 유지했다.
- JAX probe deps는 기본 environment install 대상에서 제외됐다.

## 2026-07-03 — G1 pose naming + centroidal source cleanup

- `HOME_KEYFRAME`과 `KNEES_BENT_KEYFRAME`을 분리했다.
- BoT/Centroidal 기본 robot cfg와 `scripts/spawn_g1.py`는 upstream mjlab velocity default에 맞춰 `KNEES_BENT_KEYFRAME`을 사용한다.
- eICP는 knees-bent leg posture에 arm qpos=0인 별도 init을 유지한다.
- CasADi/CUDA wrapper는 `casadi_pinocchio.py` / `CasadiPinocchio`로 바꿨고 compatibility alias는 남기지 않는다.
- Centroidal periodic command는 실제 foothold planner가 아니므로 `gait_clock`으로 부르고, eICP의 실제 planner command만 `footstep`을 유지한다.
- MDP 공유와 High refactor는 하지 않고, Medium/Low naming/readability cleanup만 반영했다.

## Links

- [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]
