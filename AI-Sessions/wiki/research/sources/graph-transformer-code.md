---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/graph-transformer.md
---

# 구현 분석: Graph_Transformer (이전 이름: DL_GNN_Transformer)

## Summary

사용자가 mj_rl의 GNN/Body Transformer task를 준비하기 위해 작성 중인 PyTorch 학습·스케치 repo다. 2026-06-27 구조 개편으로 타깃 노트북은 `body_transformer/`, 개념 학습용은 `basic/`(GNN·Sequence·Transformer) 아래로 분리됐다. `body_transformer/` 노트북은 checked commit 이후 paper 흐름에 맞춰 재구성됐고, 원본 논문 레포가 `body-transformer-ref/`로 클론됐다(untracked, 분석은 [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]). Body Transformer notebook 흐름과 torch.nn 기반 Actor-Critic mock이 핵심이다. PyG 자료는 개념 참고용이고 target implementation에는 사용하지 않는다.

## Provenance

- checked commit: c63defe64c4a68af164dfc027ed31718745b1236 (2026-06-23). 2026-06-27 구조 개편을 `main`에 병합·푸시(HEAD b0f57fa): datasets/pyg untrack+삭제, `Body Transformer`→`body_transformer` rename, GNN/Sequence/Transformer를 `basic/`로 그룹화, README 추가, `body_transformer/lib/` scaffold, 상류 공식 예제 사본 삭제. `body-transformer-ref/` 클론은 working tree에만 있고 미커밋.

## 핵심 파일 (body_transformer/ 노트북, 2026-06-25 재구성)

- `00_BoT_Roadmap.ipynb`: G1 Body Transformer 구현 순서와 전체 로드맵.
- `01_MuJoCo_XML_to_RobotGraph.ipynb`: BoT 원본 `MAPS`/`SP_MATRICES`를 직접 만드는 simple builder. node/edge/SPD 정의.
- `02_BoT_GraphMask_Visualization.ipynb`: adjacency/SPD에서 attention mask를 만들고 시각화.
- `03_BoT_Tokenizer_Detokenizer.ipynb`: node별 `nn.Linear`로 flat obs→token, token→flat action (tokenize/detokenize 메커니즘 정본은 [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]).
- `04_BoT_MaskedAttention_Encoder.ipynb`: 03의 token에 02의 graph mask를 씌우는 masked attention encoder.
- `05_BodyTransformer_ActorCritic.ipynb`: tokenizer, mask, TransformerEncoder, actor/critic head를 묶은 toy class.
- `06_RslRl_CustomModel_Mock.ipynb`: rsl_rl custom model 형태 mock.
- `07_mj_rl_G1_BoT_Checklist.ipynb`: mj_rl graph_centroidal 구현 점검 checklist.
- `08_mj_rl_G1_RichGraphBuilder_Comparison.ipynb`: mj_rl rich graph builder 비교.
- `basic/GNN/01~12`: PyG 개념 학습용 노트북(사용자 본인 작성). 상류 공식 예제 사본(`pyg_colab_notebooks/`, `GraphTransformer/`, `TransformerColabNotebooks/`)은 2026-06-27 중복으로 삭제됨.
- `body_transformer/lib/`: 노트북 구현을 export 해 둘 빈 패키지 골격(graph_builder/graph_utils/tokenizer/encoder/actor_critic). 2026-06-27 scaffold만 생성.

## 가져올 패턴

- MuJoCo body graph 추출, node feature slicing, attention mask, actor/critic head를 단계별로 나누는 구현 순서.
- PPO loop는 rsl_rl에 맡기고 actor/critic model만 Body Transformer로 교체하는 통합 방식.
- PyTorch `nn.TransformerEncoderLayer`와 `nn.TransformerEncoder`를 직접 쓰는 torch.nn target path.
- notebook checklist를 mj_rl graph_centroidal 구현 작업으로 전환할 수 있다(작업 단위는 프로젝트 레포에서 관리).

## 주의점

- notebook 중심 repo라 production code로 직접 가져오기 전에 shape, dtype, device, batching을 다시 검증해야 한다.
- PyG 구현은 참고용이다. mj_rl target implementation에서는 PyG를 쓰지 않고 torch.nn 기반으로 간다.
- 실행은 notebook별 cell 흐름을 개념 검산용으로만 최소 참고한다.
- 사용자 워크플로우: 노트북에서 구현·검증 → `body_transformer/lib/`로 export → 다음 버전이 import. 노트북마다 graph utils·SimpleMapping 등이 divergent하게 중복 정의돼 있으므로 에이전트가 임의로 추출·병합하지 말고 사용자 export를 기다린다.

## Links

- raw repo: AI-Sessions/raw/repos/graph-transformer.md
- 원본 논문 레포 분석: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]
- related raw papers: 2017-vaswani-attention.pdf, 2024-sferrazza-body-transformer.pdf
