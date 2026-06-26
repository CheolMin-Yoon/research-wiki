---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. raw repo stub의 checked commit `017c485efe6024cb26825084e422cc778b4b5920`를 checkout해 확인했으며, mjlab + rsl_rl 기반으로 eICP footstep, centroidal, graph_centroidal task가 공존한다. source note에서는 구현 상태와 가져올 패턴만 남기고, 프로젝트 허브나 graph backbone으로 쓰지 않는다.

## 핵심 파일

- `source/tasks/eicp/planner/lipm.py`: eICP/LIPM footstep planner 구현.
- `source/tasks/eicp/`: eICP locomotion task의 command, observation, reward, termination, PPO config.
- `source/tasks/centroidal/`: centroidal/CAM 기반 modular task와 runner.
- `source/tasks/graph_centroidal/`: graph policy 실험 계층. README와 `rl/body_transformer_model.py`, `rl/static_graph.py`가 있으나 아직 미완성 source로 본다.
- `source/assets/graph/builder.py`: MJCF/MuJoCo model에서 body graph를 만드는 builder.
- `source/assets/cuda/`: CasADi-on-GPU centroidal/dynamics kernel generation과 wrapper.
- `source/assets/unitree/`: Unitree G1 asset, env spec, actuator/robot constants.
- `scripts/train.py`, `scripts/play.py`, `scripts/play_keyboard.py`: 학습과 재생 진입점.
- `NOTES.md`: 코드만으로 드러나지 않는 센서/동역학 함정과 디버깅 기록.

## 가져올 패턴

- eICP task는 reduced-order footstep planner와 rsl_rl policy를 묶는 현재 구현 기준이다.
- graph_centroidal은 Body Transformer/physical graph policy 실험의 landing zone으로 둔다.
- `assets/graph/builder.py`는 DL_GNN_Transformer의 notebook sketch를 실제 task graph로 연결할 때 기준 파일이다.
- CasADi-on-GPU kernel은 centroidal quantity를 vectorized env에서 계산하려는 방향성을 보여준다.

## 주의점

- `graph_centroidal`은 미완으로 표시되어 있으므로 성능 판단 source로 쓰지 않는다.
- whole-body CoM velocity는 pelvis velocity가 아니라 `subtree_linvel` sensor를 통해 확인해야 한다.
- CasADi kernel은 full 29-DOF G1 기준이고, mjlab RL model은 waist를 삭제한 26-DOF 경로가 있어 DOF mapping을 조심해야 한다.
- 실행은 repo script의 train/play 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: 017c485efe6024cb26825084e422cc778b4b5920
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
