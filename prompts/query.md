---
tags: [tier/low]
---

# Query Prompt

```text
위키에서 다음 질문에 대한 답을 찾아줘(query).

먼저 architecture.md로 영역을 잡고, 연구 질문이면 research.md 인벤토리로 관련 후보를 좁혀줘. 필요한 경우 AI-Sessions/wiki/maps, AI-Sessions/wiki/research, AI-Sessions/wiki/harness 안의 해당 노트만 읽어서 질문에 직접 답해줘.

논문·구현·아이디어에 관한 질문이면 세 레이어를 함께 읽어라:
- `research/papers/<slug>.md` (논문 내용·abstract)
- `research/sources/<slug>-code.md` (구현 분석·URL·패턴)
- `research/ideas/idea-*.md` (연결된 아이디어·가설)

wiki note는 스냅샷이라 불완전할 수 있다. 논문의 메커니즘·수식·실험 설계를 단정하기 전에 항상 source of truth를 직접 확인해라:
- `AI-Sessions/raw/papers/<...>.pdf` (논문 원문) — actor/critic 통합, 변형 선택, 수치 같은 디테일은 PDF로 검증한다.
- 대응 코드 레포(있으면) — 구현이 권위 출처다. 사용자 toy/스케치는 권위 출처가 아니다.
wiki note와 raw가 어긋나면 raw를 따르고, note를 갱신하라고 제안해라.

이건 작업 재개(reference)가 아니라 단일 사실 확인이니, 새 문서를 만들지 말고 읽기 전용으로 간결하게 답해줘. 근거가 된 노트와 원문 위치를 함께 알려줘.
```
