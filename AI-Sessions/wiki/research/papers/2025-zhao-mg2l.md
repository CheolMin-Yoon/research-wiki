---
tags: [tier/low]
type: paper
date: 2026-07-17
status: active
source: "AI-Sessions/raw/papers/2025-zhao-mg2l.pdf"
---

# Meta Learning Task Representation in Multiagent RL: From Global Inference to Local Inference (2025)

- 저자: Zijie Zhao, Yuqian Fu, Jiajun Chai, Yuanheng Zhu, Dongbin Zhao (CASIA)
- venue/arXiv: IEEE Transactions on Neural Networks and Learning Systems, vol. 36, no. 8, pp. 14908–14920, Aug 2025 (DOI 10.1109/TNNLS.2025.3540758)
- source: "AI-Sessions/raw/papers/2025-zhao-mg2l.pdf", 코드: https://github.com/zhaozijie2022/mg2l

## Abstract (한국어)

Multiagent meta reinforcement learning(MAMRL)은 multiagent system(MAS)이 여러 task에 적응할 수 있게 한다. 그러나 partial observability는 agent의 제한된 local 경험으로부터의 효율적인 task inference를 방해하는 중대한 도전이 된다. 이를 해결하기 위해 우리는 mutual information optimization(MIO)에 기반한 global-to-local(G2L) 학습 scheme을 특징으로 하는 새로운 알고리즘 MG2L을 제안한다. 우리는 먼저 centralized training and decentralized execution(CTDE) framework를 MAMRL로 확장하고, global과 local task inference를 함께 수행하는 multilevel task encoder를 도입한다. 이 encoder 위에서 MG2L scheme은 맞춤형 loss 함수들로 task representation을 최적화한다. Global inference에서는 MAS가 representation과 task context 간의 MI를 최대화하여 centralized global representation을 학습한다. Local inference에서는 G2L gap을 정량화하는 conditional MI reduction을 정식화하고, agent들이 이 reduction을 최소화하여 local representation을 학습한다. MG2L scheme은 centralized training과 decentralized execution을 효과적으로 조화시켜 MAMRL 문제에 대한 범용적인 해법을 제공한다. 추가로 behavior policy 변동에 대한 민감도를 줄이기 위해 permutation-invariant attention(PIA) module을 task encoder에 통합한다. 비교 분석, ablation, meta-test 평가, 시각화를 포함한 광범위한 실험이 MG2L의 효과를 입증한다. 구현은 https://github.com/zhaozijie2022/mg2l 에 공개되어 있다.

## 핵심 내용

### 문제

context-based meta-RL(PEARL류: context c에서 task 표현 z를 추론해 policy를 조건화)을 MARL로 확장할 때 두 장애물이 있다. (1) 다른 agent들의 행동 때문에 개별 agent 관점의 환경이 nonstationary — 같은 $(o^i_t,a^i_t)$에도 $(o^i_{t+1},r_t)$가 달라져 successor-state 예측류 auxiliary loss가 무효화된다. (2) partial observability 때문에 개별 agent의 local 경험에는 task-specific feature의 일부만 담겨 local task inference가 비효율적이다.

### meta-CTDE + multilevel task encoder

- CTDE를 task inference까지 확장: 중앙 학습은 $Q(\boldsymbol o,\boldsymbol a,z),\ z\sim q(z|\boldsymbol c)$(global context), 분산 실행은 $\pi^i(a^i|o^i,z^i),\ z^i\sim q^i(z^i|c^i)$(local context)로 정식화(식 6).
- encoder는 3층: transition encoder $E_{tran}$(MLP, 전 agent·전 timestep 공유, transition tuple 단위) → aggregation encoder $E_{agg}$(timestep 집계 → agent별 $x^i$) → global inference $E_G(\{x^i\})=z$ / local inference $E^i_L(x^i)=z^i$. 궤적이 아니라 **decorrelated transition tuple**을 입력으로 써서 behavior policy의 영향을 줄인다.

### MIO 기반 G2L 학습

- **Global**: $I(z;M)$의 InfoNCE lower bound(Theorem 1, 다른 task의 context를 negative로)를 최대화 — $\mathcal L_G$ = CL loss + $\alpha D_{KL}(q(z|\boldsymbol c)\|\mathcal N(0,I))$(식 16). critic loss $\mathcal L_Q$(식 17)와 함께 encoder 전층으로 backprop.
- **Local**: G2L gap을 conditional MI reduction $I_r(z;z^i|c)=I(z;c)-I(z,z^i;c)$로 정의하고, Theorem 2의 상한 $I_{L1o}(z;c)-I_{NCE}(z,z^i;c)$(leave-one-out upper bound + InfoNCE)을 최소화 — $\mathcal L_L$(식 24)은 local inference 층에만 gradient를 준다(하위 층은 global loss로만 갱신해 더 global한 feature 유지).
- actor loss(MAPPO식 clipped surrogate + GAE, 식 25)는 알려진 bias/불안정성 때문에 encoder 갱신에서 제외.
- 제약: context 분포가 behavior policy에 의존하므로 수집 시 policy 고정 필요, policy와 encoder buffer를 동시 갱신. $I(z;c)\le I(z;M)$이라 context 수집 자체가 정보 손실 지점. 탐색 episode는 prior $z\sim\mathcal N(0,I)$로 rollout.

