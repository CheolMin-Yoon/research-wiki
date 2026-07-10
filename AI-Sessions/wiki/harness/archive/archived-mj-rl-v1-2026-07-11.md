---
tags: [tier/low]
type: archive
date: 2026-07-11
status: archived
source: AI-Sessions/wiki/research/sources/mj-rl.md (pre-rewrite content)
---

# Archived mj_rl v1 (pre-`refactor/mj-rl-v2`)

`/home/frlab/mj_rl`가 branch `refactor/mj-rl-v2`로 전면 재작성되면서, 이전 구조(`modules/primitives`, `modules/models`, `modules/rl`, `tasks.bot_velocity`, `tasks.centroidal`, `tasks.eicp`, `tasks.waist_momentum` 등)를 설명하던 `mj-rl.md` 본문 전체를 이력으로 보존한다. 현재 구조(`source/{assets,rl,tasks,utils}`, `tasks.mlp_ctde`)는 active `mj-rl.md`를 본다.

Archive 조건: archive-policy.md의 "source repo 구조가 바뀌어 기존 분석이 부정확해짐"에 해당.

## Summary (당시 원문)

사용자의 active Unitree G1 humanoid locomotion RL repo다. 2026-07-08 reflect 기준 checked commit은 `ffbb2c3`(브랜치 `master`)이고, 이번 작업은 BoT/GCN/Transformer building block과 rsl_rl orchestration을 `primitives/models/rl`로 분리하고 legacy modular runner 증식을 `MultiAgentRunner` 중심으로 접었다.

## Current Implementation Surface (당시 원문)

- `source/modules/primitives/`: 순수 PyTorch building block. GCN stack, graph tensor builder, token layout, BoT transformer encoder 등이며 rsl_rl runner/task/PPO를 모른다.
- `source/modules/models/`: rsl_rl-compatible model surface. `BoTActor`, token model/critic, GCN actor, shared value heads가 여기 있다.
- `source/modules/rl/`: network-agnostic multi-agent orchestration. `ActorUnitCfg`, `CriticUnitCfg`, `MultiAgentRlCfg`, action/reward routing, storage, PPO, runner를 소유한다.
- `source/tasks/bot_velocity/`: active BoT G1 23DoF velocity task 등록과 env/agent config.
- `source/tasks/centroidal/`: modular leg/arm actor + centroidal/CAM reward task. agent cfg는 `MultiAgentRlCfg`로 leg/arm actor와 critic units를 직접 표현한다.
- `source/tasks/centroidal_token_group_critic/`: 기존 centroidal env/reward/action을 재사용하되 `token_critic` obs group과 shared token-group critic cfg만 별도 소유.
- `source/tasks/eicp/`, `source/tasks/waist_momentum/`: eICP/LIPM step planner와 leg 또는 leg+waist task.
- `source/assets/cuda/`: CasADi-on-GPU centroidal/dynamics kernel generation과 wrapper.
- `scripts/helper/shared.py`, `scripts/train.py`, `scripts/play.py`, `scripts/play_keyboard.py`, `scripts/spawn_g1.py`.
- `source/visualization/`: command term은 state만 갖고 drawing은 여기로 분리.
- `네이밍.md`: repo-local naming convention (v1 스타일 — v2는 별도 lint 규약, [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]] 참고).

## Current Contracts (당시 원문, 요약)

Package boundary(primitive/model/rl 3분), public naming(`BoTActor`), task naming(`tasks.bot_velocity`), G1 pose naming(`HOME_KEYFRAME` vs `KNEES_BENT_KEYFRAME`), CasADi wrapper 경로(`assets.cuda.casadi_pinocchio.CasadiPinocchio`), command/obs 키(`twist`, `step_command`, `last_leg_action`, `last_arm_action`), debug viz ownership, playback checkpoint loading(`MultiAgentPPO.load()`), task separation(centroidal vs token_group_critic). 전체 상세는 git history의 이 파일 이전 버전을 참고.

## Links

- 대체 active note: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- 이전 reflect 이력: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]
- 삭제 오판 교훈(v1 시절, 여전히 유효): [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]
