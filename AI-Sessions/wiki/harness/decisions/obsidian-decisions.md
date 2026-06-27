---
tags: [tier/low]
type: decision
date: 2026-06-24
status: active
---

# Obsidian / Graph Decisions

vault graph 구조에 대한 결정 로그. 최신 결정이 위, superseded는 아래에 보존한다.

## 3개 독립 섬 + tier 색상 graph 구조 (active)

### Decision

graph를 서로 edge로 연결되지 않는 **3개 독립 섬**으로 구성한다: `research-map`, `harness-map`, `docs-map`. resources는 최상위에서 강등해 research 섬의 상위 가지로 편입한다. 색은 폴더가 아니라 **tier 태그**로 결정한다.

| tier | 의미 | 색 |
|---|---|---|
| `tier/top` | 섬 root (map 3개) | 🔴 #FF3B30 |
| `tier/upper` | 영역 진입(idea/resources, harness 그룹, prompts+root docs) | 🟡 #FFCC00 |
| `tier/mid` | 분류 hub (categories, harness 폴더 hub) | 🟢 #34C759 |
| `tier/low` | 콘텐츠 (papers/sources, 개별 파일, prompt) | 🔵 #0A84FF |

### Reason

- Obsidian colorGroups는 graph 깊이로 색칠 불가, `path:`/`tag:`만 지원 → 깊이는 `tier/*` 태그로 부여.
- 폴더(category)와 graph 깊이(tier)는 직교 축. 폴더는 그대로, tier만 태그.
- 섬 분리를 위해 architecture는 섬 root를 wikilink로 연결하지 않고 일반 텍스트로만 가리킨다(docs 섬 소속).
- harness 상위 tier용 의미 그룹 4개(state/rules/lessons/machinery)를 `maps/`에 둔다.
- Reflect: research category는 root의 병렬 가지가 아니라 idea가 참조하는 근거 축이다. 따라서 novelty/rl-algorithms 같은 category도 research-map에 직접 붙이지 않고 idea를 통해 연결한다.

### Impact

- 새 graph 노트는 `tier/*` 태그 부여. root docs는 colorGroups `path:` 절로 upper 색.
- paper는 idea-linked primary category 1개에서 full-path wikilink로 research-map 아래에 등록한다. harness에서 paper/research 노트를 언급할 때는 plaintext를 쓴다.
- `.obsidian/graph.json`은 Obsidian 종료 상태에서만 수정. 검증은 `wiki_doctor` C1/C15.

## (superseded) 최상위 group 4개 고정

> ⚠️ 위 "3개 독립 섬" 결정으로 대체됨. 최상위는 3개로 줄고 resources는 research로 강등, 색은 폴더 group이 아니라 tier 태그로 결정. 아래는 historical record.

원래 결정: 최상위 graph group을 `research-map`, `resources`, `harness-map`, `docs-map` 네 개로 고정하고 resources를 독립 최상위로 유지. 근거: source/code 노트를 research에 nesting하면 backbone에 섞이거나 끊겨 보여서 독립 group으로 의미축을 분리. 파일은 `research/sources/`에 두되 graph상으로만 resources group에 속하게 함.

## Links

- [[AI-Sessions/wiki/harness/policies/obsidian-policy|obsidian-policy]]
- [[AI-Sessions/wiki/harness/errors/obsidian-errors|obsidian-errors]]
- [[AI-Sessions/wiki/harness/decisions/harness-decisions|harness-decisions]]
