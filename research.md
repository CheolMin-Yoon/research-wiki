# Research Router

연구 지식 작업에서만 읽는 얇은 라우터다. 전체 인벤토리는 수동 목록이 아니라 `AI-Sessions/wiki/research/research-library.base`가 frontmatter를 조회해 제공한다.

## Type Routing

| Question | Canonical location |
|---|---|
| 무엇인가, 어떤 경계인가 | `AI-Sessions/wiki/research/concepts/` |
| 어떻게 동작하는가 | `AI-Sessions/wiki/research/methods/` |
| 무엇을 풀고 어떻게 평가하는가 | `AI-Sessions/wiki/research/tasks/` |
| 한 논문의 검증 가능한 근거 | `AI-Sessions/wiki/research/papers/` |
| 코드·저장소의 실제 구현 | `AI-Sessions/wiki/research/sources/` |
| 둘 이상을 어떤 기준으로 고를 것인가 | `AI-Sessions/wiki/research/comparisons/` |
| 반증 가능한 연구 가설 | `AI-Sessions/wiki/research/ideas/` |
| 실행 조건·측정·판정 | `AI-Sessions/wiki/research/experiments/` |

## Contracts

- domain language: `CONTEXT.md`
- topic registry: `schema/research-topics.json`
- ingest and relation rules: `AI-Sessions/wiki/harness/policies/research-policy.md`
- graph and Bases rules: `AI-Sessions/wiki/harness/policies/obsidian-policy.md`
- un-ingested candidates: `AI-Sessions/wiki/harness/state/research-backlog.md`
- raw originals: `AI-Sessions/raw/` (read-only, graph-visible wikilink 금지)

## Current Anchors

- active implementation source: `AI-Sessions/wiki/research/sources/mj-rl.md`
- central hypotheses: `AI-Sessions/wiki/research/ideas/idea-model-based-critic.md`, `AI-Sessions/wiki/research/ideas/idea-physical-feature-graph.md`
- MPC/RL synthesis: `AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures.md`

새 지식 페이지는 독립 근거 두 개 이상 또는 curator 승인을 만족할 때만 만든다. topic membership은 `topics` metadata이고, graph에는 설명·구현·근거·대조·검증의 strong relation만 둔다.
