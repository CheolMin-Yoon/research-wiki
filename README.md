# research-wiki

논문, GitHub reference implementation, 사용자 아이디어, 실험 결과를 장기적으로 이어가기 위한 Obsidian 기반 **Research Agent Harness Wiki**입니다.

이 vault는 단순 지식 저장소가 아니라 여러 AI 에이전트가 연구 맥락을 이어받고, 실패를 재발 방지하고, wiki 품질을 점검하도록 설계되어 있습니다.

## 시작 방법

1. Obsidian에서 이 폴더(`research-wiki`)를 vault로 엽니다.
2. Claude Code 또는 Codex를 이 폴더에서 실행합니다.
3. 에이전트는 `architecture.md`, `AI-Sessions/wiki/harness/state/brief.md` 순서로 현재 맥락을 읽습니다.
4. 명령형 작업은 `prompts/`의 해당 파일을 기준으로 수행합니다.

## 연구 루프

1. `ingest`로 raw 논문과 레포를 wiki 연구 노트로 컴파일합니다.
2. `reference` 또는 `query`로 축적된 근거를 불러옵니다.
3. 구현과 실험에서 나온 사실은 `research/experiments`에 기록합니다. granular한 구현 작업 단위는 프로젝트 레포에서 관리합니다.
4. 반복 실패, 운영 결정, GC, 평가 기준은 `harness`에 저장합니다.
5. `reflect`로 실험/구현 후 배운 점을 experiment, error, anti-pattern, decision 중 어디로 승격할지 판단합니다.

## 명령어

- `save`: 재사용 가치가 있는 현재 작업 맥락을 저장합니다.
- `reference`: 이전 연구 맥락, 결정, 함정을 복원합니다.
- `query`: 특정 질문에 필요한 노트만 읽고 답합니다.
- `ingest`: raw 자료를 wiki 문서로 컴파일합니다.
- `lint`: 구조, 링크, raw/wiki 경계, 정책 위반을 점검합니다.
- `reflect`: 실험/구현/ingest 이후 배운 점을 적절한 계층으로 승격합니다.
- `archive`: 삭제 대신 archive 또는 `status: obsolete`로 정리합니다.

## 주요 경로

| 경로 | 용도 |
|---|---|
| `CLAUDE.md` | Claude Code용 최소 entry |
| `AGENTS.md` | Codex 등 에이전트용 최소 entry |
| `architecture.md` | vault 구조 지도 + 콘텐츠 인벤토리 (구 index + memory) |
| `log.md` | 고신호 타임라인 |
| `AI-Sessions/raw/` | source of truth. 에이전트가 임의 수정하지 않음 |
| `AI-Sessions/wiki/research/` | papers, sources, categories, single idea note, experiments |
| `AI-Sessions/wiki/harness/` | state, policies, templates, decisions, errors, anti-patterns, GC, evals |
| `AI-Sessions/wiki/maps/` | research/resources/harness graph 진입점 |
| `prompts/` | command-specific 실행 규칙 |
