---
tags: [tier/low]
type: paper
date: 2026-06-27
status: active
source: AI-Sessions/raw/papers/2025-luo-gcnt.pdf
---

# GCNT: Graph-Based Transformer Policies for Morphology-Agnostic Reinforcement Learning (2025)

- 저자: Yingbo Luo, Meibao Yao (corresponding), Xueming Xiao
- 소속: Jilin University / Changchun University of Science and Technology
- venue/arXiv: arXiv:2505.15211 (2025-05-21)
- source: AI-Sessions/raw/papers/2025-luo-gcnt.pdf

## Abstract (한국어)

서로 다른 morphology를 가진 로봇들을 하나의 universal controller로 학습하는 morphology-agnostic RL을 다룬다. morphology가 다르면 state/action space 차원이 달라 단일 policy network로 묶기 어렵다. 기존 방법은 robot configuration을 modularize하지만 **전체(global) morphological 정보를 충분히 추출·활용하지 못한다**는 한계가 있다. GCNT는 개선된 **GCN으로 local morphology를 추출**하고 **Transformer로 모든 node가 직접 통신**하게 해 그 정보를 완전히 활용한다. GCN·Transformer 모두 임의 개수 module을 다룰 수 있다는 점을 이용한다. 2개 표준 벤치마크 8개 task에서 SOTA, 미학습 morphology로의 zero-shot generalization까지 달성한다.

## 핵심 내용

### 문제 설정 (morphology-agnostic RL)
로봇을 K개 limb **module의 조합**으로 모델링한다. 모든 module은 같은 state/action 차원을 갖는다($dim(s^i)=dim(s^j)$, $dim(a^i)=dim(a^j)$). universal policy $\pi_\theta$는 각 module의 local obs를 받아 module별 local action을 내고, 이들이 모여 robot 전체 action이 된다. morphology는 무방향 그래프 $\mathcal{G}=\langle\mathcal{V},\mathcal{E}\rangle$(node=limb, edge=관절 연결)로 표현하며 adjacency $A\in\{0,1\}^{K\times K}$로 쓴다. N개 morphology에 대한 기대 return 합을 목적함수로 joint optimization한다.

### 아키텍처 5-module (Fig 2)
1. **Limb Observation Module**: 각 limb local state를 MLP로 같은 고차원 feature $z_0$로 사영.
2. **GCN Module (개선판)**: spectral GCN으로 이웃 정보를 aggregation해 **local morphology** 추출. 원본 GCN에 **linear layer 추가 + ResNet식 residual connection**을 넣어 depth 증가 시 gradient vanishing을 막음 — $H^{(l+1)}=\sigma(\tilde D^{-1/2}\tilde A\tilde D^{-1/2}H^{(l)}W_1^{(l)})W_2^{(l)}+H^{(l)}$. 초기 node attribute는 limb type의 one-hot.
3. **Weisfeiler-Lehman Module**: GCN을 **보완**해 **global(overall) morphology** 추출. limb type을 초기 color로 두고 고정 횟수 color refinement 후 각 color 등장 횟수 vector를 만들어 node별 GCN local feature와 concat. traversal(DFS) 기반 방법의 **indexing inconsistency**(같은 type limb가 robot마다 다른 index를 받는 문제)를 해소.
4. **Learnable Distance Embedding Module**: Floyd로 모든 node쌍 shortest path distance $D$ 계산 → learnable mapping $R^{i,j}=g_\phi(D^{i,j})$로 head별 bias 생성, attention score에 가산. → **Graphormer의 spatial encoding과 동일 계열**(soft bias).
5. **Transformer Module**: full multi-head attention으로 node 간 **직접 통신**(message-passing의 multi-hop 정보 손실 회피). distance bias $R^{i,j}$를 softmax 전 attention logit에 더함. 출력 → Linear → limb별 action.

### 데이터 흐름의 핵심 (설계 포인트)
Fig 2 기준, **limb observation $z_0$가 value(v)**, **GCN+WL의 morphological feature가 query/key(q,k)**로 들어간다. 즉 "누가 누구에게 attend하는가(attention 패턴)"는 morphology가 결정하고, "무엇을 전달하는가(value)"는 observation이 담당하도록 분리했다. distance embedding은 그 attention에 거리 기반 soft bias를 더한다.

