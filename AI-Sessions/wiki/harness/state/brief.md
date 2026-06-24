---
tags: [tier/low]
type: state
date: 2026-06-24
status: active
---

# Brief

## Current Focus

research-wiki를 Research Agent Harness Wiki로 리팩토링했다. active 구조는 raw, research, harness, state, maps, prompts로 분리된다.

## Active Research Direction

Humanoid locomotion RL, centroidal/CAM, LIPM/eICP, graph/transformer policy를 중심으로 논문·source·idea를 축적한다.

## Active Implementation Source

`AI-Sessions/wiki/research/sources/mj-rl.md`가 현재 active implementation source다. `mj_rl`을 실험 런타임 허브로 두고 ModernRobotics, mj_control, DL_GNN_Transformer에서 필요한 패턴만 흡수한다.

## Active Study: Body Transformer

원 논문 레포 클론 완료: `/home/frlab/DL_GNN_Transformer/body-transformer-ref` (https://github.com/carlosferrazza/BodyTransformer). 사용자 노트북은 `/home/frlab/DL_GNN_Transformer/Body Transformer/` (00~07). 다음 단계: 노트북 구현 이어받기 → mj_rl 통합.

## Scope & Constraints

- raw는 수정하지 않는다. concept는 transformer/ppo/lipm/centroidal 네 개만 active로 유지한다.
- paper는 되도록 graph leaf로 두고, source/code 분석은 research/sources 아래에 둔다.
- 실험 기록은 `research/experiments/`에 먼저 쌓고, 반복 실패는 `harness/errors/`로 승격한다.
- Out of scope: raw 임의 정리·삭제, 새 concept taxonomy 확장, Obsidian UI 색상 자동 보정.

## Important Decisions

- raw는 source of truth이며 임의 수정하지 않는다.
- records는 harness 운영 계층으로 승격했다.
- dev-tasks는 wiki에서 제거하고 granular한 구현 작업은 프로젝트 레포에서 관리한다.
- entry 문서(AGENTS/CLAUDE)는 얇게 유지하고 세부 규칙은 prompts와 policies/templates에 둔다.
- wiki 구조·link·map/index·archive·prompt routing을 바꾼 뒤에는 `scripts/wiki_doctor.sh`(C1~C12)를 실행한다. lint이 이를 호출한다.
- Obsidian graph는 서로 연결되지 않는 3개 독립 섬(research/harness/docs)이고, 색은 폴더가 아니라 `tier/*` 태그(최상위→하위, 빨강→파랑)로 결정한다([[AI-Sessions/wiki/harness/decisions/obsidian-decisions|obsidian-decisions]]). resources는 research/sources로 통합했다.
- harness 지식 파일명은 `{도메인}-{타입}`(폴더=타입, 파일=도메인). `agent-*`는 init 로드, `{domain}-*`은 그 작업 때 로드. 읽기 라우터 `harness.md`/`research.md`가 detail로 안내한다([[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]).

## Recent Structure Work (2026-06-24)

여러 차례 정리를 거쳐 현재 형태에 도달했다(상세 이력은 log.md):
- entry/메타 압축: memory+index→`architecture.md`, 명령별 policy를 prompts에 인라인, evals를 wiki_doctor로 흡수, vault-manifest+wiki_doctor C20/C21로 구조 검증.
- graph: 3 독립 섬 + tier 태그 색상(빨~파). harness 의미 그룹 4개(maps/), resources를 research로 강등.
- harness 도메인 재구성: policies→agent/obsidian/error/research/archive-policy, decisions→obsidian/harness-decisions(통합), anti-patterns→patterns(agent-patterns), garbage-collection→archive/. 루트 라우터 `harness.md`/`research.md` 신설, Start Order 4계층화. wiki_doctor ERROR=0, cross-island 0.

## Current Risks

- 같은 basename archive가 Obsidian wikilink resolution을 깨뜨릴 수 있다.
- `.obsidian/graph.json`은 Obsidian 실행 중 외부 수정하면 덮어써질 수 있다.
- `harness/state/handoff.md`는 append history가 아니라 current snapshot으로 유지해야 한다.

## Read Next

- architecture.md → (운용) harness.md / (연구) research.md
- AI-Sessions/wiki/harness/state/handoff.md
- prompts/<command>.md
