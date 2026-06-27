---
tags: [tier/upper]
type: map
date: 2026-06-24
status: active
---

# Resources

## Graph

- [[AI-Sessions/wiki/maps/resources-frameworks|resources-frameworks]]
- [[AI-Sessions/wiki/maps/resources-dynamics-gpu|resources-dynamics-gpu]]
- [[AI-Sessions/wiki/maps/resources-policy-refs|resources-policy-refs]]

## Summary

code/repo/source 분석 노트를 묶는 graph 중심 노드다. raw repo stub은 연결하지 않고, source는 성격별 카테고리 sub-hub을 거쳐 연결한다(`resources → 카테고리 hub → source`). 카테고리:

- `resources-frameworks`: 시뮬/RL 프레임워크 + 프로젝트 레포 (mj-rl, mjlab-code, rsl-rl-code, mj-control-code)
- `resources-dynamics-gpu`: 동역학 이론 + GPU 배치 평가 (modern-robotics-code, casadi-on-gpu-code)
- `resources-policy-refs`: policy architecture + 재현 레퍼런스 (body-transformer-code, graph-transformer-code, 2024-lee-footstep-planning-rl-code, 2025-lee-humanoid-arm-cam-marl-code)
