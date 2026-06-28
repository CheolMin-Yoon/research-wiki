---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. 현재 checked commit은 `4735c7d1ecb5e1843816fdd5a1c2336fb943f682`이며, mjlab + rsl_rl 기반으로 eICP footstep, centroidal, graph Transformer 계열 task가 공존한다. source note에서는 구현 상태와 가져올 패턴만 남기고, 프로젝트 허브나 graph backbone으로 쓰지 않는다.

## 핵심 파일

- `source/tasks/eicp/planner/lipm.py`: eICP/LIPM footstep planner 구현.
- `source/tasks/eicp/`: eICP locomotion task의 command, observation, reward, termination, PPO config.
- `source/tasks/centroidal/`: centroidal/CAM 기반 modular task와 runner.
- `source/tasks/graph_transformer/`: graph Transformer task 계층. env/MDP/registry/agent cfg를 소유한다. 기존 `graph_centroidal` 이름은 rename되어 삭제 흐름이며, task ID는 `G1-GraphTransformer-Locomotion`, `G1-BodyTransformer-Locomotion`, `G1-GCNT-Limb-GraphTransformer-Locomotion`, `G1-CMM-Transformer-Locomotion`을 기본으로 본다.
- `source/modules/common/`: Mapping, graph builder, tokenizer, transformer encoder, detokenizer, `GraphActorCritic` 공통 구현을 소유한다. obs slice, action order, node order, CMM/centroidal field 계약은 model 내부 hard-code가 아니라 mapping/graph spec으로 이동했다.
- `source/modules/{body_transformer,gcnt_limb,cmm_transformer}.py`: task cfg가 직접 import하는 공개 policy variant wrapper다. top-level `modules`는 wrapper만 노출하고, 공통 구현은 `modules.common`으로 숨기는 구조를 따른다.
- `source/assets/graph/builder.py`: MJCF/MuJoCo model에서 body graph를 만드는 builder.
- `source/assets/cuda/`: CasADi-on-GPU centroidal/dynamics kernel generation과 wrapper.
- `source/assets/unitree/`: Unitree G1 asset, env spec, actuator/robot constants.
- `scripts/train.py`, `scripts/play.py`, `scripts/play_keyboard.py`: 학습과 재생 진입점.
- `NOTES.md`: 코드만으로 드러나지 않는 센서/동역학 함정과 디버깅 기록.

## 가져올 패턴

- eICP task는 reduced-order footstep planner와 rsl_rl policy를 묶는 현재 구현 기준이다.
- graph Transformer task는 Body Transformer/physical graph policy 실험의 landing zone으로 둔다.
- graph modules는 BoT식 `Mapping -> Tokenizer -> Transformer -> Detokenizer` 계약으로 재정리했다. 기존 `obs_slices.py`, `static_graph.py`, `topology_graph`식 source 노출은 제거하고, G1 특화 obs/action/topology 가정은 `modules.common.mapping`과 `modules.common.graph`의 명시적 contract로 둔다.
- graph Transformer task는 centroidal baseline reward/termination/observation 계열을 독립 소유하도록 분리됐다. reward에 이미 CAM 항(`tracking_CAM`·`dCAM_xy_penalty`·회전게이팅 `arm_joint_position_penalty`)이 있어 v0 thesis를 **CAM reward ablation**으로 검증 가능. CMM 캐시는 `CM_leg/CM_arm`(CMM@dq 2그룹 분해)을 이미 계산 → per-joint 열은 그 일반화.
- v0가 BoT(`BodyTransformerModel`) 대신 GCNT(`GCNTLimbModel`)를 fork하는 이유: BoT의 `nn.TransformerEncoderLayer`/`nn.MultiheadAttention`은 attention score를 숨겨 per-edge(hub) soft-bias를 못 넣지만, GCNT의 `_BiasedSelfAttention`은 score를 명시 노출(SPD bias 자리)해 CMM hub soft-bias를 그 자리에 삽입할 수 있다(근거: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]).
- `assets/graph/builder.py`는 Graph_Transformer의 notebook sketch를 실제 task graph로 연결할 때 기준 파일이다.
- CasADi-on-GPU kernel은 centroidal quantity를 vectorized env에서 계산하려는 방향성을 보여준다. production kernel 정본은 [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]를 따른다.

