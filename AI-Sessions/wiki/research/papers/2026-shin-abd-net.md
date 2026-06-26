---
tags: [tier/low]
type: paper
date: 2026-06-25
status: active
source: "AI-Sessions/raw/papers/Articulated-Body Dynamics Network:.pdf"
---

# Articulated-Body Dynamics Network: Dynamics-Grounded Prior for Robot Learning (2026)

- 저자: Sangwoo Shin, Kunzhao Ren, Xiaobin Xiong, Josiah P. Hanna
- venue/arXiv: arXiv:2603.19078 (Mar 2026)
- source: "AI-Sessions/raw/papers/Articulated-Body Dynamics Network:.pdf"

## Abstract (한국어)

기존 robot policy 구조는 link connectivity(인접행렬/attention mask)를 inductive bias로 쓰지만, dynamics(어떻게 힘과 운동이 body를 통해 전파되는지)는 활용하지 못한다. **ABD-NET**은 Articulated Body Algorithm(ABA) forward dynamics의 계산 구조를 GNN policy actor에 직접 임베드한다. exact physical quantity를 learnable parameter로 대체하면서 ABA의 child→parent bottom-up 전파 구조를 보존한다. humanoid·quadruped·hopper 실험에서 BoT, SWAT, GNN, MLP 대비 sample efficiency와 dynamics shift 일반화 모두 우수하며, Unitree G1/Go2 실물 sim-to-real을 달성했다.

## 핵심 내용

### 아키텍처 3-모듈

$$\pi_\theta = \Psi \circ \mathcal{M} \circ \Phi$$

1. **Observation Encoding (Φ)**: 각 link $i$에 독립적인 per-link projection $\phi_i$로 observation s를 link-wise embedding $z_i$로 변환.

2. **Dynamics-Informed Message Passing (M)**: ABA 구조를 학습 가능한 형태로 근사.
   - 각 link $i$에 learnable $\mathbf{B}_i \in \mathbb{R}^d$(rigid-body inertia 유사)와 $\mathbf{W}_i \in \mathbb{R}^{d \times d}$(motion subspace 유사) 부여.
   - **Bottom-up**: child → parent 방향으로만 message 전파(leaf부터 root까지).
     $$v_j^a = v_j - v_j \odot (\mathbf{W}_j \mathbf{W}_j^T v_j)$$
     $$v_i = \text{softplus}(z_i + \mathbf{B}_i) + \sum_{j \in \text{CH}(i)} v_j^a$$
   - **Orthogonality constraint**: $\mathcal{L}_{\text{orth}} = \frac{1}{K}\sum_i \|\mathbf{W}_i^T \text{diag}(v_i)\mathbf{W}_i - \mathbf{I}\|_F^2$ 를 PPO loss에 추가.

3. **Action Decoding (Ψ)**: 각 joint $j$에 대해 parent link representation $v_{\text{PA}(j)}$로부터 per-joint action head $\psi_j$로 action 계산.
   $$a_j = \psi_j(v_{\text{PA}(j)}) \in \mathbb{R}^{n_j}$$

### 기존 방법과 차이

| 방법 | inductive bias | 방향성 |
|---|---|---|
| GNN, BoT | adjacency/attention mask | 무방향(연결성) |
| SWAT | tree-traversal attention bias | 위상 순서 |
| **ABD-NET** | ABA forward dynamics 구조 | **child→parent 단방향** |

### 실험 결과

- Genesis (T1/G1/Go1/Go2) + SAPIEN (Humanoid/Hopper): ABD-NET IQM **0.85**(Genesis), **0.97**(SAPIEN). BoT 대비 +16/+31%p.
- Mass generalization retention: **91.1%**(Humanoid), **62.4%**(Hopper), **82.4%**(Go2), **81.1%**(T1). 평균 SWAT 대비 +23.9%p.
- Sim-to-real: Unitree G1(humanoid), Go2(quadruped) 실물 검증.

## 내 연구 연결

- **BoT와 비교**: BoT는 connectivity(kinematic adjacency)를 attention mask로 주입. ABD-NET은 forward dynamics 전파 방향을 GNN message passing에 내재화. 두 방법은 orthogonal한 inductive bias를 제공한다.
- **G1 구현**: MuJoCo XML에서 kinematic tree를 추출하는 `01_MuJoCo_XML_to_RobotGraph.ipynb` 흐름이 ABD-NET child→parent 관계 추출에도 직접 활용된다.
- **Physical Feature Graph 아이디어**: dynamics 전파 방향이 stability 정보(CoM·DCM·CAM) coupling의 방향성 힌트가 될 수 있다.

## Links

- concepts: [[centroidal]]
