---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/2025-mjlab.md
---

# 구현 분석: mjlab

## Summary

MuJoCo Warp와 Isaac Lab 스타일 manager API를 결합한 robotics RL framework다. raw repo stub의 checked commit `efdcadc8b281553fd3e1be2a9a88db9553356e8a`를 checkout해 확인했으며, mj_rl의 simulation/environment 기반이 되는 source다. 직접 구현 대상이라기보다 manager, entity, sensor, actuator, task registry의 의미를 정확히 이해하기 위한 reference로 둔다.

## 핵심 파일

- `src/mjlab/envs/manager_based_rl_env.py`: manager 기반 RL environment 본체.
- `src/mjlab/managers/`: action, observation, reward, termination, command, event, curriculum manager 계층.
- `src/mjlab/entity/`, `src/mjlab/scene/`, `src/mjlab/sim/`: MuJoCo model/data와 scene abstraction.
- `src/mjlab/sensor/`: contact, camera, raycast, terrain height, builtin sensor 구현.
- `src/mjlab/actuator/`: PD, DC, learned, XML actuator abstraction.
- `src/mjlab/tasks/velocity/`, `src/mjlab/tasks/tracking/`, `src/mjlab/tasks/manipulation/`: 기본 task 예제.
- `src/mjlab/rl/runner.py`, `src/mjlab/rl/vecenv_wrapper.py`: rsl_rl와 연결되는 runner/wrapper.

## 가져올 패턴

- environment logic을 observation/reward/termination manager로 쪼개는 구조.
- MuJoCo native data를 유지하면서 RL API는 Isaac Lab과 비슷하게 제공하는 방식.
- sensor와 actuator를 task config에 명시해 hidden dependency를 줄이는 패턴.
- velocity, tracking, manipulation task를 같은 manager interface에 올리는 task registry 구조.

## 주의점

- MuJoCo Warp/GPU path와 일반 MuJoCo path의 센서 계산 가능 범위가 다를 수 있다.
- mjlab의 `com` naming은 body CoM과 whole-body CoM을 혼동하기 쉬우므로 mj_rl 쪽에서는 `subtree_com`, `subtree_linvel` 사용 여부를 확인해야 한다.
- 실행은 README의 `uvx --from mjlab --refresh demo`, train/play script 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/2025-mjlab.md
- raw paper: AI-Sessions/raw/papers/2025-mjlab.pdf
- checked commit: efdcadc8b281553fd3e1be2a9a88db9553356e8a