## 2026-06-28 Reflect: 학습 실패 가설

### 관찰된 사실

- graph Transformer 계열 task는 `graph_centroidal`에서 `graph_transformer`로 rename/decouple되었고, 이후 architecture 구현은 `source/modules/common/` 공통 contract와 top-level policy wrappers 구조로 정리됐다.
- `G1-BodyTransformer-Locomotion`과 `G1-CMM-Transformer-Locomotion`은 16 env, 1 iteration smoke에서 train entry, obs/action shape, class path resolve가 통과했다. action manager는 `leg_joint_pos(12)+arm_joint_pos(14)=26`, actor 출력은 `(B,26)`, critic 출력은 `(B,1)`로 확인됐다.
- smoke 로그 기준 초반 mean episode length는 약 8 step 수준이고 mean reward는 약 -38대였다. 이는 구조 import/shape 실패가 아니라, rollout 초반 종료/불안정이 빠르게 발생하는 현상으로 본다.
- CMM actor는 zero-init action head와 Gaussian `init_std=1.0` 구조를 유지한다. deterministic mean이 0 근처여도 exploration action은 초기부터 std 1.0으로 크게 흔들릴 수 있다.

### 해석 / 가설

- 현재 실패 원인은 "registration/class path/shape가 깨진 wiring bug"보다는 **reward/optimization + architecture-tokenization pathology** 쪽이 유력하다.
- 단순 MLP와 달리 graph policy는 flat obs를 그대로 소비하지 않고 `obs -> body/joint token -> graph/attention -> action token`으로 재해석한다. 따라서 actor가 obs group 전체를 받더라도, 실제 학습에 쓰이는 정보는 각 node/token feature로 어떻게 주입되는지에 좌우된다.
- 특히 초반 불안정은 다음이 겹칠 수 있다:
  - std 1.0 exploration이 26-DOF action에 동시에 들어가며 초기 자세를 크게 흔듦.
  - BodyTransformer/GCNT/CMM이 100-D flat obs를 token별 feature로 분해하면서 global/base/CAM/command/phase 정보가 joint action token까지 충분히 전파되지 않을 수 있음.
  - reward는 baseline과 유사해도, MLP가 flat global context를 직접 쓰는 것과 graph token action head가 local token을 통해 action을 내는 것은 최적화 난이도가 다르다.
- 따라서 "reward가 같으니 아키텍처 문제가 아니다"가 아니라, **reward가 같아도 policy parameterization과 token feature routing이 다르면 학습 난이도와 초기 failure mode가 달라진다**는 쪽으로 해석한다.

### 다음 확인 우선순위

1. BodyTransformer baseline을 먼저 안정화해서 graph tokenization 자체가 걷기 reward를 풀 수 있는지 확인한다.
2. 초기 rollout에서 deterministic action, sampled action norm, termination reason histogram, episode length 분포를 함께 기록한다.
3. node/token별 feature ablation을 한다: base/global context broadcast, phase/command broadcast, foot/contact token, CMM hub bias on/off.
4. reward 변경은 최소화하되, termination penalty 강화와 metric logging으로 early termination loophole인지 optimization instability인지 분리한다.
5. CMM 모델 평가는 BodyTransformer baseline이 최소한 살아나는지를 확인한 뒤 진행한다.

## 2026-06-28 Reflect: graph module modularization + GPU smoke

### 관찰된 사실

