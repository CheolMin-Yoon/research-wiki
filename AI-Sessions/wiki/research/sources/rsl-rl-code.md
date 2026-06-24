---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/2025-rsl-rl-library.md
---

# 구현 분석: rsl_rl

## Summary

로보틱스용 GPU on-policy RL 라이브러리다. raw repo stub의 pinned commit `016c7ede710e358b7d6c205642e2540804d6281f`를 checkout해 확인했으며, mj_rl의 PPO 학습 백엔드와 custom model 통합 기준으로 둔다. 논문과 코드 모두 PPO core를 단순하게 유지하면서 robotics-specific extension을 붙이는 방향이다.

## 핵심 파일

- `rsl_rl/algorithms/ppo.py`: clipped PPO update, value loss, entropy, learning rate schedule 등 algorithm 본체.
- `rsl_rl/runners/on_policy_runner.py`: rollout 수집, update 호출, logging, checkpoint 처리.
- `rsl_rl/models/mlp_model.py`, `rsl_rl/models/rnn_model.py`, `rsl_rl/models/cnn_model.py`: actor/critic model 계층.
- `rsl_rl/storage/rollout_storage.py`: rollout buffer와 mini-batch sampling.
- `rsl_rl/extensions/symmetry.py`: symmetry augmentation/loss extension.
- `rsl_rl/extensions/rnd.py`: exploration용 random network distillation.
- `rsl_rl/algorithms/distillation.py`, `rsl_rl/runners/distillation_runner.py`: teacher-student/distillation 경로.

## 가져올 패턴

- Runner, Algorithm, Model, Storage를 분리해 custom policy network를 algorithm 바깥에서 교체한다.
- PPO 자체는 단순하게 두고 symmetry, RND, distillation을 extension으로 붙인다.
- observation group과 privileged critic observation을 분리하는 robotics RL 관행을 유지한다.
- graph/Body Transformer model을 넣을 때 PPO loop보다 model interface와 rollout storage shape를 먼저 맞춘다.

## 주의점

- VecEnv reset/timeout convention이 다른 framework와 섞이면 advantage와 bootstrap이 조용히 틀어질 수 있다.
- custom model은 actor/critic output shape, distribution parameterization, recurrent 여부를 rsl_rl interface에 정확히 맞춰야 한다.
- 실행은 라이브러리 README와 consuming repo의 runner config를 통해 확인한다.

## Links

- raw repo: AI-Sessions/raw/repos/2025-rsl-rl-library.md
- raw paper: AI-Sessions/raw/papers/2025-rsl-rl-library.pdf
- checked commit: 016c7ede710e358b7d6c205642e2540804d6281f
