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

## Links
<관련 paper/source/category/idea/policy를 [[wikilink]]로 연결. `related_*` frontmatter를 쓰면 여기에 mirror>
```
