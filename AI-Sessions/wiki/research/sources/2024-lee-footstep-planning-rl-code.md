---
type: source
date: 2026-06-24
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - centroidal-dynamics
source: AI-Sessions/raw/repos/2024-lee-footstep-planning-rl.md
---

# 구현 분석: ModelBasedFootstepPlanning-IROS2024

## Summary

2024 Lee footstep 논문의 공식 IsaacGym 구현이다. raw repo stub의 checked commit `9474713074f69e87807cfce07ac4db490664a54c`를 checkout해 확인했으며, 3D-LIPM footstep planner와 model-free PPO controller를 분리해 둔 구조가 핵심이다. mj_rl의 eICP/LIPM footstep task를 검증할 때 reference dynamics와 reward 구성을 대조하는 기준으로 쓴다.

## 핵심 파일

- `LIPM/LIPM_3D.py`: 3D-LIPM 상태 전파와 footstep pattern 생성의 중심 파일.
- `LIPM/demo_LIPM_3D_vt.py`, `LIPM/demo_LIPM_3D_vt_analysis.py`: velocity command에 따른 LIPM footstep 데모와 분석 코드.
- `gym/envs/humanoid/`: MIT Humanoid task, controller, terrain, reward가 들어 있는 환경 계층.
- `gym/utils/gait_scheduler.py`: phase/contact schedule을 관리하는 보조 계층.
- `learning/algorithms/ppo.py`: 논문 실험에 쓰인 on-policy PPO 구현.
- `learning/runners/on_policy_runner.py`: 환경 rollout, 업데이트, 로깅을 묶는 runner.
- `gym/scripts/train.py`, `gym/scripts/play.py`: 학습과 재생 진입점.

## 가져올 패턴

- reduced-order model은 full-body trajectory를 강제하지 않고 desired footstep만 제공한다.
- phase clock, contact schedule, residual joint PD action을 하나의 locomotion task로 묶는 방식은 mj_rl eICP task의 기준점으로 좋다.
- LIPM output과 RL reward를 분리해 두면, planner 버그와 policy 학습 문제를 따로 디버깅하기 쉽다.
- PPO implementation은 rsl_rl로 그대로 옮기기보다 reward term, observation term, gait schedule 의미를 대조하는 용도로 둔다.

## 주의점

- IsaacGym 기반 구현이므로 mjlab/mujoco_warp의 API, reset timing, sensor 의미와 직접 호환되지 않는다.
- 논문 구조는 MIT Humanoid와 point-foot 가정에 맞춰져 있어 Unitree G1의 ankle/foot geometry와는 보상 해석이 달라질 수 있다.
- 실행은 README의 IsaacGym setup, `gym/scripts/train.py`, `gym/scripts/play.py` 흐름만 최소 참고한다.

## Relations

- raw repo: AI-Sessions/raw/repos/2024-lee-footstep-planning-rl.md
- raw paper: AI-Sessions/raw/papers/2024-lee-footstep-planning-rl.pdf
- checked commit: 9474713074f69e87807cfce07ac4db490664a54c
