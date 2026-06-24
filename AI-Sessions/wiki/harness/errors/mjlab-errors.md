---
tags: [tier/low]
type: error
date: 2026-06-24
status: active
applies_to: mjlab, mujoco_warp, mj_rl, humanoid footstep planning
replaced_by:
severity: high
source: mj_rl repo NOTES.md (pinned commit 017c485)
related_experiments:
---

# Error: whole-body CoM 속도는 `subtreelinvel` 센서로만 얻는다

## Symptom

LIPM/XCoM footstep planner가 발자국을 미묘하게 어긋나게 찍음. 스윙 중 발끝 궤적이 안쪽/바깥쪽으로 휨. "거의 맞지만 스윙 순간마다 편향"이라 진단이 어려웠다.

## Root Cause

mjlab `EntityData`에서 `com`이 붙은 속도 property는 **전부 단일 body(pelvis) 강체 속도**다. `com` 이름은 "그 body의 관성 중심점을 기준점으로 잰다"는 뜻이지 whole-body CoM이 아니다.

- `root_com_lin_vel_w/b`, `root_com_vel_w` → pelvis CoM 점에서 잰 **pelvis** 속도
- `body_com_vel_w` → 각 body 자기 CoM 속도 (per-body)

검증: pelvis 정지 + 다리 5 rad/s 스윙 → `root_com_lin_vel = [0,0,0]`이지만 진짜 CoM 속도 `subtree_linvel = [-0.76, 0, -0.05]`. 다리를 앞으로 휘두르면 pelvis가 멈춰 있어도 전신 CoM은 뒤로 밀린다.

진짜 whole-body CoM 속도는 `data.subtree_linvel[:, root_body_id]`인데, 이 값은 `mj_subtreeVel` 패스가 돌아야 채워지고, 그 패스는 **subtree 센서(subtreelinvel/subtreeangmom)가 모델에 있을 때만** 돈다. 없으면 조용히 0. 특히 mujoco_warp(GPU)는 `mj_subtreeVel`을 직접 호출할 수 없어 **센서 등록이 유일한 트리거**다.

footstep에 치명적인 이유: `eICP = x_CoM + v_CoM/ω₀`, `1/ω₀ ≈ 0.26`이라 속도 오차가 0.26배로 발자국 위치에 직접 들어간다. pelvis vs CoM 속도 차이는 유각 다리가 가장 빠른 step 순간에 최대가 된다.

## Trigger

- pelvis 속도 property를 whole-body CoM 속도로 착각할 때.
- mujoco_warp/mjlab에서 subtree 센서 없이 `subtree_linvel` 값을 읽을 때.
- raw `g1.xml` 29-DOF와 waist 삭제 26-DOF 모델의 mapping 차이를 확인하지 않을 때.

## Fix

whole-body CoM 위치와 속도는 root subtree 기준 `subtree_com` / `subtree_linvel`로 통일한다. mujoco_warp/mjlab 모델 spec에는 `subtreelinvel` 센서를 등록한다.

## Prevention Rule

- whole-body CoM 위치·속도는 `subtree_com` / `subtree_linvel`(root_body_id)로 통일해서 읽는다. `root_*_com_*`를 CoM 속도로 쓰지 않는다.
- mujoco_warp/mjlab에서는 spec에 `subtreelinvel`(필요시 `subtreeangmom`) 센서를 반드시 등록한다. 없으면 0이 조용히 들어온다.
- 우리 모델은 waist 삭제(26-DOF)라 raw `g1.xml`(29-DOF)과 waist가 움직이는 상태에서는 subtree 값이 다를 수 있다. DOF mapping 주의.

## Related Experiments

- 아직 별도 experiment 노트 없음.

## Links

- source: mj_rl repo NOTES.md, commit 017c485
- 관련 source note: research/sources/mj-rl.md
- 관련 concept: research/concepts/lipm.md (eICP = x_CoM + v_CoM/ω₀)
