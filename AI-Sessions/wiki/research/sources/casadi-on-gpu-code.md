---
tags: [tier/low]
type: source
date: 2026-06-27
status: active
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

- `source/assets/cuda/gen_casadi_fns.py`: pinocchio.casadi로 G1(29DOF+floating, nq=36/nv=35) `compute_dynamics_terms`(M,Cv,G,h), `compute_centroidal_terms`, `compute_base_pose` 생성.
- `source/assets/cuda/pinocchio.py`: cog 커널을 MuJoCo 입력 규약(`mj_to_pin`)으로 감싼 배치 동역학 wrapper.
- `scripts/casadi_on_gpu/build_kernels.sh` / `install_kernels.sh`: 생성→빌드→설치 자동화(mj/codegen_env/mjlab_env 분담).

## 가져올 패턴 / 주의점

- MJCF→GPU는 항상 2-stage(`MJCF → pinocchio.casadi → CasADi Function → cog`). `.casadi` 직렬화는 casadi 버전 잠금이라 생성·codegen을 같은 casadi 버전에 모은다.
- CasADi dense 출력은 column-major라 행렬 출력은 `(N,cols,rows)` 후 transpose로 읽는다(`pinocchio.py _alloc_mat`).
- 29-DOF CasADi 모델과 waist 제거된 26-DOF mjlab RL 모델 간 DOF mapping을 조심(= [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] 주의점과 동일).

## Links

- raw repo: AI-Sessions/raw/repos/casadi-on-gpu.md
- checked commit: 6c4481a
- related sources: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]
- benchmark: [[AI-Sessions/wiki/research/experiments/2026-06-27-cusadi-vs-casadi-on-gpu-g1|2026-06-27-cusadi-vs-casadi-on-gpu-g1]]
- pattern: [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]
