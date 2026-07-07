---
tags: [tier/low]
type: source
date: 2026-07-03
status: active
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. 2026-07-08 reflect 기준 checked commit은 `ffbb2c3`(브랜치 `master`)이고, 이번 작업은 BoT/GCN/Transformer building block과 rsl_rl orchestration을 `primitives/models/rl`로 분리하고 legacy modular runner 증식을 `MultiAgentRunner` 중심으로 접었다. source note는 현재 구현 계약과 다음 작업 포인터만 유지하고, 오래된 reflect 상세는 [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]에 보존한다.

## Current Implementation Surface

- `source/modules/primitives/`: 순수 PyTorch building block. GCN stack, graph tensor builder, token layout, BoT transformer encoder 등이며 rsl_rl runner/task/PPO를 모른다.
- `source/modules/models/`: rsl_rl-compatible model surface. `BoTActor`, token model/critic, GCN actor, shared value heads가 여기 있다.
- `source/modules/rl/`: network-agnostic multi-agent orchestration. `ActorUnitCfg`, `CriticUnitCfg`, `MultiAgentRlCfg`, action/reward routing, storage, PPO, runner를 소유한다.
- `source/tasks/bot_velocity/`: active BoT G1 23DoF velocity task 등록과 env/agent config. 옛 `body_transformer_velocity` package와 `G1-BodyTransformer-*` task alias는 제거했다.
- `source/tasks/centroidal/`: modular leg/arm actor + centroidal/CAM reward task. agent cfg는 `MultiAgentRlCfg`로 leg/arm actor와 critic units를 직접 표현한다.
- `source/tasks/centroidal_token_group_critic/`: 기존 centroidal env/reward/action을 재사용하되 `token_critic` obs group과 shared token-group critic cfg만 별도 소유한다. Task ID는 `G1-Centroidal-TokenGroupCritic-Locomotion` 그대로 유지한다.
- `source/tasks/eicp/`, `source/tasks/waist_momentum/`: eICP/LIPM step planner와 leg 또는 leg+waist task. CUDA/CasADi optional path와 debug visualization 계약은 유지한다.
- `source/assets/cuda/`: CasADi-on-GPU centroidal/dynamics kernel generation과 wrapper. 23DOF full-body와 13DOF leg+waist kernels are stored flat under `casadi_fns/` and `cuda_fns/`, distinguished by `g1_23dof_*` and `g1_leg_waist_13dof_*` prefixes.
- `scripts/helper/shared.py`: repo-local path bootstrap, task-id suggestion, checkpoint policy loading, viewer shutdown patch, train/play shared helpers를 소유한다.
- `scripts/train.py`, `scripts/play.py`, `scripts/play_keyboard.py`, `scripts/spawn_g1.py`: 학습, 재생, 키보드/diagnostic 재생, spawn smoke 진입점. plotting/sweep utilities는 `scripts/plotting/` 아래에 둔다.
- `source/visualization/`: command term은 state만 갖고 drawing은 여기로 분리하는 계약. `graph_viz.py`는 current graph/token diagnostic overlay이며 saliency가 아니다.
- `네이밍.md`: 변수명, 함수명, 파일명, config key를 맞추기 위한 repo-local naming convention.

## Current Contracts

- Package boundary: primitive는 PyTorch building block, model은 rsl_rl-compatible neural surface, rl은 actor/critic orchestration이다. 새 runner 파일로 실험 변형을 늘리지 않는다.
- Public naming: public actor class is `BoTActor`; GCN modules keep GCN/adjacency terminology. Transformer-side structural masks/biases keep attention-mask/bias terminology.
- Task naming: active BoT task package is `tasks.bot_velocity`; old `tasks.body_transformer_velocity` and top-level `modules.body_transformer` paths are not compatibility shims.
- G1 pose naming: `HOME_KEYFRAME`과 `KNEES_BENT_KEYFRAME`은 별개다. BoT/Centroidal 기본 robot cfg와 `scripts/spawn_g1.py`는 upstream mjlab velocity default에 맞춰 `KNEES_BENT_KEYFRAME`을 쓴다.
- CasADi wrapper: compatibility import `assets.cuda.casadi_pinocchio.CasadiPinocchio`는 23DOF full-body wrapper를 가리킨다. Layout-specific wrappers are `assets.cuda.casadi_pinocchio_g1_23dof.CasadiPinocchio` and `assets.cuda.casadi_pinocchio_g1_leg_waist_13dof.CasadiPinocchio`. 옛 `assets.cuda.pinocchio.Pinocchio` alias는 남기지 않는다.
- Command/obs naming: 현재 eICP/Centroidal 계열 velocity command key는 `"twist"`, step/phase command key는 `"step_command"`다. 관측 term은 `velocity_commands`, `phase_sin`, `phase_cos`, `last_leg_action`, `last_arm_action`, `CAM`, `CAM_des`를 쓴다.
- Debug viz ownership: command term(`_debug_vis_impl`)은 상태만 읽고, 실제 drawing 함수는 `source/visualization/`에 둔다. Centroidal 계열은 viewer 종료와 draw overhead를 줄이기 위해 `step_command.debug_vis=False`가 기본이며, `play_keyboard.py --command-viz`로 opt-in한다. BoT velocity는 twist arrow 기본 on을 유지한다.
- Playback checkpoint loading: mjlab `play.py`와 repo-local `play_keyboard.py`는 runner를 `load_cfg={"actor": True}`로 로드한다. `MultiAgentPPO.load()`는 new `actor_state_dicts`/`critic_state_dicts`, old modular `policies[...]`, old shared `critic_state_dict`, single `actor_state_dict` compatibility를 처리한다.
- Task separation: baseline `source/tasks/centroidal/`은 `token_critic` obs/config/import를 갖지 않는다. token-group critic 실험은 `source/tasks/centroidal_token_group_critic/`에서 기존 centroidal env factory를 호출한 뒤 `token_critic` obs만 추가한다.

