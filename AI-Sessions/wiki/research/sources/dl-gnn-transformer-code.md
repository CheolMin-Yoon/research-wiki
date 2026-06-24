---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/dl-gnn-transformer.md
---

# 구현 분석: DL_GNN_Transformer

## Summary

사용자가 mj_rl의 GNN/Body Transformer task를 준비하기 위해 작성 중인 PyTorch 학습·스케치 repo다. raw repo stub의 pinned commit `c63defe64c4a68af164dfc027ed31718745b1236`을 checkout해 확인했으며, Body Transformer notebook 흐름과 torch.nn 기반 Actor-Critic mock이 핵심이다. PyG 자료는 개념 참고용이고 target implementation에는 사용하지 않는다.

## 핵심 파일

- `Body Transformer/00_BoT_Roadmap.ipynb`: G1 Body Transformer 구현 순서와 전체 로드맵.
- `Body Transformer/01_MuJoCo_XML_to_RobotGraph.ipynb`: MuJoCo XML/MjModel에서 robot graph를 추출하는 sketch.
- `Body Transformer/03_Transformer_MaskedAttention.ipynb`: PyTorch Transformer attention mask 실험.
- `Body Transformer/04_BoT_Tokenizer_Detokenizer.ipynb`: node feature tokenizer/detokenizer 실험.
- `Body Transformer/05_BodyTransformer_ActorCritic.ipynb`: tokenizer, mask, TransformerEncoder, actor/critic head를 묶은 toy class.
- `Body Transformer/06_RslRl_CustomModel_Mock.ipynb`: rsl_rl custom model 형태 mock.
- `Body Transformer/07_mj_rl_G1_BoT_Checklist.ipynb`: mj_rl graph_centroidal 구현 점검 checklist.
- `GNN/`, `Transformer/GraphTransformer/`: PyG와 graph transformer reference notebooks.

## 가져올 패턴

- MuJoCo body graph 추출, node feature slicing, attention mask, actor/critic head를 단계별로 나누는 구현 순서.
- PPO loop는 rsl_rl에 맡기고 actor/critic model만 Body Transformer로 교체하는 통합 방식.
- PyTorch `nn.TransformerEncoderLayer`와 `nn.TransformerEncoder`를 직접 쓰는 torch.nn target path.
- notebook checklist를 mj_rl graph_centroidal 구현 작업으로 전환할 수 있다(작업 단위는 프로젝트 레포에서 관리).

## 주의점

- notebook 중심 repo라 production code로 직접 가져오기 전에 shape, dtype, device, batching을 다시 검증해야 한다.
- PyG 구현은 참고용이다. mj_rl target implementation에서는 PyG를 쓰지 않고 torch.nn 기반으로 간다.
- 실행은 notebook별 cell 흐름을 개념 검산용으로만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/dl-gnn-transformer.md
- checked commit: c63defe64c4a68af164dfc027ed31718745b1236
- related raw papers: 2017-vaswani-attention.pdf, 2024-sferrazza-body-transformer.pdf
