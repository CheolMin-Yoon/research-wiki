---
tags: [tier/low]
type: handoff
date: 2026-06-25
status: active
last_agent: Codex
suggested_next_agent:
mode: verification
---

# Handoff

## Current Goal

Body Transformer 코드 수준 이해와 wiki hardening 1차는 완료됐다. 다음 작업은 `05~06` 노트북 shape/interface 점검과 병행해 mjlab built-in G1 tracking baseline을 재현하는 것이다.

## Next Experiment

실험 노트: `AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md`

재현 변수:

```bash
cd /home/frlab/mj_rl
conda activate mjlab_env
export MOTION=/tmp/mjlab_cache/lafan1_dance1_subject1_demo_motion.npz
```

바로 할 일:

1. `python -m mjlab.scripts.demo`로 viewer 확인.
2. `$MOTION`으로 `Mjlab-Tracking-Flat-Unitree-G1` smoke training 1 iteration 실행.
3. sanity training 100 iteration으로 `/home/frlab/mj_rl/models/motion_tracking.best.pt` export 확인.
4. run record를 실험 노트에 기록한다.
5. baseline이 정상 실행되면 같은 task/reward/motion에서 BoT actor 교체 실험을 계획한다.

## Current Facts

- `Mjlab-Tracking-Flat-Unitree-G1` task는 built-in이지만 train에는 `--env.commands.motion.motion-file` 또는 `--registry-name`이 필요하다.
- demo assets는 `/tmp/mjlab_cache/demo_ckpt.pt`, `/tmp/mjlab_cache/lafan1_dance1_subject1_demo_motion.npz`에 캐시돼 있다.
- best checkpoint export는 `/home/frlab/mj_rl/scripts/train.py`를 사용할 때만 동작한다.
- 구현 사실 정본은 [[AI-Sessions/wiki/research/sources/body-transformer-code|body-transformer-code]], 논문 통합 방식은 [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]]에 둔다.

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 안정적으로 수정한다.
- `AI-Sessions/raw/`는 사용자 승인 없이 수정·삭제하지 않는다.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml
- AI-Sessions/wiki/harness/policies/{agent,obsidian,research,archive}-policy.md
- AI-Sessions/wiki/harness/patterns/{agent-patterns,research-patterns}.md
