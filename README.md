# research-wiki

논문 인사이트와 GitHub 레퍼런스 구현체를 축적해, AI 에이전트가 조언하고 함께 구현하는 **공부/연구 프로세스**를 지원하는 Obsidian 기반 AI 업무 위키입니다.

Claude Code와 Codex 등 여러 에이전트가 같은 맥락을 공유하도록 설계되었습니다.

## 시작 방법

1. Obsidian에서 이 폴더(`research-wiki`)를 vault로 엽니다.
2. Claude Code 또는 Codex를 이 폴더에서 실행합니다.
3. raw 자료(논문 PDF, 레퍼런스 레포, 아이디어 메모)를 `AI-Sessions/raw/`에 넣고 `ingest`를 요청합니다.

## 연구 루프

1. `ingest` 논문 → `wiki/papers/` 인사이트 노트
2. `ingest` 레퍼런스 레포 → `wiki/sources/` 구현 분석
3. `reference` → 축적된 노트를 근거로 조언·설계 도출
4. 함께 구현 → `wiki/dev-tasks/`, `wiki/decisions/`, `wiki/experiments/`
5. `save` → 재사용 가치 있는 결과 저장 (5필터)
6. 함정은 `wiki/errors/`, 아이디어는 `wiki/ideas/`

## 명령어

- `save`: 현재 작업 맥락을 저장합니다.
- `reference`: wiki와 log를 참조해 이전 맥락·조언을 복원합니다.
- `ingest`: raw 자료를 읽고 wiki 문서로 정리합니다.
- `lint`: vault 구조와 규칙 위반을 점검합니다.

## 각 파일/폴더의 용도

| 경로 | 용도 |
|---|---|
| `CLAUDE.md` | Claude Code용 업무 규약 (스키마·명령·저장 규칙의 단일 기준) |
| `AGENTS.md` | Codex 등 다른 에이전트용 동일 규약 (CLAUDE.md와 동기화) |
| `index.md` | vault 전체 지도. 에이전트가 가장 먼저 읽음 |
| `log.md` | 작업 로그 (append-only) |
| `AI-Sessions/raw/` | 불변 원본 자료 (절대 수정 안 함) |
| `AI-Sessions/wiki/` | 가공된 지식 (papers/sources/concepts/experiments/ideas/decisions/errors/projects/design/dev-tasks) |
| `AI-Sessions/conversations/` | 세션 인수인계 문서 |
| `prompts/` | save·reference·ingest·lint 재사용 프롬프트 |
