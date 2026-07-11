---
tags: [tier/low]
type: error
date: 2026-06-24
status: active
applies_to: mjlab, mujoco_warp, mj_rl, humanoid footstep planning
replaced_by:
severity: high
source: mj_rl repo NOTES.md (checked commit 017c485); mjlab_env installed package inspection (2026-06-25)
related_experiments: AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md
---

# mjlab Errors

## Error: class-based event term에 `reset`이 없으면 `debug_vis`가 조용히 안 불림

### Symptom

`graph_mimic_29d`에 새 class-based event(`GraphOverlayEvent`)를 만들어 `mode="startup"`으로 등록하고 `debug_vis(self, visualizer)`를 구현했다. Native viewer는 정상 실행되고 다른 debug overlay(motion tracking의 "ghost" mesh)는 R 키로 잘 토글되는데, 새로 만든 노드-엣지 오버레이만 아무 에러 없이 전혀 안 보였다.

### Root Cause

`mjlab/managers/event_manager.py`의 `EventManager._prepare_terms()`가 `debug_vis()`용 dispatch 목록(`self._mode_class_term_cfgs`)에 term을 넣는 조건은 `hasattr(term_cfg.func, "reset") and callable(term_cfg.func.reset)`이다. 이 조건은 **event의 `mode`(`startup`/`step`/`interval`/`reset`)와 완전히 무관**하다 — `mode="startup"`이라고 자동으로 들어가지 않는다. `EventManager.debug_vis()`는 이 `_mode_class_term_cfgs`만 순회하므로, `reset` 메서드가 없는 class는 `debug_vis`를 구현해도 절대 호출되지 않는다.

더 헷갈리게 만드는 지점: `env.event_manager.get_term_cfg("name").func`로는 이 인스턴스를 문제없이 조회할 수 있다. 이건 `_mode_class_term_cfgs`와는 **별도의 일반 조회 경로**라서, "인스턴스가 존재하고 정상 생성됐다"는 확인만으로는 "실제 뷰어가 매 프레임 이걸 호출한다"는 걸 검증하지 못한다. 실제로 `term.debug_vis(FakeViz())`를 직접 호출해 테스트하면 이 필터를 완전히 우회하므로 "정상 동작"으로 잘못 확인하게 된다.

### Trigger

- 새 class-based event(특히 시각화 전용, `__call__`이 사실상 no-op인 것)를 만들면서 `reset`을 안 만들 때.
- `debug_vis`를 직접 호출해서 테스트하고, 실제 dispatch 경로(`env.update_visualizers(visualizer)` 또는 `event_manager.debug_vis(visualizer)`)로는 검증하지 않을 때.
- `HandForceEvent`(FALCON)처럼 이미 `reset`이 있는 class를 참고했지만, `reset`이 debug_vis 등록에 필요하다는 사실 자체를 몰랐을 때(그 클래스는 `reset`이 실제 per-env 상태 초기화 때문에 있는 거라, "왜 있는지" 목적이 달라서 이 조건과 연결하기 어렵다).

### Fix

빈 `reset(self, env_ids=None) -> None: pass`만 추가하면 된다. 실제 per-env 상태를 초기화할 필요가 없어도, `hasattr` 체크를 통과시키는 목적만으로 존재해도 무방하다.

### Prevention Rule

- mjlab에서 시각화 전용 class-based event(`debug_vis`만 의미 있고 `__call__`은 사실상 no-op)를 새로 만들 때는 `reset` 메서드를 (내용이 없어도) 반드시 같이 만든다.
- debug_vis 관련 기능을 테스트할 때는 `term.debug_vis(visualizer)`를 직접 부르지 말고, 실제 뷰어가 쓰는 경로인 `env.update_visualizers(visualizer)`를 통해서 검증한다 — 그래야 `_mode_class_term_cfgs` 필터링까지 같이 검증된다.
- "에러 없이 조용히 안 보인다"는 증상이 나오면, 먼저 그 term이 `EventManager._mode_class_term_cfgs`에 실제로 들어갔는지(`hasattr(func, "reset")`)부터 확인한다.

### Related Experiments

- `AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic.md` (node-edge graph debug overlay 구현 중 발견)

### Links

- 구현 source note: `AI-Sessions/wiki/research/sources/mj-rl.md`
- 참고(이미 `reset`을 갖고 있어 이 문제를 겪지 않은 선례): `source/tasks/falcon/mdp/events.py`의 `HandForceEvent`

## Error: whole-body CoM 속도는 `subtreelinvel` 센서로만 얻는다

### Symptom

LIPM/XCoM footstep planner가 발자국을 미묘하게 어긋나게 찍음. 스윙 중 발끝 궤적이 안쪽/바깥쪽으로 휨. "거의 맞지만 스윙 순간마다 편향"이라 진단이 어려웠다.

