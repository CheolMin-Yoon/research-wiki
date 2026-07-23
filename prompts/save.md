---
tags: [tier/low]
---

# Save Prompt

```text
이번 작업 내용을 옵시디언에 저장(save)해줘.

먼저 architecture.md, AI-Sessions/wiki/harness/state/brief.md를 확인해줘. 연구 지식이면 research-policy와 topic registry도 읽어줘.

아래 Save Filter를 하나 이상 통과한 내용만 저장해줘.
1. 향후 연구·구현에 반복 재사용되는가?
2. 미래의 나/에이전트가 이어받기 위해 필요한가?
3. 의사결정 근거를 추적해야 하는가?
4. 다시 시도하면 안 되는 실패·리스크인가?
5. 모든 에이전트가 맞춰야 할 공통 규칙인가?

연구 지식은 type에 맞춰 AI-Sessions/wiki/research/{concepts,methods,tasks,papers,sources,comparisons,ideas,experiments}/에 저장해줘. 공통 frontmatter type/date/status/topics/source 계약을 따르고 topics에는 schema/research-topics.json의 active canonical ID만 써. 새 topic 후보는 pending으로 제안하고 큐레이터 승인 없이 active로 사용하지 마. category와 primary_category는 만들지 마.

idea는 독립된 반증 가능 가설이고 paper의 부모가 아니다. concept/method/task는 독립 근거 2개 이상 또는 큐레이터 승인 시에만 만들어. 설명 가치가 있는 관계만 ## Relations에 전체 경로 wikilink로 기록하고, topic membership·자동 backlink·논문 전수 목록은 만들지 마. raw 원본은 수정·삭제하거나 wikilink하지 마.

운영 지식은 AI-Sessions/wiki/harness/{decisions,errors,patterns,policies,templates,evals,state,archive}/에 둬. granular 구현 작업은 프로젝트 저장소에서 관리해. typed research note는 Bases에 자동 등록되며 수동 inventory를 만들지 마. 큰 구조 변경·ingest·중요 결정·재발 방지 실패만 log.md에 한 줄 남겨.

구조, link, schema, graph, Bases, prompt를 건드렸으면 scripts/wiki_doctor.sh를 실행해 ERROR=0, WARN=0을 확인해줘. 하나도 저장 기준을 만족하지 않으면 저장하지 않은 이유만 짧게 설명해줘.
```
