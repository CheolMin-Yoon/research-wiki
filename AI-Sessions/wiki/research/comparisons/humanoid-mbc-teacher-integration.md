---
type: comparison
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - centroidal-dynamics
  - model-predictive-control
  - multi-agent-rl
  - credit-assignment
---

# Humanoid MBC Teacher Integration

## Decision

외부 humanoid MPC task를 설치하거나 복사하지 않고, local robot model과 solver owner가 만든 biped centroidal plan을 training-time teacher로 연결한다. 첫 proof는 actor를 바꾸지 않고 plan reference를 critic과 reward에만 제공한다.

## Reusable Integration Contract

1. compiled robot model에서 CoM, linear/angular momentum과 contact geometry를 얻는다.
2. biped contact schedule과 friction/wrench bounds를 별도로 검증한다.
3. task-local command term이 낮은 cadence로 plan을 계산하고 value, age, validity를 보관한다.
4. actor에는 deployable observation만 유지한다.
5. critic에는 plan reference를 추가하고 reward는 lower/upper body에 해석 가능한 quantity로 나눈다.
6. baseline이 유효한 뒤 shared critic 또는 counterfactual advantage를 설계한다.

## Evidence Matrix

| Concern | External precedent | Local ownership rule |
|---|---|---|
| plan lifecycle | `mpc-rl` command/reference pattern | task-local command owns cadence and validity |
| solver | external batched MPC | repository-selected solver owns production path |
| reward | CoM/CLM/foot and CAM references | each physical policy role receives explicit terms |
| critic | privileged MPC trajectory | actor remains deployment-clean |
| MARL | limb actors/global critic precedents | independent PPO is not labeled MAPPO |

## Stop Conditions

- nominal biped plan이 contact/friction regression을 통과하지 못함
- solver invalid/stale rate가 reward signal로 쓰기 어려움
- single-policy reference baseline이 ordinary reward baseline을 넘지 못함
- critic-only information이 actor deployability를 침범함

## Relations

- baseline: [[AI-Sessions/wiki/research/papers/2026-li-mpc-guided-rl|2026-li-mpc-guided-rl]]
- implementation-reference: [[AI-Sessions/wiki/research/sources/mpc-rl-code|mpc-rl-code]]
- guides: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Sources

- `mj_rl/docs/research/2026-07-21-mpc-rl-g1-feasibility.md` at commit `f962dd1`
