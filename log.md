# Agent Work Log

이 파일은 `reference` 때 최근 연구 흐름을 빠르게 복원하기 위한 고신호 타임라인입니다. 모든 에이전트 실행을 남기지 말고, 다음 세션이 반드시 알아야 할 구조 변화, 큰 ingest, 결정, 실패만 한 줄로 기록합니다.

형식:

```text
YYYY-MM-DD | kind | summary | linked files
```

## Log

2026-06-23~24 | setup | research-wiki 초기 설계, raw/wiki/schema 분리, graph 구조 실험 후 research-map/resources/prompts 중심으로 안정화. 상세 이력은 archive에 보존 | AI-Sessions/wiki/harness/archive/archived-setup-log-2026-06-24.md
2026-06-24 | ingest | humanoid RL 핵심 papers/sources/concepts/ideas를 raw 기반으로 1차 정리 | AI-Sessions/wiki/research/*
2026-06-24~25 | structure | wiki 구조 안정화(여러 단계 압축 요약): active를 maps/research/harness로 재편·raw graph 제외, 4 폴더→3 독립 섬+tier 색, 파일명 {도메인}-{타입}, dev-tasks 제거, index+memory→architecture.md, harness 53→37 압축, vault-manifest + wiki_doctor C14~C17·tier 계약 정비, init 다이어트(인벤토리→research.md). 전 과정 wiki_doctor ERROR=0 | architecture.md, vault-manifest.yaml, scripts/wiki_doctor.sh, AI-Sessions/wiki/harness/*, AI-Sessions/wiki/maps/*, CLAUDE.md, AGENTS.md
2026-06-27 | experiment | cusadi vs casadi-on-gpu G1 동역학 GPU 배치 벤치마크: casadi-on-gpu ~10–20× 우세(fp32, RTX5070). 일반화 교훈 → research-patterns | AI-Sessions/wiki/research/experiments/2026-06-27-cusadi-vs-casadi-on-gpu-g1.md
2026-06-27 | structure | source 그래프를 카테고리 sub-hub(frameworks/dynamics-gpu/policy-refs)으로 재편 + casadi-on-gpu-code source(+raw stub) 추가. wiki_doctor ERROR=0 WARN=0 | AI-Sessions/wiki/maps/resources*, AI-Sessions/wiki/research/sources/casadi-on-gpu-code.md
