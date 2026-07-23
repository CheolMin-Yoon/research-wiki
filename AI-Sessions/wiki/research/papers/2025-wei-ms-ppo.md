---
type: paper
date: 2026-07-09
status: active
topics:
  - reinforcement-learning
  - morphology-aware-policy
  - graph-policy
source: arXiv:2512.00727
---

# MS-PPO: Morphological-Symmetry-Equivariant Policy

## Citation

Wei, Chen, Xie, Katz, Gan, Gan. **MS-PPO: Morphological-Symmetry-Equivariant Policy for Legged Robot Locomotion** / **Beyond Topology: A Morphological Symmetry Graph Representation for Locomotion Policy Learning**. arXiv:2512.00727, 2025/2026.

Primary sources: https://arxiv.org/abs/2512.00727 · https://lunarlab-gatech.github.io/MS-PPO/

## Core Idea

MS-PPO ports the MS-HGNN symmetry graph contract into actor-critic RL. It argues that topology-only graph policies and flat symmetry-aware MLPs each miss part of the problem:

- topology alone says where information flows, but not how physical coordinates transform;
- flat symmetry alone imposes global coupling without respecting local kinematic structure.

The target identities are:

- actor equivariance: mirrored observations produce mirrored actions;
- critic invariance: mirrored observations have the same scalar value.

## Actor-Critic Contract

- The actor maps physical observations to graph features with a morphological-symmetry encoder, applies a graph network, then decodes back to physical action coordinates.
- The critic uses the same encoded graph representation but reads value through an invariant head.
- The invariant critic head can use orbit-wise permutation-invariant statistics such as symmetric sum pooling, absolute disparity, and squared disparity before an MLP.
- PPO is not the conceptual novelty; the representation is. The paper states the same function classes could be used with other actor-critic or policy-gradient objectives.

## Robot-to-Graph Lessons

- Graph nodes may be rigid-body components or grouped joints.
- Physical quantities attach to the node representing the body part or joint complex that generates them.
- Symmetry orbits and sign masks are embodiment-specific.
- For sagittal C2 reflection, node-wise sign masks absorb coordinate flips before message passing.

The G1 humanoid experiment is especially relevant:

- upper body and arms are fixed in their G1 task;
- lower-body nodes need not be one-to-one with actuated DoFs;
- each leg is grouped into hip, knee, ankle nodes;
- hip node contains hip roll/pitch/yaw features;
- knee node contains knee pitch;
- ankle node contains ankle pitch/yaw;
- waist-related observations are assigned to the base node;
- left/right lower-body nodes define C2 orbits.

## Results To Remember

- Go2: improved OOD symmetric command tracking, hardware symmetry generalization, and joint-failure tolerance.
- G1: MS-PPO is the best deployable method in the reported real-world velocity tracking comparison, while PPO and MI-PPO fail deployment.
- The G1 comparison is a warning for us: a graph backbone without the morphology-symmetry encoder/decoder can still fail on humanoid sim-to-real.

## Reading For mj_rl

MS-PPO is the closest reference for the intended WBC redesign:

- keep PPO/CTDE machinery mostly standard;
- put novelty in the graph representation;
- define C2 orbits/sign masks explicitly;
- use an equivariant actor and invariant critic rather than relying only on rsl_rl mirror augmentation.

For the current G1 WBC momentum idea, the most natural translation is:

- two actor units: `lower` and `upper`;
- lower graph: pelvis + left/right hip/knee/ankle;
- upper graph: torso + left/right shoulder/elbow/wrist;
- pelvis/torso are self-orbit context nodes;
- CMM/CAM contribution features are attached to semantic complex nodes, not necessarily scalar joint nodes;
- critic reads both upper and lower graphs through an invariant head.

This makes the research claim more specific than MS-PPO: morphology-symmetry graph policy plus centroidal/CMM-conditioned WBC momentum features.

## Relations
