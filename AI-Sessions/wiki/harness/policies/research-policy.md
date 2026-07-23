---
tags: [tier/low]
type: policy
date: 2026-07-24
status: active
---

# Research Policy

타입 기반 연구 지식과 topic 승인 규칙의 정본이다. ingest, 승격, 관계 편집 때 읽는다.

## Typed Objects

| type | 역할 | folder |
|---|---|---|
| `concept` | 정의와 다른 개념과의 경계 | `research/concepts/` |
| `method` | 입력·출력·가정·알고리즘·실패 조건 | `research/methods/` |
| `task` | 목표·관측·행동·제약·평가·baseline | `research/tasks/` |
| `paper` | 한 논문의 검증 가능한 주장과 근거 | `research/papers/` |
| `source` | 코드·저장소의 실제 구현 분석 | `research/sources/` |
| `comparison` | 선택 기준과 여러 근거의 종합 결론 | `research/comparisons/` |
| `idea` | 반증 가능한 연구 가설 | `research/ideas/` |
| `experiment` | 실행 조건·측정값·판정 기록 | `research/experiments/` |

idea와 experiment는 지식 분류의 부모가 아니다. idea를 수정해도 paper의 존재, 위치, topic은 바뀌지 않는다.

## Topic Contract

- topic 정본은 `schema/research-topics.json`이다.
- `topics`에는 `active` canonical ID만 저장한다. alias, unknown, pending 값은 오류다.
- 새 후보는 registry의 `pending`에 기록하고 큐레이터 승인 후 `active`로 승격한다.
- 관련 있지만 동의어가 아닌 용어를 alias로 합치지 않는다.
- `category`, `primary_category`, category 폴더와 category wikilink는 금지한다.
- topic membership은 graph edge가 아니며 자동 backlink나 논문 전수 목록을 만들지 않는다. 전수 조회는 Bases를 사용한다.

## Promotion Gate

concept/method/task는 서로 독립적인 근거 두 개 이상이 있거나 큐레이터가 직접 승인했을 때만 만든다. 승격 시 정의뿐 아니라 경계, 가정, 실패 조건 또는 평가 기준을 함께 기록한다.

## Relations and Provenance

- 설명 가치가 있는 관계만 `## Relations`에서 전체 경로 wikilink로 연결한다.
- paper/source/idea/experiment의 단순 topic 중복은 관계가 아니다.
- raw 원본은 graph-visible wikilink로 연결하지 않고 `source:` property 또는 plain path로 기록한다.
- 같은 basename의 raw stub이 있을 수 있으므로 research 관계에는 짧은 wikilink를 쓰지 않는다.
- source 분석은 `checked_commit` 또는 본문의 `checked commit`으로 검토한 revision을 기록한다. 외부 URL도 provenance로 허용한다.
- 관찰 사실, 원문 주장, 연구자의 해석을 분리한다. 비교·novelty 판단은 comparison 또는 idea에 둔다.

## Repository Ownership

여러 프로젝트에 재사용되는 조사 결과는 이 wiki가 정본이다. 각 프로젝트는 `source` note를 portal로 두고 checked revision, 저장소별 차이, repo-local 계약과 artifact 위치를 연결한다. 코드와 같은 commit에서 바뀌어야 하는 API·설정·실행·테스트 계약은 해당 저장소가 소유한다. wiki와 repo docs에 같은 본문을 복제하지 않는다.

| 산출물 | 정본 | 반대편에 남길 것 |
|---|---|---|
| source code, `tests/`, fixture, CI | project repo | wiki에는 checked commit과 의미 있는 test pointer |
| coding style, 변수·shape, API, design/task/run contract | project repo docs | source portal link |
| 실험 조건·측정·판정 | wiki experiment | repo에는 script, raw artifact, checkpoint와 wiki pointer |
| 재사용할 error 원인·예방 | wiki harness error | repo에는 named regression test와 wiki pointer |
| 조사·논문 비교 | wiki paper/source/comparison | repo에는 적용 차이와 wiki pointer |
| 구현 milestone handoff | project repo | cross-project 상태만 wiki brief/handoff |

`tests/`를 wiki로 옮기거나 Markdown으로 복제하지 않는다. test가 입증한 연구 사실만 experiment/source에 증류한다.
