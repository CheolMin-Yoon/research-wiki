---
tags: [tier/low]
type: experiment
date: 2026-06-27
status: done
source: 직접 벤치마크 (mj env, RTX 5070 Laptop)
related_sources: AI-Sessions/wiki/research/sources/mj-rl.md
---

# Experiment: cusadi vs casadi-on-gpu — G1 동역학 GPU 배치 평가 속도

## Question

`mj_rl/source/assets/cuda`의 G1 CasADi 동역학 함수를 GPU에서 배치 평가할 때, 현재 production이 쓰는 **casadi-on-gpu**(edxmorgan)와 대안 **cusadi**(se-hwan) 중 어느 쪽이 빠른가? 둘은 같은 niche(CasADi 심볼릭 함수를 CUDA 커널로 만들어 수천 인스턴스 배치 평가)다.

## Result (정본)

**casadi-on-gpu가 전 구간에서 cusadi보다 ~10–20× 빠르다.** 동일 함수임을 출력 교차검증으로 확인했다(같은 pinocchio 함수 재생성).

- GPU: NVIDIA RTX 5070 Laptop, precision **float32 양쪽 동일**, per-call sync, CUDA event median(warmup 15 / iters 60).
- 예: `h_g1` N=4096 → cusadi 0.82 Menv/s vs casadi-on-gpu **9.9 Menv/s** (~12×).

median kernel time (ms, 낮을수록 빠름). `cu`=cusadi, `cog`=casadi-on-gpu.

| 함수 | N=1024 | N=2048 | N=4096 | N=8192 |
|---|---|---|---|---|
| G_g1 | 0.208 / 0.021 | 0.212 / 0.022 | 0.215 / 0.023 | 0.261 / 0.028 |
| h_g1 | 3.091 / 0.142 | 3.122 / 0.152 | 4.973 / 0.412 | 22.59 / 1.039 |
| CoM_g1 | 0.092 / 0.016 | 0.093 / 0.016 | 0.095 / 0.016 | 0.113 / 0.016 |
| CMM_g1 | 0.848 / 0.053 | 0.853 / 0.054 | 0.862 / 0.061 | 1.077 / 0.104 |
| dCMM_g1 | 2.098 / 0.095 | 2.116 / 0.100 | 2.194 / 0.168 | 10.09 / 0.492 |
| CM_g1 | 0.306 / 0.028 | 0.309 / 0.027 | 0.315 / 0.029 | 0.399 / 0.033 |
| dCM_g1 | 0.507 / 0.045 | 0.516 / 0.045 | 0.529 / 0.040 | 0.662 / 0.058 |
| aba_g1 | 1.097 / 0.062 | 1.110 / 0.063 | 1.130 / 0.068 | 2.022 / 0.181 |

교차검증(cusadi vs cog max abs diff, 정규화 안 된 랜덤 입력): CoM 1.2e-7, G 2.4e-4, h 3.7e-4, aba 2.1e-3 → float32 누적 순서 차이 수준, 같은 함수 확인.

## 해석 (미검증 추정)

cusadi 생성 커널은 work 버퍼를 **env-major**(`work[idx*n_w + k]`)로 접근 → 인접 스레드가 `n_w` 간격 주소를 읽어 **uncoalesced** 글로벌 메모리 접근. 무거운 함수(h, dCMM)에서 N=8192일 때 비선형 폭증(22ms, 10ms)이 메모리 병목의 전형. casadi-on-gpu는 매끄럽게 스케일 → coalesced 레이아웃 추정. 즉 **연산량은 동일, 메모리 접근 패턴 차이**가 핵심으로 보인다(커널 소스 레이아웃 정밀 확인은 미수행).

## Caveats

- RTX 5070 Laptop / float32 / 이 8개 `_g1` 함수 한정. 다른 GPU·정밀도·함수에서 비율은 달라질 수 있다.
- production의 묶음 함수(`compute_dynamics_terms` 등)가 아니라 **동일 의미의 `_g1` 개별 함수**로 비교(비침습 경로). cog엔 이미 `_g1` 커널이 빌드돼 있었고, cusadi엔 같은 pinocchio 함수를 재생성해 codegen.
- cusadi는 라이브러리 기본 경로(`evaluate()` 내부 `cudaDeviceSynchronize`), cog는 `sync=True`로 per-call sync 맞춤.
- cusadi `CusadiFunction`은 fp64 하드코딩이라, fp32 비교를 위해 float codegen + 별도 fp32 런처를 직접 작성해 측정.

## Reproduction (세션 종료 후 artifact 삭제됨 — 재현 절차)

mj env(casadi 3.7.2 + pinocchio 4.0 + casadi_on_gpu)에 cusadi만 추가하면 재현 가능. cog의 `_g1` 커널이 설치돼 있어야 함(`cog.list_kernels()`로 확인).

1. `git clone https://github.com/se-hwan/cusadi ~/cusadi-mj` → `conda run -n mj pip install -e ~/cusadi-mj --no-deps` (casadi/torch/numpy 보존 위해 `--no-deps` 필수).
2. pinocchio.casadi로 `_g1` 함수(G, h, CoM, CMM, dCMM, CM, dCM, aba) 재생성 → `~/cusadi-mj/src/casadi_functions/*.casadi`. (G1 MJCF: `mjlab .../unitree_g1/xmls/g1.xml`, `G1_MJCF_PATH`로 지정.)
3. `generateCUDACodeFloat` + `generateCMakeLists` + cmake/make로 fp32 빌드.
4. cusadi는 ctypes로 `build/lib<name>.so`의 `evaluate(const float* inputs[], float* work, float* outputs[], int N)` 호출(fp32 텐서), cog는 `cog.launch(name, in_ptrs, out_ptrs, N, stream_ptr, sync=True)`. 양쪽 CUDA event median.

## Conclusion / Next

- RL 환경 수(1k–8k) 대역에서 **casadi-on-gpu가 일관되게 우세** → production이 `pinocchio.py`에서 casadi-on-gpu를 쓰는 선택은 속도 면에서 타당. cusadi로 갈아탈 이유 없음(현재 커널 레이아웃 기준).
- 더 볼 가치가 있다면: (a) production 묶음 함수(`compute_*`)로 재측정, (b) cusadi work 버퍼를 coalesced로 패치 후 재측정 — 둘 다 이번엔 미수행.

## Links

- sources: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] (`source/assets/cuda` = casadi-on-gpu 파이프라인 정본)
- patterns: [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]] ("CasADi 심볼릭→GPU 배치 도구" 패턴)
