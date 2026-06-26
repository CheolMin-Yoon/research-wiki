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

### Policy 통합 방식 (§4–§5.2, 원문 검증 2026-06-25)

BoT는 알고리즘이 아니라 **policy network architecture**다. "BoT를 쓴다" = 같은 구조(Tokenizer→encoder→Detokenizer)에서 **encoder만 MLP/vanilla Transformer 대신 BoT로 교체**하고 나머지는 고정한다(§5: "only replace the BoT encoder ... to single out the effect of the encoder").

- **actor와 critic 둘 다 BoT로** 쓸 수 있다. detokenizer는 actor일 때 action을, **critic일 때 node별 value를 내고 body part 평균**해 scalar value를 만든다(§4 Detokenizer).
- **Tokenizer**: global 양은 root node, local 양은 해당 limb node에 배정. node마다 **별도** linear projection(multi-task GNN의 shared projection과 대비).
- **BoT-Hard**: 모든 layer에 $M=I_n+A$ mask. self+직접 이웃만 attend.
- **BoT-Mix**: masked layer와 unmasked layer를 교대. 첫 layer는 masked, mask는 adjacency와 달라 매 layer self-attend 허용.
- **RL은 PPO**(Isaac Gym, 4 task: Humanoid-Mod/Board/Hill, A1-Walk). 결과상 **BoT-Mix가 RL에 권장**된다. BoT-Hard는 정보 전파를 병목시켜 **hard-exploration task(Humanoid-Board/Hill)에서 열세**, 단순 task(A1-Walk/Humanoid-Mod)에선 vanilla Transformer보다 우수. → G1 tracking에 BoT 붙일 때 `is_mixed=True`(BoT-Mix)부터 시도.

## 내 연구 연결

이 논문은 `transformer` concept의 robot policy 적용 근거다. Physical Feature Graph 아이디어는 BoT의 morphology graph 관점을 stability language graph로 확장하려는 방향으로 해석할 수 있다.

## Links

- raw repo: AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md
- source note: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]
- concepts: [[transformer]] · [[ppo]]
- ideas: [[idea-physical-feature-graph]]

