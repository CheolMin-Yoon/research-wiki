---
tags: [tier/low]
type: paper
date: 2026-07-18
status: active
source: "AI-Sessions/raw/papers/2025-zhao-mla.pdf"
---

# Multi-level Advantage Credit Assignment for Cooperative Multi-Agent RL (2025)

- 저자: Xutong Zhao (Mila/Polytechnique Montréal), Yaqi Xie (CMU)
- venue/arXiv: AISTATS 2025 (PMLR 258), arXiv:2508.06836
- source: "AI-Sessions/raw/papers/2025-zhao-mla.pdf"

## Abstract (한국어)

협력 MARL의 핵심 난제인 credit assignment에서, reward는 다양하고 종종 겹치는 agent 부분집합에 귀속된다. 본 논문은 reward를 얻기 위해 협력하는 agent 수를 **credit assignment level**로 정식화하고, 여러 level이 공존하는 시나리오를 다룬다. 개별 행동, joint 행동, 강하게 상관된 agent 부분집합의 행동에 대해 각각 counterfactual 추론을 수행하는 multi-level advantage 정식화를 도입한다. MACA는 attention 기반 framework로 상관된 agent 관계를 식별하고 multi-level advantage를 구성해 policy 학습을 이끈다. StarCraft v1·v2 실험으로 복잡한 credit 시나리오에서의 우수성을 보인다.

## 핵심 내용

### Credit assignment level 정식화

global reward를 **겹침을 허용하는 agent 부분집합들의 합** $r(s,a)=\sum_{\mathcal G\subset\mathcal N} r_{\mathcal G}(s,a^t_{\mathcal G})$로 본다 — $r_{\mathcal G}$는 $|\mathcal G|=k$명이 협력해야 얻는 reward(level $k$). 한 agent가 같은 시점에 여러 level에 동시 참여 가능(냉장고 3인 운반 + 배낭 1인).

### k-level counterfactual baseline과 MACA advantage

- $b^{CF}_i(s,a)=\mathbb E_{a_{\mathcal G_i}}[Q(s,a)]$ — $i$를 포함한 $k$-부분집합 $\mathcal G_i$의 행동만 marginalize하고 나머지는 고정. **COMA(k=1, individual)와 MAPPO의 $V(s)$(k=n, joint)를 양 끝으로 포괄하는 일반형** (Table 1이 COMA/MAPPO/IPPO/PPO-Sum/PPO-Mix/HAPPO의 advantage를 한 표로 정리 — 인용 가치).
- **MACA baseline** $b^{MACA}_i=\psi^{JNT}b^{JNT}+\psi^{IND}b^{IND}+\psi^{COR}b^{COR}$: joint/individual/**CorrSet**(강상관 부분집합) 세 baseline의 **상태 의존 가중합**. $a_i$가 모두 marginalize되므로 unbiasedness 보존(Lemma A.1). 가중 $\psi$는 PG/TD로는 못 배우므로(기대값 무차별) CMA-ES로 성능 차를 직접 최적화.
- **CorrSet은 attention으로 추정**: transformer critic encoder의 attention rollout $\bar A_{i,j}\ge\sigma$인 agent들 — 상태마다 동적으로 바뀌는 상관 집합.
- SMAC v1·v2에서 SOTA 상회, ablation에서 세 level 모두 필수.

## 내 연구 연결

- **joint↔individual 사이의 "중간 계층"을 명시한 첫 정식화**: 우리의 joint→limb/role→전신 계층과 동형이다. 결정적 차이: MACA는 중간 집합(CorrSet)을 **attention으로 학습**하지만, 단일 로봇에서는 그 집합이 **알려져 있다** — kinematic subtree(limb), CMM/JSIM block, QP task의 관여 joint 집합. "computed vs learned" 치환의 multi-level 버전.
- **$r=\sum_{\mathcal G}r_{\mathcal G}$는 (d1)의 형식 언어**: QP task별 reward는 정확히 "관여 joint 부분집합 $\mathcal G$(겹침 허용 — waist는 여러 task에 참여)에 귀속되는 $r_{\mathcal G}$"다. idea-model-based-critic의 "QP task 구조가 분해를 준다"를 MACA의 level 정식화로 서술하면 이론 틀을 재사용할 수 있다.
- **상태 의존 level 가중 $\psi(s)$**: contact 전환 시 유효 협력 level이 바뀐다는 우리 가설(contact가 결합 재배선)의 기성 메커니즘 — AMOR의 weight conditioning과 함께 "critic/level 가중의 상태 의존화" 축을 이룬다.
- 가중을 PG가 못 배우는 이유(기대값 무차별)와 CMA-ES 우회는 우리가 advantage mixing 가중을 설계할 때 만날 동일 문제의 선례.

## Links

- category: [[AI-Sessions/wiki/research/categories/rl-algorithms-frameworks|rl-algorithms-frameworks]]
