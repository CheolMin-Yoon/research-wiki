---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/graph-transformer.md
---

# 구현 분석: Graph_Transformer (이전 이름: DL_GNN_Transformer)

## Summary

사용자가 mj_rl의 GNN/Body Transformer task를 준비하기 위해 작성 중인 PyTorch 학습·스케치 repo다. 2026-06-27 구조 개편으로 타깃 노트북은 `body_transformer/`, 개념 학습용은 `basic/`(GNN·Sequence·Transformer) 아래로 분리됐다. `body_transformer/` 노트북은 checked commit 이후 paper 흐름에 맞춰 재구성됐고, 원본 논문 레포가 `body-transformer-ref/`로 클론됐다(untracked, 분석은 [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]). 2026-06-28에는 `cmm_transformer_v0/` notebook-only scaffold가 추가되어 CMM feature + centroidal hub-biased full attention + actor/critic forward를 학습 결합 전까지 검증한다. PyG 자료는 개념 참고용이고 target implementation에는 사용하지 않는다.

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

## CMM Transformer v0 노트북 (2026-06-28)

`/home/frlab/Graph_Transformer/cmm_transformer_v0/`에 학습/PPO 결합 전까지의 7단계 notebook-only scaffold가 생성됐다. `lib/`, runner cfg, checkpoint/export, rsl_rl mock은 만들지 않았다.

- `00_CMM_Transformer_Roadmap.ipynb`: v0 scope와 기존 `body_transformer/`, `gcnt_limb_baseline/` 관계.
- `01_Paper_Formulas_CMM_Attention.ipynb`: Orin CMM, Body Transformer masked attention, GCNT SPD/logit bias, v0 CMM feature/bias 수식.
- `02_Node_And_Observation_Schema.ipynb`: 26 joint + 1 centroidal token schema. active schema는 joint token input 15D, state token input 9D.
- `03_mj_rl_Pinocchio_CMM_Source_Check.ipynb`: `sys.path.insert(0, "/home/frlab/mj_rl/source")` 후 `assets.cuda.pinocchio.Pinocchio` import와 constants/CMM source 확인.
- `04_CMM_Feature_Construction.ipynb`: `LEG_COLS(6:18)` + `ARM_COLS(21:35)`에서 no-waist CMM columns를 만들고 contribution sum shape를 확인.
- `05_Centroidal_Hub_Biased_Attention.ipynb`: centroidal↔joint logit에만 shared `g_psi(A_G[:,j])` hub bias를 더하고 `last_attention`을 저장.
- `06_CMM_Transformer_ActorCritic_PreTrainingCheck.ipynb`: tokenizer, CMM feature, hub-biased attention, joint actor head, centroidal critic head를 통합하고 dummy backward를 확인.

검증 사실:

- `mjlab_env`에서 `Pinocchio` import, CUDA-backed real `CMM [B, 6, 35]`, notebook `02`/`06` shape·gradient check가 통과했다. 기본 `python3`에 torch가 없을 수 있으므로 `03`은 synthetic fallback을 유지한다.
- 최종 per-joint feature는 `raw_joint_obs [q_j, dq_j, prev_action_j](3) + A_G[:,j](6) + A_G[:,j]dq_j(6) = 15D`.
- 초기 centroidal/state token은 state-only로 `projected_gravity(3) + linear momentum l_G(3) + centroidal angular momentum k_G(3) = 9D`.
- `base_ang_vel(3)`는 pelvis/root rate, `command(3)`는 task condition이라 초기 state token에는 섞지 않는다. 필요하면 별도 command conditioning/token으로 분리한다. `foot_to_com_w`, contact phase, base/CoM position, quaternion, contact-relative foot geometry는 ablation 후보로만 메모됐다.

## 가져올 패턴

- MuJoCo body graph 추출, node feature slicing, attention mask, actor/critic head를 단계별로 나누는 구현 순서.
- PPO loop는 rsl_rl에 맡기고 actor/critic model만 Body Transformer로 교체하는 통합 방식.
- PyTorch `nn.TransformerEncoderLayer`와 `nn.TransformerEncoder`를 직접 쓰는 torch.nn target path.
- notebook checklist를 mj_rl graph_centroidal 구현 작업으로 전환할 수 있다(작업 단위는 프로젝트 레포에서 관리).
- CMM v0은 notebook에서 shape/source/gradient를 먼저 검증하고, mj_rl 이식 시 `cmm_transformer_model.py`와 별도 CMM obs group으로 옮긴다.

## 주의점

- notebook 중심 repo라 production code로 직접 가져오기 전에 shape, dtype, device, batching을 다시 검증해야 한다.
- PyG 구현은 참고용이다. mj_rl target implementation에서는 PyG를 쓰지 않고 torch.nn 기반으로 간다.
- 실행은 notebook별 cell 흐름을 개념 검산용으로만 최소 참고한다.
- 사용자 워크플로우: 노트북에서 구현·검증 → `body_transformer/lib/`로 export → 다음 버전이 import. 노트북마다 graph utils·SimpleMapping 등이 divergent하게 중복 정의돼 있으므로 에이전트가 임의로 추출·병합하지 말고 사용자 export를 기다린다.

## Links

- raw repo: AI-Sessions/raw/repos/graph-transformer.md
- 원본 논문 레포 분석: [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]]
- related raw papers: 2017-vaswani-attention.pdf, 2024-sferrazza-body-transformer.pdf
