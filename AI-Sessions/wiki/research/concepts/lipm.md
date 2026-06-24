---
tags: [tier/mid]
type: concept
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2024-lee-footstep-planning-rl.pdf
---

# LIPM (Linear Inverted Pendulum Model)

## 정의

LIPM은 이족보행을 단순화한 reduced-order model로, 지지발과 CoM을 무게 없는 telescopic leg로 연결한 도립진자다. CoM의 z축 속도를 일정하게 두고 ankle joint가 없는 point-foot를 가정하면 3D-LIPM의 운동방정식은 선형이 된다.

$$\ddot{r} = \omega_0^2 (r - p),\qquad \omega_0 = \sqrt{g/z_0}$$

여기서 $r=(r_x,r_y)$는 CoM 수평 위치, $p$는 지지발 위치, $\omega_0$는 진자의 natural frequency다. (1)을 적분한 "orbital energy"에서 Instantaneous Capture Point(ICP)가 유도된다.

$$\xi = r + \frac{\dot{r}}{\omega_0}$$

ICP는 그 자리에 발을 디디면 시스템이 정지하는 지면상의 점이며, ICP dynamics는 $\dot{\xi} = \omega_0(\xi - p)$로 unstable하게 발산한다. 해는 $\xi(t) = e^{\omega_0 t}\xi(0) + (1-e^{\omega_0 t})p$. 이 예측성을 이용해 desired velocity로부터 step length·width offset을 계산하고 final ICP에 더해 다음 foothold를 정한다.

## 사용 논문

- [[AI-Sessions/wiki/research/papers/2024-lee-footstep-planning-rl|2024-lee-footstep-planning-rl]] — 3D-LIPM/ICP로 desired footstep을 생성해 RL에 partial guidance로 제공

## 구현 포인트

- LIPM은 정답 dynamics가 아니라 **저차원 안정성 가이드**다. full CoM trajectory를 강제 추종시키지 말고 desired footstep만 RL에 주는 것이 핵심(과적합 방지).
- $\omega_0 = \sqrt{g/z_0}$의 $z_0$(CoM 높이)는 일정 가정. base height reward로 가정을 유지시킨다.
- ⚠️ ICP 계산에 들어가는 CoM 속도 $\dot{r}$를 pelvis 강체 속도와 혼동하면 footstep에 직접 오차가 들어간다 (harness/errors/mjlab-errors).

## Links

- raw: AI-Sessions/raw/papers/2024-lee-footstep-planning-rl.pdf
