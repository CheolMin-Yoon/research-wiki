---
tags: [tier/low]
type: handoff
date: 2026-07-03
status: active
last_agent: Claude
suggested_next_agent:
mode: implementation
---

# Handoff

## Current Goal

`/home/frlab/mj_rl`의 modular RL cleanup이 커밋(`ffbb2c3`)됐다. 새 구조는 `modules.primitives`(순수 PyTorch block), `modules.models`(rsl_rl-compatible model), `modules.rl`(generic multi-agent PPO/runner)로 나뉘며, BoT task package는 `tasks.bot_velocity`다. wiki 쪽은 `mj-rl.md`를 current digest로 압축했다.

## Read First

- Current implementation digest: `AI-Sessions/wiki/research/sources/mj-rl.md`
- Archived implementation history: `AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03.md`
- CMM graph policy design: `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit design: `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- GPU backend source: `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

## Next Implementation

1. 새 multi-actor/multi-critic 실험은 runner 파일을 새로 만들지 말고 `MultiAgentRlCfg`와 `MultiAgentRunner` config로 표현한다.
2. GCN limb actor 실험은 `modules.primitives.gcn` + `modules.models.gcn_actor`를 재사용한다.
3. 옛 `modules.common`, `modules.body_transformer`, `tasks.body_transformer_velocity`, `assets.cuda.pinocchio.Pinocchio` import가 남은 notebook/script는 alias 없이 새 경로로 고친다.
4. CMM model 평가는 BoT/GCN baseline 중 최소 하나가 안정적으로 살아나는지 확인한 뒤 진행한다.

## Current Facts

- `/home/frlab/mj_rl` checked commit은 `ffbb2c3`(`master`)이다.
- G1 `HOME_KEYFRAME`과 `KNEES_BENT_KEYFRAME`은 별개다. BoT/Centroidal은 knees-bent default, eICP는 knees-bent legs + arm zero init.
- eICP/Centroidal external command key는 현재 `twist` + `step_command`다. Centroidal `GaitClockCommand*`와 eICP `FootstepCommand*` alias는 없다.
- CasADi wrapper는 `CasadiPinocchio`이며 internal rename alias는 남기지 않는다.
- `source/assets/cuda`와 `scripts/casadi_on_gpu`는 active BoT path에서 import되지 않아도 보존 대상이다.
- Centroidal 계열 debug viz는 command term에서 `source/visualization/`으로 분리돼 있지만 기본 off다. `play_keyboard.py --command-viz`로 opt-in한다.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/agent-patterns.md
