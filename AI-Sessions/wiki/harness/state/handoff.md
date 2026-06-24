---
tags: [tier/low]
type: handoff
date: 2026-06-24
status: active
last_agent: Claude
suggested_next_agent:
mode: verification
---

# Handoff

## Current Goal

harness 도메인 재구성이 완료되었다. 다음 작업은 Obsidian UI에서 3 섬·tier 색·새 도메인 파일 확인, 또는 실제 연구 작업(ingest/query)이다.

## Last Completed (2026-06-24) — harness 도메인 재구성

파일명 `{도메인}-{타입}` 규칙으로 harness 지식을 재구성했다(누적 정리 이력은 log.md):
- **policies** → `agent-policy`(init 운용 본체, 구 core-agent-protocol) / `obsidian-policy`(구 graph+migration) / `error-policy` / `research-policy`(구 concept-promotion) / `archive-policy`(구 gc-policy).
- **decisions** 5개 → `obsidian-decisions`(graph 결정 통합, four-top-level은 내부 superseded 섹션) + `harness-decisions`(execution-first/records-refactor/workspace 통합).
- **patterns**: 폴더 `anti-patterns`→`patterns`, 파일 → `agent-patterns`.
- **archive**: `garbage-collection`/ 해체 → `archive/`(obsolete-index + setup-log), gc-policy는 archive-policy로 이동.
- **루트 라우터** `harness.md`/`research.md` 신설(plain-path로 detail 안내, 섬 연결 안 함). `architecture.md` Harness/Research 섹션 슬림화.
- **Start Order 4계층화**(자동 CLAUDE/AGENTS → init architecture+brief+agent-policy → 조건부 라우터 → detail), CLAUDE/AGENTS 동기화(C9).
- vault-manifest allowed_harness_dirs, wiki_doctor C10 exclusion·C21 dir 목록 갱신. wiki_doctor ERROR=0 WARN=0, cross-island 0.

## Next Action

- Obsidian UI에서 3 섬(research/harness/docs)·tier 색(빨~파)·도메인 파일명 확인.
- 실제 연구 작업이 생기면 ingest/save/query로 진행. 새 노트는 `{도메인}-{타입}` + `tier/*` 태그.
- 구조 변경 시 `scripts/wiki_doctor.sh` 실행(ERROR=0 유지).

## Dirty / Sensitive Files

- `.obsidian/graph.json`은 Obsidian이 켜져 있으면 덮어쓴다. **이번 세션에 Obsidian이 켜진 채라 colorGroups가 비워졌고 다시 채워 넣었다 — 앱 종료 후 다시 저장돼야 tier 색이 유지된다.**
- `AI-Sessions/raw/`는 손대지 않는다.

## Do Not Touch

- `AI-Sessions/raw/`
- 사용자 승인 없는 source of truth 삭제

## Open Questions

- Obsidian 종료 상태에서 tier 색·3 섬 분리가 의도대로 보이는지 확인 필요.

## Relevant Files

- architecture.md, harness.md, research.md
- scripts/wiki_doctor.sh, vault-manifest.yaml, .obsidian/graph.json
- AI-Sessions/wiki/harness/policies/{agent,obsidian,error,research,archive}-policy.md
- AI-Sessions/wiki/harness/decisions/{obsidian,harness}-decisions.md

## Notes

중복 basename archive는 graph 문제를 만들 수 있으므로 archive 문서는 active 문서와 다른 slug를 사용한다. 라우터(harness.md/research.md)는 다른 섬 파일을 wikilink가 아닌 plain-path로 가리켜 섬 분리를 유지한다.
