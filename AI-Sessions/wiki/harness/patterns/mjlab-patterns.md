---
tags: [tier/low]
type: pattern
date: 2026-07-04
status: active
applies_to: mj_rl, mjlab, humanoid RL implementation
---

# mjlab Patterns

`/home/frlab/mj_rl` 구현 작업 때 읽는 도메인 패턴이다. granular 작업 로그가 아니라, 이후 코드 생성·리팩터에서 반복 적용할 구조 규칙만 둔다.

## Positive Pattern — sequence-first code generation

`mj_rl`에서 새 코드를 만들거나 기존 코드를 리팩터할 때는 **실행 흐름/블록도/데이터 파이프라인 순서대로 파일을 구성**한다. 독자가 위에서 아래로 읽으면 `input → transform → model/control → output/factory` 흐름이 자연스럽게 따라와야 한다.

### Rule

1. 코드 상단에 도메인 상수나 layout 선언을 먼저 둔다.
2. 그다음 schema/config, adapter/core class, factory/entrypoint 순서로 배치한다.
3. 각 큰 단계 앞에는 짧은 sequence 주석을 둔다.
4. helper 함수는 자신이 보조하는 단계 근처에 둔다.
5. 이름은 `layout`, `token layout`, `mapping adapter`, `factory`, `encoder`, `detokenizer`처럼 실제 역할을 드러내게 쓴다.
6. 동작 변경이 목적이 아니면 public surface와 테스트 기대 shape는 유지하고, 리팩터 후 smoke/test를 실행한다.

### Comment Style

파일 단위 섹션은 아래처럼 쓴다.

```python
# ---------------------------------------------------------------------------
# 1. Flat observation layout
# ---------------------------------------------------------------------------
```

클래스/함수 내부의 실행 단계는 아래처럼 쓴다.

```python
# ---------------------------
# 1. Observation -> node tokens
# ---------------------------
```

주석은 장식이 아니라 **읽는 순서와 책임 경계**를 표시해야 한다. 짧은 파일이나 이미 자명한 함수에는 과하게 넣지 않는다.

### Good Example

`source/tasks/bot_velocity/mapping.py` 리팩터:

- `OBS_LAYOUT`으로 flat observation 순서를 먼저 선언.
- `BASE_TOKEN_ROLES`, `FOOT_TOKEN_ROLES`, `JOINT_ORDER`, `JOINT_DIMS`로 token layout을 별도 선언.
- `Mapping.create_observation()`은 `base / joint / foot` 생성 흐름만 보이게 두고, slice/cat 세부 로직은 `_base_observation`, `_all_joint_observations`, `_foot_observation`, `_role_values`로 분리.
- `build_g1_velocity_mapping()` factory는 파일 하단에 둔다.

## Positive Pattern — generic runner, specific model

Multi-actor/multi-critic 실험은 runner class를 새로 늘리지 않고, actor/critic unit config로 표현한다. 네트워크 family는 `modules.models`, orchestration은 `modules.rl`, tensor building block은 `modules.primitives`가 소유한다.

### Rule

1. 새 GCN/Transformer/MLP variant는 먼저 `modules.primitives` 또는 `modules.models`에 둔다.
2. actor 수, critic sharing, reward/action routing은 `MultiAgentRlCfg`로 표현한다.
3. task package는 env/mapping/reward/action 계약만 소유한다.
4. 옛 import path를 되살리는 shim보다 새 경로로 호출부를 고친다.

## Positive Pattern — repo-local naming contract first

`/home/frlab/mj_rl`에서 새 관측 key, tensor 이름, 함수 이름을 만들 때는 먼저 `/home/frlab/mj_rl/네이밍.md`를 따른다. 로컬 약어를 즉석에서 붙이지 말고, 물리량 의미와 기존 public key 계약을 먼저 맞춘다.

### Rule

