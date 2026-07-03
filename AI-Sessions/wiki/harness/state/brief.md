---
tags: [tier/low]
type: state
date: 2026-07-03
status: active
---

# Brief

## Current Focus

research-wiki는 휴머노이드 RL 장기 연구를 위한 Research Agent Harness Wiki다. active 구현 레포는 `/home/frlab/mj_rl`이며, wiki에는 granular 작업 로그가 아니라 current contract, 증류된 해석, 다음 포인터만 남긴다.

## Active Research Direction

Humanoid locomotion RL, centroidal/CAM, LIPM/eICP, graph/transformer policy를 중심으로 논문·source·idea·experiment를 축적한다. 현재 중심 아이디어는 CMM-conditioned graph/Transformer policy와 per-joint CAM credit이다.

## Current Canonical Pointers

- 구현 source current digest: `AI-Sessions/wiki/research/sources/mj-rl.md`
- 구현 source history archive: `AI-Sessions/wiki/harness/archive/archived-mj-rl-reflect-history-2026-07-03.md`
- CMM-conditioned graph Transformer 설계: `AI-Sessions/wiki/research/idea-physical-feature-graph.md`
- per-joint CAM credit 설계: `AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit.md`
- notebook/shape 검증: `AI-Sessions/wiki/research/sources/graph-transformer-code.md`
- CasADi-on-GPU backend: `AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md`
- Body Transformer 정본: `AI-Sessions/wiki/research/sources/body-transformer-code.md`, `AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer.md`

## Current mj_rl State

- `/home/frlab/mj_rl` checked commit은 `d7c38cb`(`feature/port-eicp-centroidal-23dof`)이고 origin에 push 완료, working tree clean.
- 이번 세션은 eICP/Centroidal 23-DOF 포팅을 커밋으로 확정하고, command term의 debug drawing을 `source/visualization/`(footstep_viz/centroidal_viz/com_viz/native_viewer_opts)로 분리했다.
- 자세한 현재 계약은 `mj-rl.md`, 오래된 reflect 상세는 archive history를 본다. **라이브 뷰어로 시각화를 눈으로 확인하지는 않았다** — `mj-rl.md`의 Next #1 참고.

## Scope & Constraints

- `AI-Sessions/raw/`는 source of truth이며 기본 읽기 전용이다.
- granular 구현 작업은 프로젝트 레포에서 관리하고, wiki에는 증류된 research/harness 지식만 둔다.
- 반복 실패는 `harness/errors/`, 일반화된 접근은 `harness/patterns/`, 설계 원칙은 `harness/decisions/`로 승격한다.
- 같은 사실은 정본 한 곳에 두고 다른 문서는 링크한다. state에는 코드 디테일을 길게 넣지 않는다.

## Operating Pointers

- Start: `architecture.md` → 이 brief → 필요 시 `handoff.md` → 작업별 `harness.md` 또는 `research.md`.
- 구조·link·map/index·archive·prompt routing 변경 후 `scripts/wiki_doctor.sh`를 실행한다.
- relation 정본은 본문 `## Links`의 `[[wikilink]]`; source provenance는 `checked commit:`로 쓴다.

## Current Risks

- `.obsidian/graph.json`은 Obsidian 실행 중 외부 수정하면 덮어써질 수 있다.
- `brief.md`와 `handoff.md`는 append history가 아니라 compact current pointer로 유지한다.
- Centroidal debug viz(`centroidal_viz.py`)는 라이브 뷰어로 그림을 확인하지 않았다. GPU CasADi 커널이 없는 환경에서는 애초에 Centroidal task가 안 돈다.

## Read Next

- architecture.md → (운용) harness.md / (연구) research.md
- AI-Sessions/wiki/harness/state/handoff.md
- prompts/<command>.md
