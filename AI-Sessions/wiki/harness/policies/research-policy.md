---
tags: [tier/low]
type: policy
date: 2026-06-24
status: active
---

# Research Policy

연구 지식 계층(concept 등) 규칙이다. concept 추가/ingest 작업일 때 읽는다.

## Active Concepts

`AI-Sessions/wiki/research/concepts/`에는 transformer, ppo, lipm, centroidal 네 개 concept만 active로 유지한다.

## Rule

세부 메커니즘, paper-specific 용어, 일회성 분류축은 새 concept 노트로 만들지 않고 paper/source/idea 본문에 둔다.

## Promotion Gate

새 concept가 정말 필요하면 먼저 decision으로 근거를 남기고, 기존 네 concept 중 하나로 흡수할 수 없는지 확인한다.

## Relation & Provenance Schema

신규/수정 research 노트부터 아래 형식을 따른다. 기존 노트는 일괄 이관하지 않는다.

- 관계의 정본은 본문 `## Links` 섹션의 `[[wikilink]]`다. Obsidian graph는 frontmatter를 edge로 그리지 않으므로, 중요한 paper/source/concept/idea/experiment 관계는 본문 링크로 남긴다.
- `related_*` frontmatter는 선택 mirror다. 쓰는 경우 같은 관계를 `## Links`에도 반복해 graph와 검색이 어긋나지 않게 한다.
- raw 원본은 graph-visible wikilink로 직접 연결하지 않는다. `source:` frontmatter 또는 plain path로만 둔다.
- source 노트의 repo provenance는 `checked commit:` 용어로 통일한다. 미커밋 working tree를 기준으로 한 분석이면 `checked commit:` 옆에 그 사실을 명시한다.
- 추측·해석은 근거 사실과 분리하고, 주관적 연구 해석은 가능하면 `research/ideas/`에 둔다.
