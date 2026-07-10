---
tags: [tier/low]
type: source
date: 2026-07-11
status: active
source: AI-Sessions/raw/repos/mj-rl.md
---

# 구현 분석: mj_rl

## Summary

사용자의 active Unitree G1 humanoid locomotion RL repo다. **repo가 branch `refactor/mj-rl-v2`로 전면 재작성됐다** — 이전 `modules/primitives`, `modules/models`, `modules/rl`, `tasks.bot_velocity`/`centroidal`/`eicp`/`waist_momentum` 구조는 사라지고 `source/{assets,rl,tasks,utils}` + `tasks.mlp_ctde` 단일 task로 새로 시작했다. v1 상세는 [[AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11|archived-mj-rl-v1-2026-07-11]]에 보존한다.

이 digest는 **2026-07-11 세션에서 직접 다룬 범위만 검증**했다: `source/assets/{layout,graph,g1,dynamics}.py`, `source/rl/{config,mappo}.py`, `source/tasks/mlp_ctde/{agent_cfg,env_cfg}.py`, `tests/{test_mlp_ctde,test_mappo}.py`. `source/rl/{storage,routing}.py`, `source/tasks/mlp_ctde/mdp/*`, `source/utils/`, `scripts/`는 이번 세션에 열어보지 않았다 — 다음 reflect에서 v2 전체 재감사가 필요하다(미검증, 추측 아님).

## Current Implementation Surface (검증됨)

- `source/assets/layout.py`: G1 23-DOF joint 이름·순서·인덱스의 단일 손-작성 원천. 손-작성은 `LEFT/RIGHT_LOWER_BODY_JOINTS`(6+6), `WAIST_JOINTS`(1), `LEFT/RIGHT_UPPER_BODY_JOINTS`(5+5) 좌/우 튜플과 SDK 모터 인덱스뿐이고, DOF/slice/NQ·NV/`qpos_slice`/`qvel_slice`/`joint_group_of`는 전부 파생이다. **leg/arm 어휘는 저장소 전체에서 제거됨**(2026-07-11) — 도메인 토큰은 `lower_body`/`upper_body`/`waist` 셋뿐이다.
- `source/assets/graph.py`: C2 sagittal-mirror 대칭 계약. `JOINT_REPRESENTATION`(전신 23-wide signed permutation) → `ACTION_REPRESENTATION`은 도메인별 block 제한으로 파생. `MorphologyNode`/`KINEMATIC_EDGES`(도메인당 7 node/6 edge)는 향후 GNN policy를 겨냥해 존재하되 현재 어떤 task도 쓰지 않는다. **`ACTION_DIM` 공개 dict는 삭제됨**(2026-07-11) — dim이 필요한 소비자는 `layout.LOWER_BODY_DOF`/`UPPER_BODY_DOF`를 직접 읽는다.
- `source/assets/g1.py`: MJLab entity 조립(actuator/모터/자세). 모듈 자체가 네임스페이스(`G1_` prefix 없음, `g1.ACTION_SCALE`처럼 접근).
- `source/assets/dynamics.py`: 설치된 `casadi_on_gpu` 커널 runtime adapter. `NQ/NV`, `LOWER_BODY_COLS`/`UPPER_BODY_COLS`/`WAIST_COLS`는 layout에서 파생, 자체 계약값 없음.
- `source/rl/config.py`: MAPPO 구조 dataclass — `AgentCfg`/`ValueCfg`/`ActorModelCfg`/`CriticModelCfg`/`MappoAlgorithmCfg`/`MappoRunnerCfg`. actor/critic별 `learning_rate`/`clip_param`/`entropy_coef`/`schedule`는 전부 동일 패턴: `X | None = None` → 미지정 시 전역 `algorithm` cfg로 fallback.
- `source/rl/mappo.py`: MAPPO 알고리즘. **logical agent(액션 소유)** × **named value(reward/advantage 라우팅)** 두 축이 actor/critic 모델 그룹핑과 독립이다. 1-agent/1-value 케이스는 RSL-RL PPO와 텐서 의미론이 정확히 일치하도록 테스트로 고정. 2026-07-11: actor별 `schedule`(adaptive/fixed) 오버라이드 추가 — critic lr 동기화는 그 critic이 소비하는 actor가 **전부** fixed일 때만 그 critic도 고정된 채로 둔다.
- `source/tasks/mlp_ctde/`: 첫 실제 MAPPO task. Full-body G1(23-DOF, waist는 joint equality로 고정, DOF는 유지)을 `lower_body`(legs, 12)/`upper_body`(arms, 10) 두 decentralized actor + 두 centralized-obs critic(각 critic은 자기 actor의 부분 관측과 무관하게 전신을 봄)으로 분해한다. `agent_cfg.py`의 lr/clip/gamma/lam/schedule 하이퍼파라미터는 RAL2025 `humanoid_full_modular_runner_cfg.py`의 `leg_algorithm`/`arm_algorithm`을 직접 이식한 것으로 확인(대조는 아래 Research-Relevant Patterns) — hidden_dims와 upper_body entropy_coef만 사용자의 의도적 편차.

## Current Contracts