### PIA module + priority buffer

- $E_{agg}$/$E_G$를 multi-head attention 블록 N개 + **PI head**(position encoding 제거, 전 입력이 query 공유, 식 26)로 구성 — 입력 순열 불변성을 증명(Theorem 3). transition 단위 입력과 결합해 behavior policy 변동 민감도를 낮춘다.
- attention score $\omega^i_t$(식 32)를 transition priority로 사용 — meta-test 때 task 정보가 많은 transition을 우선 샘플링해 적응 가속.

### 실험

- 환경 6개: MA-HalfCheetah-Dir, MPE Spread-Target/Hunting-Target, Rware-Layout, MA-Hopper-Param(질량·관성·감쇠·마찰 파라미터가 task), MAgent-Gather(대규모). baseline: Mix-MATE, MA-PEARL, task-given(레이블 직접 제공하는 이상적 설정). 공정성 위해 전부 MAPPO로 통일, 5 seeds.
- MG2L이 거의 전 환경 최고. reward로 task가 정의되는 환경에선 후반에 task-given까지 추월(레이블보다 풍부한 feature 추출). meta-test 일반화도 가장 빠름(Hunting-Target에서 MA-PEARL/Mix-MATE는 100 step 탐색에도 거의 무반응). t-SNE에서 task cluster 분리가 가장 뚜렷.
- Hopper-Param context-mismatch 분석(식 33): source→target task 전이 성능은 파라미터 공간 거리와 대체로 일치하나 비선형 — 질량·감쇠·마찰이 관성보다 meta-learning에 민감.
- Ablation: (global loss) CL > Q-only > +dynamics prediction(task-redundant feature 때문에 오히려 해로움) > +task label prediction(one-hot에 semantics 없음). (local loss) MG2L ≈ Global-Only(CTCE 이상치) ≫ Local-Only(MI loss 수렴 실패 — local context만으론 충분히 구별되는 표현 불가), KL consistency loss 대체(CSTL)도 후반 수렴 실패 → MI가 distillation 매개로 적절하다는 근거. (aggregator) PIA > Transformer(학습속도 비슷하나 PI 없어 불안정) > Gaussian Product(균등 가중이라 task-redundant 필터링 불가) > RNN.

## 내 연구 연결

- **CTDE의 global↔local 정보 비대칭을 표현 수준에서 다루는 일반 레시피**: global(critic 쪽) 표현을 MI로 학습하고 conditional MI reduction으로 local(actor 쪽) 표현에 증류한다. 우리 limb=agent MARL 라인(MASH식 4-limb 분해, isaac_rl SPOT_3C multi-critic MAPPO)에서 "global critic만 아는 전신 정보를 limb-local actor가 어떻게 활용하게 하나"와 같은 구조의 문제다 — 단, MG2L은 task-level 표현(z)이고 우리 중심 관심사는 state-level feature(CMM/centroidal) 주입이라 직접 적용은 아니고 학습 signal 설계의 참고 축 (추측 아님, 구조 대응은 명시적; 적용 가능성은 추측).
- **MA-Hopper-Param(task=질량/관성/마찰)** 설정은 dynamics-guided-rl 축(heavy limb/payload 적응)과 접점: payload·물성 변화를 online task inference로 다루는 경로의 근거가 될 수 있다. 관성이 질량·마찰보다 meta-learning에 덜 민감하다는 분석도 payload 실험 설계 시 참고(추측 포함).
- **PIA + transition-tuple 입력 + priority buffer**는 morphology 구조 없이 set 집계로 순열 불변성을 얻는 인코더 — BoT/GCNT류 topology-aware token 인코더와 대비되는 저구조 대안. token-group critic이나 context 인코더 설계 시 aggregation baseline으로 참고.
- actor loss를 encoder에서 배제하고 표현 학습을 auxiliary(대조) loss에 맡기는 설계, dynamics prediction loss가 MARL nonstationarity에서 해롭다는 ablation 결과는 우리 쪽 auxiliary loss 설계에 바로 쓸 수 있는 부정적 근거.

## Links

- category: [[AI-Sessions/wiki/research/categories/rl-algorithms-frameworks|rl-algorithms-frameworks]]
