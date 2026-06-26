# Agent Entry

이 저장소는 휴머노이드 RL 연구를 오래 이어가기 위한 **Research Agent Harness Wiki**입니다. Claude Code와 Codex 등 여러 에이전트가 같은 vault를 공유하므로 `CLAUDE.md`와 `AGENTS.md`는 의미가 같아야 합니다.

## Start Order (context 절약 4계층)

1. **자동**: 이 파일은 항상 context에 있습니다(얇게 유지).
2. **init**: `architecture.md`(구조 지도) → `AI-Sessions/wiki/harness/state/brief.md`(현재 상태) → 이어받으면 `handoff.md`. 운용 규칙 본체는 `AI-Sessions/wiki/harness/policies/agent-policy.md`(+ `patterns/agent-patterns.md`).
3. **영역 라우터(조건부)**: 운용 작업이면 `harness.md`, 연구 작업이면 `research.md` 중 해당하는 것만 읽고 거기서 detail로 라우팅합니다.
4. **명령형 작업**: `prompts/<command>.md`만 추가로 읽습니다.

`log.md`는 최근 흐름 복원이 필요할 때만 봅니다.

## Core Rules

- `AI-Sessions/raw/`는 사용자가 명시적으로 요청하지 않는 한 수정하거나 삭제하지 않습니다.
- compiled research knowledge는 `AI-Sessions/wiki/research/` 아래에 씁니다.
- agent operation, decisions, errors, patterns, archive, policies, templates, evals는 `AI-Sessions/wiki/harness/` 아래에 씁니다. 파일명은 `{도메인}-{타입}`으로 짓습니다(`agent-*`=init 로드, `{domain}-*`=그 작업 때 로드).
- 삭제보다 `status: obsolete` 또는 archive 처리를 우선합니다.
- `CLAUDE.md`와 `AGENTS.md`를 의미상 동기화합니다.
- 모든 policy를 기본으로 읽지 않습니다. 현재 작업에 필요한 policy만 on demand로 읽습니다.
- recall·system-reminder·brief·요약에 적힌 파일 내용은 스냅샷입니다. 파일을 수정·삭제하거나 구조를 판단하기 전에 실제 파일을 `Read`로 검증합니다. (근거: `AI-Sessions/wiki/harness/patterns/agent-patterns.md`)
- wiki 구조, wikilink, map/index, archive, prompt routing을 변경한 뒤에는 `scripts/wiki_doctor.sh`를 실행합니다. ERROR는 완료 보고 전에 고치거나 못 고친 이유를 보고하고, 그대로 두는 WARN은 이유를 남깁니다.

## Command Routing

- `save` -> `prompts/save.md`
- `reference` -> `prompts/reference.md`
- `query` -> `prompts/query.md`
- `ingest` -> `prompts/ingest.md`
- `lint` -> `prompts/lint.md`
- `reflect` -> `prompts/reflect.md`
- `archive` -> `prompts/archive.md`

## Shared Protocol

자세한 read/write 규칙은 `AI-Sessions/wiki/harness/policies/agent-policy.md`를 사용합니다.
구조 검증 기준은 `vault-manifest.yaml`과 `scripts/wiki_doctor.sh`를 따릅니다.
