---
type: paper
date: 2026-06-30
status: active
topics:
  - morphology-aware-policy
  - graph-policy
source: AI-Sessions/raw/papers/2025-zhou-hyper-gcn.pdf
---

# Adaptive Hyper-Graph Convolution Network for Skeleton-based Human Action Recognition with Virtual Connections — Hyper-GCN (2025)

- 저자: Youwei Zhou, Tianyang Xu (corresponding), Cong Wu, Xiaojun Wu, Josef Kittler
- 소속: Jiangnan University (China) / University of Surrey (UK)
- venue/arXiv: arXiv:2411.14796v3 (2025-08-04)
- code: https://github.com/6UOOON9/Hyper-GCN
- source: AI-Sessions/raw/papers/2025-zhou-hyper-gcn.pdf

## Abstract (한국어)

skeleton 기반 action recognition에서 대부분의 GCN은 **bone(edge)으로 묶인 두 인접 joint의 binary 연결**에만 의존해 multi-vertex(다관절) 구조를 놓친다. hyper-graph를 쓴 선행연구도 있으나 **고정된 construction(human prior 기반)**이라 action마다 달라지는 잠재 관계를 담지 못한다. 이 논문은 학습 중 hyper-graph를 **적응적으로(adaptive) 최적화**하는 Hyper-GCN을 제안한다. 또한 **virtual connection(가상 hyper-joint)** 을 주입해 dependency의 spectrum을 넓히고 다양한 action category의 semantic clue를 부각한다. NTU-60, NTU-120, NW-UCLA에서 SOTA.

## 핵심 내용

### 동기 — binary edge의 한계
human action은 여러 joint가 함께 정의하는 **multi-joint synergy**다(예: "starting running" = 왼손 들기 + 오른발 내딛기). binary 연결(adjacency normal graph)로는 이 동시적 상호작용을 못 담는다. 그래서 hyper-edge가 **2개 초과 vertex**를 묶는 hyper-graph로 skeleton topology를 표현한다. normal graph conv는 2-layer 후 2개 vertex로만 정보가 퍼지지만, hyper-graph conv는 한 hyper-edge가 묶은 **모든 vertex로 한 번에** 퍼져 receptive field가 확장된다 (Fig 1b).

### A-NHG: Adaptive Non-uniform Hyper-graph 구성 (3.3)
- 각 joint를 center로 한 hyper-edge를 만들어 총 **N개 hyper-edge**(N=joint 수). incidence matrix $H\in\mathbb{R}^{N\times N}$로 표현.
- mapping function $\Phi\in\mathbb{R}^{C\times C_h}$로 feature를 subspace에 embed → $X_H\in\mathbb{R}^{N\times C_h}$. joint쌍 Euclidean distance로 distance matrix $M$, $m_{i,j}=\lVert v_i-v_j\rVert_2$.
- **non-uniform 핵심**: 각 joint가 속할 hyper-edge를 $K$-nearest로 제한(과도 연결 방지), softmax로 확률화:
  $$h_{i,j}=\begin{cases}\dfrac{\exp(-m_{i,j})}{\sum_{k\in set_i}\exp(-m_{i,k})}, & j\in set_i\\[4pt]0,& j\notin set_i\end{cases}$$
  → hyper-edge가 묶는 joint 수가 **가변**(uniform hyper-graph는 모든 hyper-edge가 동일 K개; non-uniform이 action별 다양한 조합을 더 잘 포착).
- $K$가 A-NHG의 hyper-parameter.

### M-HGC: Multi-head Hyper-graph Convolution (3.4)
- channel을 **8개 branch로 split**, 각 branch가 독립 hyper-graph(8 head) 구성 → 효율↑.
- hyper-graph 구성 **전에 temporal average-pooling**($\bar F_{in}\in\mathbb{R}^{C_{in}\times V}$)으로 spatio-temporal을 decouple.
- weight matrix $W$는 MLP(mapping $\Psi_1,\Psi_2$ + LeakyReLU/Tanh)로 hyper-edge별 weight를 $[-1,1]$로 산출.
- **physical topology와 융합**: 신체 물리 topology를 3 subset $S=\{s_{id},s_{cf},s_{cp}\}$(identity/centrifugal/centripetal)으로 나눠 병합. 학습 가중 $\alpha$로 적응 hyper-graph $\hat H$와 물리 adjacency $\hat A$를 결합:
  $$F_{out}=\biguplus_{k=1}^{8}(\hat A_k+\alpha\cdot\hat H_k)\,\bar F_{in}^k P_k$$
  ($\uplus$=channel concat, $P_k$=learnable transform). → 학습된 hyper-edge가 **고정 물리 골격 위에 더해지는** soft augmentation.

### Virtual Connections / hyper-joints (3.5)
- 학습 가능한 **hyper-joint $F_h$** 를 hyper-graph conv에 참여시킴. 물리 joint $F_p$와 같은 shape, **프레임 간 공유**, **layer별 독립**, **spatial conv에만** 참여(temporal 제외).
- marionette 비유: hyper-joint가 real joint를 "조종". Transformer의 **class token / Graphormer VNode와 동일 계열**(전 joint와 연결되는 global hub).
- **Divergence Loss $\mathcal{L}_h$**: hyper-joint들이 동질화(homogenization)되는 걸 막기 위해 cosine matrix $C=\frac{F_hF_h^T}{\lVert F_h\rVert^2}$ 기반으로 차이를 키움:
  $$\mathcal{L}_h(C)=\frac{\sum_{i}\sum_{j}\mathrm{ReLU}(c_{i,j})-V_h}{V_h(V_h-1)},\quad \mathcal{L}=\mathcal{L}_{CE}+\frac1L\sum_l \mathcal{L}_h(C_l)$$

