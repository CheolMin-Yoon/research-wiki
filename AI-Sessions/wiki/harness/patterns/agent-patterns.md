---
tags: [tier/low]
type: anti-pattern
date: 2026-06-24
status: active
source:
related_errors: harness/errors/obsidian-errors.md
related_experiments: AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline.md
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

구현 작업을 계획할 때 Explore 에이전트를 파일시스템(`Graph_Transformer/`, `/home/frlab/`)으로만 보내고 wiki를 건너뜀. "구현 작업 = codebase 탐색 = 파일시스템"이라는 잘못된 전제. 이 프로젝트에서 URL, 구현 분석, 관련 아이디어는 wiki에 있으므로 plan mode라도 `architecture.md → research.md → paper/source/idea` 체인을 먼저 타야 한다. 결과: 이미 위키에 있는 repo URL을 사용자에게 물어봄.

### 사례 5 — active import가 없다는 이유로 보존 자산을 dead code로 삭제

`mj_rl` review에서 active BoT velocity task가 `source/assets/cuda/`와 `scripts/casadi_on_gpu/`를 import하지 않는다는 사실만 보고 centroidal/CasADi CUDA bundle을 삭제했다. 실제로는 current branch의 active runtime path와 별개로 보존해야 하는 optional/branch-continuity 자산이었다. `rg` import 결과는 "현재 active path" 증거이지 "삭제 승인" 증거가 아니다.

삭제 후보는 먼저 `active unused`, `optional preserved`, `obsolete`, `unknown`으로 분류한다. `assets/`, generated kernels, external install scripts, branch-specific experiment bundles는 사용자의 명시 승인 없이는 제거하지 않고 역할을 문서화한다. (사례 정본: [[AI-Sessions/wiki/harness/errors/mjlab-errors|mjlab-errors]])

### 사례 6 — "committed HEAD = 깨끗한 기본 상태"라고 가정하고 git checkout

isaac_humanoid에서 실험 launcher 스크립트를 테스트하다가 cfg 파일이 이전 dry-run이
남긴 어중간한 상태(정규식 패치 일부만 적용됨)라고 판단해, `git checkout -- <file>`로
"깨끗한 기본값"으로 되돌리면 될 거라 가정하고 실행했다. 실제로는 그 파일의 committed
HEAD가 그날 이미 커밋되지 않은 실제 기능 작업(`_NODE_MLP_LAYERS`/`_DECODER_CONTEXT`/
`_HYPERS` 리팩터 — 실험 launcher가 아니라 그날의 진짜 구현 변경)보다 **뒤처져** 있었다.
checkout 직전에 `git diff --stat`로 21 insertions/10 deletions를 보고도 "이건 그냥
launcher가 남긴 transient 값이겠지"라고 추측하고 내용을 열어보지 않았다 — 사례 1/3과
같은 뿌리: diff 크기라는 신호는 봤지만 그 신호가 뜻하는 실제 내용은 확인하지 않았다.

다행히 checkout 몇 턴 전에 같은 파일을 `Read`로 전체 캡처해 둔 게 있어서 그 내용으로
복구했다. **destructive 커맨드(checkout/reset/rm) 실행 직전에 대상을 Read해 둔 이력이
있으면 그게 유일한 안전망이 된다** — 이번엔 우연히 있었지만, 없었으면 실제 기능
코드를 영구히 잃을 뻔했다.

**Prevention rule**: 실험/설정 파일을 "기본값으로 되돌리기" 위해 `git checkout`을 쓰기
전에, 그 파일이 (a) 정말 transient/launcher-patched 값만 담고 있는지, (b) 그날의
committed 이후 실제 feature 작업이 섞여 있지 않은지를 `git log --oneline -3 -- <file>`
+ diff 내용을 실제로 읽어서 확인한다. "되돌리고 싶은 상태"를 정확히 아는 경우가
아니면 checkout보다 수동 patch(원하는 필드만 명시적으로 고치기)가 더 안전하다.

### 사례 7 — repo-local errors.md에서 이미 읽은 교훈을 실행 시점에 안 지킴

