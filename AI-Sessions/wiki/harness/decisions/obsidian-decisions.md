---
tags: [tier/low]
type: decision
date: 2026-07-24
status: active
---

# Obsidian / Graph Decisions

최신 결정이 위에 있으며 대체된 결정은 아래에 역사 기록으로 남긴다.

## Typed stable graph + Bases (active)

### Decision

- 기본 global graph는 `research-map`과 stable research 타입(concept, method, task, paper, source, comparison)만 표시한다.
- ideas와 experiments는 local graph/Bases로 조회한다.
- topic membership은 graph edge가 아니며 `research-library.base`가 다중 분류와 전수 조회를 담당한다.
- research 색은 `type` property query로 구분하고 orphan은 Louvain 보고서에서 검사한다.
- `research-map`은 Bases와 네 개의 안정 anchor만 링크한다.

### Reason

아이디어를 분류 트리의 뿌리로 두면 가설 변경이 지식 구조 전체를 흔든다. 단일 category partition은 다중 주제 논문을 왜곡하며, 모든 membership을 edge로 표현하면 graph가 읽기 어려워진다. 타입, topic metadata, 설명적 relation을 분리하면 세 축이 독립적으로 진화한다.

### Impact

새 research note는 올바른 폴더, `type/date/status/topics`, canonical topic을 갖추면 Bases에 자동 등록된다. 의미 있는 relation만 전체 경로 wikilink로 기록한다. category와 `primary_category`는 사용하지 않는다.

## 3개 독립 섬 + tier 색상 (superseded)

2026-06-24의 기존 결정은 idea → category → paper 트리와 `tier/*` 기반 research 색상을 사용했다. typed stable graph 결정으로 대체되었다. harness/docs에서 계층 안내용 tier는 유지할 수 있으나 research 분류에는 사용하지 않는다.

## 최상위 group 4개 고정 (superseded)

resources를 독립 top-level group으로 유지하던 초기 결정은 이후 research 섬 편입을 거쳐 현재의 typed stable graph로 대체되었다.

## Relations

- [[AI-Sessions/wiki/harness/policies/obsidian-policy|Obsidian Policy]]
- [[AI-Sessions/wiki/harness/policies/research-policy|Research Policy]]
- [[AI-Sessions/wiki/harness/errors/obsidian-errors|Obsidian Errors]]
