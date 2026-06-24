---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
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

## 내 연구 연결

이 논문은 `transformer` concept의 원전이다. Body Transformer와 Physical Feature Graph 아이디어는 이 attention 구조를 robot body graph 또는 physical feature graph의 masked relation으로 제한하는 방향이다.

## Links

- concepts: transformer
- related papers: 2024-sferrazza-body-transformer

