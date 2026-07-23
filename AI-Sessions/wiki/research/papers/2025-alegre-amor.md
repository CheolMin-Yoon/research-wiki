---
type: paper
date: 2026-07-18
status: active
topics:
  - humanoid
  - loco-manipulation
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
source: "AI-Sessions/raw/papers/2025-alegre-amor.pdf"
---

# AMOR: Adaptive Character Control through Multi-Objective Reinforcement Learning (2025)

- 저자: Lucas N. Alegre, Agon Serifi, Ruben Grandia, David Müller, Espen Knoop, Moritz Bächer (Disney Research/UFRGS)
- venue/arXiv: SIGGRAPH 2025 계열(CCS: physical simulation), arXiv:2505.23708
- source: "AI-Sessions/raw/papers/2025-alegre-amor.pdf"

## Abstract (한국어)

물리 기반 캐릭터/로봇의 motion tracking RL은 보통 상충하는 reward들의 가중합에 의존해 광범위한 튜닝을 요구하며, 로봇에서는 sim-to-real까지 고려한 가중 선택이 필요하다. AMOR은 reward 가중 벡터에 조건화된 policy를 multi-objective RL(MORL)로 학습해 상충 trade-off의 Pareto front를 하나의 policy로 스팬한다. 가중을 학습 후에 선택·튜닝할 수 있어 반복 시간을 크게 줄이고, 동적 모션의 로봇 이전에 활용한다. 나아가 high-level policy(HLP)가 현재 task에 따라 가중을 동적으로 선택하는 계층 구성을 탐구하며, 이는 implicit reward의 해석 가능성도 부산물로 제공한다.

## 핵심 내용

### 7-objective 벡터 reward — 신체 그룹 × task 분해가 이미 내장

$\mathbf r = [r^{up}, r^{lo}, r^{feet}, r^{rbs}, r^{root}, r^{vel}, r^{smooth}]$ — **upper/lower/feet 신체 그룹별 tracking**과 root/속도/smoothness의 혼합. 스케일 prior를 항별로 부여(휴머노이드 캐릭터 vs 로봇에서 값이 다름 — 예: smoothness 스케일 로봇 $10^{-4}$급으로 상향).

### MOPPO: vector-valued critic + weight-conditioned policy

- **vector value function** $\mathbf V^\pi(s,c,\mathbf w)\in\mathbb R^m$ — objective별 성분을 갖는 사실상의 multi-critic(단일 헤드 벡터형). vector advantage $\mathbf A^\pi$를 $\mathbf A\cdot\mathbf w$로 스칼라화해 PPO clip 갱신.
- policy·critic 모두 $\mathbf w$에 조건화, 에피소드마다 $\mathbf w\sim$ Dirichlet(simplex) 샘플 → **단일 policy가 Pareto front 전체를 커버**. 학습 후 zero-shot으로 가중 변경 가능(재학습 없는 trade-off 튜닝, sim-to-real에서 smoothness 가중만 올려 이전).
- 수렴은 고정 가중 PPO보다 약간 느림(더 어려운 과제) — 평균 가중 기준 최종 보상은 비슷.

### HLP: 실행 중 가중의 동적 선택 + 해석 가능성

frozen AMOR 위에 high-level policy $\bar\pi(\mathbf w_t|s_t,c_t)$가 motion context에 따라 가중을 실시간 조정. HLP는 discriminator 기반 implicit reward(GAN식, reference vs simulated 전이 구분)로 학습 — **HLP가 고른 가중을 들여다보면 implicit reward가 무엇을 우선하는지 해석 가능**(원저 Fig.1: 시점별 objective 가중 막대).

### 관찰: objective 충돌의 실체

Pareto front 분석에서 smoothness↔lower tracking뿐 아니라 **"겉보기에 무관한 upper-body tracking과 lower-body tracking도 충돌"** — body 부위 간 coordination이 물리적으로 정확하지 않기 때문. 모션마다 Pareto front가 달라 고정 가중은 원리적으로 suboptimal.

## 내 연구 연결

- **단일 로봇 multi-critic의 가장 정돈된 기존 구현**: vector critic의 성분이 이미 신체 그룹(up/lo/feet)으로 나뉘어 있어 2A2C reward group의 MORL 정식화판이다 — 논증 1–2의 강한 근거. 단 **분해 자체는 여전히 손 설계**((a)-family)이고 가중만 적응한다: (d1) "QP task 구조가 분해를 준다"가 채울 자리가 그대로 비어 있다.
- **advantage mixing 문제의 기성 해답**: multi-critic에서 "critic별 advantage를 어떻게 섞나"를 — 가중을 고정 설계에서 **조건 입력**으로 바꾸고(simplex 샘플링) 실행 중 HLP로 선택 — 로 푼다. 우리의 "contact가 critic 분할을 재배선한다" 가설의 소프트 구현 경로: HLP 입력에 contact 상태를 넣으면 상태 의존 가중이 된다.
- **upper↔lower tracking 충돌 관찰 = hub 결합의 실증 흔적**: 그들은 충돌을 현상으로 보고하지만, 왜 무관해 보이는 두 그룹이 충돌하는지는 설명하지 않는다 — centroidal 결합(CMM)이 그 메커니즘이며, 우리의 매핑 사전 렌즈가 이 관찰에 설명을 제공한다.
- sim-to-real을 "가중 이동"으로 처리한 사례는 (d2) $V_{MPC}$ prior의 강도 조절(모델 신뢰도에 따른 가중)에도 참고.
- related work가 지목한 Xu et al. 2023(신체 그룹별 독립 value function, 고정 가중 MORL)은 body-group multi-critic의 추가 선례 — 미ingest backlog 후보.

## Relations
