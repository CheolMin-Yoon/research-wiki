---
tags: [tier/upper]
type: idea
date: 2026-07-18
status: active
source: AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md
---

# 아이디어: Kinematic Dependence-Graph Credit (mimic IL per-joint advantage)

## Thesis

"Explicit Credit Assignment through Local Rewards and Dependence Graphs"(arXiv 2601.21523, EPyMARL 기반)의 **graph-masked GAE**를 mimic IL 라인(`graph_mimic_29d`)에 가져오되, 원 논문이 reverse-model MI로 **학습**하는 dependence graph를 **kinematic reachability(계산된 oracle)**로 대체한다. mimic reward는 per-joint/per-body tracking으로 자연스럽게 local 분해되므로, 이 방법의 강한 전제(`common_reward=False`, agent별 local reward 필수)를 공짜로 충족한다 — centroidal 축(global reward 하나)에는 이 계열이 못 들어오고 [[AI-Sessions/wiki/research/idea-gpae-centroidal-advantage|GPAE counterfactual 축]]이 배정된 것과 대칭.

## 원 논문 메커니즘 (코드 직접 확인 2026-07-18)

- **graph-masked GAE**(`compute_adv_gae_graph_naive`): agent $i$의 advantage = "$i$가 (전이적으로) 영향을 준 agent들의 local reward TD-delta"만 합산. `reach` = 시간축 graph 곱(0..1 클램프)으로 도달성 추적, $(\gamma\lambda)^{t-t_0}$ 감쇠로 누적. 즉 "내가 영향을 준 보상만 내 credit"의 명시적 라우팅.
- **graph 추론**: reverse world model — $(s^i, s^{i\prime}, s^j)$에서 $a^j$ 예측, conditional/marginal entropy 비율 < 0.9(하드코딩)이면 edge. oracle graph / Erdős–Rényi random graph 옵션도 지원.
- 스택: PyTorch/EPyMARL, **discrete action 전제**(categorical `gather`), 벤치마크는 LBF/SMAClite/MPE.

## 이 아이디어의 치환: graph를 학습하지 않고 계산한다

- kinematic chain에서 "누가 누구에게 영향을 주나"는 **정확히 알려져 있다** — parent joint의 행동은 모든 descendant body의 tracking에 영향을 주고, 그 구조가 kinematic tree(이미 보유한 morphology graph)다. oracle graph 자리에 kinematic reachability를 꽂으면 MI 추론이 통째로 불필요해진다.
- mj_rl의 `body_name` 계약(joint node↔link anchor 매핑)이 "per-body tracking reward를 어느 joint에 귀속시키나"의 배관을 이미 절반 제공한다.
- graph가 **static**이므로 reach를 사전 계산할 수 있다(원 논문의 per-timestep `bmm`보다 저렴).
- 29 DoF에서 graph가 29×29라 방법이 실제로 유의미해지는 규모다 — 2-actor(upper/lower) 수준의 2×2는 무의미.

## 기대 효과

- **anchor(pelvis) tracking 약세 공격**: graph mimic interim 비교에서 anchor tracking이 MLP 대비 약했다([[AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic|graph mimic 실험 정본]]). 지금은 pelvis tracking reward가 전체에 희석되는데, kinematic reach로 라우팅하면 다리 joint들에 명시적으로 credit이 간다 — shortcut edge 실험(계획 4번)과 같은 문제의식의 advantage-side 대안/보완.
- **시간축 영향 전파**: graph 곱 + $(\gamma\lambda)$ 감쇠는 지연 영향(지금 hip 행동 → 나중 발 접촉)을 표현하는 장치 — CMM credit의 순간성(순간 momentum 기여만 잡음)을 보완할 참조 메커니즘.

## 통합 포지셔닝: "influence는 학습 말고 계산"

| 접근 | influence 출처 | reward 요구 |
|---|---|---|
| GPAE (AAMAS 2026) | counterfactual critic이 **근사** | team reward 하나 |
| dependence-graph (arXiv 2601.21523) | reverse-model MI로 **학습** | per-agent local reward |
| **이 연구** | **물리로 계산** — centroidal엔 CMM, kinematic tracking엔 kinematic reachability | 각 축의 자연 구조 사용 |

[[AI-Sessions/wiki/research/idea-physical-feature-graph|physical feature graph]]의 "관계 정답지로서의 CMM" 논리를 credit-assignment 축에서 반복 — centroidal(CMM)과 mimic(kinematics) 두 도메인에서 같은 novelty 주장을 반복 검증하는 구조.

## 구현 주의

- 이식 대상은 `compute_adv_gae_graph_naive` 한 함수(~60줄 pure torch). EPyMARL learner는 discrete action 전제라 버린다.
- local reward 분해 시 global 항(생존, action smoothness 등)과 **이중 계상 금지** — potential-based shaping 원칙([[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|credit note]]와 동일)을 유지.
- per-body tracking 항의 귀속 = kinematic ancestors(reach). waist 같은 공유 조상이 양쪽 limb reward를 받는 것은 중복이 아니라 실제 영향의 반영.

## 피해야 할 주장

- MI reverse-model 추론까지 이식해야 한다 → 아니다, graph는 kinematics로 계산한다.
- 2-actor(upper/lower) 수준에서 의미 있다 → 아니다, per-joint(29D) 세분화에서만 유의미.
- kinematic reach가 모든 영향을 담는다 → 아니다, dynamics 경유 영향(momentum 전달)은 못 담는다 — 그것은 centroidal 축(CMM)의 몫이고, 두 축이 상보적인 이유다.
- 원 논문 코드를 그대로 쓴다 → 아니다, discrete-action EPyMARL이라 advantage 함수만 이식한다.

## Links

- 상위 아이디어: [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]] (advantage-level credit 원칙 공유)
- 자매 아이디어(centroidal 축): [[AI-Sessions/wiki/research/idea-gpae-centroidal-advantage|idea-gpae-centroidal-advantage]]
- 관련 category: [[rl-algorithms-frameworks]] · [[graph-transformer-rl]] · [[novelty]]
- 실험 정본: [[AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic|2026-07-11-g1-29d-graph-mimic]] (anchor 약세, shortcut edge 계획 4번)
- 구현 정본: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] (`body_name` joint↔link 계약)
- 근거 논문(ingested 2026-07-18): 2026-le-dependence-graph-credit (arXiv:2601.21523, Le & Ta) — 이론 상세(meeting-time gradient, sample complexity 보간, **Lemma 4.6 근사 graph bias bound = kinematic oracle의 라이선스**)는 paper note를 본다.
