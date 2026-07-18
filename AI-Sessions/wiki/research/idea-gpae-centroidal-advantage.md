---
tags: [tier/upper]
type: idea
date: 2026-07-18
status: active
source: AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md
---

# 아이디어: GPAE Counterfactual Per-Joint Advantage (centroidal credit의 배관·대조군)

## Thesis

[[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|centroidal momentum allocation credit]]의 S2(per-joint advantage PPO)를 **GPAE**(Generalized Per-Agent Advantage Estimation, AAMAS 2026)로 뒷받침한다. 역할은 두 가지다: (1) per-agent advantage를 PPO surrogate에 흘리는 **배관의 구현 참조**, (2) exact CMM credit에 대한 **learned counterfactual 대조군**. 적합성 근거: centroidal reward(CAM damping/tracking)는 본질적으로 global 하나라서, per-agent local reward를 전제하는 dependence-graph 계열([[AI-Sessions/wiki/research/idea-kinematic-dependence-credit|kinematic dependence credit]]은 mimic IL 축에 배정)은 못 들어오고 counterfactual critic 계열이 정확히 이 설정을 위한 방법이다.

## GPAE 메커니즘 (코드 직접 확인 2026-07-18)

- **핵심 = COMA counterfactual baseline의 GAE(λ) 일반화**: centralized Q-critic 입력 (world_state, 전 agent action 연결)에서 agent $j$ 자리만 실제 action 대신 **자기 정책의 marginal**로 치환(`marginal_actions()`)해 per-agent counterfactual 가치를 얻는다. 코드상 `coma` 옵션은 1-step TD residual을 advantage로 쓰고, `gpae`는 같은 구조를 multi-step GAE로 확장한 것 — 이 확장이 논문의 기여.
- **CORRECTION 항(st/dt/it/true)**: PPO가 한 배치로 여러 epoch를 도는 동안 다른 agent 정책이 함께 바뀌는 multi-agent off-policy drift를 잡는 importance-sampling 보정(기본 `dt`, η=1.05 클립). per-joint advantage로 갈 때 똑같이 만나는 문제의 기성 해법.
- 스택: JAX/Flax/JaxMARL(PureJaxRL 기반), MaBrax continuous control 지원.
- **`humanoid_9|8` 벤치마크**: agent_0=abdomen+arms(9 actuator), agent_1=legs(8) — 2A2C(upper/lower) 분할과 사실상 동일한 설정의 외부 실험장.

## 역할 1: S2 배관 참조

S2가 요구하는 요소(per-joint GAE, diagonal Gaussian log-prob의 per-joint 분해, multi-epoch drift 보정)가 continuous control에서 동작하는 형태로 이미 있다. rsl_rl/mjlab(PyTorch) 쪽에는 **알고리즘 구조만 이식**한다 — JAX 코드 직접 재사용 아님.

## 역할 2: exact vs learned 대조 실험 축

기존 R0/R1/R2에 **R-GPAE(learned counterfactual per-joint advantage)** 축을 추가한다. 같은 per-joint advantage 구조에서 신호 출처만 exact CMM decomposition ↔ 학습된 counterfactual로 갈리므로, Mirage(Tucker 2018) 비판 — "per-component baseline의 이득은 종종 분산-감소 아티팩트" — 에 대한 가장 강한 방어가 된다: 이득이 구조가 아니라 **exact 신호에서 온다**는 것을 learned 대조군으로 입증.

## 한계 / 주의

- GPAE에는 CMM/물리 주입이 전혀 없다 — 순수 black-box counterfactual. representation 축([[AI-Sessions/wiki/research/idea-physical-feature-graph|physical feature graph]])과는 직교.
- credit 품질이 critic 학습 품질에 종속되고 검증 수단이 없다(그래서 대조군 가치).
- `marginal_actions()`가 critic 입력을 agent 수만큼 복제 — 2-agent는 싸지만 per-joint 26 agent로 세분화하면 비용이 커진다.

## 피해야 할 주장

- GPAE 코드를 통째로 이식한다 → 아니다, 알고리즘 구조만.
- counterfactual critic이 CMM credit을 대체할 수 있다 → 아니다, 대조군이다. GPAE 대비 우위가 exact 신호의 가치 증거.
- GPAE가 이미 per-agent credit을 풀었으니 novelty가 없다 → 아니다, GPAE는 신호를 *근사*하고 이 연구는 *계산*한다 — "관계 정답지로서의 CMM" 논리의 credit-축 반복.

## Links

- 상위 아이디어: [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]] (S2의 배관·대조군)
- 자매 아이디어(IL 축): [[AI-Sessions/wiki/research/idea-kinematic-dependence-credit|idea-kinematic-dependence-credit]]
- 관련 category: [[rl-algorithms-frameworks]] · [[centroidal-wbc]] · [[novelty]]
- 실험 계획: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]] (R-GPAE 축 추가 후보)
- 근거 논문(ingested 2026-07-18): 2026-kim-gpae (AAMAS 2026, arXiv:2603.02654) — 이론 상세(operator contraction, policy invariance, DT-ISR ablation)는 paper note를 본다.
