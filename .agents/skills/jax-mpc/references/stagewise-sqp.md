# Stagewise SQP modeling

## Condensed와 stagewise 역할

Condensed NumPy 모델은 원본 수식 검증용 oracle이다.

\[
X = P_x x_0 + P_u U
\]

Stagewise sparse 모델은 production JAX solver 표현이다.

\[
Z = [z_0, z_1, \ldots, z_N], \qquad z_k=[x_k,u_k]
\]

\[
x_0-x_{measured}=0, \qquad x_{k+1}-f(x_k,u_k,p_k)=0
\]

둘은 같은 미래 trajectory를 만들어야 하지만 내부 decision은 다르다. Prediction matrix를 stagewise solver의 dynamics constraint로 다시 넣지 않는다.

## Stage interface

Nonterminal stage:

```text
(z_k, z_{k+1}, p_k) -> cost_k, g_k, lower_k, upper_k
```

Terminal stage:

```text
(z_N, p_N) -> cost_N, g_N, lower_N, upper_N
```

`p_k`에는 measured initial state, reference, gait phase, contact mask, support geometry, dt처럼 runtime에 바뀌지만 최적화하지 않는 값을 둔다. 최적화 변수는 `z_k`에 둔다.

## Footstep decision

미래 foothold는 최적화 대상이면 parameter가 아니다. 한 착지점이 여러 stage의 support/ZMP constraint에서 공유되므로 다음 중 하나를 택한다.

### Carried foothold state

```text
z_k = [x_k, u_k, foothold_memory_k]
foothold_memory_{k+1} - update_or_hold(foothold_memory_k, landing_k) = 0
```

Landing event에서만 값을 갱신하고 그 사이에는 propagation equality로 같은 값을 유지한다. Stage-local adjacency와 고정 sparsity에 가장 자연스럽다.

### Stage-local copies with consensus

```text
z_k = [x_k, u_k, foothold_copy_k]
foothold_copy_{k+1} - foothold_copy_k = 0
```

필요 stage에 복제하고 equality로 묶는다. 구현은 단순하지만 variable/equality 수가 늘어난다.

독립 global foothold block을 두고 모든 stage가 멀리 참조하게 만들면 WarpMPC의 기본 `(z_k,z_{k+1})` locality와 맞지 않는다. 별도 assembler 확장 없이 사용하지 않는다.

## Contact와 support mapping

- Landing foot identity, contact phase, support polygon 선택은 fixed-shape parameter로 둔다.
- `if contact:`로 symbolic branch를 제거하지 말고 mask 곱으로 가능한 derivative 위치를 유지한다.
- Support mapping은 `stage -> current/carried foothold slot`의 고정-shape index 또는 mask로 만든다.
- 같은 0.5 s gait 주기라도 horizon 안의 touchdown 이후 constraint가 새 foothold를 참조하므로 미래 foothold decision의 필요성은 사라지지 않는다.

## 최소 shape 기록

구현 전 다음 표를 실제 숫자로 채운다.

| 이름 | shape | 소유자 | compile/runtime |
|---|---:|---|---|
| `z_k` | `(nz_k,)` | SQP | runtime value, fixed shape |
| `p_k` | `(np_k,)` | outer NMPC | runtime value, fixed shape |
| `g_k` | `(ng_k,)` | stage function | runtime value, fixed shape |
| `p_values` | `(batch, nnz(P))` | linearization | runtime |
| `a_values` | `(batch, nnz(A))` | linearization | runtime |
| `q` | `(batch, nvar)` | linearization | runtime |
| `l,u` | `(batch, ncon)` | linearization | runtime |

Decision ordering을 정한 뒤에는 direct slices 한 곳에서만 해석하고, 같은 의미의 selector matrix와 slice를 동시에 유지하지 않는다.
