---
type: source
date: 2026-06-27
status: active
topics:
  - model-predictive-control
  - jax-solver
source: AI-Sessions/raw/repos/casadi-on-gpu.md
---

# 구현 분석: casadi-on-gpu

## Summary

CasADi 심볼릭 `Function`을 CUDA 커널로 codegen해 GPU에서 수천 인스턴스를 배치 평가하는 경량 런타임(edxmorgan). mj_rl `source/assets/cuda` 파이프라인의 GPU 백엔드 정본이다. checked commit `6c4481a`. 같은 niche의 대안 cusadi(se-hwan)와 비교했고, 이 환경에선 casadi-on-gpu가 우세해 채택을 유지한다.

## 핵심 구조

- 입력은 오직 CasADi `Function`(`.casadi`). 로봇 모델 포맷(MJCF/URDF)은 직접 못 먹는다.
- `tools/generate_manifest_and_registry.py`로 `.casadi` → `.cu/.cuh` + `kernels_manifest.json` + `casadi_on_gpu_kernel_registry.cu` 생성, cmake/pip로 패키지에 빌드.
- Python에서 `cog.list_kernels()` / `cog.launch(name, in_ptrs, out_ptrs, N, stream_ptr, sync)`. 입출력은 **float32**, PyTorch/CuPy 텐서의 `data_ptr()`를 raw pointer로 넘긴다.

## mj_rl에서의 사용

- `source/assets/cuda/gen_casadi_fns.py`: pinocchio.casadi로 selected G1 MJCF layout을 `compute_dynamics_terms`(M,Cv,G,h), `compute_centroidal_terms`, `compute_base_state` 함수로 생성한다. `CASADI_FUNCTION_PREFIX`를 써서 `g1_23dof_*`, `g1_leg_waist_13dof_*` 함수명을 만든다.
- `source/assets/cuda/casadi_pinocchio*.py`: cog 커널을 MuJoCo 입력 규약(`mj_to_pin`)으로 감싼 배치 동역학 wrapper. Compatibility wrapper는 23DOF를 가리키고, flat layout-specific wrappers는 23DOF와 13DOF leg+waist를 각각 호출한다.
- `scripts/casadi_on_gpu/build_kernels.sh` / `install_kernels.sh`: 생성→빌드→설치 자동화(mj/codegen_env/mjlab_env 분담).

## Reflected production state (mj_rl `5d87ee3`)

- production registry는 `compute_base_state`, `compute_centroidal_terms`, `compute_dynamics_terms` 3개만 유지한다. `compute_base_pose`는 `compute_base_state`로 hard rename했고 compatibility alias는 두지 않는다.
- `compute_dynamics_terms`는 full Coriolis matrix를 만들지 않고 `h = nonLinearEffects(q,dq)`, `G = computeGeneralizedGravity(q)`, `Cv = h - G`로 생성한다.
- `compute_centroidal_terms`는 `CMM/dCMM`은 Pinocchio 생성식을 유지하고, `CM = CMM @ dq`, `dCM = CMM @ ddq + dCMM @ dq`로 중복 momentum 호출을 제거한다.
- `scripts/casadi_on_gpu/validate_mjlab_centroidal.py`는 mjlab 직접 기준이 있는 `CoM`, whole-body linear momentum, angular momentum만 검증한다. `CMM/dCMM`은 mjlab 직접 API가 없어 skip으로 기록한다.
- compare/report 산출물은 checked-in production artifact로 남기지 않는다. 필요하면 비교 스크립트를 다시 만들어 재측정하고, wiki에는 요약만 남긴다.

## Reflected production state (mj_rl `b362398` + pending push)

- `source/assets/cuda/casadi_fns/` and `source/assets/cuda/cuda_fns/` are flat artifact folders. They contain both G1 layouts, separated by function/file prefixes rather than subdirectories.
- Registered kernels are `g1_23dof_compute_{base_state,centroidal_terms,dynamics_terms}` and `g1_leg_waist_13dof_compute_{base_state,centroidal_terms,dynamics_terms}`.
- `scripts/casadi_on_gpu/build_kernels.sh` builds both layouts into one casadi-on-gpu extension by default; `install_kernels.sh` installs the flat prebuilt artifact set. There is no per-run kernel switching between 23DOF and 13DOF.
- Wrapper shape guards choose the prefixed kernel matching the wrapper layout, so 23DOF Centroidal and 13DOF `waist_momentum` can initialize in one process.

## 가져올 패턴 / 주의점

- MJCF→GPU는 항상 2-stage(`MJCF → pinocchio.casadi → CasADi Function → cog`). 일반 절차와 version caveat는 [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]를 따른다.
- CasADi dense 출력은 column-major라 행렬 출력은 `(N,cols,rows)` 후 transpose로 읽는다(`pinocchio.py _alloc_mat`).
- DOF mapping은 항상 [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]의 task contract를 기준으로 확인한다. Current G1 kernels include 23DOF full-body and 13DOF leg+waist layouts in the same registry.

## Relations

- raw repo: AI-Sessions/raw/repos/casadi-on-gpu.md
- upstream checked commit: 6c4481a
- mj_rl integration checked commits: 5d87ee3ea85eed570f5931e181326e937c4f811f, b362398 (`master`, before current push)
- related sources: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- benchmark: [[AI-Sessions/wiki/research/experiments/2026-06-27-cusadi-vs-casadi-on-gpu-g1|2026-06-27-cusadi-vs-casadi-on-gpu-g1]]
- pattern: [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]
