---
tags: [tier/low]
---

# Save Prompt

```text
이번 작업 내용을 옵시디언에 저장(save)해줘.

먼저 architecture.md, AI-Sessions/wiki/harness/state/brief.md를 확인해줘.

Save Filter를 통과한 내용만 저장해줘.

1. 향후 내 연구·구현에 반복 재사용될 데이터인가?
2. 미래의 나/다른 AI 에이전트가 이어받기 위해 반드시 읽어야 하는가?
3. 의사결정의 근거를 추적할 필요가 있는가?
4. 다시 시도하면 안 되는 실패/리스크 정보인가?
5. 나와 모든 에이전트가 맞춰야 하는 공통 규칙·설계·구현 가이드인가?

저장 위치:
- 연구 지식: AI-Sessions/wiki/research/{papers,sources,categories,experiments} 또는 단일 idea note `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- 운영 지식: AI-Sessions/wiki/harness/{decisions,errors,patterns,policies,templates,evals,state,archive}

category는 7개(centroidal-wbc/rl-algorithms-frameworks/morphology-aware-policy/graph-transformer-rl/loco-manipulation/dynamics-guided-rl/novelty)만 사용하고 새 category 노트는 만들지 마. category는 research-map에 직접 붙이지 말고 idea의 근거 축으로 연결해. paper는 primary category 1개에서 full-path wikilink로 graph 등록하고, idea/harness/state/pattern 문서에서는 paper wikilink 대신 plaintext path/name을 써. 미수록 논문은 category note의 to-ingest backlog에 plaintext로 남겨. 주관적 연구 해석은 새 idea 파일을 만들지 말고 단일 idea note에 통합할지 판단해. raw 원본은 수정·삭제하지 마.

새 graph 노트를 만들면 frontmatter에 깊이에 맞는 `tier/*` 태그(top/upper/mid/low)를 부여하고 해당 섬 hub에 wikilink로 등록해줘(obsidian-policy 참조). paper는 idea-linked category를 통해 research-map 아래에 등록하되 harness-map과 연결하지 않는다. 파일명은 `{도메인}-{타입}`으로. 저장했다면 관련 map/index를 필요한 만큼 갱신해줘. AI-Sessions/wiki/harness/state/brief.md는 compact current pointer로 유지하고 research 노트는 wikilink가 아니라 plaintext path로 남겨줘(Current Focus, Important Decisions, Active Implementation Source, Read Next). log.md는 Log Policy를 통과하는 큰 구조 변화, 큰 ingest, 중요한 결정, 재발 방지 실패일 때만 한 줄로 남겨줘.

하나도 만족하지 않으면 Wiki에 저장하지 말고 저장하지 않은 이유를 짧게 설명해줘.

map/index/link/archive/prompt/structure를 건드렸으면 마지막에 scripts/wiki_doctor.sh를 실행해줘. ERROR가 있으면 완료 보고 전에 고치거나 못 고친 이유를 보고하고, 그대로 두는 WARN은 이유를 brief/handoff나 완료 보고에 남겨줘.
```
