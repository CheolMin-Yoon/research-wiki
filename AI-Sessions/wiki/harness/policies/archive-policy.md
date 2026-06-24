---
tags: [tier/low]
type: policy
date: 2026-06-24
status: active
---

# Archive Policy

obsolete/archive 정리 규칙이다. 문서를 정리·보존하는 작업일 때 읽는다. 보존 장부는 `AI-Sessions/wiki/harness/archive/`에 둔다.

## Principle

삭제보다 `status: obsolete` 또는 archive를 우선한다.

## Obsolete 처리 조건

- 환경이 바뀌어 더 이상 적용되지 않음
- 더 좋은 decision/policy로 대체됨
- 특정 실험 조건에서만 의미 있었음
- 현재 research-map과 연결이 끊김
- source repo 구조가 바뀌어 기존 분석이 부정확해짐

## 삭제하지 않는 조건

- 실패 재발 가능성이 있음
- root cause가 일반화 가능함
- 같은 pattern이 여러 번 등장함
- 과거 decision의 근거 추적에 필요함

## Archive 대상

- 초기 setup 상세 로그
- superseded graph 실험 기록
- 완료된 오래된 task
- active context에서 밀려난 handoff history

## Rule

active 문서와 같은 basename의 archive 사본을 만들지 않는다(Obsidian wikilink resolution 충돌). archive 문서는 active hub에 일반 entry로 노출하지 않고 `archive/obsolete-index`에 기록한다.
