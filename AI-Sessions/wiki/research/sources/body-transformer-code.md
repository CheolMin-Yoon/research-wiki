---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
---

# 구현 분석: BodyTransformer

## Summary

2024 Body Transformer 논문의 공식 구현이다. raw repo stub의 pinned commit `008d8cd514322252b53f4d5e3dd5c2fc47c7b9cd`를 checkout해 확인했으며, robot body graph를 attention mask로 넣는 imitation learning 및 RL 코드가 핵심이다. mj_rl graph policy에는 network pattern만 참고하고, 환경별 mapping과 A1 sim-to-real 코드는 그대로 이식하지 않는다.

## 핵심 파일

- `imitation_learning/models/networks.py`: `Tokenizer`, `Detokenizer`, `Transformer`, `SoftBiasTransformer`, `BodyTransformer` class가 들어 있는 핵심 구현.
- `imitation_learning/models/masked_transformer_encoder.py`: attention mask를 받는 Transformer encoder wrapper.
- `imitation_learning/models/mappings.py`: env별 observation/action을 body token으로 나누는 mapping.
- `imitation_learning/utils/build_mocapact_mask.py`, `imitation_learning/utils/adjacency_matrix_cmu_humanoid.py`: graph mask 생성과 humanoid adjacency 처리.
- `reinforcement_learning/`: IsaacGymEnvs/rl_games 기반 RL 쪽 통합 코드.
- `a1_walk/`: Unitree A1 sim-to-real 관련 코드와 onboard 실행 자료.

## 가져올 패턴

- observation을 body/node 단위 token으로 나누고, detokenizer에서 action dimension으로 다시 모으는 구조.
- kinematic adjacency 또는 shortest-path 정보를 attention mask로 주입하는 방식.
- vanilla Transformer, soft-bias Transformer, hard mask BodyTransformer를 분리해 비교하는 class 구조.
- graph policy를 만들 때 core network를 environment wrapper와 분리해야 한다는 점.

## 주의점

- repo의 핵심 네트워크는 참고 가치가 크지만, A1 locomotion과 MoCapAct/Adroit mapping은 mj_rl G1 task와 직접 호환되지 않는다.
- mask 의미가 `allowed attention`인지 `blocked attention`인지 PyTorch API와 local wrapper에서 반드시 재확인해야 한다.
- 실행은 imitation learning/RL README의 환경별 script 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
- raw paper: AI-Sessions/raw/papers/2024-sferrazza-body-transformer.pdf
- checked commit: 008d8cd514322252b53f4d5e3dd5c2fc47c7b9cd
