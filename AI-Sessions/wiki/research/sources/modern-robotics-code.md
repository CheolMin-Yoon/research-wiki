---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/modern-robotics.md
---

# 구현 분석: ModernRobotics

## Summary

사용자의 Modern Robotics 교재 기반 robotics math reference repo다. raw repo stub의 checked commit `ee49b600f058349e2d045ad76fad1d035cd0045f`를 checkout해 확인했으며, SO(3)/SE(3), forward/inverse kinematics, Jacobian, closed-chain, trajectory generation을 Python/PyTorch로 검증하는 성격이다. mj_rl의 math utils와 frame sanity check에 연결할 수 있는 수식 기준으로 둔다.

## 핵심 파일

- `ch03_rigid_body_motion/modern_robotics_ch03.py`, `modern_robotics_ch03_torch.py`: SO(3), SE(3), adjoint, twist/exponential map 관련 함수.
- `ch04_forward_kinematics/`: PoE 기반 forward kinematics와 Pinocchio/MuJoCo comparison.
- `ch05_velocity_kinematics/`: space/body Jacobian, manipulability, velocity kinematics.
- `ch06_inverse_kinematics/`: Newton-style IK와 comparison script.
- `ch07_closed_chain_kinematics/`: closed-chain kinematics 실습.
- `ch08_dynamics/`: dynamics 실습과 comparison code. 현재 runtime 이식 기준으로는 실패 상태로 본다.
- `kinematics_pick_and_place/`: UR5e pick-and-place, OSQP IK, MuJoCo/Pinocchio 연동 예제.
- `pin_utils/pin_utils.py`: Pinocchio helper utilities.

## 가져올 패턴

- SO(3)/SE(3) 변환, adjoint, Jacobian 계산을 mj_rl math utils 검산에 사용한다.
- PyTorch 버전은 autograd 기반 sanity check 또는 batched robotics math로 확장할 후보가 된다.
- Pinocchio/MuJoCo comparison script는 frame convention mismatch를 잡는 테스트 패턴으로 재사용한다.

## 주의점

- `ch08_dynamics`는 FAIL 상태로 표시되어 있으므로 dynamics runtime code로 이식하지 않는다.
- UR5e 중심 예제와 humanoid G1 kinematics는 joint layout과 frame convention이 다르다.
- 실행은 chapter별 script/notebook을 수식 검산용으로만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/modern-robotics.md
- checked commit: ee49b600f058349e2d045ad76fad1d035cd0045f
