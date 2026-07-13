---
tags: [tier/low]
type: error
date: 2026-07-12
status: active
applies_to: Isaac Sim 6.0.1 standalone, /home/frlab/isaac_gnn, Robot Assembler/Robot Inspector, custom USD-authored robots (indy7)
replaced_by:
severity: medium
source: /home/frlab/isaac_gnn 세션 (indy7 + Robotiq 2F-140 그리퍼 결합 작업 중 직접 재현·확인)
related_experiments:
---

# Isaac Sim Errors

## Error: `PhysicsArticulationRootAPI`가 있어도 Robot Assembler/Robot Inspector가 로봇을 인식 못 함

### Symptom

커스텀 USD로 직접 만든 로봇(indy7)에 `PhysicsArticulationRootAPI` + `PhysxArticulationAPI`가 정상적으로 붙어 있고(Property 패널에서 `Articulation Enabled` 체크 확인됨), Play를 눌러 PhysX가 실제로 rigid body들을 파싱하는 로그(inertia 경고 등)도 찍히는데, Robot Assembler 창의 `Select Base/Attach Robot` 드롭다운과 `Robot Inspector` 트리 뷰 어디에도 그 로봇이 나타나지 않았다. 같은 스테이지에 있던 (제조사가 배포한) Robotiq 2F-140 그리퍼는 정상적으로 인식됐다.

### Root Cause

Isaac Sim 6.0.1의 `isaacsim.robot.schema` 확장이 정의하는 `IsaacRobotAPI`(그리고 `IsaacLinkAPI`/`IsaacJointAPI`)라는 **Isaac 전용 USD 스키마**가 따로 있다. Robot Assembler/Robot Inspector 같은 툴은 PhysX의 `ArticulationRootAPI`(물리 시뮬레이션용)가 아니라 이 `IsaacRobotAPI`(툴링이 "이건 로봇이다"라고 인식하는 용도)가 붙어 있는지를 기준으로 목록을 채운다. 제조사가 배포한 최신 로봇 에셋(Robotiq 등)에는 이게 이미 붙어 있지만, 직접 authoring한 USD에는 보통 빠져 있다.

두 스키마는 목적이 완전히 다르다 — `ArticulationRootAPI`는 PhysX가 실제로 시뮬레이션할지를 결정하고, `IsaacRobotAPI`는 Isaac Sim의 로봇 관련 UI 툴(Assembler, Inspector 등)이 그 prim을 로봇으로 취급할지를 결정한다. 물리 시뮬레이션이 정상 동작한다고 해서(Play 시 rigid body 관련 로그가 찍힌다고 해서) 툴링에도 인식된다는 보장이 없다.

### Trigger

- URDF importer나 공식 로봇 에셋을 거치지 않고 USD를 직접 authoring(또는 手동으로 physics 스키마만 추가)했을 때.
- Property 패널에서 `ArticulationRootAPI`만 확인하고 "로봇으로 인식되겠지"라고 판단할 때 — 이 확인만으로는 Assembler/Inspector 인식 여부를 검증하지 못한다.

### Fix

대상 prim(articulation root, 보통 로봇 최상위 Xform) 선택 → Property 패널 `+ Add` → 검색창에 `robot` 입력 → **Isaac → Robot API**(`IsaacRobotAPI`) 추가. 이후 Play 한 번 돌리고 Robot Inspector를 새로고침하면 목록에 나타난다.

### Prevention Rule

- 커스텀 USD 로봇이 Robot Assembler/Robot Inspector 목록에 안 뜨면, 먼저 `ArticulationRootAPI` 유무가 아니라 `IsaacRobotAPI`(Add 메뉴 검색창에 `robot`으로 검색) 유무부터 확인한다.
- "물리적으로 동작한다"(Play해서 안 넘어짐, rigid body 로그가 정상적으로 찍힘)와 "Isaac 툴링이 로봇으로 인식한다"는 서로 다른 확인 축이라는 걸 구분한다.