### Root Cause

mjlab `EntityData`에서 `com`이 붙은 속도 property는 **전부 단일 body(pelvis) 강체 속도**다. `com` 이름은 "그 body의 관성 중심점을 기준점으로 잰다"는 뜻이지 whole-body CoM이 아니다.

- `root_com_lin_vel_w/b`, `root_com_vel_w` → pelvis CoM 점에서 잰 **pelvis** 속도
- `body_com_vel_w` → 각 body 자기 CoM 속도 (per-body)

검증: pelvis 정지 + 다리 5 rad/s 스윙 → `root_com_lin_vel = [0,0,0]`이지만 진짜 CoM 속도 `subtree_linvel = [-0.76, 0, -0.05]`. 다리를 앞으로 휘두르면 pelvis가 멈춰 있어도 전신 CoM은 뒤로 밀린다.

진짜 whole-body CoM 속도는 `data.subtree_linvel[:, root_body_id]`인데, 이 값은 `mj_subtreeVel` 패스가 돌아야 채워지고, 그 패스는 **subtree 센서(subtreelinvel/subtreeangmom)가 모델에 있을 때만** 돈다. 없으면 조용히 0. 특히 mujoco_warp(GPU)는 `mj_subtreeVel`을 직접 호출할 수 없어 **센서 등록이 유일한 트리거**다.

footstep에 치명적인 이유: `eICP = x_CoM + v_CoM/ω₀`, `1/ω₀ ≈ 0.26`이라 속도 오차가 0.26배로 발자국 위치에 직접 들어간다. pelvis vs CoM 속도 차이는 유각 다리가 가장 빠른 step 순간에 최대가 된다.

### Trigger

- pelvis 속도 property를 whole-body CoM 속도로 착각할 때.
- mujoco_warp/mjlab에서 subtree 센서 없이 `subtree_linvel` 값을 읽을 때.
- raw `g1.xml` 29-DOF와 waist 삭제 26-DOF 모델의 mapping 차이를 확인하지 않을 때.

### Fix

whole-body CoM 위치와 속도는 root subtree 기준 `subtree_com` / `subtree_linvel`로 통일한다. mujoco_warp/mjlab 모델 spec에는 `subtreelinvel` 센서를 등록한다.

### Prevention Rule

- whole-body CoM 위치·속도는 `subtree_com` / `subtree_linvel`(root_body_id)로 통일해서 읽는다. `root_*_com_*`를 CoM 속도로 쓰지 않는다.
- mujoco_warp/mjlab에서는 spec에 `subtreelinvel`(필요시 `subtreeangmom`) 센서를 반드시 등록한다. 없으면 0이 조용히 들어온다.
- 우리 모델은 waist 삭제(26-DOF)라 raw `g1.xml`(29-DOF)과 waist가 움직이는 상태에서는 subtree 값이 다를 수 있다. DOF mapping 주의.

### Related Experiments

- 아직 별도 experiment 노트 없음.

### Links

- source: mj_rl repo NOTES.md, commit 017c485
- 관련 source note: research/sources/mj-rl.md
- 관련 paper: AI-Sessions/wiki/research/papers/2024-lee-footstep-planning-rl.md (eICP = x_CoM + v_CoM/ω₀)

## Error: built-in task와 runtime asset requirement를 구분하지 않음

### Symptom

사용자가 "conda의 mjlab 내장 task라서 바로 될 것 같다"고 짚기 전까지, G1 tracking task가 설치된 `mjlab_env`에 실제로 등록돼 있는지 직접 확인하지 않고 `motion-file` 명령 형태를 먼저 제시했다. 결과적으로 "built-in task가 없다"는 식의 인상을 줄 수 있는 답이 됐다.

### Root Cause

task registry 확인과 runtime asset 확인을 한 단계로 뭉뚱그렸다. 실제 상태는 둘로 나뉜다.

- built-in task는 conda `mjlab_env`에 등록돼 있다: `Mjlab-Tracking-Flat-Unitree-G1`, `Mjlab-Tracking-Flat-Unitree-G1-No-State-Estimation`.
- 그러나 tracking train script는 `motion_file` 기본값이 빈 문자열이라, 학습 실행 시 local `--env.commands.motion.motion-file` 또는 W&B `--registry-name`을 요구한다.
- demo script는 별도 경로로 pretrained checkpoint와 default motion을 자동 다운로드한다.

### Fix

명령어를 주기 전에 설치된 패키지의 실제 registry와 CLI 분기를 확인한다.