- `/home/frlab/mj_rl/source/modules`는 torch.nn처럼 얇은 공개 표면으로 정리됐다. top-level에는 `body_transformer.py`, `gcnt_limb.py`, `cmm_transformer.py` wrapper와 `common/`만 남고, 공통 구현은 `modules.common` 아래에 둔다.
- `modules.common`은 `mapping.py`, `graph.py`, `functional.py`, `tokenizer.py`, `transformer.py`, `detokenizer.py`, `actor_critic.py`로 나뉜다. task cfg는 여전히 `modules.body_transformer:BodyTransformer`, `modules.gcnt_limb:GCNTLimb`, `modules.cmm_transformer:CMMTransformer` 공개 경로를 사용한다.
- old common source인 `obs_slices.py`, `static_graph.py`와 topology-specific source 노출은 제거됐다. `rg` 기준 `_ACTOR_SLICES`, `_CRITIC_SLICES`, `topology_graph`, `common.static_graph`, `common.obs_slices` 참조가 남아 있지 않았다.
- graph specs는 `g1_leg`, `g1_arm`, `g1_leg_arm_no_waist`, `g1_full`, `g1_waist`로 명시화됐다. `g1_full`은 mjlab 기본 Unitree-G1 task와 같은 waist yaw/roll/pitch 포함 29-DOF action surface로 맞췄다.
- mapping specs는 graph_transformer whole-body(26), eICP leg-only(12), centroidal leg/arm(12/14), mjlab 기본 G1 velocity obs surface(99/111 obs → 29 action)를 소유한다. 새 task는 named mapping을 추가하거나 explicit `slices/base_roles/foot_roles/joint_order/joint_dims` contract를 넘긴다.
- `RslRlModelCfg`의 field 이름은 mjlab 프레임워크 경계 때문에 `cnn_cfg`로 남는다. 이 필드 안의 실제 의미는 graph module config이며, 내부 key는 `variant`, `mapping`, `graph`, `use_cmm`, `use_spd_bias`, `use_hub_bias`처럼 graph policy 용어로 유지한다.
- GPU 확인은 `mjlab_env`에서 `torch.cuda.is_available() == True`, device `NVIDIA GeForce RTX 5070 Laptop GPU`로 확인했다. CUDA obs로 wrapper를 직접 생성해도 output, tokenizer static buffer, attention mask buffer가 `cuda:0`에 놓였다.
- 1-iteration smoke는 CUDA에서 통과했다: `G1-BodyTransformer-Locomotion`, `G1-GCNT-Limb-GraphTransformer-Locomotion`, `G1-CMM-Transformer-Locomotion`, `G1-eICP-Graph-Locomotion`, `G1-Centroidal-Graph-Locomotion`.
- 추가 unit test는 mapping/action count, wrapper output shape, eICP/centroidal/mjlab-velocity mapping shape, explicit mapping contract, CUDA observation-device following을 확인한다.

### 해석 / 설계 결정

- 모든 task가 같은 graph policy를 쓰려면 "모델이 G1 no-waist 100D obs를 안다"가 아니라 "task가 Mapping/Graph contract를 제공한다"가 중심이어야 한다. 이번 구조는 그 방향으로 맞췄다.
- top-level `modules`는 사용자가 cfg에서 고르는 policy variant 이름만 보이게 두고, mapping/tokenizer/graph 같은 shared machinery는 `modules.common`에 둔 것이 더 안정적이다. task cfg의 공개 class path가 실험 이름과 일치하기 때문이다.
- 이전 CPU smoke는 환경/권한 경로의 산물로 보고, 검증 기준은 mjlab train entrypoint의 `cuda:0` smoke로 둔다. 모델 내부 static graph tensor도 obs sample device를 따라 초기화하도록 바꿔 CPU 초기화 오해를 줄였다.
- `cnn_cfg` rename은 mjlab/rsl_rl adapter를 건드리지 않는 한 비용이 더 크다. 대신 repo-local helper와 문서에서 "graph module config carrier"로 해석하고, 불필요한 alias layer는 만들지 않는다.

### 다음 확인 우선순위

1. smoke가 아니라 실제 장기 학습에서 BodyTransformer baseline이 기존 MLP reward를 풀 수 있는지 확인한다.
2. modular graph policy가 eICP/centroidal/graph_transformer/mjlab 기본 G1 task에서 같은 Mapping/Graph contract로 유지되는지, 새 robot/task 추가 시 cfg만으로 붙는지 확인한다.
3. checkpoint migration은 이번 범위 밖이다. class path와 output shape compatibility만 보장된 상태로 본다.