### Related Experiments

- (없음 — /home/frlab/isaac_gnn 워크스페이스, mj_rl 실험 로그와 별개)

---

## Error: `physxArticulation:solverVelocityIterationCount`가 높으면(TGS 씬) 경고 + 관절 불안정에 일조

### Symptom

indy7 + Robotiq 2F-140 그리퍼를 결합한 뒤 스폰하면 팔이 발작하듯 떨렸다("미쳐 날뛴다"). Play 시 콘솔에 다음 경고가 찍힘:

```
Detected an articulation at /World/indy7/indy7_v2 with more than 4 velocity iterations
being added to a TGS scene. The related behavior changed recently, please consult
the changelog. This warning will only print once.
```

### Root Cause

USD에 `physxArticulation:solverVelocityIterationCount = 16`으로 authoring되어 있었다. PhysX의 TGS(Temporal Gauss-Seidel) 솔버는 velocity iteration을 4 이상 주면 최근 버전에서 동작이 바뀌었다고 명시적으로 경고한다 — 필요 이상으로 높은 값이 솔버 안정성/수렴 특성에 영향을 준다.

이 케이스에서 "팔이 발작하는" 주 원인은 사실 관절 드라이브의 `maxForce`(관절당 100 N·m)가 그리퍼 무게까지 지탱하기엔 너무 낮았던 것이었다(원래 값은 팔만 있을 땐 어찌어찌 버텨졌는데, 그리퍼가 손목에 추가되며 필요 토크가 한계를 넘었다). `solverVelocityIterationCount`는 그 자체로 치명적 원인은 아니었지만, 불필요하게 과한 값이라 같이 낮췄다 — TGS 권장치를 벗어난 설정은 다른 불안정 요인(낮은 maxForce, 과도한 stiffness/damping 비율 등)과 겹쳤을 때 문제를 더 키울 수 있다.

### Trigger

- indy7처럼 URDF importer 기본값이 아니라 수작업/변환 과정에서 만들어진 USD에서 physxArticulation 솔버 파라미터가 별 근거 없이 크게 잡혀 있을 때.
- 관절 `drive:angular:physics:maxForce`가 실제 로봇 스펙(진짜 모터 토크)보다 훨씬 낮게 authoring되어 있을 때 — 특히 로봇 끝단에 그리퍼 등 추가 페이로드를 붙이면 잠재해있던 토크 부족이 드러난다.

### Fix

- `physxArticulation:solverVelocityIterationCount`를 4 이하로 낮춘다 (해당 USD에서 16 → 4로 수정, `solverPositionIterationCount`는 그대로 32 유지).
- 근본 원인인 낮은 `maxForce`는 별도로 로봇 실제 스펙에 맞게 올려야 한다(이 세션에서는 아직 미조치 — 후속 작업 필요).

### Prevention Rule

- "관절이 떨린다/발작한다" 증상이 나오면 확인 순서: (1) 각 관절의 `maxForce`가 지탱해야 할 무게(끝단 페이로드 포함)를 감당할 만큼 큰지, (2) `stiffness`/`damping` 비율이 과소감쇠(underdamped)는 아닌지, (3) `solverVelocityIterationCount`가 TGS 권장치(≤4)를 넘는지 — 이 순서로 좁혀간다. velocity iteration 경고만 보고 그것부터 고치면 진짜 원인(토크 부족)을 놓칠 수 있다.
- 로봇 USD에 그리퍼 등 끝단 페이로드를 새로 추가할 때는, 기존에 "그럭저럭 버텨지던" `maxForce` 값이 새 무게에서도 충분한지 재검토한다.

### Related Experiments

- (없음 — /home/frlab/isaac_gnn 워크스페이스)

### Links

- 관련 발견(같은 세션): 위 "IsaacRobotAPI" 에러 항목
