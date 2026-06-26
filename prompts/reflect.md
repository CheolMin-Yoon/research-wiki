---
tags: [tier/low]
---

# Reflect Prompt

```text
최근 실험, 구현, ingest 이후 무엇을 배웠는지 reflect 해줘.

먼저 architecture.md, AI-Sessions/wiki/harness/state/brief.md를 확인해줘.

1. 최근 experiment/source를 읽어 새로 알게 된 사실을 식별해줘.
2. 단일 실험 사실은 AI-Sessions/wiki/research/experiments/에 둬.
3. 재발 방지 실패는 AI-Sessions/wiki/harness/errors/로 승격해줘.
4. 일반화된 접근(좋은/나쁜)은 AI-Sessions/wiki/harness/patterns/로 승격해줘.
5. 앞으로 따를 설계 원칙은 AI-Sessions/wiki/harness/decisions/로 승격해줘.
6. 다음 세션이 바로 이어받아야 하는 상태는 AI-Sessions/wiki/harness/state/brief.md 또는 handoff.md에 반영해줘.
7. 같은 사실을 여러 계층에 복붙하지 마. 계층 하나를 정본(canonical home)으로 정하고(구현→source, 논문→paper, 실험설계→experiment) 나머지 문서는 restate 대신 [[링크]]로 가리켜. state(brief/handoff)에는 코드 디테일·메커니즘을 넣지 말고 "무엇을 했다 + 어디를 봐라" 포인터와 현재상태만 둬. (근거: AI-Sessions/wiki/harness/patterns/agent-patterns.md "정본 한 곳에 두고 나머지는 링크")

raw 원본은 수정하지 마. 추측은 미검증으로 표시하고, 근거와 해석을 분리해줘.
```
