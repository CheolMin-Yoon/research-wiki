---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
---

# 구현 분석: BodyTransformer

## Summary

2024 Body Transformer 논문의 공식 구현이다. 공식 repo `https://github.com/carlosferrazza/BodyTransformer`를 `/home/frlab/BodyTransformer`에 clone했고, checked commit `008d8cd514322252b53f4d5e3dd5c2fc47c7b9cd`를 확인했다. robot body graph를 attention mask로 넣는 imitation learning 및 RL 코드가 핵심이다. mj_rl graph policy에는 network pattern만 참고하고, 환경별 mapping과 A1 sim-to-real 코드는 그대로 이식하지 않는다.

## 핵심 파일

- `imitation_learning/models/networks.py`: `Tokenizer`, `Detokenizer`, `Transformer`, `SoftBiasTransformer`, `BodyTransformer` class가 들어 있는 핵심 구현.
- `imitation_learning/models/masked_transformer_encoder.py`: attention mask를 받는 Transformer encoder wrapper.
- `imitation_learning/models/mappings.py`: env별 observation/action을 body token으로 나누는 mapping.
- `imitation_learning/utils/build_mocapact_mask.py`, `imitation_learning/utils/adjacency_matrix_cmu_humanoid.py`: graph mask 생성과 humanoid adjacency 처리.
- `reinforcement_learning/`: IsaacGymEnvs/rl_games 기반 RL 쪽 통합 코드.
- `a1_walk/`: Unitree A1 sim-to-real 관련 코드와 onboard 실행 자료.

## 구현 세부 (코드 검증, 2026-06-25)

### q / k / v 처리
q/k/v는 **커스터마이징 없음**. `nn.TransformerEncoderLayer` 내부 `nn.MultiheadAttention.in_proj_weight` (shape: 3\*d\_model × d\_model) 이 Q/K/V를 한 번에 사영한다. RL 학습 파라미터는 이 weight 행렬 전체다.

### Tokenizer — 왜 node별 별도 Linear인가
각 body node의 obs 차원이 다르기 때문 (`[q, dq]`=2, IMU=6, …). node별 `nn.Linear(obs_dim_i → embed_dim)`으로 모두 같은 embed\_dim 토큰으로 압축한 뒤 Transformer에 넣는다. Transformer 단계부터는 node 간 차이가 없다.

### is\_mixed 패턴
`MaskedTransformerEncoder.forward`에서 `is_mixed=True`이면 layer 인덱스 홀/짝으로 masked↔unmasked를 교대한다. hard mask만 쓰면 정보가 local에 갇히므로 global attention layer를 사이사이에 끼워 보완하는 방식.

### SoftBiasTransformer = Graphormer Spatial Encoding
SPD를 learnable scalar로 매핑(`nn.Embedding(max_spd+1, 1)`)해 attention logit에 additive bias로 더한다. Graphormer의 Spatial Encoding과 구조가 동일하며, hard mask보다 soft한 graph inductive bias를 제공한다.

### mask 부호 주의
PyTorch `src_mask`에서 `True`=**blocked**. 코드에서 `mask=~self.adjacency_matrix`로 invert하는 이유다.

## 가져올 패턴

- observation을 body/node 단위 token으로 나누고, detokenizer에서 action dimension으로 다시 모으는 구조.
- kinematic adjacency 또는 shortest-path 정보를 attention mask로 주입하는 방식.
- vanilla Transformer, soft-bias Transformer, hard mask BodyTransformer를 분리해 비교하는 class 구조.
- graph policy를 만들 때 core network를 environment wrapper와 분리해야 한다는 점.
- is\_mixed: hard mask만 쓰면 정보가 local에 갇히는 문제를 masked/unmasked layer 교대로 완화.

## 주의점

- repo의 핵심 네트워크는 참고 가치가 크지만, A1 locomotion과 MoCapAct/Adroit mapping은 mj_rl G1 task와 직접 호환되지 않는다.
- mask 의미가 `allowed attention`인지 `blocked attention`인지 PyTorch API와 local wrapper에서 반드시 재확인해야 한다.
- 실행은 imitation learning/RL README의 환경별 script 흐름만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
- local clone: /home/frlab/BodyTransformer
- upstream URL: https://github.com/carlosferrazza/BodyTransformer
- raw paper: AI-Sessions/raw/papers/2024-sferrazza-body-transformer.pdf
- checked commit: 008d8cd514322252b53f4d5e3dd5c2fc47c7b9cd
