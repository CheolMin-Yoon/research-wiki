---
tags: [tier/low]
type: handoff
date: 2026-07-24
status: active
last_agent: Codex
suggested_next_agent:
mode: implementation
---

# Handoff

## Current Goal

typed research model과 3-command interface 구현·검증은 완료됐다. `research-wiki` 변경을 먼저 검토·병합한 뒤 `mj_rl`의 포인터 문서 변경을 별도 PR로 전달한다. 별도 tracking issue는 만들지 않는다.

## Implemented

- concept 5, method 7, task 2의 초기 stable knowledge 페이지
- canonical topic registry와 paper/source/idea/experiment metadata migration
- category 7개와 `primary_category` 제거; idea 5개를 `research/ideas/`로 이동·가설 형식으로 축약
- Research Library Bases 6 view와 type-based stable global graph
- `mj_rl` 조사에서 comparison 5개, 직접 근거 paper 6개, `tsid-code` source 이관
- pure-Python typed schema validator와 resolution 1.15 Louvain report
- unit tests와 GitHub Actions quality gate
- 공개 prompt를 query/ingest/reflect로 압축하고 resume/durable capture/post-write validation/archive maintenance를 자동 수명주기로 전환
- wiki, repo-local docs, `.agents/skills`의 정본 경계와 source portal 원칙 명시
- `mj_mpc` checked commit 기반 source/doc portal과 NIPFM flywheel 핵심 digest 추가

## Repository State

- `research-wiki`: branch `refactor/typed-research-wiki`
- `mj_rl`: branch `refactor/wiki-research-pointers`; 다섯 research 문서는 정본 URL과 저장소별 차이만 남김
- `mj_mpc`: 변경 없음
- 사용자 변경 `research.code-workspace`: 수정하거나 stage하지 않음
- `AI-Sessions/raw/`: diff 없음

## Verification

- `scripts/wiki_doctor.sh`: `ERROR=0`, `WARN=0`
- `python3 -m unittest discover -s tests -v`: schema/topic/legacy/folder/relation/command interface/Louvain 12 tests 통과
- `python3 scripts/analyze_research_graph.py --check`: tracked report와 현재 graph 일치
- 두 저장소 `git diff --check`: 통과

## Manual Check Before Merge

1. Obsidian에서 `research-library.base`의 6 view를 연다.
2. multi-topic paper가 topic 필터마다 조회되는지 확인한다.
3. global graph가 stable research 타입과 research-map만 표시하고 orphan을 숨기는지 확인한다.
4. local graph에서 idea/experiment 근거 relation이 보이는지 확인한다.
5. wiki PR 병합 후에만 `mj_rl` 포인터 PR을 연다.

## Rollback

삭제한 category와 experiment hub는 별도 archive가 없으며 Git 이력에서 복구한다. raw 원본은 migration 중 수정하지 않았다.
