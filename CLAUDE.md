# CLAUDE.md

이 파일은 Claude Code가 이 Obsidian vault(`research-wiki`)에서 일할 때 따라야 하는 업무 규약입니다.

목표는 개인 메모장이 아니라, 여러 AI 에이전트와 사람이 같은 연구 맥락을 공유하며 이어갈 수 있는 안정적인 연구·구현 프로세스를 만드는 것입니다.

## Work Profile

주 사용자는 **연구 엔지니어**(소프트웨어 개발 + 논문 리서치 병행), 현재 **1인** 워크플로입니다. 단, **Claude Code와 Codex 등 여러 AI 에이전트**가 같은 vault를 공유하므로, 어느 에이전트가 이어받아도 맥락이 끊기지 않게 기록합니다.

이 vault의 목적은 분명합니다. **논문에서 얻은 인사이트**와 **GitHub 레퍼런스 구현체에서 얻은 최신 구현 방법**을 한곳에 축적하고, 그 축적을 근거로 **에이전트가 조언하고 사용자와 함께 구현하는 공부/연구 프로세스**를 지원하는 것입니다.

주 raw 입력 3종:

1. 논문 PDF / 논문 본문 자료
2. 논문의 레퍼런스 구현 GitHub 레포(코드 폴더)
3. 사용자 본인의 아이디어·인사이트 메모

## Research Loop

이 vault는 아래 루프를 돈다. 에이전트는 각 단계에서 적절한 wiki 카테고리에 기록한다.

1. **ingest 논문** → `wiki/papers/`에 인사이트 노트 (핵심 아이디어·방법·내 연구와의 연결)
2. **ingest 레퍼런스 구현 레포** → `wiki/sources/`에 구현 분석 (아키텍처·핵심 파일·실행법·재현 포인트)
3. **reference** → 축적된 papers/sources/concepts를 참조해 현재 구현에 대한 **조언과 설계 방향**을 도출
4. **함께 구현** → 작업 단위는 `wiki/dev-tasks/`, 방향 결정은 `wiki/decisions/`, 돌린 실험은 `wiki/experiments/`
5. **save** → 재사용 가치 있는 결과만 저장 (아래 Save Filter)
6. 막힌 함정은 `wiki/errors/`, 떠오른 아이디어는 `wiki/ideas/`

핵심은 좋은 답변을 채팅에 흘려보내지 않고 **wiki 문서로 남겨 다음 세션이 이어받게** 하는 것이다.

## Core Operating Rules

1. 작업을 시작하기 전에 `index.md`, `log.md`, 관련 `AI-Sessions/wiki/` 문서를 먼저 확인한다.
2. `AI-Sessions/raw/` 안의 원본 자료는 수정하거나 삭제하지 않는다.
3. 가공된 지식, 결정, 에러, 프로젝트 문서는 `AI-Sessions/wiki/` 아래에 저장한다.
4. 세션 인수인계가 필요하면 `AI-Sessions/conversations/`에 저장한다.
5. 중요한 저장 작업 후에는 `index.md`와 `log.md`를 갱신한다.
6. 사용자가 명시적으로 원하지 않는 한 민감정보, 토큰, 비밀번호, 개인정보를 저장하지 않는다.
7. 이 규약은 `AGENTS.md`(Codex용)와 동기화한다. 한쪽 규칙을 바꾸면 다른 쪽도 맞춘다.

## Commands (자연어 명령)

사용자는 자연어로 명령한다. 아래 키워드(영어 고정)로 의도를 매핑한다.

- `save`: 현재 작업 맥락을 wiki에 저장한다. (예: "방금 결정한 거 저장해줘", "옵시디언에 남겨줘")
- `reference`: 기존 wiki와 log를 참조해 현재 연구·구현에 필요한 맥락·조언을 복원한다. (예: "이거 관련해서 우리가 정리해둔 거 참조해줘", "이전 맥락 불러와줘")
- `ingest`: raw 자료(논문/레포/아이디어)를 읽어 wiki 문서로 가공한다. (예: "이 논문 정리해줘", "이 레포 분석해줘")
- `lint`: vault 구조와 규칙 위반을 점검한다. (예: "위키 점검해줘")

명령 키워드 자체는 영어로 고정하되, 사람이 읽는 가이드라인은 한국어로 쓴다.

## Raw / Wiki Separation

`AI-Sessions/raw/`는 불변 자료 저장소다. 논문 원문, 레퍼런스 레포 스냅샷, 외부 자료, 아이디어 원본처럼 나중에 근거로 다시 확인해야 하는 자료를 둔다.

에이전트는 raw 파일을 수정하지 않는다. raw를 바탕으로 요약·분석·결정·구현 메모를 만들 때는 반드시 `AI-Sessions/wiki/` 아래에 별도 문서를 만든다.

## Wiki Categories

