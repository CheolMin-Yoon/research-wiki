---
type: paper
date: 2026-06-25
status: active
topics:
  - graph-policy
source: "AI-Sessions/raw/papers/Do Transformers Really Perform Bad.pdf"
---

# Do Transformers Really Perform Bad for Graph Representation? — Graphormer (2021)

- 저자: Chengxuan Ying, Tianle Cai, Shengjie Luo, Shuxin Zheng, Guolin Ke, Di He, Yanming Shen, Tie-Yan Liu
- venue/arXiv: NeurIPS 2021 / arXiv:2106.05234
- source: "AI-Sessions/raw/papers/Do Transformers Really Perform Bad.pdf"

## Abstract (한국어)

Transformer는 NLP·vision에서 표준이 됐으나 graph-level prediction에서는 주류 GNN보다 성능이 낮다는 미스터리가 있었다. 이 논문은 **Graphormer**를 제안해 그 이유를 해결한다. 핵심은 그래프의 구조 정보를 Transformer에 효과적으로 인코딩하는 세 가지 방법이다. OGB-LSC 등 large-scale graph 벤치마크에서 SOTA를 달성하고, 대부분의 GNN 변종이 Graphormer의 special case임을 수학적으로 증명한다.

## 핵심 내용

### 세 가지 구조 인코딩

1. **Centrality Encoding**: degree를 기준으로 node 중요도를 인코딩. indegree·outdegree별로 learnable embedding $z^-, z^+$를 node feature에 더한다.
   $$h_i^{(0)} = x_i + z^-_{\deg^-(v_i)} + z^+_{\deg^+(v_i)}$$

2. **Spatial Encoding**: node pair $(v_i, v_j)$의 shortest path distance(SPD)를 learnable scalar $b_{\phi(v_i,v_j)}$로 매핑해 attention logit에 bias로 더한다. 연결되지 않으면 -1로 처리.
   $$A_{ij} = \frac{(h_i W_Q)(h_j W_K)^T}{\sqrt{d}} + b_{\phi(v_i,v_j)}$$

3. **Edge Encoding**: node pair 사이의 shortest path 위 edge feature들을 dot-product로 평균내어 attention에 추가 bias로 주입.
   $$c_{ij} = \frac{1}{N}\sum_{n=1}^N x_{e_n}(w_n^E)^T$$

### Special Node [VNode]

BERT의 [CLS]처럼 모든 node와 연결되는 가상 node를 추가해 graph-level representation을 얻는다. SPD convention: [VNode]↔실제 node의 $\phi$는 별도 learnable scalar로 구분한다.

### Graphormer ⊇ GNN

Centrality Encoding + Spatial Encoding + Edge Encoding 조합으로 GCN, GraphSAGE, GIN 등이 Graphormer의 special case임을 증명한다.

## 내 연구 연결

- **BoT와의 차이**: BoT는 robot body graph를 hard mask(adjacency)로 attention을 제한하지만, Graphormer는 SPD를 soft bias로 추가해 전체 pair attention을 유지한다.
- **Physical Feature Graph 아이디어**: SPD-based spatial encoding은 stability language graph에서 CoM·DCM·CAM 간 coupling 거리를 attention bias로 주입하는 방식으로 확장 가능하다.
- Graphormer 계열 참고 코드(PyG `gps`/`gat`/`super_gat` 등)는 PyG 공식 예제에 있다. Graph_Transformer repo에 두었던 사본 `GraphTransformer/`는 2026-06-27 중복으로 삭제했다.

## Relations
