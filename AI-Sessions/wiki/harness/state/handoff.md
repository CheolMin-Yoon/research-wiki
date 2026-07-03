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

`/home/frlab/mj_rl`의 eICP/Centroidal 23-DOF 포팅과 debug visualization 분리가 커밋(`d7c38cb`)돼 `feature/port-eicp-centroidal-23dof`로 push 완료됐다(working tree clean). wiki 쪽은 `mj-rl.md`를 current digest로 압축했고, 오래된 reflect 상세는 archive history로 보냈다. 다음 구현 세션은 `play_keyboard.py`로 eICP/Centroidal 라이브 뷰어 검증부터 이어가면 된다.

## Read First

- Current implementation digest: `AI-Sessions/wiki/research/sources/mj-rl.md`
- Archived implementation history: `AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03.md`
- CMM graph policy design: `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit design: `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- GPU backend source: `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`

## Next Implementation

1. `play_keyboard.py --viewer native`로 `G1-eICP-Locomotion`/`G1-Centroidal-Locomotion`을 띄워 debug viz(footstep/LIPM ghost/CoM 구·trace/운동량 화살표)를 실제로 확인한다. 라이브 뷰어 검증은 아직 안 했다.
2. eICP/Centroidal naming은 RAL/IROS 기준 `base_velocity` + `step_command` 계약으로 이어간다. 옛 `gait_clock`, `"twist"`, `"footstep"` command key, `GaitClockCommandCfg`, `FootstepCommandCfg` alias를 되살리지 않는다.
3. 옛 `assets.cuda.pinocchio.Pinocchio` import가 남은 notebook/script는 alias 없이 `assets.cuda.casadi_pinocchio.CasadiPinocchio`로 고친다.
4. BodyTransformer hard/mix/broadcast/per-token/post-norm ablation을 같은 seed와 iteration budget으로 비교한다.
5. CMM model 평가는 BodyTransformer ablation 중 최소 하나가 살아나는지 확인한 뒤 진행한다.
6. `feature/port-eicp-centroidal-23dof`는 push만 됐다 — master merge/PR은 사용자 판단.

## Current Facts

- `/home/frlab/mj_rl` checked commit은 `d7c38cb`(`feature/port-eicp-centroidal-23dof`, origin에 push 완료)이며 working tree는 clean.
- G1 `HOME_KEYFRAME`과 `KNEES_BENT_KEYFRAME`은 별개다. BoT/Centroidal은 knees-bent default, eICP는 knees-bent legs + arm zero init.
- eICP/Centroidal external command key는 `base_velocity` + `step_command`다. Centroidal `GaitClockCommand*`와 eICP `FootstepCommand*` alias는 없다.
- CasADi wrapper는 `CasadiPinocchio`이며 internal rename alias는 남기지 않는다.
- `source/assets/cuda`와 `scripts/casadi_on_gpu`는 active BoT path에서 import되지 않아도 보존 대상이다.
- Debug viz는 command term에서 `source/visualization/`으로 분리됐고(footstep_viz/centroidal_viz/com_viz/native_viewer_opts), 두 task 모두 `step_command.debug_vis=True`가 기본이라 추가 CLI 없이 native/viser 뷰어에서 자동으로 그려진다.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/agent-patterns.md