```bash
python - <<'PY'
from mjlab.tasks.registry import list_tasks, load_env_cfg
print(list_tasks())
cfg = load_env_cfg("Mjlab-Tracking-Flat-Unitree-G1")
print(repr(cfg.commands["motion"].motion_file))
PY
```

그리고 train/demo를 구분해 답한다.

- demo: `python -m mjlab.scripts.demo`만으로 default assets 다운로드 후 실행 가능.
- train: built-in task id는 바로 쓰되, motion source는 명시해야 한다.

### Prevention Rule

- mjlab 명령어를 줄 때는 `conda env` 안의 installed package를 직접 import해서 `list_tasks()`와 task default cfg를 확인한다.
- "내장 task"와 "실행에 필요한 외부 asset/checkpoint/motion file"을 분리해 설명한다.
- `--help` 출력만 보지 말고 train/play/demo script의 실제 분기 조건을 읽는다.

### Related Experiments

- AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md

## Error: optional/branch-preserved 자산을 dead code로 오판해 삭제

### Symptom

`/home/frlab/mj_rl` code review에서 `source/assets/cuda/`와 `scripts/casadi_on_gpu/`가 active BoT velocity task에서 import되지 않는다는 이유로 stale centroidal remnant로 판단하고 삭제했다. 사용자가 "centroidal 부분 제거하지마"라고 지적해 즉시 `git restore -- source/assets/cuda scripts/casadi_on_gpu`로 복구했다.

### Root Cause

"현재 active task에서 import되지 않음"을 "삭제 가능"으로 과잉 일반화했다. 이 repo에서는 branch continuity와 optional workflow 자산이 working tree에 보존될 수 있다.

- active runtime path: BoT velocity task.
- preserved optional asset path: centroidal/CasADi CUDA kernels and helper scripts.
- 삭제 권한 기준: import graph가 아니라 사용자의 보존 의도, branch/workflow 역할, 문서화된 optional path를 함께 확인해야 함.

### Trigger

- dead-code review 중 `rg` import 결과만 보고 보존 자산을 stale로 분류할 때.
- "현재 branch active task"와 "보존해야 하는 optional/develop workflow"를 구분하지 않을 때.
- generated kernel이나 helper script가 크고 noisy해서 정리 욕구가 강할 때.

### Fix

삭제한 파일을 즉시 복구하고, README를 "active BoT task에서는 import되지 않지만 centroidal/CasADi CUDA 자산은 보존"으로 수정했다. 구현 상태와 교훈은 research/sources/mj-rl.md의 "2026-07-01 Reflect: BoT master cleanup + graph/token visualization review"에 둔다.

### Prevention Rule

- dead-code review에서 삭제 후보는 `active unused`, `optional preserved`, `obsolete`, `unknown` 네 상태로 먼저 분류한다.
- optional/branch-preserved 가능성이 있는 자산은 삭제하지 말고 README/source note에 역할을 명시한다.
- 특히 `assets/`, generated kernels, external install scripts, branch-specific experiment bundles는 사용자의 명시 승인 없이는 제거하지 않는다.

### Related Experiments

- 없음. 구현/운용 reflect 사례.

### Links

- 관련 source note: AI-Sessions/wiki/research/sources/mj-rl.md

## Error: native play Ctrl-C가 viewer sync에서 즉시 빠지지 않음

### Symptom

`/home/frlab/mj_rl`의 `scripts/play.py` 또는 `scripts/play_keyboard.py`를 native viewer로 실행한 뒤 Ctrl-C를 눌러도 프로세스가 바로 종료되지 않는 현상이 있었다.

### Root Cause

mjlab 기본 `BaseViewer._sigint_handler`는 `_interrupted=True`만 세운다. 정상적으로는 main loop가 다음 조건 평가에서 빠지고 `finally: close()`를 호출하지만, native MuJoCo viewer가 `sync()`/render backend 경로에 걸려 있으면 loop condition까지 돌아오지 못할 수 있다.

### Fix

repo-local `scripts/helper/shared.py`에 `patch_viewer_sigint_close()`를 두고, `play.py`와 `play_keyboard.py` 시작 시 적용한다. Ctrl-C handler에서 native viewer handle이 있으면 먼저 `close()`한 뒤 mjlab 기본 handler를 호출한다. `BaseViewer.run`의 기존 `finally: close()` cleanup은 그대로 유지한다.

### Prevention Rule

- viewer 종료 문제를 고칠 때 `BaseViewer.run` 전체를 monkey patch하지 않는다.
- native backend handle close처럼 막힌 경로를 깨우는 최소 hook만 둔다.
- Viser는 브라우저 탭 close로 종료되지 않는 것이 upstream 동작이다. native shutdown 문제와 섞어 해결하려 하지 않는다.

### Links

- 구현 source note: AI-Sessions/wiki/research/sources/mj-rl.md
