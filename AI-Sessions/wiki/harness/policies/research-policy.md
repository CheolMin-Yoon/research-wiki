---
tags: [tier/low]
type: policy
date: 2026-06-24
status: active
---

# Research Policy

연구 지식 category와 ingest 분류 규칙이다. category 추가/ingest 작업일 때 읽는다.

## Active Categories

`AI-Sessions/wiki/research/categories/`에는 7개 category만 active로 유지한다: centroidal-wbc, rl-algorithms-frameworks, morphology-aware-policy, graph-transformer-rl, loco-manipulation, dynamics-guided-rl, novelty.

## Rule

category는 research-map에 직접 붙이지 않고 idea의 근거 축으로 연결한다. paper는 primary category 1개에서 full-path wikilink로 graph 등록한다(partition, graph 중복 방지). idea/harness/state/pattern 문서에서 paper를 언급할 때는 plaintext path/name을 쓴다. 세부 메커니즘·수식은 원전 paper/source 본문에 두고, 부차 연관은 plaintext로 남긴다. 미수록 논문은 해당 category 노트의 to-ingest backlog에 plaintext로만 남긴다.

## Promotion Gate

새 category가 정말 필요하면 먼저 decision으로 근거를 남기고, 기존 7개 중 하나로 흡수할 수 없는지 확인한다.

## Relation & Provenance Schema

신규/수정 research 노트부터 아래 형식을 따른다. 기존 노트는 일괄 이관하지 않는다.

- 관계의 정본은 본문 `## Links` 섹션이다. Obsidian graph edge가 필요한 source/idea/category/experiment 관계와 category→paper 등록만 `[[wikilink]]`를 쓰고, paper와 harness를 잇는 관계는 plaintext로 남긴다.
- `related_*` frontmatter는 선택 mirror다. 쓰는 경우 같은 관계를 `## Links`에도 반복해 graph와 검색이 어긋나지 않게 한다.
- raw 원본은 graph-visible wikilink로 직접 연결하지 않는다. `source:` frontmatter 또는 plain path로만 둔다.
- source 노트의 repo provenance는 `checked commit:` 용어로 통일한다. 미커밋 working tree를 기준으로 한 분석이면 `checked commit:` 옆에 그 사실을 명시한다.
- 추측·해석은 근거 사실과 분리하고, 주관적 연구 해석은 새 idea 파일을 만들지 말고 단일 idea note(`AI-Sessions/wiki/research/idea-physical-feature-graph.md`)에 통합할지 판단한다.
