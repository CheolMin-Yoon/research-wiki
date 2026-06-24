---
tags: [tier/low]
type: policy
date: 2026-06-24
status: active
---

# Obsidian Policy

vault/graph 구조와 그 변경(migration) 규칙이다. graph·구조·map·prompt routing을 바꾸는 작업일 때 읽는다.

## Top-Level Islands

graph는 서로 edge로 연결되지 않는 **3개 독립 섬**이다. 각 섬은 root(tier/top) 하나에서 tier별로 뻗는다. 상세 근거는 [[AI-Sessions/wiki/harness/decisions/obsidian-decisions|obsidian-decisions]].

- `research-map`(섬 root): idea/resources/experiments(상위) → concept(중위) → paper/source(하위)
- `harness-map`(섬 root): state/rules/lessons/machinery group(상위) → 폴더 hub(중위) → 파일(하위)
- `docs-map`(섬 root): prompts 허브 + root entry 문서(상위) → 개별 prompt(하위)

## Tier 색상

색은 폴더가 아니라 frontmatter `tier/*` 태그로 결정한다. 새 노트는 깊이에 맞는 태그를 부여한다: `tier/top`(섬 root) → `tier/upper` → `tier/mid` → `tier/low`. colorGroups가 태그로 매칭한다(빨강→파랑). root docs는 `path:` 절로 upper 색을 받는다.

## Research Rules

- idea는 관련 concept로, concept는 paper로 연결한다. concept->paper 링크는 전체 경로를 사용한다.
- paper/source는 되도록 leaf로 둔다.
- source/repo/code 노트는 `resources`(research 섬의 상위 가지) 아래에 둔다.

## Boundaries

- raw 파일은 graph-visible node로 만들지 않는다(filter와 wikilink 양쪽에서 제외).
- 섬끼리 wikilink로 연결하지 않는다. architecture는 docs 섬 소속이며 다른 섬 root를 일반 텍스트로만 가리킨다.
- 새 graph-visible 노트는 해당 섬의 hub에서 연결하고 `tier/*` 태그를 부여한다.
- `.obsidian/graph.json`은 Obsidian 실행 중 덮어써질 수 있으므로 종료한 상태에서 수정한다.

## Registration

새 active 문서는 생성만 하지 않고 적절한 hub에 wikilink로 등록한다. `wiki_doctor` C21이 harness 하위 문서의 hub 등록을 검사한다.

| New document type | Register in |
|---|---|
| paper | related concept note + architecture.md |
| source | AI-Sessions/wiki/maps/resources.md |
| idea | AI-Sessions/wiki/maps/research-map.md |
| experiment | AI-Sessions/wiki/research/experiments/experiments.md |
| decision | AI-Sessions/wiki/harness/decisions/decisions.md |
| error | AI-Sessions/wiki/harness/errors/errors.md |
| pattern | AI-Sessions/wiki/harness/patterns/patterns.md |
| policy | AI-Sessions/wiki/harness/policies/policies.md |
| template | AI-Sessions/wiki/harness/templates/templates.md |
| eval | AI-Sessions/wiki/harness/evals/evals.md |
| prompt | prompts/prompts.md + AI-Sessions/wiki/maps/docs-map.md |
| map | architecture.md |

## Migration Workflow

vault 구조, 경로, graph, command routing, status lifecycle, prompt routing을 바꾸는 작업은 migration이다. 트리거: 폴더 구조 변경, map/index backbone 변경, prompt routing 변경, raw/wiki boundary 변경, concept promotion rule 변경, archive/obsolete 정책 변경, wiki_doctor 검사 기준 변경, graph registration rule 변경.

1. Problem 정의 → 2. Before/After 명시 → 3. 영향 파일 목록 → 4. Link migration 계획 → 5. Risk와 rollback plan → 6. 변경 수행 → 7. `scripts/wiki_doctor.sh` → 8. brief/handoff 갱신 → 9. log.md 1줄.

규칙: raw 미수정, 삭제보다 archive/status, 같은 basename archive 금지, migration decision에 Final State 명시, rollback plan 없이 큰 변경 금지.
