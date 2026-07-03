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

`source/tasks/body_transformer_velocity/mapping.py` 리팩터:

- `OBS_LAYOUT`으로 flat observation 순서를 먼저 선언.
- `BASE_TOKEN_ROLES`, `FOOT_TOKEN_ROLES`, `JOINT_ORDER`, `JOINT_DIMS`로 token layout을 별도 선언.
- `Mapping.create_observation()`은 `base / joint / foot` 생성 흐름만 보이게 두고, slice/cat 세부 로직은 `_base_observation`, `_all_joint_observations`, `_foot_observation`, `_role_values`로 분리.
- `build_g1_velocity_mapping()` factory는 파일 하단에 둔다.

## Links

- related source: AI-Sessions/wiki/research/sources/mj-rl.md
- related error note: AI-Sessions/wiki/harness/errors/mjlab-errors.md
