# JAX execution contract

## Pure numerical seam

- Array 입력을 읽기 전용으로 취급한다.
- 결과는 입력과 alias되지 않는 새 값으로 반환한다.
- JIT 함수 안에서 Python object, class runtime state, global state를 갱신하지 않는다.
- Horizon, shape, dtype, sparsity, iteration count를 compile 동안 고정한다.

NumPy에서 먼저 같은 interface를 만들고 JAX에서는 `np.asarray`와 slice assignment만 `jnp.asarray`와 functional update로 바꾼다.

## Transform 선택

| 계산 | transform | 이유 |
|---|---|---|
| Condensed recurrent rollout | `lax.scan` | `x_{k+1}`가 `x_k`에 의존 |
| Stagewise dynamics defects | `vmap` | 모든 `x_k,x_{k+1}`가 decision에 있어 stage 평가가 독립 |
| Batch instances | `vmap` | 같은 static problem의 독립 solve |
| Repeated identical stage function | nested `vmap` | stage 객체와 수식을 재사용 |
| NLP evaluation/linearization | `jit` | fixed shape의 큰 계산 seam |
| OSQP ADMM iterations | `lax.scan` | 고정 횟수의 순차 iterate |
| Line-search candidates | `vmap` 또는 broadcast | 후보가 독립이며 후보 수 고정 |
| Outer SQP iteration | 먼저 Python loop | 진단과 compile 크기를 확인한 뒤 필요할 때만 scan |

`vmap`을 recurrent time axis에 쓰지 않고, `scan`을 독립 stage residual 계산에 습관적으로 쓰지 않는다.

## Dtype

WarpMPC는 `f32/f64` 별칭이나 mutable global precision 파일을 사용하지 않는다. Compile interface에서 `dtype`을 받고 다음처럼 고정한다.

```python
dtype = np.dtype(dtype)
jdtype = jnp.dtype(dtype)
```

- NumPy/C++ parity는 float64로 먼저 확인한다.
- JAX production은 float32를 기본 후보로 삼고 constraint scaling과 solver tolerance를 다시 조정한다.
- float64를 쓰면 JAX computation을 만들기 전에 `jax.config.update("jax_enable_x64", True)`를 호출한다.
- 한 compiled solver 안에서 dtype을 바꾸지 않는다. dtype별 compiled artifact를 별도로 만든다.
- Scalar constant는 주변 array dtype을 따라 만들고 무의식적인 float64 승격을 검사한다.

## Compile 크기와 batch

- Batch size가 바뀌면 같은 plan이어도 XLA가 재compile될 수 있다.
- Humanoid problem에서 monolithic SQP step이 너무 커지면 evaluation/linearization/QP solve를 split compile한다.
- `jit` decorator를 작은 helper마다 붙이지 말고 stable outer seam에 둔다.
- Compile time, first-call time, steady-state runtime을 분리해 측정한다.

## Autodiff

Stage derivative sparsity와 값은 CasADi symbolic graph에서 만든다. 매 tick 전체 dense `jax.hessian`/`jax.jacobian`을 계산하는 구조로 바꾸지 않는다.

QP-through-gradient가 필요할 때만 `derivatives=True`와 implicit custom VJP를 사용한다. Filter line-search selection은 piecewise이므로 end-to-end gradient의 의미를 별도로 검증한다.
