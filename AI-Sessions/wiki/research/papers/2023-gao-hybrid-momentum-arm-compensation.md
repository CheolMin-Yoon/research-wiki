---
tags: [tier/low]
type: paper
date: 2026-07-08
status: active
source: AI-Sessions/raw/papers/2023-gao-hybrid-momentum-arm-compensation.pdf
---

# Hybrid Momentum Compensation Control by Using Arms for Bipedal Dynamic Walking (2023)

- 저자: Zhifa Gao, Xuechao Chen, Zhangguo Yu, Lianqiang Han, Jintao Zhang, Gao Huang
- venue/DOI: Biomimetics 2023, 8, 31 / https://doi.org/10.3390/biomimetics8010031
- source: AI-Sessions/raw/papers/2023-gao-hybrid-momentum-arm-compensation.pdf

## Abstract (한국어)

이 논문은 torque-controlled biped robot이 dynamic walking 중 swing leg가 만드는 내재 disturbance와 unknown terrain disturbance를 팔 swing으로 보상하는 model-based 방법을 제안한다. 핵심은 팔을 단순 passive style motion이 아니라 **linear momentum과 angular momentum을 함께 보상하는 upper-body actuator**로 쓰는 것이다. 저자는 swing leg 상태에 따라 arm momentum compensation regulator를 만들고, leg의 실시간 동역학 상태를 기반으로 mixed-momentum QP controller를 풀어 reference arm torque/state를 생성한다. BHR-B2 force-controlled biped robot 실험에서 arm swing이 straight walking의 yaw drift를 줄이고, 5 cm platform descent 같은 disturbance 상황에서 balance recovery를 개선함을 보인다.

## 핵심 내용

논문은 팔이 biped dynamic walking에서 두 가지 disturbance를 보상한다고 본다. 첫째, swing leg가 support foot around yaw moment를 만들면 robot이 진행 방향에서 벗어나므로, arm angular momentum이 이 yaw disturbance를 상쇄한다. 둘째, swing leg가 unknown terrain과 갑자기 접촉하면 upper body가 overturn하려는 경향이 생기므로, arm linear momentum까지 포함한 hybrid momentum이 balance recovery에 기여한다.

팔 swing model은 human-like gait intuition을 쓴다. 같은 쪽 arm과 leg는 sagittal plane에서 반대 방향으로 swing하고, 반대쪽 arm과 leg는 같은 방향으로 움직인다. 보상 목표는 전체 angular momentum과 linear momentum이 reference에 가까워지도록 arm/leg momentum 합을 맞추는 것이다. angular part는 left arm/right leg 또는 right arm/left leg의 cross-side compensation, linear part는 same-side arm/leg compensation으로 설명된다.

controller는 두 층이다. 먼저 arm momentum compensation regulator가 swing leg 상태에서 desired arm state를 만든다. 그 다음 QP controller가 arm acceleration과 driving torque를 최적화한다. objective는 arm acceleration이 swing leg acceleration과 동조되도록 하는 항, swing leg momentum과 arm momentum이 상쇄되도록 하는 항, regulator가 낸 desired arm acceleration tracking 항, torque smoothing 항으로 구성된다. dynamics constraint와 torque limit이 들어가므로, pure trajectory swing이 아니라 force-controlled biped의 WBC/QP 계층 안에서 momentum compensation을 수행한다.

## 내 연구 연결

이 논문은 RAL2025 arm-CAM MARL보다 더 고전적인 model-based 선행근거로, 팔이 locomotion 중 **비접촉 centroidal stabilizer**라는 주장을 직접 뒷받침한다. 특히 팔의 angular momentum만 보는 것이 부족하고 linear momentum도 함께 고려해야 한다는 문제의식은 Physical Feature Graph에서 CAM token만이 아니라 linear momentum 또는 full centroidal momentum token을 분리/통합할지를 판단할 때 유용하다.

현재 mj_rl의 WBC momentum 방향과도 잘 맞는다. RAL2025가 CAM reward/obs로 arm behavior를 학습하게 했다면, 이 논문은 leg 상태에서 arm momentum compensation target을 계산하는 classical control 관점을 준다. 즉 `q`, `dq`, `last_action` 위에 CMM/CAM contribution을 joint token feature로 주는 설계는 "팔이 어떤 방향의 centroidal disturbance를 보상할 수 있는가"를 policy representation에 드러내려는 시도로 해석할 수 있다.

주의점도 있다. 논문은 QP/WBC controller가 명시적으로 arm reference와 torque를 계산하는 구조라서, RL policy가 CMM feature를 보고 암묵적으로 allocation을 학습하는 우리의 설정과 동일하지 않다. 따라서 이 논문은 직접 baseline이라기보다 **arm momentum compensation mechanism의 model-based evidence**로 쓰는 것이 맞다.

## 구현/실험 포인트

- `cam`, `dcam` joint scalar만으로 부족하면 base/global token에 linear momentum error 또는 full centroidal momentum error를 같이 주는 ablation을 열 수 있다.
- 2-actor upper/lower BoT-Mix 구조에서는 leg actor가 swing leg disturbance를, arm actor가 compensating momentum을 담당한다는 본 논문의 controller decomposition을 더 자연스럽게 반영할 수 있다.
- 평가 metric은 yaw drift, CAM/CMM-related error, platform descent 또는 push recovery survival, arm torque smoothness가 맞다.

## Links

- category: centroidal-wbc
- related papers: [[AI-Sessions/wiki/research/papers/2013-orin-centroidal-dynamics|2013-orin-centroidal-dynamics]], [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]]
