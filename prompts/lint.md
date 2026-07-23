---
tags: [tier/low]
---

# Lint Prompt

```text
이 Obsidian 연구 위키를 lint 해줘.

먼저 scripts/wiki_doctor.sh를 실행해. 기계 검사 정본은 doctor와 내부 Python validator다. ERROR 또는 WARN이 있으면 먼저 보고해.

그다음 architecture.md, research-policy, obsidian-policy, brief.md를 읽고 자동 검사가 못 잡는 의미 품질을 점검해.

[구조·경계]
1. raw 원본이 수정·삭제되거나 wiki 영역에 섞이지 않았는가?
2. research note가 concept/method/task/paper/source/comparison/idea/experiment 타입과 폴더 계약을 따르는가?
3. category, primary_category, 단일 소속 규칙이 active 정책·prompt에 남아 있지 않은가?
4. CLAUDE.md와 AGENTS.md의 의미가 동기화되어 있는가?
5. 비밀, token, 개인정보가 저장되지 않았는가?

[연구 의미]
6. topics가 분류 편의용 edge나 본문 목록으로 중복되지 않았는가?
7. concept/method/task가 독립 근거 2개 이상 또는 큐레이터 승인 없이 만들어지지 않았는가?
8. paper/source에 연구자의 해석이 원문 사실처럼 섞이지 않았는가?
9. idea에 가설, 반증 조건, 찬성·반대 근거, 관련 experiment가 있는가?
10. comparison에 비교 축, 근거, 선택 기준, 한계가 있는가?
11. 설명 가치 없는 자동 backlink나 paper 전수 목록이 재도입되지 않았는가?

[조회·graph]
12. Research Library의 6개 view가 의도한 타입과 status를 조회하는가?
13. 기본 global graph가 stable research 타입과 research-map만 표시하고 orphan을 숨기는가?
14. relation이 full-path이며 동일 basename raw stub과 충돌하지 않는가?
15. Louvain 보고서를 분류 정본이나 note frontmatter로 쓰지 않았는가?

[계층]
16. 최상위 문서가 detail DB가 되지 않았는가?
17. hub가 수동 inventory를 복제하지 않는가?
18. policy/pattern/state가 같은 규칙을 여러 정본으로 반복하지 않는가?

기본은 보고만 하고 수정은 별도 승인 뒤 수행해.
```
