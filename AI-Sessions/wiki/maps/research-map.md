---
tags: [tier/top]
type: map
date: 2026-06-24
status: active
---

# Research Map

## Graph

- [[idea-physical-feature-graph]]
- [[AI-Sessions/wiki/maps/resources|resources]]
- [[AI-Sessions/wiki/research/experiments/experiments|experiments]]

## Summary

research 섬의 root(tier/top)다. 다른 섬(harness/docs)과 edge로 연결되지 않는 독립 트리다. graph-visible 흐름은 `research-map -> idea -> category -> paper`이며, resources/experiments는 research root의 별도 상위 가지다.

상위 tier는 idea 노트, resources(소스 허브), experiments다. research-map은 category를 직접 링크하지 않고, idea가 근거 category(중위: A–G 7개 — `centroidal-wbc`, `rl-algorithms-frameworks`, `morphology-aware-policy`, `graph-transformer-rl`, `loco-manipulation`, `dynamics-guided-rl`, `novelty`)로 fanout한다. category는 primary paper를 full-path wikilink로 등록한다. resources는 성격별 카테고리 sub-hub(`resources-frameworks`, `resources-dynamics-gpu`, `resources-policy-refs`)을 거쳐 source/repo/code 분석 노트(하위)로 뻗는다.
