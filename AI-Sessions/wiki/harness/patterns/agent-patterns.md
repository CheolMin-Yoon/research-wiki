---
tags: [tier/low]
type: anti-pattern
date: 2026-06-24
status: active
source:
related_errors: harness/errors/obsidian-errors.md
related_experiments:
---

# Agent Pattern (anti): 실제 상태 대신 내 머릿속 모델을 신뢰

## Pattern

파일 내용, 폴더 의미, 도구의 동작을 **실제로 확인하지 않고** 내 추론·기억·요약 속 모델을 사실로 간주해 행동한다. 검증 한 번이면 깨질 가정 위에서 편집·삭제·분류·도구 작성을 진행한다.

## Why It Fails

내 모델과 실제 상태는 자주 어긋난다. 어긋난 줄 모르고 행동하면 멀쩡한 것을 망가뜨리거나, 망가진 것을 멀쩡하다고 판단한다. 이 함정은 표면이 달라도 뿌리가 같다.

### 사례 1 — 폴더 이름으로 분류 규칙을 기계 적용

`decisions/`, `errors/` 같은 폴더 *이름*만 보고 "records → 프로젝트 레포로 이동" 규칙을 그 안 모든 문서에 일괄 적용. 분류의 진짜 축은 이름이 아니라 **granular 원본 기록이냐 증류된 재사용 교훈이냐**다. `harness/errors/mjlab-errors.md`는 이름은 error지만 증류된 교훈이라 옮기면 안 된다.

### 사례 2 — 도구가 시스템의 실제 동작 모델을 안 따름

wiki_doctor 첫 버전이 wikilink를 "리터럴 경로 존재"로만 검사했다. 하지만 Obsidian은 짧은 링크를 **vault 전체 basename으로 해석**한다. 실제 동작 모델을 안 따른 검사기가 멀쩡한 링크 17개를 "깨졌다"고 오판했다. 실행해보지 않았으면 멀쩡한 링크를 고치려 들었을 것이다.

### 사례 3 — stale 스냅샷으로 추론

system-reminder가 준 옛 CLAUDE.md(긴 버전)로 구조를 진단했는데, 디스크의 실제 CLAUDE.md는 이미 얇게 리팩터돼 있었다. recall·요약은 작성 시점의 스냅샷이라 현재와 다를 수 있다.

## Signals

- "이 폴더/파일 이름이 X니까 Y" — 내용·동작을 안 보고 이름으로 단정할 때
- recall·system-reminder·brief·요약에 적힌 파일 내용을 현재 사실로 쓸 때
- 도구·스크립트를 짤 때 대상 시스템(Obsidian, git, 빌드)의 실제 해석 규칙을 추측으로 채울 때
- 편집·삭제·분류 전에 실제 파일을 한 번도 Read 하지 않을 때

## Better Approach

1. 편집·삭제·구조 판단 전에 실제 파일을 `Read`로 확인한다. 스냅샷은 단서로만 쓴다.
2. 검증 도구는 대상 시스템의 실제 동작 모델을 따른다. 모르면 작은 케이스로 **실행해서** 확인한다.
3. 규칙을 일괄 적용하기 전 대표 사례 1~2개를 실제로 열어 가정을 검증한다.
4. 가능하면 정적 추론을 실행 메커니즘으로 바꾼다(→ [[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]).

### 사례 4 — plan mode에서 wiki chain을 건너뛰고 파일시스템만 탐색

구현 작업을 계획할 때 Explore 에이전트를 파일시스템(`DL_GNN_Transformer/`, `/home/frlab/`)으로만 보내고 wiki를 건너뜀. "구현 작업 = codebase 탐색 = 파일시스템"이라는 잘못된 전제. 이 프로젝트에서 URL, 구현 분석, 관련 아이디어는 wiki에 있으므로 plan mode라도 `architecture.md → research.md → paper/source/idea` 체인을 먼저 타야 한다. 결과: 이미 위키에 있는 repo URL을 사용자에게 물어봄.

## Related Errors

- harness/errors/obsidian-errors.md (basename 충돌 — "이름만 보고 판단"이 깨지는 사례)

## Related Experiments

## Links

- harness/errors/mjlab-errors.md
- harness/decisions/harness-decisions.md
- [[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]
