---
tags: [tier/mid]
type: concept
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2017-vaswani-attention.pdf
---

# Transformer

## 정의

Transformer는 recurrence와 convolution 없이 attention만으로 sequence를 변환하는 architecture다. 핵심은 scaled dot-product attention으로, query·key·value를 받아

$$\text{Attention}(Q,K,V) = \text{softmax}\!\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

로 계산한다. $\sqrt{d_k}$ 스케일링은 $d_k$가 클 때 dot product가 커져 softmax gradient가 소실되는 것을 막는다. Multi-head attention은 query/key/value를 $h$개의 부분공간으로 선형사영해 병렬 attention을 수행하고 concat 후 다시 사영한다($h=8$, $d_k=d_v=d_{model}/h=64$, $d_{model}=512$). 각 layer는 multi-head self-attention + position-wise FFN의 두 sub-layer로 구성되고, residual connection과 layer normalization으로 감싼다. recurrence가 없으므로 sinusoidal positional encoding으로 위치 정보를 주입한다. decoder의 self-attention은 미래 위치를 $-\infty$ 마스킹해 auto-regressive 성질을 보존한다.

self-attention은 임의의 두 위치를 $O(1)$ path length로 연결해 long-range dependency 학습에 유리하고 병렬화가 쉽다.

## 사용 논문

- [[AI-Sessions/wiki/research/papers/2017-vaswani-attention|2017-vaswani-attention]] — 원전. scaled dot-product / multi-head attention 정의
- [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]] — attention에 robot embodiment graph mask를 씌워 구조를 주입
- [[AI-Sessions/wiki/research/papers/2021-ying-graphormer|2021-ying-graphormer]] — SPD·degree·edge를 attention bias로 주입해 GNN을 Graphormer special case로 포괄

## 연결 아이디어

- [[idea-physical-feature-graph]] — stability language(CoM·DCM·CAM)의 coupling을 attention graph로 표현
- [[idea-humanoid-arm-dual-role]] — 팔의 역할(stabilizer/wrench source)에 따라 context-conditioned attention mask로 확장 가능

## 구현 포인트

- mask는 softmax 입력에 $-\infty$를 더하는 방식이다. PyTorch attention mask에서 `True`가 **block**인지 allow인지 프레임워크별로 반드시 확인한다.
- 구조 주입(Body Transformer / Physical Feature Graph)은 attention mask = `I + A`(self-loop + adjacency) 형태로 표현한다.
- positional encoding과 node/type embedding을 더해 token을 만든다.

## Links

- raw: AI-Sessions/raw/papers/2017-vaswani-attention.pdf
