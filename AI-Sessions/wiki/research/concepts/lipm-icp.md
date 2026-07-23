---
type: concept
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - centroidal-dynamics
---

# LIPM and ICP

## Definition and Boundary

Linear Inverted Pendulum Model(LIPM)은 CoM 높이를 일정하게 두고 지지점을 기준으로 수평 CoM dynamics를 선형화한 보행 모델이다.

$$\ddot r = \omega_0^2(r-p), \qquad \omega_0=\sqrt{g/z_0}$$

Instantaneous Capture Point(ICP)는 $\xi=r+\dot r/\omega_0$이며 현재 속도를 멈추기 위해 필요한 지면상의 지점을 나타낸다. LIPM/ICP는 full-body dynamics의 대체물이 아니라 foot placement와 안정성 판단을 위한 reduced-order guide다.

## Engineering Implications

- pelvis velocity 대신 실제 CoM velocity를 사용한다.
- 고정 CoM 높이와 point-foot 가정이 깨지는 동작에서는 모델 오차를 명시한다.
- RL에는 full trajectory 강제보다 foothold/reference 제공이 덜 경직된 interface가 된다.

## Relations

- guides: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]
- modeled-by: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Evidence

- Lee et al. 2024, LIPM/ICP-guided footstep planning RL
- Bang et al. 2024, ALIP-MPC footstep plan with learned residual
