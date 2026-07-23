---
type: source
date: 2026-07-10
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - graph-policy
source: AI-Sessions/raw/repos/isaac-humanoid.md
---

# 구현 분석: isaac_humanoid

## Summary

사용자의 실험용 IsaacLab 레포(`/home/frlab/isaac_humanoid`)다. RAL2025
(LearningHumanoidArmMotion) MIT Humanoid full modular baseline을 IsaacLab
2.3.2 + `casadi-on-gpu` + 로컬 modular PPO runner로 재배선한 것을 baseline으로
유지하면서, mj_rl의 morphology GCN CTDE 구조(`wbc_momentum` 계열)를 이 레포의
변수명/패키지 경계에 맞춰 이식하는 것이 목표다. RAL2025의 IsaacLab fork/커스텀
`rsl_rl` fork/`cusadi`는 의도적으로 벤더링하지 않는다. checked commit
`4351ffb`("init") — 실제 작업 대부분은 이 위 uncommitted 변경으로 존재(2026-07-10
세션 기준).

## 핵심 파일

- `AGENTS.md`(레포 루트): 이 레포 전용 에이전트 진입 문서. 목적/스코프/rsl_rl
  버전 고정/모듈러 포팅 계획/casadi-on-gpu 빌드 계약/경계 규칙을 담는다.
- `source/tasks/ral2025_mit/ral2025_mit_env_cfg.py`: RAL2025 baseline env cfg +
  `RAL2025MitHumanoidGcnCTDEEnvCfg`(observation group만 교체, 나머지는 상속).
- `source/tasks/ral2025_mit/gcn_mapping.py`: MIT Humanoid 전용 flat-obs →
  semantic morphology node mapping. leg/arm 그래프, C2 mirror(`FLAT_OBS_MIRROR`),
  action mirror를 소유.
- `source/tasks/ral2025_mit/agent/rsl_rl_gcn_ctde_ppo_cfg.py`: leg/arm
  `MorphologyGCNActor`/`Critic` PPO cfg. PPO 하이퍼파라미터는 baseline MLP task와
  숫자까지 동일하게 유지(비교 실험 의도).
- `source/modules/{primitives,models,rl}`: mj_rl에서 이식한 재사용 GCN/PPO 코드.
  `modules/primitives/gcn.py`는 mj_rl과 byte-identical(2026-07-10 diff 확인).
- `source/utils/`: task-agnostic 위치에 둔 keyboard teleop/live plot/code-snapshot/
  analysis recorder(RAL2025 원본에서 포팅) + `morphology_utils.py`(mj_rl에서
  포팅한 signed-permutation involution 유틸).
- `docs/decisions/`: 재사용 가능한 GCN 설계 축(관측 feature, linear layer 층수,
  GCN 폭/adjacency bias, C2 mirror 계약) 하나당 문서 하나. `docs/experiments/`:
  task별 실행 계약/결과. (repo-local, wiki에 내용 복붙하지 않음 — 필요하면 직접 열어본다.)

## 가져올 패턴

- [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]의
  "GCN 관절 노드 관측을 mirror-safe하게 설계하기" 항목 참고 — 여기서 나온
  일반 원칙(pseudovector 관절 feature의 결합 부호, 코사인 내적 소거, 수치적
  equivariance 검증)이 이 레포에서 처음 도출·검증됐다.
- Observation 안정성: raw error(목표-실측)나 가속도 기반(dCAM) feature는 평소
  거의 0이다가 스파이크하는 통계라 online normalization과 상성이 나쁘다 — capacity
  (raw 상태)/cosine(bounded) 조합이 더 안전하다는 판단을 `docs/decisions/2026-07-10-node-obs-features.md`에
  근거와 함께 기록해 둠.
- `docs/decisions/` vs `docs/experiments/` 분리: "이 축에서 뭘 고를 수 있고 지금
  뭘 골랐나"(decisions, ablation 축 단위)와 "이번 실행에 뭘 했고 결과가 뭐였나"
  (experiments, task/run 단위)를 분리해서 문서 중복과 혼동을 줄인다. 다른 레포에도
  적용해볼 만한 문서화 패턴.

## 주의점

- `RAL2025MitHumanoidGcnCTDEEnvCfg`는 baseline의 `rewards`/`events`/`terminations`를
  **상속만 하고 오버라이드 안 함** — 즉 PPO 비교 실험에서 reward/외란은 항상
  동일하다(재확인 필요 없음, 클래스 상속 자체가 보장). 다만 `observations`만
  교체하므로, 새 obs term을 leg/arm 양쪽에 실수로 공유시키면(공유 flat obs
  group) baseline이 의도적으로 갈라둔 정보(예: arm actor는 velocity_commands/phase를
  원래 못 봄)가 새 아키텍처에서만 새어 들어갈 수 있다 — 2026-07-10에 실제로
  이 버그를 발견/수정했다(`docs/decisions/2026-07-10-node-obs-features.md`).
- `casadi-on-gpu` 커널은 이 레포 전용 MIT Humanoid DOF(NQ=25/NV=24)로 고정
  빌드된다 — mj_rl의 G1 커널과 별개 설치본이며, 두 레포가 같은 conda env를
  공유하면 mj_rl에서 실제로 겪은 것과 같은 종류의 DOF mismatch 사고(설치된 `.so`가
  빌드 시점 DOF에 고정되는 문제)가 날 수 있다 — auto-memory
  `casadi-on-gpu-kernel-dof-state`에 기록돼 있다(wiki 노트 아님, agent memory).
- `MorphologyTokenizer`는 flat obs 전체(base_group)에 `EmpiricalNormalization`을
  node로 쪼개기 **전에** 적용한다(`morphology_gcn_actor.py`). 즉 raw feature의
  물리 단위가 달라도(관절각 vs 각운동량 vs cosine) 각 채널이 이미 정규화된 뒤
  linear layer에 들어간다 — "여러 feature를 한 층에 태우면 불안정하지 않냐"는
  질문에 대한 답이 이미 코드에 있었다.
- 이 레포에는 아직 wiki에 자세한 실험 결과가 없다 — `docs/experiments/2026-07-10-gcn-ctde.md`가
  현재 유일한 실행 기록이고, 첫 GCN CTDE 학습은 이 세션의 observation 재설계
  직후 막 시작하는 단계다.

## Relations

- raw repo: AI-Sessions/raw/repos/isaac-humanoid.md
- checked commit: 4351ffb ("init", `main`) + 2026-07-10 uncommitted 작업
- 관련 source: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] (GCN/casadi-on-gpu 원본 구현)
- 관련 source: [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]] (RAL2025 원본 baseline)
- 패턴: [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]
- repo-local 상세: `/home/frlab/isaac_humanoid/AGENTS.md`, `docs/decisions/`, `docs/experiments/`
