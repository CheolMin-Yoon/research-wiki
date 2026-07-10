---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/2025-lee-humanoid-arm-cam-marl.md
---

# 구현 분석: LearningHumanoidArmMotion-RAL2025-Code

## Summary

2025 Lee arm-CAM 논문의 공식 IsaacLab 구현이다. raw repo stub의 checked commit `d176a14bd2ae4d7acaa8770a76931d2c3bbd205d`를 checkout해 확인했으며, 팔과 다리를 modular actor-critic으로 나누고 CAM을 observation/reward/analysis 축으로 쓰는 구조가 핵심이다. mj_rl의 centroidal 또는 modular policy task를 만들 때 CAM 계산, arm/leg 분리, 분석 recorder 패턴을 참고한다.

## 핵심 파일

- `extensions/humanoid/task/humanoid_full_modular.py`: modular humanoid task 본체. CMM/CAM 계산과 arm/leg policy 흐름이 집중돼 있다.
- `extensions/humanoid/task/humanoid_full_modular_task_cfg.py`: modular task의 observation, reward, terrain, command 설정.
- `extensions/humanoid/task/humanoid_full_modular_runner_cfg.py`: modular actor/critic 학습 설정.
- `extensions/humanoid/mdp/observations.py`: CAM, base, joint, command observation term 정의.
- `extensions/humanoid/mdp/rewards.py`: CAM regularization과 locomotion reward term 정의.
- `extensions/humanoid/dynamics/casadi_fns/`: CoM, CMM, dCMM 등 centroidal 계산용 CasADi 함수.
- `extensions/humanoid/utils/analysis_recorder.py`, `extensions/humanoid/utils/recorder_interface.py`: CAM total/base/leg/arm 분해와 시각화 기록.
- `scripts/train_modular.py`, `scripts/play_modular.py`: modular 학습과 재생 진입점.

## 가져올 패턴

- arm actor와 leg actor를 분리하되, CAM 같은 공통 centroidal quantity로 둘을 다시 coupling한다.
- reward에 CAM magnitude만 넣는 것이 아니라 base/leg/arm contribution을 분석 가능하게 기록한다.
- CMM @ generalized velocity 형태의 계산을 policy observation과 post-analysis 양쪽에서 재사용한다.
- vanilla task와 modular task를 나란히 둬 ablation이 가능하게 만든 점이 mj_rl 실험 구조에도 유용하다.
- **하이퍼파라미터 대조(2026-07-11, `humanoid_full_modular_runner_cfg.py` 직접 확인)**: `leg_algorithm`/`arm_algorithm` 두 `RslRlPpoAlgorithmCfg`가 완전히 독립이며, **arm 쪽도 `schedule="adaptive"`를 그대로 쓴다** — `learning_rate=1e-5`처럼 낮은 값이 fixed가 아니라 adaptive KL 스케줄러의 시작점으로 설계됐다는 뜻이다(gamma/lam/clip_param/entropy_coef/epochs/mini_batches까지 leg=0.9751·0.12143·4.1e-4, arm=0.99·0.2·1e-5로 mj_rl `agent_cfg.py`와 일치 확인). mj_rl의 `rl/mappo.py`가 나중에 추가한 actor별 `schedule` 오버라이드 기능을 이 task에 켤지 말지 결정할 때는 이 사실을 baseline으로 삼는다 — 자세한 소비처는 [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] Research-Relevant Patterns.

## 주의점

- IsaacLab, cusadi, 커스텀 rsl_rl submodule에 강하게 묶인 구현이다. 파일 구조는 참고하되 mjlab에 그대로 복사하면 안 된다.
- PhysX/IsaacLab generalized mass matrix와 mjlab/MuJoCo의 frame, velocity convention은 별도로 검증해야 한다.
- 실행은 README의 submodule 초기화와 `scripts/train_modular.py`, `scripts/play_modular.py` 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/2025-lee-humanoid-arm-cam-marl.md
- raw paper: AI-Sessions/raw/papers/2025-lee-humanoid-arm-cam-marl.pdf
- checked commit: d176a14bd2ae4d7acaa8770a76931d2c3bbd205d
