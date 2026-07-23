---
type: paper
date: 2026-06-24
status: active
topics:
  - graph-policy
source: AI-Sessions/raw/papers/2017-vaswani-attention.pdf
---

# Attention Is All You Need (2017)

- 저자: Ashish Vaswani et al.
- venue/arXiv: NeurIPS 2017 / arXiv:1706.03762
- source: AI-Sessions/raw/papers/2017-vaswani-attention.pdf

## Abstract (한국어)

기존 sequence transduction model은 encoder와 decoder를 포함한 recurrent 또는 convolutional neural network에 기반했고, 성능 좋은 모델은 attention mechanism으로 encoder와 decoder를 연결했다. 이 논문은 recurrence와 convolution을 완전히 제거하고 attention mechanism만 사용하는 Transformer라는 단순한 architecture를 제안한다. 두 machine translation task에서 Transformer는 품질이 우수하면서 더 병렬화 가능하고 학습 시간이 훨씬 적었다. WMT 2014 English-to-German에서 28.4 BLEU, English-to-French에서 41.8 BLEU를 달성했고, English constituency parsing에도 적용해 일반화를 보였다.

## 핵심 내용

Transformer는 scaled dot-product attention, multi-head attention, position-wise feed-forward network, positional encoding, residual connection, layer normalization으로 구성된다. 핵심은 sequence position 사이의 전역 의존성을 recurrent step 없이 직접 계산한다는 점이다.

결론에서 논문은 Transformer가 recurrent/convolutional layer 기반 architecture보다 더 빠르게 학습될 수 있고, attention-based model을 text 외 modality와 local/restricted attention으로 확장할 수 있음을 제안한다.

## 메커니즘

핵심은 scaled dot-product attention으로, query·key·value를 받아

$$\text{Attention}(Q,K,V) = \text{softmax}\!\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

로 계산한다. $\sqrt{d_k}$ 스케일링은 $d_k$가 클 때 dot product가 커져 softmax gradient가 소실되는 것을 막는다. Multi-head attention은 query/key/value를 $h$개의 부분공간으로 선형사영해 병렬 attention을 수행하고 concat 후 다시 사영한다($h=8$, $d_k=d_v=d_{model}/h=64$, $d_{model}=512$). 각 layer는 multi-head self-attention + position-wise FFN의 두 sub-layer로 구성되고, residual connection과 layer normalization으로 감싼다. recurrence가 없으므로 sinusoidal positional encoding으로 위치 정보를 주입한다. decoder의 self-attention은 미래 위치를 $-\infty$ 마스킹해 auto-regressive 성질을 보존한다.

self-attention은 임의의 두 위치를 $O(1)$ path length로 연결해 long-range dependency 학습에 유리하고 병렬화가 쉽다.

### 구현 포인트

- mask는 softmax 입력에 $-\infty$를 더하는 방식이다. PyTorch attention mask에서 `True`가 **block**인지 allow인지 프레임워크별로 반드시 확인한다.
- 구조 주입(Body Transformer / Physical Feature Graph)은 attention mask = `I + A`(self-loop + adjacency) 형태로 표현한다.
- positional encoding과 node/type embedding을 더해 token을 만든다.

## 내 연구 연결

이 논문은 Transformer attention의 원전이다. Body Transformer와 Physical Feature Graph 아이디어는 이 attention 구조를 robot body graph 또는 physical feature graph의 masked relation으로 제한하는 방향이다.

## Relations

- related papers: [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]]
