---
type: paper
date: 2026-07-09
status: active
topics:
  - morphology-aware-policy
  - graph-policy
source: arXiv:2409.11146v3
---

# MI-HGNN: Morphology-Informed Heterogeneous Graph Neural Network

## Citation

Butterfield, Garimella, Cheng, Gan. **MI-HGNN: Morphology-Informed Heterogeneous Graph Neural Network for Legged Robot Contact Perception**. arXiv:2409.11146v3, 2025.

Primary sources: https://arxiv.org/abs/2409.11146 · https://github.com/lunarlab-gatech/Morphology-Informed-HGNN

## Core Idea

MI-HGNN turns the robot kinematic structure into a heterogeneous graph for supervised contact perception. The graph uses node types `base`, `joint`, `foot`; links become typed edges. Sensor streams are attached to their corresponding node type, then fused by heterogeneous message passing, and predictions are read from foot nodes.

Important distinction for our work: MI-HGNN is **morphology-informed topology**, not a full morphological-symmetry policy. It shares weights across morphologically identical branches through type/edge-typed message passing, but it does not introduce the MS-HGNN/MS-PPO encoder-decoder that converts physical sign/permutation actions into graph reindexing.

## Architecture Contract

- Nodes: base body, actuated/revolute joints, and foot fixed joints.
- Edges: robot links, typed by connected node types such as base-joint, joint-joint, joint-foot.
- Node features:
  - base: IMU-like base acceleration and angular velocity history.
  - joint: joint position, velocity, and sometimes torque history.
  - foot: foot position/velocity history from forward kinematics.
- Encoder: node-type-specific heterogeneous encoder.
- Message passing: edge-type-specific aggregation over the kinematic graph.
- Decoder: foot-node decoder for contact state classification or GRF regression.

## Results To Remember

- Contact detection on Mini-Cheetah: graph formulation improves performance and model efficiency over CNN/CNN-Aug/ECNN baselines.
- GRF estimation on A1: MI-HGNN beats MLP and model-based floating-base dynamics baseline on unseen friction, speed, terrain, and combined OOD cases.
- The paper explicitly notes future work should integrate morphological symmetry more rigorously; MS-HGNN is that follow-up.

## Reading For mj_rl

MI-HGNN is useful as the **baseline grammar**:

- how to convert morphology into heterogeneous node/edge types;
- why sensor modalities should attach to local nodes instead of one flat vector;
- why message passing can encode kinematic causality with fewer parameters.

But it is insufficient for the current G1 WBC direction because it does not enforce:

- actor equivariance;
- critic invariance;
- node orbit/sign-mask contracts;
- upper/lower or left/right action transformation consistency.

For WBC momentum, MI-HGNN is the reference for topology-aware graph construction, while MS-HGNN/MS-PPO are the references for symmetry-aware policy structure.

## Relations

- source: [[AI-Sessions/wiki/research/sources/mi-hgnn-code|mi-hgnn-code]]
