---
tags: [tier/low]
type: archive
date: 2026-06-24
status: archived
source: log.md pre-harness-refactor
---

# Archived Setup Log (2026-06-23~24)

`log.md`를 고신호 타임라인으로 압축하면서 초기 setup, graph 실험, 구조 재편 상세 이력을 이 문서로 보존한다. 이 문서는 active workflow 진입점이 아니라 이력 추적용 archive다.

```text
2026-06-23 | setup | research-wiki 초기 구성: 연구 엔지니어용 LLM wiki로 카테고리, 명령(save/reference/query/ingest/lint), Save Filter 5게이트, Raw/Wiki/Schema 3계층, Log Policy 정립 | CLAUDE.md, AGENTS.md, README.md, prompts/*
2026-06-23 | decision | vault 운용 레이아웃 결정: 부모 워크스페이스 아래 research-wiki와 구현 레포를 형제 배치하고, wiki는 여러 레포보다 수명이 긴 장기 연구 자산으로 운영 | decisions/repo-operation-layout.md
2026-06-23 | ingest | humanoid locomotion RL 핵심 자료 ingest: Lee footstep/arm-CAM, PPO, RSL-RL, mjlab, centroidal dynamics, Attention, Body Transformer, mj_rl 레포를 papers/sources/concepts/projects/errors로 정리 | AI-Sessions/wiki/{papers,sources,concepts,projects,errors}
2026-06-23 | idea | 사용자 승인 아이디어 source snapshot 2개와 대응 wiki idea 작성: humanoid arm dual role, Physical Feature Graph | raw/ideas/{humanoid-arm-dual-role.md,physical-feature-graph.md}, wiki/ideas/{idea-humanoid-arm-dual-role.md,idea-physical-feature-graph.md}
2026-06-23 | cleanup | 초기 구성 오류로 들어간 기존 raw idea PDF 2개와 오래된 wiki idea 2개를 사용자 명시 요청에 따라 일회성 정리. 일반 raw 삭제 규칙으로 확장하지 않음 | log.md, CLAUDE.md, AGENTS.md
2026-06-23 | design | mj_rl 중심 통합 로드맵 작성: ModernRobotics=수식 검증, mj_control=classical control/WBC/MPC oracle, DL_GNN_Transformer=BoT/graph policy 레이어로 흡수 | AI-Sessions/wiki/design/mj-rl-repo-integration-roadmap.md
2026-06-23 | ingest | 사용자 본인 코드베이스 3개를 raw/source로 편입: ModernRobotics(math utils·검증), mj_control(classical control oracle), DL_GNN_Transformer(torch.nn graph policy source) | raw/repos/{modern-robotics,mj-control,dl-gnn-transformer}.md, wiki/sources/{modern-robotics-code,mj-control-code,dl-gnn-transformer-code}.md
2026-06-23 | graph | Keyword/Concept/Idea-Insight 중심 Paper Graph 레이어 추가: paper 8개, idea 2개, concept 노트에 graph 섹션을 얹고 keyword seed 7개와 상위 concept 2개 생성 | AI-Sessions/wiki/{papers,ideas,concepts}
2026-06-23 | graph | Obsidian graph backbone을 Idea/Insight -> Keyword -> Paper 단방향 구조로 축소: paper는 keyword만, idea는 keyword/evidence paper만, keyword 노트는 papers만 유지 | AI-Sessions/wiki/{papers,ideas,concepts}
2026-06-23 | graph | Obsidian graph 노출 범위를 index+papers+concepts+ideas로 제한하고 index의 graph edge를 concept/keyword/idea 진입점 중심으로 정리. source/project/code repo는 graph-visible wikilink에서 제외 | index.md, .obsidian/graph.json, AI-Sessions/wiki/{papers,concepts}
2026-06-23 | decision | wiki 카테고리별 문서화 규칙(Document Format) 확정: papers(Abstract 한국어 번역·핵심 내용 통합·아이디어 연결 섹션 신설), projects(구현 대상 명시), sources(실행·재현 섹션 폐지·핵심 파일 집중), ideas(현행 유지), concepts(reuse 게이트: 2편 이상 공유 시만 독립 노드) | CLAUDE.md, AGENTS.md
2026-06-23 | graph | Obsidian graph를 index -> keyword/concept/idea 3허브 구조로 재편: keyword는 paper, concept는 transformer/ppo/lipm/centroidal->paper, idea는 개별 idea->상위 concept로 연결 | index.md, .obsidian/graph.json, AI-Sessions/wiki/{concepts,ideas,papers}
2026-06-23 | graph | Obsidian graph를 research-map 중심 구조로 재편: index는 research-map만 연결하고, research-map -> idea -> keyword/evidence paper 흐름으로 단순화. concept 노트는 graph backbone에서 제외 | index.md, .obsidian/graph.json, AI-Sessions/wiki/design/research-map.md, AI-Sessions/wiki/ideas/*
2026-06-23 | graph | research-map graph backbone을 idea -> concept -> paper 구조로 조정: keyword와 direct evidence paper edge를 graph-visible layer에서 제외하고 transformer/ppo/lipm/centroidal concept를 중간 노드로 사용 | AI-Sessions/wiki/design/research-map.md, AI-Sessions/wiki/ideas/*, AI-Sessions/wiki/concepts/{transformer,ppo,lipm,centroidal}.md
2026-06-24 | rewrite | raw 기반 wiki 전면 재작성: 기존 active를 _archive/2026-06-24-pre-raw-rewrite로 이동하고 raw PDF/repo/idea를 근거로 papers 8·sources 9·concepts 4(transformer/ppo/lipm/centroidal)·ideas 2·records 3·research-map을 새 maps/research/records 구조로 재작성. index는 research-map 단일 backbone, paper는 leaf, keyword/old concept/experiments/projects/design 폐지. archive는 중복 basename이 wikilink resolution을 깨뜨려 `.archive`(점-폴더)로 옮겨 Obsidian 인덱스에서 제외 | AI-Sessions/wiki/{maps,research,records}/*, index.md, .obsidian/graph.json
2026-06-24 | structure | wiki 폴더 구조를 maps / research / records로 재편: papers/ideas/concepts/sources/experiments는 research, mj-rl project note는 research/sources, design은 maps, decisions/errors/dev-tasks는 records로 이동 | AI-Sessions/wiki/{maps,research,records}
2026-06-24 | schema | AGENTS/CLAUDE/README/prompts를 새 wiki 구조와 문서화 규칙으로 재작성: graph는 index->research-map->idea->concept->paper, concept는 transformer/ppo/lipm/centroidal 4개로 제한 | AGENTS.md, CLAUDE.md, README.md, prompts/*
2026-06-24 | graph | Obsidian graph를 세 분리 클러스터로 재편: ① 연구(research-map 독립 루트→idea→concept→paper, index/log 연결 끊음) ② 문서(index↔README/CLAUDE/AGENTS/log) ③ 프롬프트(save/reference/query/ingest/lint 상호 연결). concept→paper는 raw/repos basename 충돌 회피 위해 전체경로 명시, paper는 1 primary concept만(partition). graph 규칙 CLAUDE/AGENTS 동기화 | index.md, CLAUDE.md, AGENTS.md, prompts/*, AI-Sessions/wiki/research/concepts/*
2026-06-24 | graph | Obsidian graph를 index -> research-map/prompts/records/resources 4허브 구조로 정리하고 raw 파일은 graph filter에서 제외 | index.md, AGENTS.md, CLAUDE.md, prompts/prompts.md, AI-Sessions/wiki/{maps,records}, .obsidian/graph.json
```
