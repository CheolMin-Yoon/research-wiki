---
tags: [tier/low]
type: handoff
date: 2026-07-11
status: active
last_agent: Codex
suggested_next_agent:
mode: implementation
---

# Handoff

## Current Goal

`/home/frlab/mj_rl` branch `refactor/mj-rl-v2`의 commit `cf81c31` 위 미커밋 graph mimic/MAPPO fast-path working tree까지 반영됐다. FALCON 정밀 parity와 보류 검증 자동화는 완료 상태이고, graph mimic은 strict RSL-RL 5.4.0 PPO parity를 유지한 채 GCN/MAPPO 복사 fast path와 benchmark를 마쳤다. 이어서 `graph_29`/`graph`에 link 시각화 anchor 계약(`MorphologyNode.body_name`)을 추가하고 `graph_mimic_29d`에 node-edge debug overlay를 구현, `g1_tracking` 대비 iteration-matched interim 비교까지 마쳤다. 구현 정본은 `mj-rl.md`, graph mimic 실험 정본은 `2026-07-11-g1-29d-graph-mimic.md`, FALCON 상세 감사표는 repo-local `docs/design/falcon-parity-audit-2026-07-11.md`를 본다.

## Read First

- Current implementation digest(**검증 범위 명시됨**, 이번 세션이 안 연 파일은 미확인으로 표시): `AI-Sessions/wiki/research/sources/mj-rl.md`
- v1(pre-rewrite) 구현 이력: `AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11.md`
- 도메인 네이밍 일반 원칙: `AI-Sessions/wiki/harness/patterns/mjlab-patterns.md` ("one token per domain concept")
- RAL2025 하이퍼파라미터 대조(schedule=adaptive 확인): `AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code.md`
- CMM graph policy design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- GPU backend source(v1 시절 계약, v2 재확인 필요): `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

## Next Implementation

1. 사용자가 play.py 시각화 확인을 위해 일시 중단한 4096-env `G1-GRAPH-MIMIC-29D`(iter 1002/3000)를 재개하고, 기본 MjLab MLP mimic(`g1_tracking`, iter 3672/30000)과 동일 iteration/full run 비교를 이어간다. 중간 비교 결과(같은 iteration 기준 graph가 body/joint tracking·생존에서 우세, anchor tracking과 FPS는 MLP가 우세)는 `2026-07-11-g1-29d-graph-mimic.md`의 "Interim Baseline Comparison"에 있다.
2. 속도를 더 줄일 필요가 있으면 strict PPO parity fast path 범위인지, 아니면 GCN 폭/깊이·actor/critic 통합·epoch/minibatch 같은 별도 ablation인지 먼저 분리한다.
3. 필요 시 IsaacGym 환경을 별도 마련해 cross-simulator state replay를 추가한다.
4. anchor(pelvis/root) tracking이 graph mimic에서 약한 이유(root node가 명령/방향 정보는 갖지만 위치 결정 신호가 약함)를 검증하려면, `pelvis→knee/ankle` 같은 shortcut edge를 추가하는 실험이 다음 후보다(실험 설계 규칙: `2026-07-11-g1-29d-graph-mimic.md`의 "Planned Runs and Decision Rule" 4번 참고).

## Current Facts

- `/home/frlab/mj_rl` checked commit은 `cf81c31` + graph-mimic/MAPPO fast-path/body_name/debug-vis 미커밋 working tree(`refactor/mj-rl-v2`)다.
- 도메인 토큰은 `lower_body`/`upper_body`/`waist` 셋뿐이다. `leg`/`arm` 어휘는 저장소 전체(주석 포함)에서 제거됐다. 원칙: 같은 개념에 두 철자 금지.
- `layout.py`가 이름·인덱스·dim의 유일한 owner다. `graph.py`는 대칭/그래프 구조만 갖고 layout 사실을 재수출하지 않는다(`ACTION_DIM` 삭제됨).
- MAPPO의 actor/critic 모델 개별 노브(lr/clip/entropy/schedule)는 전부 `X | None = None` → 전역 algorithm cfg fallback 패턴이다.
- RAL2025(`humanoid_full_modular_runner_cfg.py`) 원본은 leg/arm 둘 다 `schedule="adaptive"`를 쓴다(arm lr=1e-5도 fixed 아님). mj_rl 현재 기본값이 이와 일치.
- `graph.py`/`graph_29.py`의 `MorphologyNode`에 `body_name`(link 시각화 anchor) 필드가 추가됐다 — 마지막 joint 기계적 유도 + 파일별 예외 1~2개, 단 hip/shoulder는 예외적으로 **첫 번째** joint를 쓴다(근위 anchor, 원리는 `mjlab-patterns.md`). `source/utils/graph_viz.py`(순수 draw) + `tasks/graph_mimic_29d/mdp/debug_vis.py`(`GraphOverlayEvent`)로 native viewer에 실제로 그려짐을 확인했다.
- mjlab `EventManager`는 class-based event에 `reset` 메서드가 없으면 `mode`와 무관하게 `debug_vis` dispatch에서 조용히 빠진다 — `mjlab-errors.md`에 새 항목으로 승격, 재발 방지 규칙 포함.
- 검증: 전체 92 tests OK, `git diff --check` OK. graph-mimic CPU 2-env rollout/MAPPO 1 update와 GPU 4-env MAPPO 1 update를 통과했다. 기존 graph checkpoint와 fast-path smoke checkpoint의 state dict key는 동일하다. `env.update_visualizers()`(실제 뷰어 dispatch 경로)로 15 sphere + 13 cylinder가 CPU에서 정확히 그려짐을 별도 확인했다.
- 4096-env graph mimic runtime check: eager fast path와 `torch_compile_mode=default` 모두 10% 이상 learning-time 개선을 보이지 않았다. 현재 병목은 불필요 복사보다 네 개의 128x4 GCN을 20개 PPO minibatch에서 돌리는 구조적 계산량에 가깝다.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.
- ACCAD는 Git LFS object이므로 clone 환경에서 `git lfs pull`이 필요하다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/{agent,mjlab}-patterns.md
