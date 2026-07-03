---
tags: [tier/low]
type: source
date: 2026-07-03
status: active
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. 2026-07-04 reflect 기준 checked commit은 `b362398`(브랜치 `master`)이고, 이번 작업은 BoT mapping/readability 정리, leg+waist `waist_momentum` task, G1 CasADi-on-GPU kernel layout 공존화를 진행했다. source note는 현재 구현 계약과 다음 작업 포인터만 유지하고, 오래된 reflect 상세는 [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]에 보존한다.

## Current Implementation Surface

- `source/tasks/body_transformer_velocity/`: active BoT/BodyTransformer G1 23DoF velocity task 등록과 env/agent config.
- `source/modules/common/`: Mapping, graph spec, tokenizer, transformer, detokenizer, `GraphTransformerModel` 공통 계약. obs slice, action order, node order는 model 내부 hard-code가 아니라 mapping/schema/graph spec으로 둔다.
- `source/modules/{body_transformer,gcnt_limb,cmm_transformer}.py`: task cfg가 참조하는 공개 policy wrapper. top-level `modules`는 wrapper 표면만 노출하고 shared machinery는 `modules.common`에 둔다.
- `source/tasks/eicp/`: reduced-order LIPM/eICP step planner와 leg policy task. 외부 command key는 RAL/IROS naming에 맞춰 `"base_velocity"` + `"step_command"`다.
- `source/tasks/centroidal/`: modular leg/arm policy + centroidal/CAM reward task. 외부 command key는 `"base_velocity"` + periodic `"step_command"`다.
- `source/tasks/waist_momentum/`: eICP/LIPM step planner 기반 leg+waist 13DOF task. arms are locked by the G1 leg+waist spec, and debug visualization can show CoM sphere/trace plus 13DOF centroidal momentum arrows through the leg+waist CasADi wrapper.
- `source/assets/cuda/`: CasADi-on-GPU centroidal/dynamics kernel generation과 wrapper. 23DOF full-body와 13DOF leg+waist kernels are stored flat under `casadi_fns/` and `cuda_fns/`, distinguished by `g1_23dof_*` and `g1_leg_waist_13dof_*` function/file prefixes. active BoT velocity runtime import가 아니어도 보존 대상이다.
- `source/assets/unitree/`: Unitree G1 asset, keyframe/init state, actuator/robot constants.
- `scripts/train.py`, `scripts/play.py`, `scripts/play_keyboard.py`, `scripts/spawn_g1.py`: 학습, 재생, 키보드/diagnostic 재생, spawn smoke 진입점. `play.py`는 mjlab의 tyro CLI(`mjlab.scripts.play`)로 그대로 위임하는 얇은 wrapper라 `--checkpoint-file`은 mjlab 자체 필드다. `play_keyboard.py`는 키보드 텔레옵을 위해 mj_rl이 직접 짠 argparse 스크립트이며, 같은 플래그 이름을 관례상 재선언한 것뿐이다.
- `source/visualization/`: command term은 state만 갖고 drawing은 여기로 분리하는 계약. `footstep_viz.py`(eICP 발자국 박스/LIPM ghost/스윙 궤적), `centroidal_viz.py`(whole-body CoM 구+trace, `get_centroidal()` 캐시 기반 실제/명령 선·각운동량 화살표), `com_viz.py`(공유 `TraceBuffer` 슬라이딩 궤적 버퍼), `native_viewer_opts.py`(mjlab이 cfg로 노출하지 않는 MuJoCo native 뷰어 플래그 — transparent/contact_force/com 등 — 를 `viewer.setup()` wrap으로 켬, `play_keyboard.py --native-viz`에 연결).
- `네이밍.md`: 변수명, 함수명, 파일명, config key를 맞추기 위한 repo-local naming convention.

## Current Contracts

