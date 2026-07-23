---
tags: [tier/low]
type: error
date: 2026-06-24
status: active
applies_to: Obsidian graph, wikilink resolution, research-wiki archive
replaced_by:
severity: medium
source: 2026-06-24 raw 기반 wiki 재작성 세션 graph 디버깅
related_experiments:
---

# Error: 옵시디언 graph / wikilink 함정

## Symptom

graph view에서 research relation 일부가 끊기고 여러 논문(body-transformer, footstep, arm-cam, mjlab, rsl-rl)이 미연결 노드로 떴다. 파일에는 wikilink가 있는데도 graph 엣지가 붙지 않았다.

`.obsidian/graph.json`을 외부에서 수정해도 Obsidian 실행 상태에 따라 설정이 되돌아갔고, 파일 이동/삭제 후에도 graph 캐시가 즉시 갱신되지 않았다.

## Root Cause

Obsidian은 wikilink를 경로가 아니라 **basename으로 전역 resolve**한다. 그리고 이 vault는 CLAUDE.md의 "논문↔코드 공유 slug" 규칙 때문에 **`research/papers/<slug>.md`와 `raw/repos/<slug>.md`가 같은 이름**이다.

따라서 `[[2024-sferrazza-body-transformer]]`는 graph에 보이는 paper가 아니라 `AI-Sessions/raw/repos/2024-sferrazza-body-transformer.md`(alphabet상 `raw` < `research`라 우선 선택)로 resolve됐다. raw stub은 graph 필터 밖이라 엣지가 **조용히 드롭**되고 paper는 orphan이 됐다.

검증: raw/repos stub이 **있는** 논문(footstep·arm-cam·body-transformer·mjlab·rsl-rl)은 전부 미연결, stub이 **없는** 논문(vaswani·orin·schulman)은 전부 정상 연결. 충돌 여부가 정확한 기준이었다. (여러 concept이 공유하는 논문이라서가 아니다 — body-transformer는 한 concept만 거는데도 끊겼다.)

`_archive/`에 둔 pre-rewrite 사본도 같은 basename 충돌을 일으켰다(곁다리 원인). → archive는 삭제했다.

Obsidian은 실행 중 graph view 설정을 만지거나 종료할 때 메모리 상태로 `.obsidian/graph.json`을 덮어쓴다. 또한 메타데이터를 mtime 기준으로 캐싱한다.

## Trigger

- `[[<slug>]]`처럼 짧은 wikilink를 쓰고 raw/repos 또는 archive에 같은 basename이 있을 때.
- active 파일과 같은 basename의 archive 사본을 vault 안에 둘 때.
- Obsidian을 켠 상태에서 `.obsidian/graph.json`을 외부 편집할 때.
- 외부 파일 이동 뒤 source note mtime이 바뀌지 않을 때.

## Fix

research relation을 전체 경로로 바꾸고, active와 같은 basename의 archive 사본을 graph-visible 위치에 두지 않는다. graph 설정은 Obsidian을 종료한 상태에서만 수정한다.

## Prevention Rule

- **설명 가치가 있는 research relation은 `## Relations`에서 full-path wikilink로 기록한다.** 짧은 `[[<slug>]]`는 raw/repos stub과 충돌해 graph에서 끊길 수 있으므로 쓰지 않는다. topic membership은 relation으로 만들지 않는다.
- vault 안에 active와 같은 basename 사본(archive, 백업)을 두지 않는다. 보존이 필요하면 다른 slug의 archive 문서에 내용을 옮기거나 git history를 사용한다.
- `.obsidian/graph.json`, `app.json` 등 설정 파일은 **Obsidian을 완전히 종료한 상태에서** 수정한다. 켜진 채 고치면 종료 시 덮어써진다.
- 색상 그룹 같은 건 차라리 UI에서 직접 설정하는 게 안전하다.
- 외부 파일 이동/삭제 후 graph가 갱신되지 않으면 source note의 mtime을 바꾼다.

## Related Experiments

- 해당 없음.

## Links

- source: 2026-06-24 wiki 재작성 세션 graph 디버깅
- 관련: AI-Sessions/wiki/research/sources/mj-rl.md (이전 mj-rl-integration-roadmap은 wiki에서 제거되어 프로젝트 레포로 이관)
