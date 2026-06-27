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

- `research-map`(섬 root): idea/resources/experiments(상위). category는 idea에서 fanout하고 category → paper로 내려감
- `harness-map`(섬 root): state/rules/lessons/machinery group(상위) → 폴더 hub(중위) → 파일(하위)
- `docs-map`(섬 root): prompts 허브 + root entry 문서(상위) → 개별 prompt(하위)

## Tier 색상

색은 폴더가 아니라 frontmatter `tier/*` 태그로 결정한다. 새 노트는 깊이에 맞는 태그를 부여한다: `tier/top`(섬 root) → `tier/upper` → `tier/mid` → `tier/low`. colorGroups가 태그로 매칭한다(빨강→노랑→초록→파랑). root docs는 `path:` 절로 upper 색을 받는다.

## Research Rules

- research-map은 category를 직접 링크하지 않는다. idea가 관련 category로 fanout하고, paper의 graph 등록은 primary category 1개가 full-path wikilink로 담당한다.
- idea/harness/state/pattern 문서에서 paper를 언급할 때는 plaintext path/name을 사용한다. paper 내부의 paper-to-paper wikilink는 허용한다.
- source/repo/code 노트는 `resources`(research 섬의 상위 가지) 아래에 둔다.

## Boundaries

- raw 파일은 graph-visible node로 만들지 않는다(filter와 wikilink 양쪽에서 제외).
- 섬끼리 wikilink로 연결하지 않는다. architecture는 docs 섬 소속이며 다른 섬 root를 일반 텍스트로만 가리킨다.
- harness 노트는 research 노트로 wikilink하지 않고 plaintext path로만 가리킨다.
- 새 graph-visible 노트는 해당 섬의 hub에서 연결하고 `tier/*` 태그를 부여한다.
- `.obsidian/graph.json`은 Obsidian 실행 중 덮어써질 수 있으므로 종료한 상태에서 수정한다.

## Registration

새 active 문서는 생성만 하지 않고 적절한 hub에 wikilink로 등록한다. `wiki_doctor` C15가 harness 하위 문서의 hub 등록을 검사한다.

| New document type | Register in |
|---|---|
| paper | research.md inventory + idea-linked primary category note full-path wikilink |
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

vault 구조, 경로, graph, command routing, status lifecycle, prompt routing을 바꾸는 작업은 migration이다. 트리거: 폴더 구조 변경, map/index backbone 변경, prompt routing 변경, raw/wiki boundary 변경, category promotion rule 변경, archive/obsolete 정책 변경, wiki_doctor 검사 기준 변경, graph registration rule 변경.

1. Problem 정의 → 2. Before/After 명시 → 3. 영향 파일 목록 → 4. Link migration 계획 → 5. Risk와 rollback plan → 6. 변경 수행 → 7. `scripts/wiki_doctor.sh` → 8. brief/handoff 갱신 → 9. log.md 1줄.

규칙: raw 미수정, 삭제보다 archive/status, 같은 basename archive 금지, migration decision에 Final State 명시, rollback plan 없이 큰 변경 금지.

## Tier Maintenance Contract

MD 계층별 역할 계약. 시간이 지나도 최상위 문서가 detail DB로 비대해지지 않게 한다. 한 사실/규칙은 **정본 한 곳**에 두고 다른 tier는 restate 대신 링크한다(근거: [[AI-Sessions/wiki/harness/patterns/agent-patterns|agent-patterns]] "정본 한 곳+링크"). lint의 [계층 감사]가 이를 수동 점검한다.

- **최상위 (AGENTS·CLAUDE·architecture·harness·research·log)** — 시작 순서·구조 지도·영역 라우팅·현재 포인터만. 금지: 세부 policy 복붙, doctor C번호 전체 나열, paper/source 전체 설명, 과거 이력 장문. 크기 가이드 ~60줄 안팎. init pattern/state는 C14 cap(brief 80/handoff 120/log 30).
- **차상위 hub/router (maps/\*, prompts/\*, harness/{dir}/{dir}.md)** — graph backbone + routing만. 대표 링크 + 짧은 판단 기준만, 세부는 mid/leaf로. prompt 문서는 실행 절차만 담고 기계 검사 항목 목록은 `wiki_doctor`(script 출력)에 위임한다.
- **중간 정본 (policy·pattern·state)** — `agent`/`research`/`obsidian`-policy = 정책 정본. `agent-patterns` = init용 보편 패턴만, 도메인 패턴은 `research-patterns` 등 on-demand. `brief`/`handoff` = compact current pointer, 과거 이력은 `log.md`/archive 링크로만.
- **leaf (paper·source·idea·experiment)** — 실제 지식 정본. category는 중위 분류 hub로 둔다. paper는 primary category의 full-path wikilink로 research graph에 등록하고, harness와 잇는 관계는 plaintext로 표현한다(Research Rules 참조).
