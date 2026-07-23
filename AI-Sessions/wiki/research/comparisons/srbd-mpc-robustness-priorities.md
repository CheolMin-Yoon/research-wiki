---
type: comparison
date: 2026-07-24
status: active
topics:
  - locomotion
  - model-predictive-control
---

# SRBD-MPC Robustness Priorities

## Decision

fixed-pattern SRBD QP를 유지하면서 uncertainty 가설만 분리할 수 있는 Chance-Constrained Convex MPC(CCMPC)를 첫 확장으로 선택한다. 큰 자세 변화에는 representation-free MPC, payload identification에는 indirect adaptive MPC를 후속 비교군으로 둔다.

## Evidence Matrix

| Priority | Method | Existing QP reuse | Main value | Main risk |
|---:|---|---:|---|---|
| 1 | CCMPC | high | covariance와 chance-constraint tightening | risk calibration |
| 2 | Representation-Free MPC | medium | RPY singularity 제거, agile motion | SO(3) regression scope |
| 3 | Indirect Adaptive MPC | medium | mass/inertia online identification | large regressor and WBC dependency |
| 4 | Adaptive-Force MPC | low | payload/soft-ground adaptation without learning | dual-loop complexity |
| 5 | Learned uncertainty-set RMPC | conceptual | RL-parameterized robustness | baseline과 learner 동시 변경 |

## Recommendation

- 독립 quadruped SRBD regression에서 nominal MPC와 CCMPC를 먼저 비교한다.
- uncertainty distribution, covariance propagation, bound tightening과 risk violation을 각각 검증한다.
- learned residual/uncertainty는 manual uncertainty baseline이 재현된 뒤 추가한다.
- humanoid 적용은 biped contact/model migration과 별도 milestone로 둔다.

## Relations

- preferred-evidence: [[AI-Sessions/wiki/research/papers/2025-trivedi-chance-constrained-mpc|2025-trivedi-chance-constrained-mpc]]
- extends: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Sources

- `mj_rl/docs/research/2026-07-21-srbd-mpc-quadruped-journal-survey.md`
- Trivedi et al. 2025 and cited primary papers
