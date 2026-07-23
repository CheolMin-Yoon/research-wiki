---
tags: [tier/low]
type: policy
date: 2026-07-24
status: active
---

# Obsidian Policy

vault 조회, graph, migration 규칙의 정본이다.

## Research Views

`AI-Sessions/wiki/research/research-library.base`가 연구 목록의 정본 조회 계층이다. Stable Knowledge, Evidence, Comparisons, Active Ideas, Experiments, Draft/Curator Review 여섯 view를 제공한다. multi-topic note는 `topics` property로 여러 필터에서 조회하며, 별도 community plugin은 사용하지 않는다.

기본 global graph에는 `research-map`과 stable research 타입(`concept`, `method`, `task`, `paper`, `source`, `comparison`)만 표시한다. `idea`, `experiment`, harness, prompts, docs, raw, archive는 기본 graph에서 제외하되 local graph와 Bases에서는 조회할 수 있다. orphan 표시는 끄고 `exports/research-communities.json`에서 점검한다.

research 타입의 색은 `[type:paper]` 같은 property query로 구분한다. harness/docs의 기존 `tier/*`는 운용 계층 표시에만 남길 수 있고 research note의 분류 계약으로 사용하지 않는다.

## Research Map

`research-map`은 Bases 진입점과 소수의 안정적 anchor만 연결한다. topic별 전수 목록, idea fanout, paper 자동 backlink는 만들지 않는다. research 관계는 의미가 있을 때만 노트 본문의 `## Relations`에 전체 경로 wikilink로 둔다.

## Boundaries

- raw 파일은 기본 graph와 research relation에서 제외한다.
- active와 같은 basename의 vault 내 백업 사본을 만들지 않는다. 복구는 Git 이력을 사용한다.
- `.obsidian/graph.json`은 Obsidian을 종료한 상태에서 수정한다.
- harness 문서의 등록은 각 harness hub가 담당한다. typed research note는 경로와 frontmatter만 맞으면 Bases에 자동 노출된다.

## Registration

| New document type | Register in |
|---|---|
| concept/method/task/paper/source/comparison/idea/experiment | 올바른 folder + frontmatter; Bases 자동 조회 |
| decision/error/pattern/policy/template/eval | 해당 harness hub |
| prompt | `prompts/prompts.md` + `AI-Sessions/wiki/maps/docs-map.md` |
| map | `architecture.md` |

## Migration Workflow

폴더 구조, schema, graph, Bases, prompt routing, raw/wiki boundary, archive 정책, doctor 기준을 바꾸면 migration으로 취급한다.

1. 문제와 Before/After를 기록한다.
2. 영향 파일과 rollback 수단을 확인한다.
3. 링크·property migration을 수행한다.
4. `scripts/wiki_doctor.sh`와 unit tests를 실행한다.
5. brief/handoff/log에 필요한 고신호 상태만 반영한다.

raw는 수정하지 않는다. 큰 삭제는 대상이 명확해야 하며 Git 이력을 복구 수단으로 남긴다.

## Maintenance Contract

- 최상위 문서는 시작 순서와 라우팅만 둔다.
- hub는 목록을 수기로 복제하지 않고 조회 진입점과 판단 기준만 둔다.
- policy/pattern/state는 한 규칙의 정본 한 곳만 유지한다.
- research leaf는 실제 근거와 분석을 소유하고, topic 목록이나 backlink를 본문에 반복하지 않는다.