## 2026-06-29 Reflect: BoT ablation design

### 관찰된 사실

- `mj_rl` BoT baseline은 공식 BodyTransformer A1/RL 스타일을 유지하되, `source/modules/common`에 ablation 가능한 cfg 축을 추가했다.
- 새 cfg 축은 `is_mixed`, `first_hard_layer`, `norm_first`, `broadcast_global_to_joints`, `action_head_type`이다.
- 새 task aliases:
  - `G1-BodyTransformer-Mix-Locomotion`
  - `G1-BodyTransformer-MixBroadcast-Locomotion`
  - `G1-BodyTransformer-MixBroadcastPerToken-Locomotion`
  - `G1-BodyTransformer-PostNorm-Locomotion`
- 모든 BoT runner cfg는 RL size를 유지한다: `d_model=64`, `heads=2`, `ff=128`, `layers=10`, `num_mini_batches=6`.
- 검증: unit shape smoke, compile check, `git diff --check`, 128 env 1-iteration smoke for all new aliases, 512 env 1-iteration smoke for `MixBroadcastPerToken`.

### 해석 / 설계 결정

- 이번 변경은 논문의 sparse FLOPs 주장을 재현하는 최적화가 아니다. PyTorch `nn.TransformerEncoderLayer`/`MultiheadAttention`을 쓰므로 hard mask가 있어도 실제 실행은 dense attention 경로로 본다.
- 목표는 96GB 학습 전제에서 메모리보다 **정보 전파와 readout 표현력**을 분리해 보는 것이다.
- `is_mixed=True`는 hard mask inductive bias가 너무 강해 global/base context가 action token까지 늦게 도달하는지 확인하는 ablation이다. 공식 구현의 masked/unmasked layer 교대 규칙을 따른다.
- `broadcast_global_to_joints=True`는 mapping contract를 깨지 않기 위해 actor/critic flat obs의 기존 base slice만 joint token에 더한다. command/phase/CAM을 새로 re-slice하지 않는다.
- `action_head_type="per_token"`은 shared scalar head보다 action token별 독립 readout을 늘리되, joint-type별 head까지는 가지 않는다. type별 head는 별도 mapping 정책이 필요해 실험축을 흐린다.
- `PostNorm` alias는 architecture size를 바꾸지 않고 `norm_first=False`만 확인하는 안정성 ablation이다.

### 다음 확인 우선순위

1. 96GB 머신에서 baseline hard, mix, mix+broadcast, mix+broadcast+per-token, post-norm을 같은 seed/iteration budget으로 비교한다.
2. primary metric은 `Train/mean_reward`, `Train/mean_episode_length`, termination histogram, action std, reward terms로 둔다.
3. 학습이 살아나면 CMM hub 계열과 비교하고, 실패하면 deterministic action norm과 sampled action norm부터 분리한다.

## 주의점

- `graph_transformer`는 physical-feature-graph v0 landing zone이다. v0는 `modules.cmm_transformer:CMMTransformer` wrapper + `modules.common` contract + obs에 per-joint CMM 열 추가 + hub soft-bias로 본다. 설계 정본: AI-Sessions/wiki/research/idea-physical-feature-graph.md "확정 v0 스펙".
- whole-body CoM velocity는 pelvis velocity가 아니라 `subtree_linvel` sensor를 통해 확인해야 한다.
- CasADi kernel은 full 29-DOF G1 기준이다. mjlab 기본 Unitree-G1 velocity/tracking task는 29-DOF action surface를 쓰고, 이 repo의 graph_transformer v0/eICP/centroidal graph aliases에는 waist 삭제 26-DOF 또는 부위별 12/14-DOF 경로도 공존하므로 DOF mapping을 항상 task contract 기준으로 확인한다.
- 실행은 repo script의 train/play 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: 4735c7d1ecb5e1843816fdd5a1c2336fb943f682
- initial raw-stub checked commit: 017c485efe6024cb26825084e422cc778b4b5920
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