1. `CAM_des`의 `_des`는 desired target 의미로만 쓴다. derivative 또는 delta 의미로 재사용하지 않는다.
2. per-joint WBC momentum token처럼 `k_j^T e_hat`, `dot{k}_j^T e_hat`를 scalar로 넣을 때는 현재 물리량을 `cam`, 시간미분 계열을 `dcam`으로 둔다.
3. `_c`, `_d` 같은 formula/local shorthand는 네이밍 문서에 없는 한 public observation key나 mapping term에 쓰지 않는다.
4. 이름을 바꾸면 alias를 남기지 않고 observation cfg, mapping, cache, test call site를 함께 고친다.
5. 헷갈리면 suffix를 먼저 붙이지 말고 “이 값이 desired/ref/cmd/current/derivative 중 무엇인가”를 말로 풀어본 뒤 이름을 정한다.

## Positive Pattern — one token per domain concept

같은 개념을 가리키는 이름이 layer/파일마다 다른 철자로 흩어지면(예: `leg`/`arm` vs `lower_body`/`upper_body`) grep 한 방으로 도메인 전체를 못 잡고, import-time assert가 조용히 깨진다. 2026-07-11 `mj_rl` v2 domain-token rename에서 이 문제를 두 번 직접 봤다: (1) task 레이어 reward 키가 `leg/`인데 module 상수는 `LOWER_BODY_REWARD_TERMS`라 assert 불일치, (2) `layout.py` 자신이 손-작성 원천(`LEFT_LEG_JOINTS`)과 파생 상수(`LOWER_BODY_JOINTS`)에서 서로 다른 어휘를 씀 — 원천은 "해부학이라 다른 어휘가 정당하다"고 절충했다가, 같은 파일 안에서 leg/arm과 lower_body/upper_body가 섞이는 것 자체가 모순이라는 사용자 지적으로 재통일했다.

### Rule

1. 도메인을 가리키는 토큰은 저장소 전체(주석·docstring 포함)에서 하나로 통일한다. 역할은 접미사로만 파생한다(`{token}_actor`, `{token}_critic`, `{token}_joint_pos`, reward `{token}/...`).
2. "원천 데이터는 해부학적 이름을 써도 된다" 같은 절충은 같은 파일 안에 두 어휘가 공존하는 순간 깨진다 — 절충하지 말고 손-작성 원천부터 도메인 토큰으로 통일한다.
3. 숫자·인덱스·dim처럼 파생 가능한 사실은 단일 owner 모듈(`layout.py`류)이 갖고, 구조(대칭·그래프)를 얹는 모듈(`graph.py`류)이 그 사실을 재수출하지 않는다 — 숫자가 필요한 소비자는 owner를 직접 참조한다. 재수출된 사실은 "이 소비자가 구조에도 의존한다"는 거짓 신호가 되고, owner 모듈보다 무거운 의존성(예: torch)을 끌어온다.
4. rename 전에는 손-작성 원천 이름의 외부 사용처를 `grep`으로 전수 확인한다. 사용처가 0이면 파생값과 함께 안전하게 rename할 수 있다.

## Caution Pattern — viewer shutdown and debug viz

Viewer에서 task별 debug visualization이 무거우면 종료가 늦거나 Viser threadpool close가 물릴 수 있다. Native MuJoCo handle을 SIGINT handler 안에서 직접 닫으면 double-close segfault 위험이 있으므로 피한다.

### Rule

1. command debug visualization은 성능/종료 안정성이 확인된 task만 기본 on으로 둔다.
2. Centroidal 계열처럼 overlay가 무거운 task는 기본 off로 두고 CLI opt-in을 둔다.
3. Viser shutdown은 queued scene/debug update를 끝까지 기다리지 않게 non-blocking close patch를 사용한다.
4. Native viewer는 `BaseViewer.run()`의 `finally: close()` 경로에 맡긴다.

## Links

- related source: AI-Sessions/wiki/research/sources/mj-rl.md
- related error note: AI-Sessions/wiki/harness/errors/mjlab-errors.md
