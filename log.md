# Agent Work Log

이 파일은 `reference` 때 최근 연구 흐름을 빠르게 복원하기 위한 고신호 타임라인입니다. 모든 에이전트 실행을 남기지 말고, 다음 세션이 반드시 알아야 할 구조 변화, 큰 ingest, 결정, 실패만 한 줄로 기록합니다.

형식:

```text
YYYY-MM-DD | kind | summary | linked files
```

## Log

2026-06-23~24 | setup | research-wiki 초기 설계, raw/wiki/schema 분리, graph 구조 실험 후 research-map/resources/prompts 중심으로 안정화. 상세 이력은 GC archive에 보존 | AI-Sessions/wiki/harness/garbage-collection/archived-setup-log-2026-06-24.md
2026-06-24 | ingest | humanoid RL 핵심 papers/sources/concepts/ideas를 raw 기반으로 1차 정리 | AI-Sessions/wiki/research/*
2026-06-24 | structure | active 구조를 maps/research/harness 중심으로 재편하고 raw는 graph에서 제외 | index.md, .obsidian/graph.json
2026-06-24 | harness | records를 harness 운영 계층으로 승격하고 dev-tasks를 research로 이동. entry 문서는 경량화하고 세부 규칙은 prompts와 harness/policies/templates/state/evals로 분리 | AGENTS.md, CLAUDE.md, prompts/*, AI-Sessions/wiki/harness/*, AI-Sessions/wiki/research/dev-tasks/*
2026-06-24 | harness | dev-tasks를 wiki에서 완전히 제거(granular 작업은 프로젝트 레포에서 관리). 반복 실수 방지를 실행 메커니즘으로 승격: anti-pattern을 CLAUDE.md/AGENTS.md 트리거로, evals를 wiki_doctor 검사로 흡수. lint이 wiki_doctor 호출 | CLAUDE.md, AGENTS.md, scripts/wiki_doctor.sh, prompts/lint.md, AI-Sessions/wiki/harness/*
2026-06-24 | hardening | minimal hardening: vault-manifest.yaml 추가, graph-registration-policy/migration-policy 생성, wiki_doctor C20/C21 추가(ERROR=0), archive status 정리, decision Final State 보완 | vault-manifest.yaml, scripts/wiki_doctor.sh, AI-Sessions/wiki/harness/policies/*
2026-06-24 | compaction | harness 압축(53->37): 명령별 policy 7개를 prompts에 인라인 후 삭제, GC 정책 중복 제거, superseded evals(check 3+probe 3) 삭제, graph-registration를 graph-policy로 병합, active-context를 brief로 흡수. wiki_doctor ERROR=0 | prompts/*, AI-Sessions/wiki/harness/{policies,evals,state}/*
2026-06-24 | structure | index + memory -> architecture.md 통합: memory.md 삭제(중복), index.md를 architecture.md로 rename. entry_files/wiki_doctor C11/Start Order/전체 참조 갱신. wiki_doctor ERROR=0 | architecture.md, CLAUDE.md, AGENTS.md, vault-manifest.yaml, scripts/wiki_doctor.sh, prompts/*
2026-06-24 | graph | graph 재구성: 4 폴더 group -> 3 독립 섬(research/harness/docs) + tier 태그 색상(빨~파). harness 의미그룹 4개 신설, resources를 research로 강등, ~77노트에 tier/* 태그, graph.json colorGroups tag화. wiki_doctor ERROR=0 | AI-Sessions/wiki/maps/*, .obsidian/graph.json
2026-06-24 | structure | harness 도메인 재구성: 파일명 {도메인}-{타입} 규칙. policies→agent/obsidian/error/research/archive-policy, decisions 5개→obsidian/harness-decisions, anti-patterns→patterns(agent-patterns), garbage-collection→archive/. 루트 라우터 harness.md/research.md 신설, Start Order 4계층. wiki_doctor ERROR=0 cross-island 0 | architecture.md, harness.md, research.md, AI-Sessions/wiki/harness/*, CLAUDE.md, AGENTS.md
