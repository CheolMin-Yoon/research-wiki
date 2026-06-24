---
tags: [tier/low]
---

# Lint Prompt

```text
이 Obsidian 연구 위키를 lint 해줘.

먼저 `scripts/wiki_doctor.sh`를 실행해줘. C1~C12 및 C20/C21을 기계적으로 검사한다: C1 깨진/모호 wikilink, C2 wiki->raw 링크, C3 frontmatter 필수 필드, C4 concept 화이트리스트, C5 stale draft, C6 ingest coverage(raw->wiki 컴파일), C7 source provenance, C8 concept orphan, C9 AGENTS/CLAUDE 동기화, C10 obsolete path, C11 index coverage, C12 secret scan, C20 state/log size limits, C21 harness graph registration. ERROR가 있으면 먼저 그걸 보고해줘.

새 active 문서를 만들거나 이동한 경우, `AI-Sessions/wiki/harness/policies/obsidian-policy.md`의 Registration 규칙에 따라 적절한 hub에 wikilink로 등록했는지 확인한다.

그다음 architecture.md, AI-Sessions/wiki/harness/state/brief.md를 확인하고, wiki_doctor가 자동으로 못 잡는 아래 항목을 사람 판단으로 점검해줘.

[구조·경계]
1. raw 원본이 수정·삭제되었거나 wiki 영역에 섞여 있지 않은가?
2. active wiki 구조가 AI-Sessions/wiki/maps, AI-Sessions/wiki/research/{papers,sources,concepts,ideas,experiments}, AI-Sessions/wiki/harness 기준을 따르는가?
3. 중요한 wiki 문서가 architecture.md와 map에 누락되어 있지 않은가?
4. log.md에 고신호 인수인계 사건만 남아 있는가?
5. source/repo/code 노트가 research/sources 아래로만 노출되고, raw 파일은 graph에 노출되지 않는가?
6. 민감정보, API 키, 토큰, 개인정보가 저장되어 있지 않은가?
7. CLAUDE.md와 AGENTS.md 규칙이 서로 어긋나지 않는가?

[Wiki 오염 탐지]
8. paper/source/concept 노트에 주관적 해석이 근거처럼 섞여 있지 않은가?
9. 주관적 연구 해석은 AI-Sessions/wiki/research/ideas/에만 있는가?
10. transformer, ppo, lipm, centroidal 외 concept 노트가 active concept처럼 쓰이고 있지 않은가?
11. 같은 내용이 여러 노트에 중복 저장되어 있지 않은가?
12. 출처 없는 decision, 근거 없는 단정, 미검증 추측 표시 누락이 있지 않은가?
13. Save Filter를 통과하지 못한 일회성 정보가 wiki에 올라와 있지 않은가?
14. obsolete/archive 문서가 active map에 잘못 노출되어 있지 않은가?

문제가 있으면 파일별로 수정 제안을 정리해줘. 기본은 보고만 하고, 수정은 별도 승인 뒤 진행해줘.
```
