---
type: source
date: 2026-07-23
status: active
topics:
  - model-predictive-control
  - jax-solver
source: https://github.com/hshose/WarpMPC/tree/e5ddb20a1fcb06453e97f31936b3f7c5164e7ca1
---

# 구현 분석: WarpMPC

## Summary

WarpMPC의 JAX SQP는 stage별 CasADi `cost,g,l,u`에서 고정 Hessian/Jacobian sparsity를 추출하고, CPU plan 단계에서 전역 CSC P/A와 OSQP KKT/QDLDL symbolic 구조를 만든다. Runtime에는 dense P/A가 아니라 batched packed nonzero 값과 dense `q,l,u`만 전달한다. 확인 기준은 clean checked commit `e5ddb20a1fcb06453e97f31936b3f7c5164e7ca1`이다.

## 핵심 구조

```text
stage functions
→ SparseMPCProblem
→ SparseMPCPlan
→ CompiledSparseMPCSQP
→ SQPLinearization
→ fixed-iteration OSQP + sparse QDLDL
→ z_next and diagnostics
```

- 대표 stage variable은 `z_k=[x_k,u_k]`이며 dynamics는 `x_{k+1}-f(x_k,u_k)=0` defect로 둔다. 이 배치는 예제 관례이고 라이브러리 강제 규칙은 아니다.
- Plan이 horizon, stage dimension, P/A/KKT pattern, constraint row 종류와 QDLDL symbolic data를 고정한다.
- Compile이 dtype/backend와 JAX `jit/vmap/scan` 배치를 고정한다. Runtime parameter 값과 nonzero 값만 바뀐다.
- 동일 middle stage 객체를 반복해 stage-axis `vmap` grouping을 얻고, OSQP ADMM은 고정 iteration `scan`으로 실행한다.
- Outer NMPC가 measured state/reference/gait, trajectory shift, 첫 control 적용, NLP iterate와 QP warm state를 소유한다.

## mj_mpc 적용

- C++/NumPy condensed 구현은 원본 수식과 trajectory parity를 검증하는 oracle로 유지한다.
- 최종 JAX 경로는 stagewise uncondensed sparse form으로 만들고 contact/gait는 fixed-shape parameter mask로 갱신한다.
- 여러 stage가 공유하는 최적화 foothold는 carried stage variable과 propagation equality 또는 stage-local copy consensus로 표현한다.
- Float64 parity를 먼저 통과한 뒤 float32 solver scaling과 tolerance를 다시 검증한다.

## Skill

재사용 절차와 상세 근거는 `.agents/skills/jax-mpc/`에 저장했다. Codex/Claude 전역 skill 이름은 `$jax-mpc`다.

## Relations

- local repository: `/home/frlab/WarpMPC`
- checked commit: `e5ddb20a1fcb06453e97f31936b3f7c5164e7ca1`
- local skill package: `/home/frlab/research-wiki/.agents/skills/jax-mpc`
- related source: [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]