- G1 pose naming: `HOME_KEYFRAME`과 `KNEES_BENT_KEYFRAME`은 별개다. BoT/Centroidal 기본 robot cfg와 `scripts/spawn_g1.py`는 upstream mjlab velocity default에 맞춰 `KNEES_BENT_KEYFRAME`을 쓴다. eICP는 knees-bent leg posture에 arm qpos=0인 init을 유지한다.
- CasADi wrapper: compatibility import `assets.cuda.casadi_pinocchio.CasadiPinocchio`는 23DOF full-body wrapper를 가리킨다. Layout-specific wrappers are `assets.cuda.casadi_pinocchio_g1_23dof.CasadiPinocchio` and `assets.cuda.casadi_pinocchio_g1_leg_waist_13dof.CasadiPinocchio`. 옛 `assets.cuda.pinocchio.Pinocchio` alias는 남기지 않는다.
- Reference naming sources: `/home/frlab/LearningHumanoidArmMotion-RAL2025-Code`(`d176a14`)와 `/home/frlab/ModelBasedFootstepPlanning-IROS2024`(`9474713`)를 clone해 RAL/IROS variable/function naming을 확인했다.
- Command/obs naming: eICP와 Centroidal 모두 velocity command key는 `"base_velocity"`, step/phase command key는 `"step_command"`다. 관측 term은 `velocity_commands`, `phase_sin`, `phase_cos`, `last_leg_action`, `last_arm_action`, `CAM`, `CAM_des`를 쓴다.
- CAM/reward style: RAL2025 표면 이름에 맞춰 `dCAM_xy_penalty`, `tracking_CAM_reward`, `action_smoothness1/2`, `base_lin_vel_z_penalty`, `base_ang_vel_xy_penalty`를 쓴다. 옛 alias는 남기지 않는다.
- Symmetry cfg: G1 leg/arm action mirror를 모두 처리하므로 `g1_symmetry_cfg`를 쓴다. `leg_symmetry_cfg` alias는 남기지 않는다.
- MDP ownership: eICP와 Centroidal MDP는 의도적으로 공유하지 않는다. planner ownership과 reward/obs 계약이 달라서 naming/stale comment cleanup만 각 task 안에서 진행한다.
- Debug viz ownership: command term(`_debug_vis_impl`)은 상태만 읽고, 실제 drawing 함수는 `source/visualization/`에 둔다. eICP는 `StepCommandCfg.viz_footsteps/viz_lipm/viz_swing_ref/viz_swing_actual/viz_com_actual`, Centroidal은 `viz_com_sphere/viz_com_trace/viz_momentum`으로 개별 on/off한다. 두 task 모두 `step_command.debug_vis=True`가 기본이라 `play.py`/`play_keyboard.py`를 native/viser 뷰어로 켜면 추가 플래그 없이 바로 그려진다(뷰어 자체의 `_show_debug_vis`/`debug_visualization_enabled` 토글은 기본 on, native는 `R` 키로 끔).
- mjlab native viewer 플래그: `viewer.opt`/`vopt`(mjVIS_TRANSPARENT, mjVIS_CONTACTFORCE 등)는 mjlab cfg가 노출하지 않고, `launch_passive` 실행 이후(=`setup()` 호출 후)에만 존재한다. 켜려면 `viewer.setup`을 감싸 실행 직후 플래그를 세팅해야 한다(`native_viewer_opts.apply_native_viz`).

## Research-Relevant Patterns

- graph policy는 `Mapping -> Tokenizer -> Transformer -> Detokenizer` 계약으로 둔다. 새 task/robot은 모델을 고치기보다 mapping/graph contract를 추가하는 쪽이 맞다.
- v0 physical-feature graph 설계는 BoT보다 GCNT 계열 attention implementation이 더 알맞다. BoT의 `nn.MultiheadAttention`은 score를 숨겨 CMM hub soft-bias 삽입이 어렵고, GCNT의 biased attention은 score 경로가 열려 있다. 설계 정본은 [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]]를 본다.
- per-joint CAM credit은 scalar reward로 합치면 global CAM penalty로 telescope될 위험이 있다. 정식 설계와 열린 항목은 [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]]를 본다.
- CasADi/CMM kernel은 23DOF full-body와 13DOF leg+waist layout을 prefix 이름으로 공존시킨다. lock은 질량 drop이 아니라 부모 바디로 관성 lumping된다. GPU backend 정본은 [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]를 본다.
- graph/token visualization에서 token 색은 policy attention/importance가 아니라 diagnostic heuristic이다. saliency처럼 해석하지 않는다.

## Verification Snapshot

