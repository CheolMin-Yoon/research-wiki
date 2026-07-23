# WarpMPC architecture reference

확인 기준은 `/home/frlab/WarpMPC`의 clean commit `e5ddb20a1fcb06453e97f31936b3f7c5164e7ca1`이다. 다른 commit을 사용할 때는 아래 line reference와 계약을 다시 확인한다.

## 전체 흐름

```text
CasADi stage function: (z_k, z_{k+1}, p_k) -> cost, g, l, u
    -> CasadiStageFunction: sparse gradient/Hessian/Jacobian expressions
    -> SparseMPCProblem: first / repeated middle / terminal
    -> SparseMPCPlan: global CSC P/A + scatter maps + OSQP/QDLDL symbolic plan
    -> CompiledSparseMPCSQP: backend/dtype를 고정한 JIT callables
    -> runtime SQPLinearization: p_values, a_values, q, l, u
    -> fixed-iteration OSQP ADMM + sparse QDLDL
    -> SQPLineSearchStepResult: z_next + solve/line-search diagnostics
```

QP subproblem은 다음과 같다.

\[
\min_{\Delta z}\; \frac{1}{2}\Delta z^T P\Delta z + q^T\Delta z,
\qquad
l-g(z,p) \le J_g(z,p)\Delta z \le u-g(z,p).
\]

Runtime은 dense P/A가 아니라 `p_values: (batch, nnz(P))`, `a_values: (batch, nnz(A))`를 사용한다. `q`, `l`, `u`만 dense vector다.

## Problem

- `warpmpc/jax_sqp/casadi_stage.py:40-188`: `CasadiStageFunction`. Nonterminal 입력은 `(z, z_next, params)`, terminal은 `(z, params)`, 출력은 정확히 `cost, g, l, u`다.
- `casadi_stage.py:102-120`: local variable을 `[z_k, z_{k+1}]`로 만들고 cost gradient, cost Hessian, constraint Jacobian을 CasADi로 생성한다.
- `casadi_stage.py:128-160`: Hessian upper triangle과 Jacobian structural nonzero 값만 뽑는다.
- `casadi_stage.py:170-171`: 생성된 CasADi 함수를 `numpysadi`로 JAX callable로 바꾼다.
- `warpmpc/jax_sqp/sparse_mpc.py:71-101`: horizon interval N을 `N+1` stage인 first, repeated middle, terminal로 구성한다.
- `examples/jax_sqp_minimal.py:40-102`: 관례적인 `z_k=[x_k,u_k]`, initial equality, dynamics defect의 최소 예다.

현재 Hessian은 `hessian(cost, local_variables)`다. Constraint multiplier가 포함된 정확한 Lagrangian Hessian이 아니므로 exact SQP Hessian이라고 가정하지 않는다.

## Plan

- `sparse_mpc.py:532-690`: `build_sparse_mpc_plan`.
- `sparse_mpc.py:542-561`: stage 연결 차원과 variable/parameter/constraint offset을 고정한다.
- `sparse_mpc.py:563-607`: local derivative 좌표를 global structural coordinate로 합치고 CSC P/A 및 `StageAssembly` scatter position을 만든다.
- `sparse_mpc.py:610-622`: fixed OSQP settings와 representative bound 종류를 정한다.
- `sparse_mpc.py:629-677`: optional representative linearization으로 scaling data를 계획한다.
- `warpmpc/jax_sqp/types.py:56-96`: plan이 소유하는 고정 pattern/index 데이터다.

Plan 이후 고정되는 것은 horizon, stage 순서와 차원, P/A/KKT CSC index, constraint row 종류, QDLDL permutation/elimination tree/L pattern이다. Runtime에는 그 pattern의 값만 바뀐다.

## Compile

- `sparse_mpc.py:703-794`: `compile_sparse_mpc_sqp`; dtype을 `np.dtype`/`jnp.dtype`로 고정하고 QP backend를 compile한다.
- `sparse_mpc.py:796-832`: 같은 객체인 repeated stages를 그룹화하고 stage 축과 batch 축에 nested `vmap`을 적용한다.
- `sparse_mpc.py:855-901`: sparse linearization을 `jit`하고 packed P/A 값, q, bound residual을 scatter한다.
- `sparse_mpc.py:1055-1191`: evaluation, QP build/solve, direction, fixed step, filter line-search step의 public callables를 노출한다.
- 큰 문제에서 monolithic XLA executable이 커질 때 `step_split_compile`을 선택할 수 있다.

같은 middle 수식을 서로 다른 `CasadiStageFunction` 객체로 만들면 `id(stage)` 기반 grouping을 놓친다. 한 객체를 반복 재사용한다.

## QP solver

- `warpmpc/jax_osqp/solver.py:574-684`: fixed OSQP/KKT/QDLDL plan을 만든다.
- KKT 구조는 `[[P + sigma I, A.T], [A, -rho^-1 I]]`다.
- `solver.py:685-872`: packed 값을 KKT에 scatter하고 factorization한 뒤 `settings.max_iter` 고정 길이의 `lax.scan`으로 ADMM을 수행한다.
- `warpmpc/jax_qdldl/core.py:1-15,259-313`: CPU symbolic analysis와 JAX/Warp numeric factor/solve를 분리한다.
- `solver.py:1238-1265`: `derivatives=True`일 때 implicit adjoint를 `custom_vjp`로 제공한다.

현재 JAX OSQP는 조기 종료가 아니라 항상 고정 `max_iter`를 수행한다. `adaptive_rho=True`와 polishing은 지원하지 않으며, 실제 warm start는 호출자가 `(x,z,y)` state를 다음 solve에 넘겨 유지한다.

## Runtime/result 이름

- `warpmpc/jax_sqp/types.py:14-52`: linearization, solve, fixed-step, line-search result.
- `types.py:99-118`: compiled solver의 public callable 목록.
- `sparse_mpc.py:1081-1110`: QP warm state 초기화와 전달.

이름 충돌에 주의한다.

- SQP 입력 `z`: 전체 NLP decision.
- `OSQPWarmStart.z`: constraint-space ADMM auxiliary variable.
- `SQPSolveResult.z`: 같은 QP auxiliary variable.
- 다음 NLP decision: `result.z_next`.

Outer receding-horizon controller가 측정값, reference, gait parameter, trajectory shift, 첫 control 적용, NLP iterate와 QP warm state lifecycle을 소유한다.

## 고정 sparsity 함정

- Bound row의 equality/lower/upper 성격은 0, 1, -1 probe로 대표 분류한다 (`sparse_mpc.py:476-518`). Parameter에 따라 row 종류가 바뀌는 모델을 피한다.
- Runtime structural zero가 새 nonzero가 될 수 없다. Contact/gait branch의 가능한 derivative 위치를 symbolic graph에 유지하고 parameter mask 값만 0으로 만든다.
- Batch size는 plan 데이터가 아니지만 JIT input shape이므로 바꾸면 재compile될 수 있다.
- float64 compile 전 `jax_enable_x64=True`가 필요하다 (`sparse_mpc.py:39-45`).
- Low-level Warp QDLDL은 values/rhs layout 계약이 있다. 일반 구현에서는 high-level SQP interface가 adapter를 소유하게 한다.
- Filter line search는 고정 step ladder를 모두 평가하고 첫 accepted candidate를 고른다. 선택은 piecewise이며 일반적으로 미분 가능하다고 가정하지 않는다.
