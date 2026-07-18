---
tags: [tier/low]
type: paper
date: 2026-07-18
status: active
source: "AI-Sessions/raw/papers/2024-kapoor-prd-mappo.pdf"
---

# Assigning Credit with Partial Reward Decoupling in Multi-Agent PPO (2024)

- 저자: Aditya Kapoor, Benjamin Freed, Jeff Schneider, Howie Choset (TCS/CMU)
- venue/arXiv: RLC 2024, arXiv:2408.04295
- source: "AI-Sessions/raw/papers/2024-kapoor-prd-mappo.pdf"

## Abstract (한국어)

MAPPO는 강력하지만 개별 agent 행동에 credit을 귀속하는 문제가 팀 크기에 따라 악화된다. 본 논문은 partial reward decoupling(PRD)을 MAPPO에 결합한다. PRD는 학습된 attention 메커니즘으로 특정 agent의 학습 갱신에 어떤 팀원이 관련 있는지 추정하고, 이를 이용해 큰 팀을 더 작은 하위 그룹으로 동적으로 분해한다. PRD-MAPPO는 자기 기대 미래 보상에 영향을 주지 않는 팀원들로부터 agent를 분리해 credit assignment를 간소화하며, StarCraft II 등에서 MAPPO 및 SOTA 대비 높은 데이터 효율과 점근 성능을 보인다. 개별 reward 스트림 없이 shared reward만 있는 설정에 적용 가능한 버전도 제안한다.

## 핵심 내용

### credit 문제 = advantage 분산의 팀 크기 스케일링 (정량 정식화)

협력 설정에서 agent $i$의 gradient는 $\nabla\log\pi_i\sum_{j=1}^M \hat A_{ij}$ ($\hat A_{ij}$ = $i$의 행동이 $j$의 미래 보상에 준 영향). 분산 상계가 $\sum_j\mathrm{Var}(\hat A_{ij})$ + 쌍별 공분산으로 **팀 크기에 대략 선형으로 증가** — 같은 SNR을 위해 더 많은 데이터가 필요해진다. **무관한 advantage 항 제거가 곧 분산 감소 = 데이터 효율**이라는 메커니즘 규명.

### PRD: 학습된 attention으로 relevant set 추정

- **relevant set** $R_i(s_t)$: $i$의 행동이 기대 미래 보상에 영향을 주는 agent 집합. $i$의 학습 갱신에서 $R_i$ 밖 agent들의 advantage 항 제거 — bias 없이(평균적으로 기여 0) 분산만 줄인다.
- 추정: GNN Q-function $Q^\phi_i(s,a)$의 **attention weight $w_{ij}$** — $w_{ij}=0$이면 $j$의 action이 $Q_i$에 못 들어가므로 관련 없음. 실전은 $w_{ij}<\epsilon$ 임계.
- Freed 2022 원본 대비 개선 3: (1) PPO 통합, (2) **soft 변형** — hard threshold 대신 attention weight로 advantage 항을 연속 재가중, 이것이 hard보다 유의하게 좋음, (3) 이중 critic(관련집합용 Q + baseline용 V)으로 $M^2$→선형 계산.
- **shared-reward 버전**: 개별 reward 스트림 없이 팀 공동 reward만으로도 PRD 적용 가능하게 확장.
- SMAC 등에서 QMix/MAPPO/LICA/G2ANet/HAPPO/COMA 상회, MAPPO의 gradient 분산 스파이크 회피를 실측.

## 내 연구 연결

- **routing 계열의 세 번째 축**: local reward를 누구에게 흘릴지의 추정 방식이 — 2026-le-dependence-graph-credit(MI reverse model), PRD(critic attention), 우리(물리 매핑 계산) — 로 나란히 선다. 비교표(idea-kinematic-dependence-credit)의 (b) 칸을 채우는 MAPPO-native 구현.
- **soft > hard의 실증 = 가중 dependence graph 지지**: 이진 edge보다 연속 가중이 낫다는 결과는 "CMM column norm을 edge weight로 쓰는 weighted graph" 확장(2026-le note의 다음 질문)의 독립 증거. 학습된 $w_{ij}$의 자리에 계산된 $A_G[:,j]$/kinematic reach를 꽂는 것이 우리의 치환.
- **분산 스케일링 명제는 논증 3–4의 비용함수**: per-joint 26–29 agent로 세분화할수록 공유 advantage의 분산 비용이 선형 이상으로 커진다는 정량 근거 — 분해(라우팅·counterfactual·계산 credit)의 필요성을 팀 크기 함수로 서술할 수 있게 한다.
- shared-reward 버전은 global reward만 있는 centroidal 축에도 routing 계열을 적용할 수 있는 경로 — (b) 대조군 후보에 GPAE와 함께 추가.

## Links

- category: [[AI-Sessions/wiki/research/categories/rl-algorithms-frameworks|rl-algorithms-frameworks]]
