---
tags: [tier/low]
---

# Ingest Prompt

```text
AI-Sessions/raw/에 추가된 자료를 ingest 해줘.

먼저 architecture.md, research.md, AI-Sessions/wiki/harness/state/brief.md를 확인해줘.

raw 원본은 읽기 전용으로 취급하고 수정·삭제하지 마. 새 wiki 문서를 만들기 전에 research.md 인벤토리와 관련 wiki 노트를 먼저 확인해서 중복을 피하고, 같은 주제가 있으면 새 문서보다 기존 노트 갱신을 우선해줘. 상충하는 내용은 덮어쓰지 말고 "상충:"으로 표시해줘.

- 논문이면: AI-Sessions/wiki/research/papers/에 근거 노트를 작성해줘.
- 레퍼런스 구현 GitHub 레포나 코드 자료면: AI-Sessions/wiki/research/sources/에 구현 분석 노트를 작성해줘.
- 사용자 아이디어·인사이트면: AI-Sessions/wiki/research/ideas/에 작성해줘.
- 실험 사실이면: AI-Sessions/wiki/research/experiments/에 작성해줘.
- 결정, 실패, anti-pattern이면: AI-Sessions/wiki/harness/ 아래 decisions, errors, patterns 중 맞는 곳에 연결해줘.
- granular한 구현 작업 단위는 wiki에 만들지 말고 프로젝트 레포에서 관리해줘.

concept는 transformer, ppo, lipm, centroidal 네 개만 사용해줘. 새 concept 노트를 만들지 말고, 세부 메커니즘이나 일회성 용어는 paper/source 본문에 둬.

새 graph 노트(paper/source/idea 등)는 frontmatter에 `tier/*` 태그(보통 paper/source는 low, idea는 upper)를 부여하고 해당 섬 hub에 등록해줘(obsidian-policy 참조). 작업이 끝나면 research.md와 필요한 map/state를 갱신해줘. log.md는 큰 ingest나 운영 규칙 변화일 때만 한 줄로 남겨줘.

map/index/link/structure를 건드렸으면 마지막에 scripts/wiki_doctor.sh를 실행해줘. ERROR가 있으면 완료 보고 전에 고치거나 못 고친 이유를 보고하고, 그대로 두는 WARN은 이유를 남겨줘.
```