- **도메인 토큰 단일화**: `lower_body`/`upper_body`(+독립 그룹 `waist`) 세 토큰만 쓴다. 규칙: *한 파일·한 저장소 안에서 같은 개념을 가리키는 철자가 두 개 있으면 안 된다.* 2026-07-11에 이 규칙 위반을 두 번 발견·수정했다 — (1) task 레이어 reward 키가 `leg/`인데 상수는 `LOWER_BODY_REWARD_TERMS`라 import-time assert가 깨짐, (2) `layout.py` 자신이 손-작성 원천(`LEFT_LEG_JOINTS`)과 파생 상수(`LOWER_BODY_JOINTS`)에서 서로 다른 어휘를 씀(사용자가 직접 지적). 자세한 원칙은 [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]] "one token per domain concept".
- **layout ↔ graph 책임 분리**: 숫자·인덱스·dim은 layout, 대칭·그래프 구조는 graph. graph는 torch 의존이라 대칭/그래프 구조를 실제로 쓰는 task만 import해야 한다 — 안 그러면 "이 task가 그래프에 의존한다"는 거짓 신호가 된다. layout 사실을 재수출하는 공개 API(예: 이전 `graph.ACTION_DIM`)는 만들지 않는다.
- **per-model hyperparameter override 패턴**: `ActorModelCfg`/`CriticModelCfg`의 모든 개별 노브(`learning_rate`, `clip_param`, `entropy_coef`, `schedule`)는 `X | None = None` → 전역 fallback 패턴을 따른다. 새 per-model 노브를 추가할 때 이 패턴을 유지한다.

## Research-Relevant Patterns

- RAL2025(`LearningHumanoidArmMotion-RAL2025-Code`, `humanoid_full_modular`)와 mj_rl `agent_cfg.py`를 하이퍼파라미터 대조한 결과, **leg/arm(우리 lower_body/upper_body) 두 그룹 모두 `schedule="adaptive"`를 쓰며 arm 쪽 `learning_rate=1e-5`은 fixed가 아니라 adaptive 스케줄러의 시작점**이다. mj_rl의 현재 기본값(두 actor 모두 전역 adaptive 상속, `schedule='fixed'` 미사용)이 원 논문 설계와 일치함을 확인했다 — 상세 대조표는 [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]를 본다.
- (v1 시절 patterns: graph policy mapping/tokenizer/transformer 계약, per-joint CAM credit telescoping 위험, CasADi 23DOF/13DOF 공존 — v2에 아직 재이식되지 않았으므로 archive를 참고만 한다.)

## Verification Snapshot

- 2026-07-11: `PYTHONPATH=source /home/frlab/anaconda3/envs/mjlab_env/bin/python -m unittest discover -s tests -p 'test_*.py'` → **42 tests OK** (도메인 토큰 통일 + graph 의존 제거 + per-actor schedule 기능 추가 이후).
- 이전 v1 검증 스냅샷은 archive를 본다(더 이상 유효하지 않은 구조 기준).

## Next

1. v2 전체 재감사: `source/rl/{storage,routing}.py`, `source/tasks/mlp_ctde/mdp/*`, `source/utils/`, `scripts/`를 다음 세션에서 확인하고 이 digest에 채운다.
2. working tree에 커밋 `c890973` 이후 대량 삭제(`docs/experiments/*`, `docs/figures/bot_*`, `.gitignore` 등)가 unstaged로 남아 있음(git status로 직접 관측, 내용 미분석) — 의도된 정리인지 다음 세션에서 확인.
3. `ActorModelCfg.schedule='fixed'` per-actor 오버라이드는 구현만 되어 있고 `mlp_ctde` task는 미사용(RAL2025 parity 유지 목적). 실험적으로 켜려면 위 Research-Relevant Patterns 대조표를 baseline으로 삼는다.
4. v1의 GCN/BoT/CasADi-GPU 자산이 v2로 재이식됐는지 여부는 미확인 — `source/assets/cuda/`가 v2에도 존재하는지부터 확인.

## Cautions

- repo가 branch `refactor/mj-rl-v2`로 전면 재작성됨. 이 digest 이전 구조(모듈 3분할, `tasks.bot_velocity` 등)는 더 이상 존재하지 않는다 — archive를 봐야 한다.
- v1 시절 `네이밍.md`(single-quote 아닌 v1 스타일)는 v2에 그대로 적용되지 않는다. v2 lint 스타일(single-quote/4-space/79자/docstring 필수)은 [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]]를 본다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 current contract와 증류된 해석만 남긴다.

## History

- v1(pre-rewrite) 구현 상세: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-v1-2026-07-11|archived-mj-rl-v1-2026-07-11]]
- v1 이전 reflect 이력: [[AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03|archived-mj-rl-reflect-history-2026-07-03]]
- 삭제 오판 교훈(구조 변경 이후에도 원칙은 유효): [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]]

## Links

- raw repo: AI-Sessions/raw/repos/mj-rl.md
- checked commit: c890973 (branch `refactor/mj-rl-v2`)
- previous checked commit (v1, pre-rewrite): ffbb2c3 (`master`)
- related RAL2025 reference (hyperparameter parity 확인): [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]
- related raw papers: 2024-lee-footstep-planning-rl.pdf, 2025-lee-humanoid-arm-cam-marl.pdf