- 최근 source cleanup 검증: `compileall` 통과, `unittest discover -s tests` → 31 tests OK, skipped 1.
- 2026-07-04 BoT/waist/CasADi 검증: `tests.test_graph_modules` 12 tests OK, `G1-BoT-Velocity-Flat-Locomotion` zero-agent smoke 통과, `G1-BodyTransformer-Velocity-Flat-Mix-Locomotion` zero-agent smoke 통과, `G1-WaistMomentum-Locomotion` zero-agent smoke 통과. CasADi-on-GPU all-kernel build produced six prefixed kernels and both 23DOF/13DOF wrappers initialized in one process.
- cfg 직접 import 확인: eICP/Centroidal commands는 모두 `['base_velocity', 'step_command']`; `GaitClockCommandCfg`/`FootstepCommandCfg` alias 없음; Centroidal CAM reward key는 `arm/dCAM_xy`, `arm/tracking_CAM_reward`.
- Debug viz 검증: `py_compile` + 모듈 import 통과, `TraceBuffer` 슬라이딩/마스크-fill 동작 단위 테스트(CoM prefix, 양발 prefix) 통과, eICP/Centroidal env cfg factory 빌드 확인. **native/viser 뷰어로 실제 창을 띄워 그림을 눈으로 확인하지는 않았다** — 다음 세션이 `play_keyboard.py`로 라이브 검증해야 한다.
- 이전 GPU smoke와 BoT ablation 설계 상세는 archive history와 관련 experiment/source notes를 본다.

## Next

1. `play_keyboard.py`로 `G1-WaistMomentum-Locomotion`을 native 뷰어로 띄워 footstep/LIPM ghost/CoM 구/운동량 화살표가 실제로 잘 보이는지 눈으로 확인한다. zero-agent smoke는 통과했지만, 사람이 scale/readability를 확인해야 한다.
2. notebook이나 외부 스크립트가 옛 `assets.cuda.pinocchio.Pinocchio` 경로를 쓰면 alias를 되살리지 말고 import를 `assets.cuda.casadi_pinocchio.CasadiPinocchio`로 고친다.
3. BodyTransformer baseline hard, mix, mix+broadcast, mix+broadcast+per-token, post-norm을 같은 seed/iteration budget으로 비교한다.
4. CMM 모델 평가는 BodyTransformer ablation 중 최소한 하나가 살아나는지 확인한 뒤 진행한다.
5. `feature/port-eicp-centroidal-23dof`는 origin에 push만 됐고 master로 merge/PR은 아직이다 — 필요하면 사용자가 PR을 연다.

## Cautions

- `source/assets/cuda`와 `scripts/casadi_on_gpu`는 active BoT path에서 import되지 않아도 삭제 대상이 아니다. centroidal optional 자산과 branch continuity를 위해 보존한다.
- whole-body CoM velocity는 pelvis velocity가 아니라 `subtree_linvel` sensor를 통해 확인한다.
- task별 action surface는 항상 task contract 기준으로 확인한다. CMM kernel DOF와 policy action DOF는 별개다.
- repo-local `cnn_cfg` 필드명은 mjlab/rsl_rl adapter 경계 때문에 남을 수 있다. local helper 변수명은 실제 의미에 맞춰 `model_overrides`처럼 쓴다.
- repo-local naming 정본은 `/home/frlab/mj_rl/네이밍.md`다. `desired_` prefix 대신 내부 상태는 `_des`, command 값은 `_cmd`, reference trajectory는 `_ref` suffix를 우선한다.
- `centroidal_viz.py`는 task별 `centroidal_getter`가 가리키는 pinocchio cache를 읽는다. `G1-Centroidal-Locomotion`은 23DOF wrapper, `G1-WaistMomentum-Locomotion`은 13DOF leg+waist wrapper를 쓴다. BoT-only 환경(`environment-win.yml`)에서는 못 켠다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 current contract와 증류된 해석만 남긴다.

## History

- Detailed reflect archive: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]
- 삭제 오판 교훈: [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]

## Links

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: b362398 (`master`, before current push)
- previous checked commit: 7173d3ec6afe50e38f80105c4f679648c0799796
- initial raw-stub checked commit: 017c485efe6024cb26825084e422cc778b4b5920
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
