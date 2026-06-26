---
tags: [tier/low]
---

# Archive Prompt

```text
오래되었거나 현재 구조에서 벗어난 문서를 archive 해줘.

먼저 architecture.md, AI-Sessions/wiki/harness/state/brief.md, AI-Sessions/wiki/harness/policies/archive-policy.md를 확인해줘.

1. 오래된 log, superseded decision, obsolete error, 완료된 task를 찾아줘.
2. 삭제하지 않고 archive 문서로 보존하거나 status: obsolete 처리해줘.
3. research.md 인벤토리와 active map에서 active link를 제거해줘. 구조 지도 자체가 바뀌는 경우에만 architecture.md도 갱신해줘.
4. 필요하면 AI-Sessions/wiki/harness/archive/obsolete-index.md에 기록해줘.
5. brief.md를 갱신해줘.

active 문서와 같은 basename의 archive 사본은 만들지 마. Obsidian wikilink resolution을 깨뜨릴 수 있어.

archive로 map/index/link를 바꿨으면 마지막에 scripts/wiki_doctor.sh를 실행해줘. ERROR가 있으면 완료 보고 전에 고치거나 못 고친 이유를 보고하고, 그대로 두는 WARN은 이유를 남겨줘.
```
