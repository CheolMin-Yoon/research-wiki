---
tags: [tier/low]
type: paper
date: 2026-07-08
status: active
source: AI-Sessions/raw/papers/2026-miao-gt-td3.pdf
---

# GT-TD3: Kinematics-Aware Graph-Transformer for High-DOF Manipulator Trajectory Tracking (2026)

- 저자: Hanwen Miao, Haoran Hou, Zhaopeng Zhu, Zheng Chao, Rui Zhang (China University of Petroleum, Beijing)
- venue: Machines 2026, 14(5), 397 (MDPI, 2026-04-05 published), DOI 10.3390/machines14040397
- source: AI-Sessions/raw/papers/2026-miao-gt-td3.pdf (원본 파일명 machines-14-00397-v2.pdf)

## Abstract (한국어)

7-DoF redundant manipulator의 궤적 추종을 위해 TD3의 **actor만** GNN+Transformer 하이브리드로 교체한 GT-TD3를 제안한다. raw 상태를 joint-level node로 재구성하고, GCN(gated message passing)으로 인접 관절의 local coupling을 뽑은 뒤, kinematic-aware attention bias를 넣은 Transformer로 장거리 관절 의존성을 모델링하고, gated fusion으로 local/global feature를 융합해 joint velocity command를 낸다. PyBullet KUKA iiwa 14 point-to-point tracking에서 MLP/pure GNN/pure Transformer baseline 대비 수렴 속도·성공률·RMSE·경로 품질·외란 안정성 모두 우위.

## 핵심 내용

### Actor 파이프라인 (4단계)

1. **Joint-wise state encoding**: 20-D 상태($q,\dot q,p_{ee},g$) → 7개 joint node. node feature 7-D = $[q_i, \dot q_i/1.5, q^{cum}_i, \rho_t/1.2, \hat g_x, \hat g_y, e_i]$ — 누적 관절각 $q^{cum}$(base→i 자세 요약), goal 거리/방향은 **모든 node에 broadcast**, $e_i$는 1-D learnable joint ID.
2. **Gated GCN 2층** ($d_g$=64): chain adjacency(+self-loop, row-normalize), gate $z_i=\sigma(W_z[h_i \| m_i])$로 자기 상태 vs 이웃 메시지를 element-wise 혼합 + LayerNorm.
3. **Kinematic-aware Transformer 2층/4-head** ($d$=128, sinusoidal PE): attention bias $B_h=\alpha_h P + \tanh(\Delta_h)$, $P = C - D + S$ —
   - $D$: link 길이 기반 정규화 **path distance** (index 거리가 아니라 실제 kinematic chain 거리),
   - $C$: motion-range coupling $r_ir_j/\max(r_ur_v)$ (가동범위 큰 관절쌍 강조),
   - $S$: 같은 kinematic category 관절쌍 +0.1 (iiwa의 대칭 교대 패턴),
   - $\Delta_h$: learnable residual bias (고정 prior에만 의존하지 않게).
   - node-level output reweight $w_i \in [0.6, 1.2]$ (joint range 비례, softmax 이후 feature rescale).
4. **Gated cross-scale fusion + readout**: GNN local $g_i$ vs Transformer global $t_i$를 gate $\beta_i$로 융합, mean+max pooling concat → MLP → $a_{max}\tanh(\cdot)$ 7-D joint velocity.

### 학습 구조

- **critic은 무수정 twin MLP** (asymmetric actor-critic): 구조 prior를 actor에만 넣어 Q 추정 안정성 유지가 명시적 설계 결정. SmoothL1 critic loss, action-magnitude regularizer $\lambda=0.001$ (tanh 포화 시 weak-gradient 완화), grad clip 1.0.
- off-policy TD3 학습 규칙 자체는 표준 그대로 — novelty는 actor 표현에만.

### 실험 (PyBullet KUKA iiwa 14, 5 seeds, 500k steps)

- 4-way: MLP / pure GNN / pure Transformer / GT-TD3 (전부 TD3, 동일 hyperparameter).
- GT-TD3가 수렴 속도·최종 reward·성공률(350k 이후 지배적)·RMSE·max deviation·path length에서 우위. 외란 안정성 분석(negative dV ratio, Lyapunov식)에서도 전 외란 스펙트럼에서 최상.
- 실패 양상 해석: MLP=jitter/진동 발산, pure GNN=장거리 정보 부족으로 S자 우회(over-smoothing/receptive field 한계, Alon & Yahav 인용), pure Transformer=구조 prior 부재로 control lag·종단 진동.
- 비용: 학습 1.98 h vs MLP 1.25 h.

### 한계 (논문 명시)

- point-to-point 직선 추종만, velocity command 수준 kinematic 제어(torque/contact 없음), sim-to-real 미검증, reward 경험적. **kinematic-aware이지 dynamic-aware가 아님**(dynamics/Jacobian/관성 미모델링)을 스스로 명시.

## 내 연구 연결

- GCNT(2025-luo-gcnt)와 같은 축의 독립 재확인: **GCN(local) + biased-attention Transformer(global)** 조합이 MLP/단독 아키텍처보다 관절 제어에서 낫다. 결합 방식은 GCNT(q/k 주입)와 달리 직렬 연결 + gated cross-scale fusion.
- attention bias $P=C-D+S$는 Graphormer(2021-ying-graphormer)의 SPD/degree bias의 **kinematic 실측치 버전**(link 길이 path distance + joint range coupling). idea-physical-feature-graph의 "score가 열린 attention에 물리 prior 주입" 방향의 또 다른 사례이나, 정적 kinematic prior에 머문다 — configuration-dependent dynamics(CMM $A_G(q)$) 주입은 이 축에서 한 단계 더 나간 것이라는 novelty 위치 확인에 유용.
- **asymmetric 설계 근거**: 구조 prior를 actor에만 넣고 critic은 단순 MLP로 유지해 Q 추정 안정성을 지킨다는 논리는, 우리 limb-MARL 설계(GCN actor + Transformer token-group critic)와 **정반대 분배**다. GT-TD3는 "graph/attention 모듈이 Q 추정에 불안정성을 넣을 수 있다"고 주장하므로, token-group critic 실험에서 critic 학습 안정성(value loss 발산 여부)을 모니터링할 반대 근거로 삼는다.
- goal 정보를 모든 joint node에 broadcast하는 encoding은 mj_rl Tokenizer의 `broadcast_global_to_joints`와 동일 패턴 — feature-level virtual hub의 단일팔 사례.
- 도메인 차이 유의: 단일 팔 tracking, single-agent TD3, floating base 없음 — humanoid locomotion으로의 전이 주장에는 직접 근거가 못 된다.

## Links

- category: [[AI-Sessions/wiki/research/categories/graph-transformer-rl|graph-transformer-rl]]
