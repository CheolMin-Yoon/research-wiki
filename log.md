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
2026-06-27 | ingest | GCNT(arXiv:2505.15211) paper 추가: GCN+WL morphology 추출→q/k, full attention+distance soft-bias, morphology-agnostic RL. "GCN+BoT" 질문의 참조점 | AI-Sessions/wiki/research/papers/2025-luo-gcnt.md
2026-06-27 | structure | concept 중심 research graph 잔여 지시를 category 중심 체계로 정리하고 legacy concept 노트/template은 제거. idea는 단일 note로 통합. wiki_doctor ERROR=0 WARN=0 | prompts/ingest.md, AI-Sessions/wiki/harness/policies/*, AI-Sessions/wiki/harness/templates/*, AI-Sessions/wiki/research/idea-physical-feature-graph.md
2026-06-27 | graph | harness→research wikilink를 차단하고 paper cluster는 primary category 1개를 통해 research-map 아래에 등록하도록 정정. tier 색상은 빨강-노랑-초록-파랑으로 고정. wiki_doctor C18 갱신 | .obsidian/graph.json, scripts/wiki_doctor.sh, AI-Sessions/wiki/maps/research-map.md
2026-06-27 | graph | research category를 research-map 직접 자식이 아니라 idea의 근거 축으로 정정: research-map→idea→category→paper. rl-algorithms도 idea에 연결하고 C18에 direct category 금지 추가 | AI-Sessions/wiki/maps/research-map.md, AI-Sessions/wiki/research/idea-physical-feature-graph.md, scripts/wiki_doctor.sh
