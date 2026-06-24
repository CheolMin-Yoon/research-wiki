---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2024-sferrazza-body-transformer.pdf
---

# Body Transformer: Leveraging Robot Embodiment for Policy Learning (2024)

- 저자: Carmelo Sferrazza, Dun-Ming Huang, Fangchen Liu, Jongmin Lee, Pieter Abbeel
- venue/arXiv: CoRL 2024 / arXiv:2408.06316
- source: AI-Sessions/raw/papers/2024-sferrazza-body-transformer.pdf

## Abstract (한국어)

Transformer architecture는 NLP와 vision에서 사실상 표준이 되었고 robot learning에도 성공 사례가 있지만, vanilla transformer는 robot learning problem의 구조를 충분히 활용하지 못한다. 이 논문은 robot embodiment를 inductive bias로 사용하는 Body Transformer(BoT)를 제안한다. 로봇 body를 sensor와 actuator node의 graph로 표현하고, masked attention으로 정보를 pool한다. 결과 architecture는 imitation learning과 reinforcement learning policy에서 vanilla transformer와 MLP보다 task completion, scaling property, computational efficiency 측면에서 더 좋은 성능을 보인다.

## 핵심 내용

BoT는 robot body graph를 기반으로 observation을 node token으로 만들고, action도 node 단위로 detokenize한다. graph mask는 attention을 제한해 body-induced bias를 policy에 주입한다.

논문은 imitation learning과 RL 양쪽에서 BoT를 평가하고, custom masked attention이 sparse mask를 활용하면 sequence length가 커질수록 계산상 이점이 있음을 보인다. 결론에서는 temporal dimension으로 확장하는 것을 future work로 남긴다.

## 내 연구 연결

이 논문은 `transformer` concept의 robot policy 적용 근거다. Physical Feature Graph 아이디어는 BoT의 morphology graph 관점을 stability language graph로 확장하려는 방향으로 해석할 수 있다.

## Links

- raw repo: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
- source note: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]
- concepts: [[transformer]] · [[ppo]]
- ideas: [[idea-physical-feature-graph]]