### Optimization
actor-critic(actor·critic 동일 architecture), deterministic policy gradient 계열. **benchmark1(SMPENV)은 TD3, benchmark2(UNIMAL)는 PPO**로 선행연구와 공정 비교.

## 실험

- **SMPENV** (Huang 2020): Walker++/Cheetah++/Humanoid++/CWHH++. baseline = SMP(message passing)·AMORPHEUS(pure Transformer)·SWAT(structure-aware Transformer). GCNT가 sample efficiency·성능 모두 최고. SMP는 multi-hop 정보 손실로 최약, AMORPHEUS는 morphology 무시, SWAT의 traversal 기반 추출은 효과가 일관되지 않음(Walker++에선 pure Transformer보다도 못함).
- **UNIMAL** (Gupta 2021): FT/Incline/MT/Obstacles. baseline = MetaMorph·MetaMorph*·ModuMorph·SR-fair·SR-top. GCNT가 전 시나리오 선두. ModuMorph는 유사 성능이나 파라미터가 2–3배(limb별 hypernetwork)이고 zero-shot이 더 약함.
- **Zero-shot to unseen morphology** (Table 1): 7개 중 5개에서 최고. limb 수가 적은 단순 구성(walker_3, cheetah_3)에선 열세, **limb 많아질수록 우세**.
- **Zero-shot to kinematics/dynamics 변화**(400 robot): GCNT 최강.
- **Ablation** (Humanoid++): GCN/WL/distance embedding 각각 제거 시 모두 성능 하락, 그래도 pure Transformer(AMORPHEUS)보다는 우수.
- **t-SNE**(Fig 10): GCNT는 robot이 달라도 같은 기능 limb를 가깝게 매핑, SWAT는 흩어짐 → GCNT의 구조 추출이 더 효과적.

### Related work 3단계 프레이밍
message-passing(NerveNet, SMP/DGN) → pure Transformer(AMORPHEUS, "My body is a cage") → morphology를 Transformer에 주입(SWAT, MetaMorph, ModuMorph, Patel&Song 2024). GCNT는 3단계에 속하되 GCN+WL로 추출을 강화.

## 내 연구 연결

- **사용자 "GCN + Body Transformer" 질문의 실현형**: GCNT가 바로 GCN(local 추출) + Transformer(global 통신) 구조다. 단 목표가 **multi-morphology 범용 controller**라는 점이 다르다. 내 타깃은 단일 G1이라 범용성은 불필요하고, **GCN을 local inductive bias 블록으로 차용**하는 관점으로 빌려오면 된다.
- **vs [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|Body Transformer]]**: BoT는 adjacency **hard/mixed mask** + **node별 별도 Linear tokenizer**(→ 본질적으로 morphology-specific). GCNT는 **shared GCN+WL 추출** + **full attention** + **soft distance bias** → morphology-agnostic. 구조를 mask로 *제한*하는 BoT와, q/k로 *주입*하고 attention은 열어두는 GCNT의 대비가 핵심. GCN+hard-mask는 둘 다 local이라 중복 위험 — GCNT는 full attention을 써 그 중복을 피한다.
- **vs [[AI-Sessions/wiki/research/papers/2021-ying-graphormer|Graphormer]]**: distance embedding은 Graphormer spatial encoding(SPD→learnable bias)과 동일 계열. GCNT는 거기에 GCN local + WL global 추출을 더한 것.
- **idea-physical-feature-graph 연결**: GCN/WL이 morphology graph를 추출하듯, stability-language coupling graph도 같은 패턴(local 추출 + full attention + 거리 soft bias)으로 표현 가능. BoT 이식 후보 메커니즘: ① Q/K(morphology)·V(observation) 분리, ② residual GCN 블록, ③ distance soft-bias(Graphormer식).

## Links

- raw paper: AI-Sessions/raw/papers/2025-luo-gcnt.pdf
- category: graph-transformer-rl
- related papers: [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]] · [[AI-Sessions/wiki/research/papers/2021-ying-graphormer|2021-ying-graphormer]]
- ideas: idea-physical-feature-graph
