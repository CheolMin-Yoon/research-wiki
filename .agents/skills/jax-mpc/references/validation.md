# Validation ladder

다음 gate를 건너뛰지 않는다. 각 gate는 작은 deterministic case와 shape assertion을 포함한다.

## 1. Dynamics oracle

- C++ 한 stage와 NumPy `discrete_dynamics`를 같은 state/control로 비교한다.
- 입력이 바뀌지 않고 반환값이 입력과 memory를 공유하지 않는지 확인한다.
- Condensed prediction matrix 결과를 반복 rollout의 `[1:]`와 비교한다.

## 2. Stage conversion

- CasADi `value_function`과 변환된 JAX value function의 `cost,g,l,u`를 비교한다.
- CasADi sparse derivative output과 JAX output을 동일 입력에서 비교한다.
- WarpMPC reference: `tests/test_jax_sqp.py:165-176`.

## 3. Global sparse assembly

- Packed `p_values`, `a_values`를 plan의 CSC pattern으로 dense 복원한다.
- 전역 CasADi dense Hessian/Jacobian과 비교한다.
- `q`, `l-g`, `u-g`도 함께 비교한다.
- WarpMPC reference: `tests/test_jax_sqp.py:178-226`.

## 4. Static shape and grouping

- Batch별 `z_next`, direction, warm `(x,z,y)` shape와 finite value를 검사한다.
- Grouped repeated-stage evaluation과 ungrouped evaluation을 비교한다.
- WarpMPC reference: `tests/test_jax_sqp.py:245-270`, `351-381`.

## 5. QP parity

- 같은 fixed iteration과 scaling 조건에서 JAX OSQP와 official OSQP를 비교한다.
- Residual, objective, primal solution뿐 아니라 warm-state lifecycle을 확인한다.
- Early termination solver와 fixed-iteration solver 결과를 조건 없이 직접 비교하지 않는다.

## 6. Precision and batching

- float64 oracle과 float32 결과의 state, constraint violation, QP residual 허용 오차를 따로 기록한다.
- batch size 1 결과와 같은 sample을 포함한 batched 결과를 비교한다.
- Contact/gait mask가 바뀌어도 P/A `nnz`와 packed shape가 그대로인지 확인한다.

## 7. Receding horizon

- Optimal trajectory shift가 stage layout과 맞는지 확인한다.
- 첫 control만 plant에 적용하고 다음 tick measured state를 다시 넣는지 확인한다.
- NLP decision warm start와 OSQP ADMM warm state를 따로 shift/보존한다.
- Foothold memory가 touchdown 전후에 올바른 stage에서 hold/update되는지 검사한다.

## 8. Differentiation

학습 또는 bilevel 최적화에 QP gradient가 실제로 필요할 때만 수행한다.

- `derivatives=True`를 plan과 compile 양쪽에 일관되게 설정한다.
- 작은 문제에서 central finite difference와 비교한다.
- WarpMPC reference: `tests/test_jax_sqp.py:272-315`.

## 실패 보고 형식

```text
gate:
equation/constraint:
expected shape/value:
actual shape/value:
first mismatching stage/index:
dtype/backend:
next smallest experiment:
```