## Research-Relevant Patterns

- graph policy는 `Mapping -> Tokenizer -> Transformer -> Detokenizer` 계약으로 둔다. 새 task/robot은 모델을 고치기보다 mapping/graph contract를 추가하는 쪽이 맞다.
- v0 physical-feature graph 설계는 BoT보다 GCNT 계열 attention implementation이 더 알맞다. BoT의 `nn.MultiheadAttention`은 score를 숨겨 CMM hub soft-bias 삽입이 어렵고, GCNT의 biased attention은 score 경로가 열려 있다. 설계 정본은 [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]]를 본다.
- per-joint CAM credit은 scalar reward로 합치면 global CAM penalty로 telescope될 위험이 있다. 정식 설계와 열린 항목은 [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]]를 본다.
- CasADi/CMM kernel은 23DOF full-body와 13DOF leg+waist layout을 prefix 이름으로 공존시킨다. lock은 질량 drop이 아니라 부모 바디로 관성 lumping된다. GPU backend 정본은 [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]를 본다.

## Verification Snapshot

- 2026-07-08 modular cleanup 검증: `conda run --no-capture-output -n mjlab_env python -m unittest discover -s tests -p 'test_*.py'` → 70 tests OK, skipped 1.
- script `py_compile` OK. `G1-Centroidal-Locomotion`/`G1-Centroidal-TokenGroupCritic-Locomotion` play cfg는 `twist=False`, `step_command=False`; `G1-BoT-Velocity-Flat-Locomotion`은 `twist=True`.
- 2026-07-07 centroidal token-group/Transformer modular 검증은 archive history에 남아 있다. 이후 transformer-modular task package는 generic multi-agent runner cleanup 과정에서 제거됐다.
- 이전 GPU smoke와 BoT ablation 설계 상세는 archive history와 관련 experiment/source notes를 본다.

## Next

1. 새 실험은 legacy runner 파일을 만들지 말고 `MultiAgentRlCfg` + `MultiAgentRunner` preset/config로 표현한다.
2. GCN limb actor 실험은 `source/modules/primitives/gcn.py`와 `source/modules/models/gcn_actor.py`를 재사용해 limb input/action 계약만 task cfg에서 바꾼다.
3. notebook이나 외부 스크립트가 옛 `modules.common`, `modules.body_transformer`, `tasks.body_transformer_velocity` 경로를 쓰면 alias를 되살리지 말고 새 `modules.primitives`, `modules.models`, `tasks.bot_velocity` 경로로 고친다.
4. CMM 모델 평가는 BoT/GCN baseline 중 최소 하나가 안정적으로 살아나는지 확인한 뒤 진행한다.

## Cautions

- `source/assets/cuda`와 `scripts/casadi_on_gpu`는 active BoT path에서 import되지 않아도 삭제 대상이 아니다. centroidal optional 자산과 branch continuity를 위해 보존한다.
- whole-body CoM velocity는 pelvis velocity가 아니라 `subtree_linvel` sensor를 통해 확인한다.
- task별 action surface는 항상 task contract 기준으로 확인한다. CMM kernel DOF와 policy action DOF는 별개다.
- repo-local naming 정본은 `/home/frlab/mj_rl/네이밍.md`다.
- `centroidal_viz.py`는 task별 `centroidal_getter`가 가리키는 pinocchio cache를 읽는다. `G1-Centroidal-Locomotion`은 23DOF wrapper, `G1-WaistMomentum-Locomotion`은 13DOF leg+waist wrapper를 쓴다. BoT-only 환경(`environment-win.yml`)에서는 못 켠다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 current contract와 증류된 해석만 남긴다.

## History

- Detailed reflect archive: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]
- 삭제 오판 교훈: [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]

## Links

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: ffbb2c3 (`master`)
- previous checked commit: b362398
- initial raw-stub checked commit: 017c485efe6024cb26825084e422cc778b4b5920
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
