---
type: paper
date: 2026-07-09
status: active
topics:
  - morphology-aware-policy
  - graph-policy
source: PMLR v283 / arXiv:2412.01297
---

# MS-HGNN: Morphological-Symmetry-Equivariant HGNN

## Citation

Xie, Wei, Song, Yue, Gan. **Morphological-Symmetry-Equivariant Heterogeneous Graph Neural Network for Robotic Dynamics Learning**. L4DC / PMLR 283, 2025.

Primary sources: https://proceedings.mlr.press/v283/xie25a.html · https://arxiv.org/abs/2412.01297 · https://github.com/lunarlab-gatech/MorphSym-HGNN

## Core Idea

MS-HGNN extends MI-HGNN by combining two priors:

1. kinematic topology as a heterogeneous graph;
2. morphological symmetry as a group action over robot components and local coordinate frames.

The key move is to distinguish **physical morphological action** from **graph reindexing action**. Physical signals may require left/right permutation and sign changes, while graph tensors should transform as node permutation after an encoder. An encoder/decoder pair bridges these two spaces.

## Architecture Contract

- Node types follow MI-HGNN: base, joint, foot.
- Links in the kinematic tree become graph edges.
- Repeated branches define symmetry orbits.
- Missing base-node orbit elements can be replicated so the graph has a complete orbit under the symmetry group.
- A Cayley graph connects base nodes across symmetry elements.
- Node-specific encoders and decoders are added so morphological physical transformations become pure graph permutations in latent space.

Mathematically:

- graph backbone: equivariant to graph reindexing;
- encoder: maps physical transformed features into reindexed graph features;
- decoder: maps reindexed graph features back into physically transformed outputs.

This yields morphological-symmetry equivariance without requiring every GNN layer to be a specialized equivariant convolution.

## Empirical Lessons

- On contact classification, MS-HGNN-K4 beats MI-HGNN and non-graph baselines, showing morphology symmetry improves over topology-only MI-HGNN.
- On A1 GRF regression, MS-HGNN-C2 improves over MI-HGNN.
- On Solo centroidal momentum estimation, MS-HGNN significantly outperforms MLP, MLP-Aug, EMLP, and MI-HGNN; the paper notes MI-HGNN's broader S4-style geometric symmetry can misalign with the true morphological structure.

## Reading For mj_rl

MS-HGNN is not directly an RL implementation. The useful part is the **symmetry graph contract**:

- node orbits;
- group action on graph indices;
- physical sign/permutation action on raw features;
- encoder/decoder pair;
- graph construction that is topology-aware and symmetry-aware.

For G1 WBC momentum, this suggests:

- left/right C2 orbits should be explicit;
- torso and pelvis can be self-orbit core/context nodes;
- hip/knee/ankle and shoulder/elbow/wrist complex nodes are more symmetry-aligned than one node per scalar joint;
- CMM/CAM features need sign masks consistent with the chosen body/world frame.

## Relations

- source: [[AI-Sessions/wiki/research/sources/ms-hgnn-code|ms-hgnn-code]]