### 전체 architecture (3.6)
embedding + PE → spatio-temporal layer 9개(각 layer = M-HGC + Multi-Scale TC), 3 stage, dense connection. Base channel 128/256/256, Large 128/256/512. 4-stream ensemble(J/B/JM/BM).

## 실험

- **데이터셋**: NTU-RGB+D 60(60 class), NTU-RGB+D 120(120 class; XSub/XView/XSub/XSet 4 benchmark), NW-UCLA. 단일 RTX 3090, SGD+Nesterov, label-smooth CE + Divergence Loss, 140 epoch.
- **SOTA 비교(Table 1)**: Base는 **1.1M params / 1.63 GFLOPs**로 모든 GCN·HGCN SOTA를 능가하고 NTU120에서 가장 가벼운 Transformer(SkateFormer)도 상회. Large(2.3M)는 4개 benchmark 1위, 1개 2위. Transformer 계열 대비 **압도적으로 lightweight**(예: DSTA-Net 16.18 GFLOPs vs Base 1.63).
- **Ablation K(Table 2, NTU120 XSub)**: Baseline 84.7 → uniform K=5가 86.5(+1.9), non-uniform **K=9가 86.7(+2.2)** 최고. K가 너무 작으면 복잡 조합 표현 곤란, 너무 크면 "extra" joint가 noise. non-uniform이 uniform보다 우세.
- **Ablation hyper-joints(Table 3)**: hyper-joint 수는 단조증가가 아님 — **3개**가 최적(많으면 redundant/ambiguous). Divergence Loss가 일관되게 도움.
- **시각화**: Fig 4 — 학습된 hyper-edge가 action에 가장 관련된 joint에 집중(예: "kicking" → 왼다리+오른손). Fig 5 — Divergence Loss 없으면 hyper-joint cosine matrix가 동질화. Fig 6 — 마지막 layer t-SNE에서 Hyper-GCN feature가 더 수렴(같은 semantic joint가 모임).

### Related work 프레이밍
GCN 계열(ST-GCN→CTR-GCN→HD-GCN→BlockGCN)은 binary edge에서 channel/topology refine. Transformer 계열(DSTA-Net, IIP-Transformer, SkateFormer)은 성능↑이나 GFLOPs/param 대폭↑. 기존 HGCN(Hyper-GNN, Selective-HCN, DST-HCN)은 **고정 hyper-graph**. 본 논문은 그 고정성을 adaptive non-uniform으로 깨고 virtual connection을 더함.

## 내 연구 연결

- **idea-physical-feature-graph 연결**: 이 논문의 핵심 두 메커니즘이 내 thesis와 직접 대응한다. ① **virtual hyper-joint = 전 joint와 연결되는 global hub token** → 내 CMM/centroidal hub token과 같은 역할(kinematic edge를 넘는 추가 노드). ② **adaptive hyper-edge = kinematic adjacency를 넘어서는 multi-joint 결합** → "physical-feature-graph"가 주장하는 "순수 운동학 인접만으로는 부족, 물리적 coupling을 그래프에 추가" 명제의 recognition-domain 실증.
- **multi-joint synergy ↔ centroidal momentum coupling**: hyper-edge가 한 동작에서 여러 joint를 함께 묶듯, $A_G$(CMM)의 한 행은 여러 joint $\dot q_j$를 하나의 centroidal momentum 성분으로 묶는다. "여러 joint가 하나의 물리량에 공동 기여" = hyper-edge view. → idea-centroidal-momentum-allocation-credit의 spatial credit 분해에 "hyper-edge"식 grouping 관점을 빌릴 수 있다.
- **vs [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|Body Transformer]] (고정 vs 적응 topology)**: BoT는 kinematic adjacency를 **hard mask로 고정**해 inductive bias를 강제한다. Hyper-GCN은 정반대로 "**고정 topology가 adaptivity를 제한**"한다며 학습된 adaptive hyper-graph를 쓴다(단 물리 adjacency $\hat A$는 $\alpha\hat H$로 더해져 base로 유지). → 단일 G1 control에서 "mask를 얼마나 고정 vs 학습 허용할지"의 직접적 반례/스펙트럼 제공. mj_rl의 `is_mixed`(hard/unmasked 교대)가 이 스펙트럼의 중간형.
- **vs [[AI-Sessions/wiki/research/papers/2021-ying-graphormer|Graphormer]]**: hyper-joint = Graphormer **VNode**(=BERT [CLS])의 hyper-graph 판. Graphormer는 SPD soft bias로 전 pair attention 유지, Hyper-GCN은 incidence matrix로 hyper-edge aggregation. 둘 다 "global hub token + 구조 주입" 패턴.
- **도메인 주의(상충 아님, 적용 차이)**: 이 논문은 **action recognition(지각)** 이고 RL control이 아니다. topology/virtual-node 메커니즘은 이식 가능하지만, hyper-graph 구성이 **temporal pooling 후 spatial-only**라는 점, multi-stream(J/B/JM/BM) ensemble 전제 등은 control policy로 그대로 옮기기 어렵다.

## Relations

- raw paper: AI-Sessions/raw/papers/2025-zhou-hyper-gcn.pdf
- related papers: [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]] · [[AI-Sessions/wiki/research/papers/2021-ying-graphormer|2021-ying-graphormer]] · [[AI-Sessions/wiki/research/papers/2025-luo-gcnt|2025-luo-gcnt]]
- hypothesis: [[AI-Sessions/wiki/research/ideas/idea-physical-feature-graph|idea-physical-feature-graph]]
- credit-hypothesis: [[AI-Sessions/wiki/research/ideas/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]]
