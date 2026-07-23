---
type: source
date: 2026-07-09
status: active
topics:
  - morphology-aware-policy
  - graph-policy
source: AI-Sessions/raw/repos/mi-hgnn.md
checked_commit: 0e47175
---

# Source: MI-HGNN Code

## What Was Checked

Local temporary clone: `/tmp/Morphology-Informed-HGNN`, checked commit `0e47175`.

Important files:

- `src/mi_hgnn/graphParser.py`
- `src/mi_hgnn/lightning_py/hgnn.py`
- dataset builders under `src/mi_hgnn/datasets_py/`

## Graph Construction

`RobotGraph` parses a URDF and constructs the heterogeneous graph:

- links become edges;
- joints become nodes;
- node type is inferred by local connectivity:
  - no parent + children = `base`;
  - parent + children = `joint`;
  - parent + no children = `foot`.

This is the opposite of PhysGraph's manual MANO topology: MI-HGNN uses URDF-derived robot topology.

## Model Construction

`GRF_HGNN` uses PyTorch Geometric hetero modules:

- `HeteroDictLinear` encodes each node type;
- `HeteroConv` holds a `GraphConv` per edge type;
- aggregation is `sum`;
- decoder is applied only to `foot` nodes.

So the code is a compact example of morphology-informed typed message passing, not an actor-critic policy implementation.

## Relevance To mj_rl

Useful pieces:

- URDF/topology-to-heterogeneous-graph logic;
- node-type-specific feature encoders;
- foot/node-specific readout;
- clear distinction between node type and edge type.

Not enough for current WBC:

- no actor/critic;
- no PPO;
- no invariant value head;
- no morphology-sign encoder/decoder;
- no semantic upper/lower G1 node grouping.

## Relations

- paper: [[AI-Sessions/wiki/research/papers/2025-butterfield-mi-hgnn|2025-butterfield-mi-hgnn]]
