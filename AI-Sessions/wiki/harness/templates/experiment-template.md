---
tags: [tier/low]
type: template
date: 2026-06-24
status: active
target_type: experiment
---

# Experiment Template

```markdown
---
type: experiment
date: YYYY-MM-DD
status: planned | running | done | invalid | archived
topics:
  - canonical-topic
project:
source:
---

# Experiment: <name>

## Purpose

## Hypothesis

## Setup
- robot/model:
- simulator:
- code branch/commit:
- config file:
- seed:
- training steps:

## Change
- changed component:
- before:
- after:

## Metrics
- reward:
- stability:
- velocity tracking:
- fall rate:
- qualitative gait:

## Result

## Interpretation

## Failure / Risk

## Next Experiment

## Relations
<검증하는 idea와 직접 사용한 paper/source/method만 전체 경로 [[wikilink]]로 연결>
```
