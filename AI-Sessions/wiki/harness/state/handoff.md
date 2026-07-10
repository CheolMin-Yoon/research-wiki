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

`/home/frlab/mj_rl` branch `refactor/mj-rl-v2`의 commit `8bfdca4`까지 원본 FALCON 설정 정밀 parity의 첫 구현 pass를 완료했다. 구현 정본은 `mj-rl.md`, 상세 감사표는 repo-local `docs/design/falcon-parity-audit-2026-07-11.md`를 본다.

## Read First

- Current implementation digest(**검증 범위 명시됨**, 이번 세션이 안 연 파일은 미확인으로 표시): `AI-Sessions/wiki/research/sources/mj-rl.md`
- v1(pre-rewrite) 구현 이력: `AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11.md`
- 도메인 네이밍 일반 원칙: `AI-Sessions/wiki/harness/patterns/mjlab-patterns.md` ("one token per domain concept")
- RAL2025 하이퍼파라미터 대조(schedule=adaptive 확인): `AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code.md`
- CMM graph policy design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit design(v1 시절, v2 미이식): `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- GPU backend source(v1 시절 계약, v2 재확인 필요): `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

## Next Implementation

1. 49개 reward의 원본 FALCON golden-state parity를 확장한다.
2. 4096-env 장기 학습으로 constraint peak와 curriculum progression을 확인한다.
3. ACCAD pickle·말단 관성·결합 friction의 보류 검증을 마친다.

## Current Facts

- `/home/frlab/mj_rl` checked commit은 `8bfdca4`(`refactor/mj-rl-v2`)이다.
- 도메인 토큰은 `lower_body`/`upper_body`/`waist` 셋뿐이다. `leg`/`arm` 어휘는 저장소 전체(주석 포함)에서 제거됐다. 원칙: 같은 개념에 두 철자 금지.
- `layout.py`가 이름·인덱스·dim의 유일한 owner다. `graph.py`는 대칭/그래프 구조만 갖고 layout 사실을 재수출하지 않는다(`ACTION_DIM` 삭제됨).
- MAPPO의 actor/critic 모델 개별 노브(lr/clip/entropy/schedule)는 전부 `X | None = None` → 전역 algorithm cfg fallback 패턴이다.
- RAL2025(`humanoid_full_modular_runner_cfg.py`) 원본은 leg/arm 둘 다 `schedule="adaptive"`를 쓴다(arm lr=1e-5도 fixed 아님). mj_rl 현재 기본값이 이와 일치.
- 검증: 전체 67 tests OK, CPU 2-env rollout, GPU 4-env MAPPO 1 update, GPU 16-env 2 update OK.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.
- ACCAD는 Git LFS object이므로 clone 환경에서 `git lfs pull`이 필요하다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/{agent,mjlab}-patterns.md
