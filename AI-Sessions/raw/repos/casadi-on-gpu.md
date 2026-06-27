---
type: raw-repo
date: 2026-06-27
---
- url: https://github.com/edxmorgan/casadi-on-gpu
- commit: 6c4481a   # 본 시점 HEAD ("cache stream workspace allocations")
- local clone: /home/frlab/casadi-on-gpu
- 왜 관련: mj_rl `source/assets/cuda`가 이걸로 G1 centroidal/dynamics CasADi 함수를 CUDA 커널로 만들어 vectorized env에서 배치 평가한다. cusadi(se-hwan)와 같은 niche의 경량 구현.
