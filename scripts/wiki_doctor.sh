#!/usr/bin/env bash
# Single user-facing entrypoint for research-wiki structural validation.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

ERRORS=0
WARNINGS=0

err() {
  printf 'ERROR  %s\n' "$1"
  ERRORS=$((ERRORS + 1))
}

ok() {
  printf 'OK     %s\n' "$1"
}

echo "== wiki_doctor: $ROOT =="

echo "-- typed research schema --"
if python3 scripts/validate_research.py; then
  ok "typed research schema, topics, relations, Bases, graph 정상"
else
  err "typed research schema validator 실패"
fi

echo "-- CLAUDE/AGENTS semantic sync --"
claude_shared="$(sed -n '/^## Start Order/,$p' CLAUDE.md 2>/dev/null)"
agents_shared="$(sed -n '/^## Start Order/,$p' AGENTS.md 2>/dev/null)"
if [ -z "$claude_shared" ] || [ -z "$agents_shared" ]; then
  err "CLAUDE.md 또는 AGENTS.md에서 Start Order를 찾지 못함"
elif [ "$claude_shared" != "$agents_shared" ]; then
  err "CLAUDE.md와 AGENTS.md의 Start Order 이후 규칙이 어긋남"
else
  ok "CLAUDE.md와 AGENTS.md 의미 동기화됨"
fi

echo "-- immutable raw boundary --"
if [ -n "$(git status --porcelain -- AI-Sessions/raw 2>/dev/null)" ]; then
  err "AI-Sessions/raw에 working-tree 변경이 있음"
else
  ok "AI-Sessions/raw diff 없음"
fi

echo "-- compact state limits --"
check_limit() {
  local path="$1" limit="$2"
  local count
  count="$(wc -l < "$path")"
  if [ "$count" -gt "$limit" ]; then
    err "$path 크기 초과 ($count > $limit lines)"
  else
    ok "$path 크기 정상 ($count <= $limit)"
  fi
}
check_limit AI-Sessions/wiki/harness/state/brief.md 80
check_limit AI-Sessions/wiki/harness/state/handoff.md 120
check_limit log.md 30

echo "-- deterministic research communities --"
if [ ! -f scripts/analyze_research_graph.py ]; then
  err "scripts/analyze_research_graph.py 없음"
elif [ ! -f exports/research-communities.json ]; then
  err "exports/research-communities.json 없음"
elif python3 scripts/analyze_research_graph.py --check; then
  ok "Louvain report 최신 상태"
else
  err "Louvain report가 현재 stable graph와 다름"
fi

echo "== 요약: ERROR=$ERRORS WARN=$WARNINGS =="
[ "$ERRORS" -eq 0 ]
