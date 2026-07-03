---
tags: [tier/mid]
type: map
date: 2026-06-24
status: active
---

# Patterns

## Graph

- [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]]
- [[AI-Sessions/wiki/harness/patterns/mjlab-patterns|mjlab-patterns]]
- [[AI-Sessions/wiki/harness/patterns/research-patterns|research-patterns]]

## Summary

도메인별 패턴(반복 확인된 좋은/나쁜 접근)을 연결하는 harness 하위 허브다. 파일명은 `{domain}-patterns`(agent-patterns, mjlab-patterns, research-patterns, 향후 reward-fns-patterns/pytorch-patterns 등). `agent-patterns`는 init 레이어로 함께 읽고, `mjlab-patterns`는 `/home/frlab/mj_rl` 구현 작업 때, `research-patterns`는 연구·노트북·실험 작업 때 라우터로만 읽는다. 단일 실패 사례는 `harness/errors/`에 먼저 둔다.