같은 세션에서 isaac_humanoid의 `docs/experiments/2026-07-10-jacobian-early-screen-errors.md`를
먼저 Read해서 "`nohup ... &`는 header만 남기고 프로세스가 사라지니 `setsid ... </dev/null &`를
쓴다"는 교훈을 명시적으로 확인했다. 그런데 몇 턴 뒤 실제로 2시간짜리 GPU 학습을
백그라운드로 띄우는 순간에는 습관적으로 `nohup ... & disown`을 먼저 썼다. 결과는
정확히 그 문서가 경고한 실패 모드는 아니었지만(로그는 이어졌다) 더 나쁜 변형이었다 —
wrapper 스크립트(순차 3-run 오케스트레이터)만 죽고 학습 서브프로세스가 부모 없는
고아로 남아 계속 GPU를 점유했다. `kill <wrapper_pid>`만으로는 안 끝나서 GPU를
직접 확인(`nvidia-smi --query-compute-apps`)하고 남은 자식 프로세스를 따로 죽여야 했다.

**Why it's distinct from 사례 1~6**: 여기서는 실제 상태를 몰랐던 게 아니라 — 올바른
정보를 세션 안에서 이미 읽고 알고 있었다. 실패는 "정보를 읽었다"와 "그 정보를 다음
관련 행동에 강제 적용했다" 사이의 간극에서 났다. 배경지식으로 스쳐 지나간 문서는
행동 시점에 재조회되지 않으면 없는 것과 같다.

**Prevention rule**: repo-local errors/lessons 문서를 읽은 뒤 그 문서가 다루는 것과
같은 종류의 작업(같은 커맨드 패턴, 같은 프로세스 유형)을 실행하기 직전에는, 그
문서의 해당 항목을 다시 떠올리고 명시적으로 반영했는지 스스로 체크한다. 특히
"몇 시간짜리 배경 작업을 지금 막 시작하려는 참"처럼 되돌리기 비싼 행동일수록 이
체크를 건너뛰면 안 된다.

## Positive Pattern — 사실은 정본 한 곳에 두고 나머지는 링크

한 사실을 여러 문서에 복붙하면 양은 늘지만 곧 서로 어긋난다(`wiki_doctor C14`는 size만, C13은 state 누출만 막을 뿐 source↔source 중복은 못 막는다). 사실을 승격·reflect할 때는 계층 하나를 **정본(canonical home)**으로 고르고, 다른 문서는 restate하지 말고 `[[wikilink]]`로 가리킨다.

1. 정본 선택: 구현 사실 → `research/sources/<slug>-code.md`, 논문 사실 → `research/papers/<slug>.md`, 실험 설계 → `research/experiments/<...>.md`.
2. 다른 문서는 같은 메커니즘을 다시 쓰지 않고 정본을 링크한다.
3. **state(brief/handoff)는 지식 저장소가 아니다.** "무엇을 했다 + 어디를 봐라" 포인터와 현재상태만 둔다. 코드 디테일·수식·메커니즘 설명이 state에 들어가면 잘못된 계층이다.
4. 같은 종류의 두 코드(공식 repo vs 사용자 toy)처럼 *대상이 다르면* 각자 무엇을 하는지는 남기되, 공통 메커니즘의 *왜/어떻게*는 정본으로 링크한다.

### Signals

- 같은 메커니즘 설명이 2개 이상 파일에서 grep된다.
- brief·handoff에 `in_proj_weight` 같은 코드 디테일이 들어간다.
- 한 사실을 고치려면 여러 파일을 동시에 고쳐야 한다(= 드리프트 예약).

(근거 사례: 2026-06-25 BoT q/k/v 분석이 brief·handoff·paper·source·experiment·dl-gnn 6곳에 복붙됐고, 같은 날 `graph-transformer-code.md`(당시 `dl-gnn-transformer-code.md`) 노트북 설명이 재구성을 못 따라가 낡았다.)

## Related Errors

- harness/errors/obsidian-errors.md (basename 충돌 — "이름만 보고 판단"이 깨지는 사례)
- repo-local: `/home/frlab/isaac_humanoid/docs/experiments/2026-07-10-jacobian-early-screen-errors.md`
  (사례 7의 nohup/setsid 원본 교훈 — 정본은 이 repo-local 문서이고 사례 7은 "읽었는데도
  적용 안 한" 상위 패턴만 기록)

## Related Experiments

- AI-Sessions/wiki/research/experiments/2026-07-10-isaac-mit-gcn-jacobian-early-screen.md
  (사례 6/7이 발생한 실제 실험 — `assets/graph` 삭제로 인한 큐 중단과 재시도)

## Links

- harness/errors/mjlab-errors.md
- harness/decisions/harness-decisions.md
- harness/patterns/research-patterns.md
- [[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]
