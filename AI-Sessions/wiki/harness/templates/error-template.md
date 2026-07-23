---
tags: [tier/low]
type: template
date: 2026-06-24
status: active
target_type: error
---

# Error Template

```markdown
---
type: error
date: YYYY-MM-DD
status: active | resolved | obsolete
applies_to:
replaced_by:
severity: low | medium | high
source:
related_experiments:
---

# Error: <name>

## Symptom
무엇이 관찰되었는가?

## Root Cause
근본 원인은 무엇인가?

## Trigger
어떤 조건에서 재발하는가?

## Fix
이번에는 어떻게 해결했는가?

## Prevention Rule
다음 agent가 같은 상황에서 무엇을 먼저 확인해야 하는가?

## Related Experiments
관련 실험 링크.

## Links
관련 research object/decision/anti-pattern 링크. research 관계는 전체 경로를 사용한다.
```
