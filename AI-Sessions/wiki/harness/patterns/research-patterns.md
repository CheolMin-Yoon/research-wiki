---
tags: [tier/low]
type: pattern
date: 2026-06-25
status: active
source: AI-Sessions/wiki/harness/patterns/agent-patterns.md
---

# Research Patterns

연구·노트북·실험 작업 때만 읽는 on-demand 패턴이다. init 레이어에는 `agent-patterns`만 두고, 아래 도메인 패턴은 `research.md` 라우터를 통해 필요할 때 로드한다.

## Positive Pattern — 논문 수식을 노트북용 Markdown으로 변환

사용자가 논문 수식이나 attention/graph/mask 같은 개념식을 묻고 "노트북에 붙여넣고 싶다"는 의도를 보이면, 원문 paper 또는 local source에서 수식을 먼저 확인한 뒤 다음 형태로 답한다.

1. 원문 수식의 핵심 형태를 LaTeX Markdown으로 재작성한다.
2. 각 기호가 코드/노트북 변수와 어떻게 대응되는지 짧게 설명한다.
3. 사용자가 바로 Jupyter Markdown cell에 붙여넣을 수 있도록 fenced `markdown` 블록 하나로 제공한다.
4. 출처 paper title, section, URL 또는 local path를 마지막에 남긴다.

예: Body Transformer masked attention은 원문에서 additive bias 형태 `Attention(Q, K, V) = softmax(QK^T / sqrt(d_k) + B)V`와 `B_ij = 0 if M_ij = 1, -inf if M_ij = 0`를 확인한 뒤, 노트북의 `adjacency_matrix`, `torch_attn_mask`, `attention_bias`와 연결해서 설명한다.

## Positive Pattern — 논문 구현을 학습용 노트북으로 쪼개기

사용자가 paper implementation을 노트북 튜토리얼로 재구성하길 원하면, 단순히 파일을 기능별로 나누지 말고 사용자가 논문 흐름을 따라 이해할 수 있는 순서로 계획한다.

1. 먼저 paper와 official implementation의 핵심 interface를 확인한다.
2. 각 노트북은 논문 architecture의 한 단계만 다룬다.
3. 앞 노트북의 산출물이 다음 노트북의 입력처럼 보이게 이름과 shape를 맞춘다.
4. Markdown에는 "이 셀이 논문/원본 코드의 어느 부분에 해당하는지"를 짧게 적는다.
5. 나중에 Python module로 옮길 수 있도록 함수·class 경계를 튜토리얼 단계와 맞춘다.

예: Body Transformer는 `Mapping -> Tokenizer -> masked Transformer encoder -> Detokenizer` 흐름으로 쪼개고, `MAPS`, `SP_MATRICES`, attention mask, token shape, action scatter를 각각 별도 학습 단위로 둔다.

## Anti-pattern — 작업 repo의 Python 환경을 확인하지 않고 의존성 대체

같은 작업 공간의 repo에서 노트북이나 코드를 수정할 때, 현재 shell의 `python3`에 `torch`가 없다는 이유만으로 PyTorch 구현을 NumPy로 바꾸면 안 된다. shell 환경은 repo가 의도한 conda/kernel 환경과 다를 수 있다.

Better approach:

1. repo 안에서 `environment.yml`, `requirements.txt`, `pyproject.toml`, `.ipynb` kernelspec, README의 conda 안내를 먼저 찾는다.
2. conda 환경 후보가 있으면 `conda env list`와 kernel metadata를 확인한다.
3. 논문/원본 구현이 PyTorch 기반이면, 튜토리얼도 기본은 PyTorch로 유지한다.
4. NumPy fallback은 "개념 확인용" 또는 "torch 미설치 환경에서도 일부 셀 실행"이라는 목적을 명시할 때만 둔다.
5. 검증 보고에는 어떤 Python/conda/kernel 환경에서 실행했는지, PyTorch 셀을 실행했는지 skip했는지 밝힌다.

## Positive Pattern — 노트북 rename/resequence 후 downstream 참조 점검

노트북 번호나 파일명을 바꿀 때는 해당 노트북만 고치지 말고, 다음 단계 노트북과 roadmap의 참조가 끊기지 않는지 함께 확인한다.

1. `rg`로 old filename과 new filename을 모두 검색한다.
2. `00` 로드맵, 이후 노트북의 설명, import/load 경로, README성 문서를 확인한다.
3. 같은 graph/order/schema를 반복하는 standalone 노트북이면 01과 값이 일치하는지 실행 검증한다.
4. 이번 범위 밖이라 수정하지 않는 downstream 불일치는 완료 보고에 남긴다.

## Positive Pattern — 시뮬레이터 스크린샷 overlay는 실제 위치 anchor를 우선

사용자가 로봇 스크린샷, MuJoCo viewer 이미지, actuator 화살표, pelvis/free-base 같은 시각적 기준을 말하며 "겹쳐서 보여줘"라고 하면, 별도 inset 설명 그림보다 **이미지 위 실제 위치에 node/label을 직접 얹는 방식**을 먼저 고려한다.

1. 먼저 이미지 크기와 시각 기준점을 확인한다.
2. 실제 actuator 화살표나 body 위치를 언급하면 tree inset이 아니라 spatial overlay일 수 있음을 점검한다.
3. 정확한 camera projection이 필요한 작업인지, 튜토리얼용 hand-anchored pixel 좌표면 충분한지 구분한다.
4. 노드 라벨은 이미지 위를 가리지 않게 짧게 둔다.
5. 기존 mask/attention 시각화를 유지하라는 요청이 있으면 기존 셀은 그대로 두고 마지막에 새 overlay 셀을 추가한다.
6. 생성 결과는 `view_image`로 직접 확인하고, 라벨 겹침·잘림·위치 어긋남을 한 번 다듬은 뒤 완료 보고한다.

## Positive Pattern — implementation repo에는 raw artifacts, wiki에는 reproducibility digest

실험이 실제 repo에서 돌아가고 wiki가 장기 기억 역할을 할 때는 산출물의 무게를 분리한다. checkpoint, TensorBoard event, generated YAML처럼 재생성 가능하거나 큰 raw artifact는 implementation repo에 두고, wiki에는 재현에 필요한 digest와 해석만 남긴다.

1. 실험 노트에는 working directory, conda env, 핵심 env var, 실행 명령어, output dir, config source path를 기록한다.
2. full config YAML은 wiki에 복사하지 않는다. 대신 task id, 주요 override, actor/critic shape, optimizer/PPO 핵심값, reward/termination 이름을 요약한다.
3. raw TensorBoard event는 repo의 `outputs/`에 두고, wiki에는 어떤 tag를 primary curve로 볼지와 최종/대표 값을 기록한다.
4. `.pt` checkpoint는 repo의 `models/` 또는 run dir에 두고, wiki에는 best checkpoint path와 선택 metric만 남긴다.
5. 이후 architecture 비교를 할 때는 task/reward/motion/action/config source를 고정하고, 무엇을 바꿨는지 한 줄로 분리해 적는다.

## Links

- [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]
- [[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]
