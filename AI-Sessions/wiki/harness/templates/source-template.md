---
tags: [tier/low]
type: template
date: 2026-06-24
status: active
target_type: source
---

# Source Template

```markdown
---
type: source
date: YYYY-MM-DD
status: draft | active | superseded
topics:
  - canonical-topic
source:
---

# 구현 분석: <repo 또는 자료명>

## Summary
<무엇을 구현하는지, 어떤 논문/방법과 연결되는지, 왜 관련 있는지>

## Provenance
- checked commit: <hash 또는 unavailable>. 미커밋 working tree 기준이면 그 사실을 명시.

## 핵심 파일
<파일/디렉토리별 역할>

## 가져올 패턴
<내 구현에 흡수할 구체적 패턴>

## 주의점
<의존성, 프레임워크, 이식 리스크, 실행상 핵심 주의사항>

## Relations
<설명 가치가 있는 concept/method/task/paper/comparison 관계만 전체 경로 [[wikilink]]로 연결. topic 중복은 relation으로 만들지 않고 raw는 wikilink 금지>
```
