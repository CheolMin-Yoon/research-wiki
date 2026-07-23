---
name: jax-mpc
description: Design, port, implement, review, or debug nonlinear MPC and SQP in JAX using a WarpMPC-style stagewise uncondensed fixed-sparsity formulation. Use for JAX_MPC work involving decision and parameter layouts, CasADi stage functions, packed CSC Hessian/Jacobian values, plan/compile/runtime/result seams, jit/vmap/scan placement, OSQP/QDLDL settings, warm starts, receding-horizon ownership, optimized footholds, dtype selection, or C++/NumPy-to-JAX parity tests. Do not use for generic JAX neural-network or RL code.
---

# JAX MPC

설명을 크게 한 번에 만들지 말고, 검증 가능한 수직 단계 하나씩 진행한다. NumPy/C++ oracle이 맞기 전에 sparse/JAX 최적화로 넘어가지 않는다.

## 시작 절차

1. 대상 저장소의 `AGENTS.md`와 coding contract를 먼저 읽는다.
2. 현재 state, control, parameter, decision 순서와 각 shape를 실제 코드에서 확인한다.
3. 작업을 `condensed validation`, `stagewise formulation`, `plan`, `compile`, `runtime`, `result` 중 하나로 분류한다.
4. WarpMPC 동작을 근거로 삼을 때는 [references/warpmpc-architecture.md](references/warpmpc-architecture.md)를 읽고, 로컬 HEAD가 기록된 commit과 다르면 관련 코드를 다시 확인한다.
5. 모델링에는 [references/stagewise-sqp.md](references/stagewise-sqp.md), 변환·dtype에는 [references/jax-execution.md](references/jax-execution.md), 구현 검증에는 [references/validation.md](references/validation.md)를 필요한 경우에만 읽는다.

## 사용자와 진행하는 단위

한 단계는 다음 순서로만 설명하거나 구현한다.

1. 수식과 그 단계의 목적
2. 프로젝트 변수명
3. 입력·출력 shape
4. 원본 C++/NumPy/WarpMPC 대응 위치
5. 통과해야 할 최소 test

사용자가 큰 구현을 명시적으로 요청하지 않으면 한 번에 100줄 이상의 코드를 만들지 않는다. 검토만 요청하면 파일을 수정하지 않는다.

## 구조 선택

- C++ 원본 재현과 수식 검산에는 condensed NumPy 경로를 oracle로 유지한다.
- JAX 병렬 production solver에는 stagewise uncondensed sparse form을 기본으로 선택한다.
- condensed prediction matrix와 stagewise dynamics defect를 같은 solver 내부 표현으로 섞지 않는다.
- 공통 seam은 순수한 `state, control, params -> next_state/cost/constraints`로 둔다. runtime trajectory, SQP iterate, warm start는 이 함수 밖에서 소유한다.

## 필수 구현 순서

### 1. 수치 계약 고정

- state/control/parameter/decision의 순서와 frame suffix를 문서와 테스트로 고정한다.
- horizon, stage 수, 모든 array shape, dtype을 compile 동안 고정한다.
- gait/contact는 값이 바뀌는 parameter로 두되 가능한 모든 derivative 위치는 symbolic graph에 남긴다.

### 2. NumPy oracle 검증

- 단일 stage dynamics를 먼저 검증한다.
- condensed prediction 결과와 반복 rollout의 미래 state가 같은지 비교한다.
- 입력 불변성과 출력 non-aliasing을 확인한다.
- float64에서 원본 C++ 수식과 맞춘 뒤 float32 허용 오차를 별도로 정한다.

### 3. Stage 함수 정의

