---
tags: [tier/top]
type: map
date: 2026-06-24
status: active
---

# Research Map

## Graph

- [[idea-physical-feature-graph]]
- [[idea-humanoid-arm-dual-role]]
- [[AI-Sessions/wiki/maps/resources|resources]]
- [[AI-Sessions/wiki/research/experiments/experiments|experiments]]

## Summary

research 섬의 root(tier/top)다. 다른 섬(harness/docs)과 edge로 연결되지 않는 독립 트리다. 흐름은 `research-map -> idea -> concept -> paper`로 고정한다.

상위 tier는 idea 노트, resources(소스 허브), experiments다. idea는 근거 concept(중위: `transformer`, `ppo`, `lipm`, `centroidal`)로, concept는 근거 paper(하위)로 내려간다. resources는 성격별 카테고리 sub-hub(`resources-frameworks`, `resources-dynamics-gpu`, `resources-policy-refs`)을 거쳐 source/repo/code 분석 노트(하위)로 뻗는다. paper/source는 graph leaf이며, 관계 정본인 `## Links` wikilink 외에 hub처럼 확장하지 않는다.
