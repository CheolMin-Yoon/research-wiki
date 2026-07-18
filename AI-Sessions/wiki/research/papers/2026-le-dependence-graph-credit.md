---
tags: [tier/low]
type: paper
date: 2026-07-18
status: active
source: "AI-Sessions/raw/papers/2026-le-dependence-graph-credit.pdf"
---

# Explicit Credit Assignment through Local Rewards and Dependence Graphs (2026)

- 저자: Bang Giang Le, Viet Cuong Ta (VNU University of Engineering and Technology, Hanoi)
- venue/arXiv: arXiv:2601.21523 (preprint, 2026-01)
- source: "AI-Sessions/raw/papers/2026-le-dependence-graph-credit.pdf", 코드: https://github.com/giangbang/dependence-graph-epymarl (PyTorch/EPyMARL, 클론 분석 2026-07-18)

## Abstract (한국어)

협력 MARL에서 모든 agent의 reward를 합산한 global reward는 각 agent의 기여가 섞여 있어 노이즈가 크고 credit assignment 과정을 요구한다. 반면 local reward는 기여 분리 덕에 학습이 빠르지만 agent가 근시안적으로 자기 reward만 최적화해 전역 최적성을 해칠 수 있다. 본 연구는 agent 간 상호작용의 dependence graph를 사용해 두 접근의 장점을 결합한다 — global reward보다 세밀하게 개별 기여를 가르면서, local reward의 협력 문제를 완화한다. 그런 graph를 근사하는 실용적 방법도 제시한다. 알려진 dependence graph와 학습된 graph 모두로 fully cooperative 설정에서 검증하며, 전통적 local/global reward 설정 대비 개선을 보인다.

## 핵심 내용

### Reward dilemma (문제 정식화)

global reward는 협력을 보장하지만 credit assignment 분산이 agent 수에 따라 커지고(표준 PG sample complexity $N^2$ 스케일), local reward는 빠르지만 miscoordination으로 suboptimal 수렴 가능. 이 양극단 사이의 **매끄러운 전이(smooth transition)**를 만드는 것이 목표.

### Networked Multi-Agent MDP + state-dependent dependence graph

- 상태공간을 agent별 substate로 분해($\mathcal S = \mathcal S_1\times\cdots\times\mathcal S_N$)하고, agent $i$의 다음 상태는 parent 집합 $\mathrm{Pa}^i(s^i)$의 상태·행동에만 의존하도록 transition을 인수분해. 이 구조가 **(state-)dependence graph**를 정의한다 — **state마다 달라지는 dynamic graph**이며 static graph는 특수 사례.
- **first meeting time** $T_{ji}$: agent $j$의 영향이 graph 경로를 타고 agent $i$에 도달하는 최소 시간.

### Dependency-graph policy gradient (Prop. 4.1)와 sample complexity (Thm 4.2)

- cross-agent gradient 항 $\nabla_{\pi_j}J^i$에서 **$T_{ji}$ 이전의 reward를 절단**: $\nabla\log\pi_j \cdot \sum_{k\ge T_{ji}}\gamma^k r^i_k$. 도달하기 전의 남의 reward는 내 gradient에 못 들어온다.
- sample complexity가 $N^2$(표준 PG) 대신 $\Gamma=\sum_j\Gamma_j$($\Gamma^i_j=\sup\mathbb E[\gamma^{T_{ji}}]\le1$) 스케일 — **graph가 완전 분리면 N개 독립 단일 agent 문제, 완전 연결이면 global과 동일**로 매끄럽게 보간(Remark 4.4/4.5). reward dilemma의 이론적 해소.

### 근사 graph의 라이선스 (Lemma 4.6)와 MI 기반 graph 학습

- **Lemma 4.6**: 근사 graph $\mathcal G'$를 admit하는 transition kernel과 실제 dynamics의 total-variation 거리가 $\varepsilon$이면 gradient bias는 $O(B_j\,\gamma\varepsilon R_{max}/(1-\gamma)^2)$ — **heuristic/외부 지식 graph를 써도 모델 오차만큼만 편향**된다는 보증.
- 실용 근사: $I(S^{i\prime}; A^j\,|\,S^i,A^i)$를 reverse model 2개(action predictor + multi-agent reverse world model)의 entropy 차로 추정, $\hat H(A^j|s^j,s^i,s^{i\prime})/\hat H(A^j|s^j) < c$ (c=0.9)면 edge. **c=0이면 순수 local reward로 환원**(밀도 조절 노브).
- 구현은 graph 도달성(reach = 시간축 graph 곱)으로 마스킹한 GAE(`compute_adv_gae_graph_naive`).

### 실험

MPE star-spread(known graph, N=5→100): global reward는 N 증가에 급락, DG는 local의 속도와 global의 협력을 유지 — N=100에서 가장 큼. LBF/SMAClite(learned graph)에서 local/global baseline 대비 경쟁적·우세. random graph 밀도 p로도 local(p=0)↔global(p=1) 보간 확인.

## 내 연구 연결

- **kinematic oracle graph의 이론적 라이선스**: idea-kinematic-dependence-credit이 제안한 "MI 학습 대신 kinematic reachability를 oracle로"는 Lemma 4.6이 정확히 보증하는 사용법이다 — 단일 로봇의 kinematic tree는 transition 인수분해를 구조적으로 admit하므로(관절 행동→자손 body 상태) $\varepsilon$이 원리적으로 0에 가깝다. 학습 graph가 아니라 계산 graph를 쓸수록 이 bound가 좋아진다.
- **state-dependent graph 정식화가 contact 재배선을 담는다**: 접촉이 생기면 wrench 경로가 열려 로봇의 실제 dependence가 바뀐다 — 이 논문의 dynamic graph는 그것을 표현할 수 있는 프레임이고, credit note의 "critical-first(contact 전환 가중)" 아이디어와 접점.
- **단일 로봇에선 hub 때문에 완전 분리가 불가능**: floating base/centroidal 결합으로 모든 joint 쌍의 meeting time이 짧다(base 경유 ≤2) — 순수 local reward(per-limb 근시안)가 로봇에서 실패하는 이유의 이론적 표현. 결합 강도는 이진 edge가 아니라 CMM이 정량화하므로, **가중(weighted) dependence graph** 확장이 자연스러운 다음 질문.
- 벤치마크·구현은 discrete action(LBF/SMAClite) 전제 — 이식 대상은 advantage 함수 하나(idea-kinematic-dependence-credit 참조).

## Links

- category: [[AI-Sessions/wiki/research/categories/rl-algorithms-frameworks|rl-algorithms-frameworks]]
