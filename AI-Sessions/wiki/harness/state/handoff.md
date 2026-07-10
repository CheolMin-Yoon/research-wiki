---
tags: [tier/low]
type: handoff
date: 2026-07-11
status: active
last_agent: Claude
suggested_next_agent:
mode: implementation
---

# Handoff

## Current Goal

`/home/frlab/mj_rl`이 branch `refactor/mj-rl-v2`(checked commit `c890973`)로 전면 재작성됐다. **이전 handoff/brief에 있던 mj_rl 구조(modules/primitives, tasks.bot_velocity 등)는 이제 존재하지 않는다** — 지금은 `source/{assets,rl,tasks,utils}` + `tasks.mlp_ctde` 단일 task뿐이다. v1 상세는 `archived-mj-rl-v1-2026-07-11.md`.

이번 세션은 `tasks.mlp_ctde`(첫 실제 MAPPO task: G1 lower_body/upper_body 2-actor 2-critic CTDE)에서 두 가지 작업을 했다: (1) 도메인 네이밍을 `leg`/`arm`에서 `lower_body`/`upper_body`로 저장소 전체 통일 + `graph.py`의 dim 재수출 제거, (2) MAPPO에 actor별 learning-rate schedule(adaptive/fixed) 오버라이드 추가, RAL2025 원본과 하이퍼파라미터 대조.

## Read First

- Current implementation digest(**검증 범위 명시됨**, 이번 세션이 안 연 파일은 미확인으로 표시): `AI-Sessions/wiki/research/sources/mj-rl.md`
- v1(pre-rewrite) 구현 이력: `AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11.md`
- 도메인 네이밍 일반 원칙: `AI-Sessions/wiki/harness/patterns/mjlab-patterns.md` ("one token per domain concept")
- RAL2025 하이퍼파라미터 대조(schedule=adaptive 확인): `AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code.md`
- CMM graph policy design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- GPU backend source(v1 시절 계약, v2 재확인 필요): `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

## Next Implementation

1. v2 전체 재감사: `source/rl/{storage,routing}.py`, `source/tasks/mlp_ctde/mdp/*`, `source/utils/`, `scripts/`를 읽고 `mj-rl.md`에 채운다. 이번 세션은 `assets/{layout,graph,g1,dynamics}.py`, `rl/{config,mappo}.py`, `tasks/mlp_ctde/{agent_cfg,env_cfg}.py`, `tests/{test_mlp_ctde,test_mappo}.py`만 확인했다.
2. working tree에 커밋 `c890973` 이후 대량 삭제(`docs/experiments/*`, `docs/figures/bot_*`, `.gitignore`)가 unstaged로 남아 있다(git status로만 관측, 내용 미분석) — 의도된 정리인지 사용자에게 확인 후 커밋 여부 판단.
3. `ActorModelCfg.schedule='fixed'`는 구현만 됐고 `mlp_ctde`는 미사용(RAL2025 parity 유지 목적) — 켤지 여부는 사용자 결정 대기.
4. v1의 GCN/BoT/CasADi-GPU 자산(`source/assets/cuda/` 등)이 v2에도 존재하는지 아직 미확인.

## Current Facts

- `/home/frlab/mj_rl` checked commit은 `c890973`(`refactor/mj-rl-v2`)이다. 이전 `ffbb2c3`(`master`)는 v1 마지막 상태다.
- 도메인 토큰은 `lower_body`/`upper_body`/`waist` 셋뿐이다. `leg`/`arm` 어휘는 저장소 전체(주석 포함)에서 제거됐다. 원칙: 같은 개념에 두 철자 금지.
- `layout.py`가 이름·인덱스·dim의 유일한 owner다. `graph.py`는 대칭/그래프 구조만 갖고 layout 사실을 재수출하지 않는다(`ACTION_DIM` 삭제됨).
- MAPPO의 actor/critic 모델 개별 노브(lr/clip/entropy/schedule)는 전부 `X | None = None` → 전역 algorithm cfg fallback 패턴이다.
- RAL2025(`humanoid_full_modular_runner_cfg.py`) 원본은 leg/arm 둘 다 `schedule="adaptive"`를 쓴다(arm lr=1e-5도 fixed 아님). mj_rl 현재 기본값이 이와 일치.
- 검증: `PYTHONPATH=source /home/frlab/anaconda3/envs/mjlab_env/bin/python -m unittest discover -s tests -p 'test_*.py'` → 42 tests OK.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.
- `/home/frlab/mj_rl` working tree에 unstaged 대량 삭제가 있다 — 커밋/복구 여부를 사용자에게 먼저 확인한다(git status로만 관측).

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/{agent,mjlab}-patterns.md
