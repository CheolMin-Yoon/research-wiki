# Research Wiki Architecture

이 문서는 vault 전체의 구조 지도입니다. 에이전트가 가장 먼저 읽어 "무엇이 있고 어떻게 동작하는가"를 복원합니다. 현재 구조는 `research = 무엇을 알고 있는가`, `harness = 어떻게 일하고 무엇을 피할 것인가`, `state = 지금 어디까지 왔는가`, `evals = wiki 품질을 어떻게 점검할 것인가`로 나뉩니다.

## Start Here (읽는 순서)

1. **자동**: CLAUDE / AGENTS — 항상 context (읽기 단계 아님)
2. **init**: architecture(이 문서) → `AI-Sessions/wiki/harness/state/brief` → (이어받으면) handoff
3. **영역 라우터(조건부)**: harness / research 중 작업에 해당하는 것만
4. **detail**: 라우터가 가리키는 파일 또는 `prompts/<command>`

`log`는 최근 흐름 복원이 필요할 때만 보는 선택 항목입니다.

## Vault Structure

- `AI-Sessions/raw/`: source of truth. papers, repos, ideas 원본. 에이전트가 임의 수정하지 않음
- `AI-Sessions/conversations/`: 세션 인수인계 보조 자료
- `AI-Sessions/wiki/maps/`: graph backbone 진입점
- `AI-Sessions/wiki/research/`: papers, sources, concepts, ideas, experiments
- `AI-Sessions/wiki/harness/`: state, decisions, errors, patterns, archive, policies, templates, evals (라우터: harness.md)
- `prompts/`: save/reference/query/ingest/lint/reflect/archive 명령별 실행 규칙

구조 source of truth는 `vault-manifest.yaml`(schema_version, allowed dirs, state_limits, doctor triggers), 구조 검증은 `scripts/wiki_doctor.sh`를 따릅니다. 기본으로 모든 파일을 읽지 않고 현재 작업에 필요한 것만 읽습니다.

## Commands

- `save` · `reference` · `query` · `ingest` · `lint` · `reflect` · `archive`
- 프롬프트 허브: prompts

## Graph Hubs

Obsidian graph는 서로 edge로 연결되지 않는 **3개의 독립 섬**으로 구성합니다. 각 섬은 root에서 tier별로 뻗어 내려가며, 색은 tier(최상위 빨강 → 하위 파랑)로 구분합니다. architecture는 docs 섬 소속이므로 아래 root들을 wikilink가 아닌 일반 텍스트로만 가리켜 섬을 연결하지 않습니다.

- `research-map` (research 섬 root) — idea(상위) → concept(중위) → paper(하위). resources/experiments도 상위 가지.
- `harness-map` (harness 섬 root) — state/rules/lessons/machinery(상위) → 폴더 hub(중위) → 파일(하위).
- `docs-map` (docs 섬 root) — prompts 허브와 root entry 문서(상위) → 개별 prompt(하위).

raw 파일은 graph-visible wikilink로 연결하지 않습니다. paper/source는 hub처럼 확장하지 않는 leaf로 유지하되, 관계 정본인 `## Links` wikilink는 허용합니다. tier 분류와 색은 `.obsidian/graph.json`의 tag 기반 colorGroups가 담당하며, 새 노트는 `tier/*` 태그를 부여해야 합니다.

## Research

연구 지식의 detail 라우팅과 전체 paper/source/concept/idea 인벤토리는 **research**(research.md)가 담당합니다(작업할 때만 읽음). `architecture.md`는 init context 절약을 위해 연구 목록을 직접 들지 않습니다.

## Harness

운용 지식의 detail 라우팅은 **harness**(harness.md)가 담당합니다(작업할 때만 읽음). 요약:

- 파일명은 `{도메인}-{타입}`. `agent-*`(agent-policy, agent-patterns)는 init 로드, `{domain}-*`(obsidian/error/research/archive/mjlab…)은 그 작업 때 로드.
- policies: agent / obsidian / error / research / archive-policy
- decisions: obsidian-decisions, harness-decisions
- errors: mjlab-errors, obsidian-errors · patterns: agent-patterns, research-patterns
- state: brief, handoff, tasks · archive: obsolete-index + setup-log · templates · evals(=wiki_doctor)