- 대표 배치는 `z_k = [x_k, u_k, optional carried variables]`로 둔다. 이는 프로젝트 계약이며 WarpMPC가 강제하는 배치는 아니다.
- nonterminal 함수를 `(z_k, z_{k+1}, p_k) -> cost, g, l, u`로 만든다.
- terminal 함수를 `(z_N, p_N) -> cost, g, l, u`로 만든다.
- 첫 stage에 `x_0 - x_measured = 0`, 각 transition에 `x_{k+1} - f(x_k, u_k, p_k) = 0`을 넣는다.
- 같은 수식의 middle stage는 같은 stage-function 객체를 재사용한다.

### 4. Problem과 Plan 생성

- `first + repeated middle + terminal` 순서를 구성한다.
- CPU plan 단계에서 stage offset과 Hessian/Jacobian structural nonzero를 전역 CSC pattern으로 합친다.
- local derivative nonzero를 global packed 위치로 보내는 scatter map을 만든다.
- P/A/KKT pattern, constraint row 종류, QDLDL symbolic factorization을 runtime 전에 고정한다.

### 5. Compile

- backend, dtype, fixed QP iteration 수, line-search 후보 수를 compile 인자로 고정한다.
- dtype은 mutable 전역 설정으로 바꾸지 않는다. WarpMPC처럼 compile 경계에서 `np.dtype`로 정규화하고 JAX dtype으로 변환한다.
- float64이면 JAX compile 전에 `jax_enable_x64=True`를 설정한다. production은 검증 후 float32를 우선 검토한다.

### 6. Runtime과 Result

- runtime에는 batched decision/parameter/warm state와 `p_values`, `a_values`, `q`, `l`, `u`만 전달한다.
- 전체 dense P/A를 매 tick 재생성하지 않는다.
- outer NMPC가 measured state, reference, gait parameters, trajectory shift, first-control 적용, NLP iterate와 QP warm state를 소유한다.
- 다음 NLP iterate는 SQP result의 `z_next`에서 읽는다. OSQP warm state의 `z`와 혼동하지 않는다.

## JAX 변환 규칙

- `jit`: NLP evaluation, sparse linearization, QP solve, SQP step처럼 가장 바깥의 안정된 계산에 적용한다.
- `vmap`: batch, 같은 stage 함수가 반복되는 stage 축, 고정 line-search 후보처럼 서로 독립인 축에 적용한다.
- `scan`: OSQP 고정 ADMM iteration, QDLDL 내부 순차 계산, condensed rollout처럼 실제 시간 재귀가 있는 축에 적용한다.
- stagewise dynamics는 모든 `x_k`가 decision에 있으므로 defect 평가를 stage 축으로 `vmap`할 수 있다. 이것을 recurrent rollout과 혼동하지 않는다.
- Python mutation, input alias, runtime class-state 갱신을 jitted 수치 함수 안에 넣지 않는다.

## Foothold와 contact 규칙

- 최적화할 미래 foothold를 reference parameter로 바꾸지 않는다.
- 한 착지점이 여러 stage에서 공유되면 carried state로 stage variable에 포함하고 propagation equality를 두거나, stage별 복제 변수 사이에 equality를 둔다.
- contact/gait activation은 고정-shape parameter mask로 값만 바꾼다. branch 때문에 structural nonzero가 생겼다 사라지게 만들지 않는다.
- 먼저 작은 horizon에서 foothold 공유 equality와 support mapping을 dense하게 복원해 검증한다.

## 완료 gate

다음 gate를 순서대로 통과시킨다.

1. C++ 식 ↔ NumPy 단일 stage
2. NumPy prediction matrix ↔ NumPy rollout
3. CasADi stage 값/derivative ↔ JAX 변환 함수
4. packed P/A dense 복원 ↔ 전역 dense reference
5. grouped stage ↔ ungrouped stage
6. float64 ↔ float32 허용 오차
7. single batch ↔ batched 결과
8. warm/cold start 및 receding-horizon shift
9. 필요할 때만 implicit derivative ↔ finite difference

실패한 gate 다음 단계의 성능 최적화는 보류하고, 가장 먼저 어긋난 수식·shape·sparsity 위치를 진단한다.
