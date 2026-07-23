---
type: source
date: 2026-07-09
status: active
topics:
  - morphology-aware-policy
  - graph-policy
source: AI-Sessions/raw/repos/ms-hgnn.md
checked_commit: 9fac4a1
---

# Source: MS-HGNN Code

## What Was Checked

Local temporary clone: `/tmp/MorphSym-HGNN`, checked commit `9fac4a1`.

Important areas:

- `src/ms_hgnn/lightning_py/hgnn.py`: MI-HGNN-style baseline HGNN.
- `src/ms_hgnn/lightning_py/hgnn_c2.py`, `hgnn_k4.py`, and `*_Morph.py`: symmetry variants.
- `src/ms_hgnn/datasets_py/*_Morph.py`: graph construction and feature placement for C2/K4 morphology modes.
- `cfg/*-c2.yaml`, `cfg/*-k4.yaml`: symmetry-operator configs.

## Code-Level Takeaways

The repo is not an RL policy codebase. It is supervised dynamics/contact/momentum learning. Still, it contains the concrete pieces needed to understand MS-style graph construction:

- node types are `base`, `joint`, `foot`;
- base nodes may be replicated to complete the symmetry orbit;
- C2/K4 variants split edge types beyond generic connectivity, e.g. front/back base-joint relations and base-base symmetry relations;
- data loaders place base acceleration/angular velocity, joint states/torques, and foot position/velocity into their corresponding node feature matrices;
- outputs are read from the relevant node type, e.g. foot for contact or base for centroidal momentum.

## Relevance To mj_rl

The useful transplant is the contract, not the code:

- define node orbits first;
- define physical sign masks separately from graph permutations;
- build encoders/decoders so latent graph features only need to permute under symmetry;
- use this contract before deciding whether the backbone is GCN, Graph Transformer, or another token mixer.

For G1 WBC momentum, the closest adaptation is C2:

- `pelvis` and `torso` are self-orbit context/core nodes;
- lower orbit pairs: left/right hip, knee, ankle;
- upper orbit pairs: left/right shoulder, elbow, wrist;
- CMM/CAM scalar or vector features must have sign rules consistent with body/world frame choices.

## Relations

- paper: [[AI-Sessions/wiki/research/papers/2025-xie-ms-hgnn|2025-xie-ms-hgnn]]