- `AI-Sessions/wiki/papers/`: 논문 인사이트 노트 (문제 정의 · 핵심 아이디어 · 방법 · 한계 · 내 연구/구현과의 연결)
- `AI-Sessions/wiki/sources/`: 레퍼런스 구현 GitHub 레포 분석 및 기타 외부 자료 (구현하는 방법 · 아키텍처 · 핵심 파일/엔트리포인트 · 실행·재현법 · 주의점)
- `AI-Sessions/wiki/concepts/`: 반복해서 쓰는 ML/연구 개념, 알고리즘, 용어, 수식
- `AI-Sessions/wiki/experiments/`: 실험 기록 (가설 · 설정 · 결과 · 해석 · 다음 액션)
- `AI-Sessions/wiki/ideas/`: 사용자 본인의 아이디어·인사이트와 발전 과정 (성숙하면 decision/project로 승격)
- `AI-Sessions/wiki/decisions/`: 기술·연구 방향 의사결정, 근거, 결정 시점
- `AI-Sessions/wiki/errors/`: 실패한 실험·접근, 다시 반복하면 안 되는 함정
- `AI-Sessions/wiki/projects/`: 연구·개발 프로젝트별 진행 맥락과 산출물
- `AI-Sessions/wiki/design/`: 시스템·모델 아키텍처 설계, 인터페이스, 구조 결정
- `AI-Sessions/wiki/dev-tasks/`: 함께 구현하는 개발 작업 단위, 의존성, 구현 메모

## Ingest Workflow (논문 / 레포 / 아이디어)

`ingest`는 새 노트만 만드는 작업이 아니다. **기존 노트를 갱신하고 연결을 늘리며, 모순을 표시하는** 살아있는 문서화다 (카파시 위키의 핵심).

자료 하나를 ingest할 때 공통 원칙:

1. 새 문서를 만들기 전에 `index.md`로 **관련 기존 노트를 먼저 찾는다.** 같은 주제가 있으면 새로 만들지 말고 그 노트를 갱신한다.
2. 한 소스가 여러 카테고리에 영향을 줄 수 있다. 관련된 concepts/decisions/dev-tasks 노트의 `[[링크]]`도 함께 갱신한다.
3. 기존 노트와 **상충하는 내용**을 발견하면 임의로 덮어쓰지 말고, 해당 노트에 `> ⚠️ 상충:` 메모로 표시하고 사용자에게 알린다.

**논문을 ingest할 때**

1. `wiki/papers/`에 인사이트 노트를 만든다: 문제 정의, 핵심 아이디어, 방법, 실험 셋업, 한계, **내 연구/구현과 연결되는 지점**.
2. 반복 등장하는 개념·알고리즘은 `wiki/concepts/`로 분리하고 `[[링크]]`로 연결한다.
3. 적용해볼 만한 아이디어가 생기면 `wiki/ideas/`에 후속 메모를 남긴다.

**레퍼런스 구현 GitHub 레포를 ingest할 때**

1. `wiki/sources/`에 구현 분석 노트를 만든다: 구현하는 논문/방법, 전체 아키텍처, 핵심 파일·엔트리포인트, 실행·재현 방법, 의존성, 주의점, **내 구현에 가져올 패턴**.
2. 대응되는 논문 노트(`wiki/papers/`)가 있으면 양방향으로 `[[링크]]`한다.
3. 직접 가져다 구현할 작업이 보이면 `wiki/dev-tasks/`로 분리한다.

**아이디어·인사이트를 ingest할 때**

1. `wiki/ideas/`에 저장하고, 근거가 된 논문/레포 노트로 `[[링크]]`한다.
2. 의사결정 수준으로 굳어지면 `wiki/decisions/`로 승격한다.

raw 원본은 어떤 경우에도 수정하지 않는다. 작업이 끝나면 `index.md`와 `log.md`를 갱신한다.

## Save Filter

무분별한 저장은 맥락 오염을 만든다. `save` 전에 아래 5가지를 확인한다.

1. 이 정보가 향후 연구·구현에 반복해서 재사용될 데이터인가?
2. 다른 에이전트나 내가 나중에 작업을 이어받기 위해 반드시 읽어야 하는가?
3. 의사결정의 근거를 나중에 추적할 필요가 있는가?
4. 실패한 방식이라 다시 시도하면 안 되는 리스크 정보인가?
5. 앞으로 맞춰야 하는 공통 규칙·설계·구현 패턴인가?

하나도 만족하지 않는 일회성 답변·감상·사소한 표현 변경은 저장하지 않고, 저장하지 않은 이유를 짧게 설명한다.

## Document Format

새 wiki 문서는 가능하면 아래 형식을 따른다.

```markdown
---
type: paper | source | concept | experiment | idea | decision | error | project | design | dev-task | handoff
date: YYYY-MM-DD
status: draft | active | superseded
source: optional
---

# 제목

## Summary

## Context

## Details

## Links
```

## Completion Rule

작업이 끝나면 다음을 보고한다.

- 읽은 주요 파일
- 수정하거나 생성한 파일
- 저장 필터 적용 결과 (저장/미저장 이유)
- 다음 세션에서 이어갈 때 먼저 볼 문서
