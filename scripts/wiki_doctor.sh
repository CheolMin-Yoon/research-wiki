#!/usr/bin/env bash
# wiki_doctor — research-wiki 구조 무결성 검사기.
# 정책 문서를 "장식"으로 두지 않고 실제로 실행 가능한 검증으로 만든다.
# lint 커맨드가 이 스크립트를 호출한다. ERROR가 하나라도 있으면 비정상 종료(1).
#
# 사용법:
#   scripts/wiki_doctor.sh           # 전체 검사
#   scripts/wiki_doctor.sh --stale-days 30
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

MANIFEST_FILE="vault-manifest.yaml"
ALLOWED_CATEGORIES="centroidal-wbc rl-algorithms-frameworks morphology-aware-policy graph-transformer-rl loco-manipulation dynamics-guided-rl novelty"
STATE_CODE_RE='in_proj|nn\.[A-Za-z]|torch\.|[A-Za-z]_weight\b|MultiheadAttention|softmax|adjacency_matrix'
BRIEF_MAX_LINES=80
HANDOFF_MAX_LINES=120
LOG_MAX_LINES=30

STALE_DAYS=30
while [ $# -gt 0 ]; do
  case "$1" in
    --stale-days) STALE_DAYS="$2"; shift 2 ;;
    *) shift ;;
  esac
done

ERRORS=0
WARNINGS=0
err()  { printf 'ERROR  %s\n' "$1"; ERRORS=$((ERRORS+1)); }
warn() { printf 'WARN   %s\n' "$1"; WARNINGS=$((WARNINGS+1)); }
ok()   { printf 'OK     %s\n' "$1"; }

# report_hits <level> <hits> <ok_msg> <hit_prefix>
# grep 결과(hits)가 있으면 줄마다 level(err|warn)로 보고하고, 없으면 ok_msg.
# C2/C10/C12/C13이 공유하는 "grep → 보고 or ok" 관용구를 한 곳에 둔다.
report_hits() {
  local level="$1" hits="$2" ok_msg="$3" prefix="$4"
  if [ -n "$hits" ]; then
    while IFS= read -r l; do [ -n "$l" ] && "$level" "${prefix}: $l"; done <<< "$hits"
  else
    ok "$ok_msg"
  fi
}

# 코드 펜스(``` ... ```)와 inline code(`...`)를 제거한 본문을 출력한다.
# 문서가 wikilink 문법을 예시로 보여줄 때 false positive를 막는다.
strip_code() {
  awk '/^[[:space:]]*```/ { infence = !infence; next } infence { next } { print }' "$1" \
    | sed 's/`[^`]*`//g'
}

normalize_lines() {
  sed '/^[[:space:]]*$/d' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | sort -u \
    | tr '\n' ' ' \
    | sed 's/[[:space:]]*$//'
}

normalize_word_string() {
  printf '%s\n' "$1" | tr ' ' '\n' | normalize_lines
}

manifest_list() {
  local key="$1"
  awk -v key="$key" '
    $0 ~ "^" key ":" { inside=1; next }
    inside && /^[^[:space:]]/ { exit }
    inside && /^[[:space:]]*-[[:space:]]*/ {
      sub(/^[[:space:]]*-[[:space:]]*/, "")
      print
    }
  ' "$MANIFEST_FILE" | normalize_lines
}

manifest_scalar() {
  local key="$1"
  grep -m1 -E "^[[:space:]]*${key}:" "$MANIFEST_FILE" 2>/dev/null \
    | sed -E "s/^[[:space:]]*${key}:[[:space:]]*//; s/^'//; s/'$//; s/^\"//; s/\"$//"
}

manifest_command_paths() {
  awk '
    /^commands:/ { inside=1; next }
    inside && /^[^[:space:]]/ { exit }
    inside && /^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]+/, "", line)
      split(line, a, ":")
      cmd=a[1]
      sub(/^[^:]+:[[:space:]]*/, "", line)
      print cmd "|" line
    }
  ' "$MANIFEST_FILE"
}

entry_command_set() {
  local f="$1"
  sed -n '/^## Command Routing/,/^## /p' "$f" 2>/dev/null \
    | grep -oE '^- `[^`]+`' 2>/dev/null \
    | sed -E 's/^- `([^`]+)`.*/\1/' \
    | normalize_lines
}

agent_policy_command_set() {
  local f="$1"
  sed -n '/^## Command Roles/,/^## /p' "$f" 2>/dev/null \
    | awk -F'|' '/^\|[[:space:]]*[a-z]+[[:space:]]*\|/ { gsub(/[[:space:]]/, "", $2); print $2 }' \
    | normalize_lines
}

prompts_command_set() {
  local f="$1"
  sed -n '/^## Command Routing Table/,/^## /p' "$f" 2>/dev/null \
    | awk -F'|' '/^\|[[:space:]]*`?[a-z]+`?[[:space:]]*\|/ {
      gsub(/[`[:space:]]/, "", $2)
      print $2
    }' \
    | normalize_lines
}

WIKI_MD=$(find AI-Sessions/wiki -name '*.md' 2>/dev/null | sort)
ALL_MD=$(find . -name '*.md' -not -path './.obsidian/*' 2>/dev/null | sort)

echo "== wiki_doctor: $ROOT =="

# ---------------------------------------------------------------------------
# C1. 깨진 wikilink. Obsidian 해석 모델을 따른다:
#   - 리터럴 경로 존재         -> OK
#   - basename 유일 매칭        -> OK (Obsidian이 vault 전체에서 basename으로 해석)
#   - basename 다중 매칭        -> WARN (규칙이 경고하는 실제 충돌 위험)
#   - 매칭 없음                 -> ERROR (진짜 깨진 링크)
#   - `<...>` placeholder       -> skip (문서 내 예시)
# ---------------------------------------------------------------------------
echo "-- C1 broken wikilinks --"
# basename -> 매칭 개수 인덱스 (모든 md 대상, .obsidian 제외)
BN_INDEX=$(while IFS= read -r m; do [ -n "$m" ] && basename "$m" .md; done <<< "$ALL_MD" | sort | uniq -c)
bn_count() { echo "$BN_INDEX" | awk -v b="$1" '$2==b{print $1; found=1} END{if(!found)print 0}' | head -1; }
c1err=0; c1warn=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  while IFS= read -r link; do
    inner="${link#\[\[}"; inner="${inner%\]\]}"
    target="${inner%%|*}"; target="${target%%#*}"
    [ -z "$target" ] && continue
    case "$target" in *"<"*|*">"*) continue ;; esac   # placeholder 예시 skip
    case "$target" in *.md) path="$target" ;; *) path="$target.md" ;; esac
    [ -f "$path" ] && continue
    bn=$(basename "$target" .md)
    n=$(bn_count "$bn")
    if [ "$n" -eq 0 ]; then
      err "$f -> 깨진 링크 [[$inner]] (basename 매칭 없음)"; c1err=$((c1err+1))
    elif [ "$n" -gt 1 ]; then
      warn "$f -> 모호한 짧은 링크 [[$inner]] (basename '$bn' $n개 충돌, 전체 경로 권장)"; c1warn=$((c1warn+1))
    fi
  done < <(strip_code "$f" | grep -oE '\[\[[^]]+\]\]' 2>/dev/null)
done <<< "$WIKI_MD"
[ "$c1err" -eq 0 ] && [ "$c1warn" -eq 0 ] && ok "깨진/모호한 wikilink 없음"

# ---------------------------------------------------------------------------
# C2. wiki -> raw wikilink 금지 (raw는 graph에 노출하지 않음)
# ---------------------------------------------------------------------------
echo "-- C2 wiki->raw wikilinks --"
report_hits err "$(grep -rnE '\[\[AI-Sessions/raw/' AI-Sessions/wiki 2>/dev/null)" \
  "wiki->raw wikilink 없음" "wiki에서 raw로 향하는 wikilink"

# ---------------------------------------------------------------------------
# C3. wiki 노트 frontmatter 필수 필드: type / date / status
# ---------------------------------------------------------------------------
echo "-- C3 frontmatter --"
c3=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  head -1 "$f" | grep -q '^---$' || { err "frontmatter 없음: $f"; c3=$((c3+1)); continue; }
  fm=$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")
  for key in type date status; do
    echo "$fm" | grep -qE "^${key}:" || { err "frontmatter '${key}' 누락: $f"; c3=$((c3+1)); }
  done
done <<< "$WIKI_MD"
[ "$c3" -eq 0 ] && ok "frontmatter 필수 필드 정상"

# ---------------------------------------------------------------------------
# C4. category whitelist: research/categories/ 는 7개만
# ---------------------------------------------------------------------------
echo "-- C4 category whitelist --"
c4=0
for cf in AI-Sessions/wiki/research/categories/*.md; do
  [ -e "$cf" ] || continue
  base=$(basename "$cf" .md)
  echo "$ALLOWED_CATEGORIES" | grep -qw "$base" || { err "비승인 category 노트: $cf (허용: $ALLOWED_CATEGORIES)"; c4=$((c4+1)); }
done
[ "$c4" -eq 0 ] && ok "category 노트 7개 화이트리스트 준수"

# ---------------------------------------------------------------------------
# C5. stale draft: status: draft 인데 date가 STALE_DAYS 초과 (lifecycle)
# ---------------------------------------------------------------------------
echo "-- C5 stale drafts (>${STALE_DAYS}d) --"
today=$(date +%s)
c5=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  grep -qE '^status:[[:space:]]*draft' "$f" || continue
  d=$(grep -oE '^date:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
  [ -z "$d" ] && continue
  ds=$(date -d "$d" +%s 2>/dev/null) || continue
  age=$(( (today - ds) / 86400 ))
  [ "$age" -gt "$STALE_DAYS" ] && { warn "stale draft (${age}d): $f"; c5=$((c5+1)); }
done <<< "$WIKI_MD"
[ "$c5" -eq 0 ] && ok "stale draft 없음"

# ---------------------------------------------------------------------------
# C6. ingest coverage (eval: ingest-quality 흡수)
#   - raw/papers/*.pdf -> wiki/research/papers/<slug>.md 가 있는가
#   - raw/repos/*.md   -> 그 raw를 source: 로 가리키는 source 노트가 있는가
# ---------------------------------------------------------------------------
echo "-- C6 ingest coverage --"
c6=0
for pdf in AI-Sessions/raw/papers/*.pdf; do
  [ -e "$pdf" ] || continue
  slug=$(basename "$pdf" .pdf)
  # 파일명 기반 매핑 우선, 없으면 source: frontmatter 기반 매핑 확인
  if [ ! -f "AI-Sessions/wiki/research/papers/$slug.md" ]; then
    matched=$(grep -rlF "$pdf" AI-Sessions/wiki/research/papers/ 2>/dev/null | head -1)
    [ -z "$matched" ] && { warn "raw paper 미컴파일: $pdf -> research/papers/$slug.md 없음"; c6=$((c6+1)); }
  fi
done
SRC_SOURCES=$(grep -hE '^source:[[:space:]]*AI-Sessions/raw/repos/' AI-Sessions/wiki/research/sources/*.md 2>/dev/null | sed -E 's/^source:[[:space:]]*//')
for repo in AI-Sessions/raw/repos/*.md; do
  [ -e "$repo" ] || continue
  echo "$SRC_SOURCES" | grep -qF "$repo" || { warn "raw repo 미컴파일: $repo 를 source: 로 가리키는 source 노트 없음"; c6=$((c6+1)); }
done
[ "$c6" -eq 0 ] && ok "raw paper/repo 모두 wiki에 컴파일됨"

# ---------------------------------------------------------------------------
# C7. source consistency (eval: source-consistency 흡수)
#   - 각 source 노트의 source: frontmatter가 실재하는 raw 파일을 가리키는가
# ---------------------------------------------------------------------------
echo "-- C7 source consistency --"
c7=0
for f in AI-Sessions/wiki/research/sources/*.md; do
  [ -e "$f" ] || continue
  sv=$(grep -E '^source:' "$f" | head -1 | sed -E 's/^source:[[:space:]]*//')
  if [ -z "$sv" ]; then
    warn "source 노트에 source: 없음: $f"; c7=$((c7+1))
  elif [ ! -f "$sv" ]; then
    err "source provenance 깨짐: $f -> source: $sv (파일 없음)"; c7=$((c7+1))
  fi
done
[ "$c7" -eq 0 ] && ok "source 노트 provenance 정상"

# ---------------------------------------------------------------------------
# C8. category probe (eval: wiki-probes 흡수)
#   - 각 category 노트가 다른 노트에서 최소 1번 참조되는가 (orphan 탐지)
# ---------------------------------------------------------------------------
echo "-- C8 category probe --"
c8=0
for cf in AI-Sessions/wiki/research/categories/*.md; do
  [ -e "$cf" ] || continue
  slug=$(basename "$cf" .md)
  refs=$(grep -rlE "\[\[[^]]*${slug}[]|#]" AI-Sessions/wiki 2>/dev/null | grep -v "research/categories/${slug}.md")
  [ -z "$refs" ] && { warn "category orphan: $slug 를 참조하는 노트 없음"; c8=$((c8+1)); }
done
[ "$c8" -eq 0 ] && ok "category 모두 1개 이상 참조됨"

# ---------------------------------------------------------------------------
# C9. CLAUDE.md == AGENTS.md (Start Order 이후 공유 규칙은 동일해야 함)
# ---------------------------------------------------------------------------
echo "-- C9 CLAUDE/AGENTS sync --"
csec=$(sed -n '/^## Start Order/,$p' CLAUDE.md 2>/dev/null)
asec=$(sed -n '/^## Start Order/,$p' AGENTS.md 2>/dev/null)
if [ -z "$csec" ] || [ -z "$asec" ]; then
  warn "CLAUDE.md/AGENTS.md에서 '## Start Order' 섹션을 찾지 못함"
elif [ "$csec" != "$asec" ]; then
  warn "CLAUDE.md와 AGENTS.md의 공유 규칙(Start Order 이후)이 어긋남 (diff CLAUDE.md AGENTS.md)"
else
  ok "CLAUDE.md == AGENTS.md 공유 규칙 동기화됨"
fi

# ---------------------------------------------------------------------------
# C10. obsolete/stale path 탐지: 폐기된 옛 구조 경로가 살아있는 문서에 남아있는가
#   이력 보존 문서(log, refactor decision, GC archive)는 제외한다.
# ---------------------------------------------------------------------------
echo "-- C10 obsolete paths --"
DEAD_RE='AI-Sessions/wiki/(records|papers|sources|concepts|decisions|errors|experiments|ideas|design|projects|dev-tasks)/|AI-Sessions/wiki/research/(ideas|concepts)/|wiki/research/dev-tasks|AI-Sessions/wiki/records'
c10hits=$(grep -rnE "$DEAD_RE" --include='*.md' . 2>/dev/null \
  | grep -v '/.obsidian/' \
  | grep -v 'log.md:' \
  | grep -v 'harness-decisions.md:' \
  | grep -v 'archive/')
report_hits err "$c10hits" "폐기된 옛 구조 경로 없음" "폐기된 경로 참조"

# ---------------------------------------------------------------------------
# C11. map/index 누락: research 노트가 research.md에 등재되어 있는가
# ---------------------------------------------------------------------------
echo "-- C11 index coverage --"
c11=0
for d in papers sources categories; do
  for f in AI-Sessions/wiki/research/$d/*.md; do
    [ -e "$f" ] || continue
    slug=$(basename "$f" .md)
    grep -qF "$slug" research.md || { warn "research.md 누락: research/$d/$slug"; c11=$((c11+1)); }
  done
done
for f in AI-Sessions/wiki/research/idea-*.md; do
  [ -e "$f" ] || continue
  slug=$(basename "$f" .md)
  grep -qF "$slug" research.md || { warn "research.md 누락: research/$slug"; c11=$((c11+1)); }
done
[ "$c11" -eq 0 ] && ok "research 노트 모두 research.md에 등재됨"

# ---------------------------------------------------------------------------
# C12. secret-looking token grep
# ---------------------------------------------------------------------------
echo "-- C12 secret scan --"
SECRET_RE='sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*['"'"'"][^'"'"'"]{8,}'
c12hits=$(grep -rnE "$SECRET_RE" --include='*.md' . 2>/dev/null | grep -v '/.obsidian/')
report_hits warn "$c12hits" "secret 의심 토큰 없음" "secret 의심 토큰"

# ---------------------------------------------------------------------------
# C13. state layer purity (vault-manifest.yaml: state_purity)
#   state(brief/handoff)는 포인터+현재상태만. 코드 메커니즘 토큰이 새어들면
#   정본(source/paper)으로 옮기고 링크만 남기라고 WARN. 파일경로·명령어·task id 제외.
# ---------------------------------------------------------------------------
echo "-- C13 state layer purity --"
c13hits=$(grep -rnE "$STATE_CODE_RE" \
  AI-Sessions/wiki/harness/state/brief.md \
  AI-Sessions/wiki/harness/state/handoff.md 2>/dev/null)
report_hits warn "$c13hits" "state 파일에 코드 메커니즘 누출 없음" \
  "state에 코드 메커니즘 누출(정본 source/paper로 옮기고 링크)"

# ---------------------------------------------------------------------------
# C14. state/log size limits (vault-manifest.yaml: state_limits)
# ---------------------------------------------------------------------------
echo "-- C14 state/log size limits --"
check_size() {
  local f="$1" max="$2" label="$3"
  [ -f "$f" ] || return
  lines=$(wc -l < "$f")
  [ "$lines" -gt "$max" ] && warn "${label} 크기 초과 (${lines} > ${max} lines): $f — archive 또는 압축 권장"
}
check_size "AI-Sessions/wiki/harness/state/brief.md"   "$BRIEF_MAX_LINES"   "brief.md"
check_size "AI-Sessions/wiki/harness/state/handoff.md" "$HANDOFF_MAX_LINES" "handoff.md"
check_size "log.md"                                    "$LOG_MAX_LINES"     "log.md"
ok "state/log size 검사 완료"

# ---------------------------------------------------------------------------
# C15. graph registration check (harness 하위 문서)
# research 노트는 C8(category orphan)/C11(index coverage)이 이미 담당한다.
# C15는 harness 하위 문서(policies/decisions/errors/anti-patterns/templates/evals)가
# 해당 folder hub(.md)에서 wikilink로 참조되는지만 검사한다.
# archive/obsolete/GC 문서는 active hub 등록 요건에서 제외한다.
# ---------------------------------------------------------------------------
echo "-- C15 harness graph registration --"
c15=0
# GC 폴더는 archive 성격이므로 제외. 각 dir의 hub는 {dir}/{dir}.md 이다.
# evals는 2단계 hub 구조(evals.md -> sub-hub -> probe)이므로 dir 내 임의 .md 참조를 허용한다.
for dir in policies decisions errors patterns templates evals; do
  hub_prefix="AI-Sessions/wiki/harness/${dir}"
  hub_file="${hub_prefix}/${dir}.md"
  for f in "${hub_prefix}"/*.md; do
    [ -e "$f" ] || continue
    slug=$(basename "$f" .md)
    # hub 파일 자체는 건너뜀
    [ "$slug" = "$dir" ] && continue
    # archive/obsolete 문서 제외
    status_val=$(grep -m1 -E '^status:' "$f" 2>/dev/null | sed 's/^status:[[:space:]]*//')
    case "$status_val" in archived|obsolete) continue ;; esac
    # evals: dir 내 임의 .md(본인 제외)에서 참조 허용 (2단계 sub-hub 구조)
    if [ "$dir" = "evals" ]; then
      refs=$(grep -rlE "\[\[[^]]*${slug}[]|#]" "${hub_prefix}/" 2>/dev/null | grep -v "/$slug.md")
    else
      refs=$(grep -E "\[\[[^]]*${slug}[]|#]" "$hub_file" 2>/dev/null)
    fi
    [ -z "$refs" ] && { warn "harness 문서가 hub에 미등록: $f (hub: $hub_file)"; c15=$((c15+1)); }
  done
done
[ "$c15" -eq 0 ] && ok "harness 문서 graph hub 등록 정상"

# ---------------------------------------------------------------------------
# C16. manifest/script drift: script 상수와 vault-manifest.yaml mirror가 어긋나는가
# ---------------------------------------------------------------------------
echo "-- C16 manifest drift --"
c16=0
manifest_categories=$(manifest_list "allowed_categories")
script_categories=$(normalize_word_string "$ALLOWED_CATEGORIES")
if [ "$manifest_categories" != "$script_categories" ]; then
  warn "manifest/script 드리프트: allowed_categories (manifest: $manifest_categories / script: $script_categories)"
  c16=$((c16+1))
fi

manifest_state_re=$(manifest_scalar "forbidden_token_regex")
if [ "$manifest_state_re" != "$STATE_CODE_RE" ]; then
  warn "manifest/script 드리프트: state_purity.forbidden_token_regex"
  c16=$((c16+1))
fi

manifest_brief_max=$(manifest_scalar "brief_max_lines")
manifest_handoff_max=$(manifest_scalar "handoff_max_lines")
manifest_log_max=$(manifest_scalar "log_max_lines")
[ "$manifest_brief_max" = "$BRIEF_MAX_LINES" ] || { warn "manifest/script 드리프트: state_limits.brief_max_lines"; c16=$((c16+1)); }
[ "$manifest_handoff_max" = "$HANDOFF_MAX_LINES" ] || { warn "manifest/script 드리프트: state_limits.handoff_max_lines"; c16=$((c16+1)); }
[ "$manifest_log_max" = "$LOG_MAX_LINES" ] || { warn "manifest/script 드리프트: state_limits.log_max_lines"; c16=$((c16+1)); }
[ "$c16" -eq 0 ] && ok "manifest/script 드리프트 없음"

# ---------------------------------------------------------------------------
# C17. command routing consistency: manifest commands와 entry/prompt 표가 같은 집합인가
# ---------------------------------------------------------------------------
echo "-- C17 command routing consistency --"
c17=0
manifest_cmds=$(manifest_command_paths | cut -d'|' -f1 | normalize_lines)
while IFS='|' read -r cmd path; do
  [ -z "$cmd" ] && continue
  [ -f "$path" ] || { warn "manifest command path 없음: $cmd -> $path"; c17=$((c17+1)); }
done < <(manifest_command_paths)

for f in AGENTS.md CLAUDE.md; do
  actual=$(entry_command_set "$f")
  if [ "$actual" != "$manifest_cmds" ]; then
    warn "command routing 집합 불일치: $f (manifest: $manifest_cmds / doc: $actual)"
    c17=$((c17+1))
  fi
done

actual=$(agent_policy_command_set "AI-Sessions/wiki/harness/policies/agent-policy.md")
if [ "$actual" != "$manifest_cmds" ]; then
  warn "command routing 집합 불일치: agent-policy.md (manifest: $manifest_cmds / doc: $actual)"
  c17=$((c17+1))
fi

actual=$(prompts_command_set "prompts/prompts.md")
if [ "$actual" != "$manifest_cmds" ]; then
  warn "command routing 집합 불일치: prompts/prompts.md (manifest: $manifest_cmds / doc: $actual)"
  c17=$((c17+1))
fi
[ "$c17" -eq 0 ] && ok "command routing 집합 일관성 정상"

# ---------------------------------------------------------------------------
# C18. research graph registration + harness isolation + tier colors
#   - harness active notes must not wikilink research notes.
#   - research-map must not directly wikilink categories; idea notes own category fanout.
#   - each paper must be graph-registered by exactly one primary category.
#   - graph tier colors must be red/yellow/green/blue.
# ---------------------------------------------------------------------------
echo "-- C18 research graph registration / tier colors --"
c18=0
c18hits=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  hits=$(strip_code "$f" | grep -nE '\[\[AI-Sessions/wiki/research/' 2>/dev/null | sed "s|^|$f:|")
  [ -n "$hits" ] && c18hits="${c18hits}${hits}"$'\n'
done < <(find AI-Sessions/wiki/harness -name '*.md' -not -path '*/archive/*' 2>/dev/null | sort)
if [ -n "$c18hits" ]; then
  report_hits err "$c18hits" "" "harness->research wikilink 금지"
  c18=$((c18+1))
fi

for cat in $ALLOWED_CATEGORIES; do
  hits=$(strip_code "AI-Sessions/wiki/maps/research-map.md" \
    | grep -nE "\[\[(AI-Sessions/wiki/research/categories/)?${cat}(\||\]\])" 2>/dev/null \
    | sed "s|^|AI-Sessions/wiki/maps/research-map.md:|")
  if [ -n "$hits" ]; then
    report_hits err "$hits" "" "research-map->category 직접 wikilink 금지"
    c18=$((c18+1))
  fi

  refs=$(grep -rlE "\[\[(AI-Sessions/wiki/research/categories/)?${cat}(\||\]\])" AI-Sessions/wiki/research/idea-*.md 2>/dev/null | sort)
  if [ -z "$refs" ]; then
    err "category가 idea에서 graph 등록 안 됨: $cat"
    c18=$((c18+1))
  fi
done

for f in AI-Sessions/wiki/research/papers/*.md; do
  [ -e "$f" ] || continue
  slug=$(basename "$f" .md)
  refs=$(grep -rlE "\[\[AI-Sessions/wiki/research/papers/${slug}(\||\]\])" AI-Sessions/wiki/research/categories 2>/dev/null | sort)
  ref_count=$(printf '%s\n' "$refs" | sed '/^$/d' | wc -l)
  if [ "$ref_count" -eq 0 ]; then
    err "paper category graph 등록 누락: $slug"
    c18=$((c18+1))
  elif [ "$ref_count" -gt 1 ]; then
    err "paper primary category 중복 등록: $slug -> $(printf '%s' "$refs" | tr '\n' ' ')"
    c18=$((c18+1))
  fi
done

graph_color() {
  awk -v needle="$1" '
    index($0, "\"query\":") && index($0, needle) { found=1 }
    found && /"rgb":/ { gsub(/[^0-9]/, ""); print; exit }
  ' .obsidian/graph.json
}
[ "$(graph_color 'tag:#tier/top')" = "16726832" ] || { err "tier/top color drift: expected #FF3B30"; c18=$((c18+1)); }
[ "$(graph_color 'tag:#tier/upper')" = "16763904" ] || { err "tier/upper color drift: expected #FFCC00"; c18=$((c18+1)); }
[ "$(graph_color 'tag:#tier/mid')" = "3458905" ] || { err "tier/mid color drift: expected #34C759"; c18=$((c18+1)); }
[ "$(graph_color 'tag:#tier/low')" = "689407" ] || { err "tier/low color drift: expected #0A84FF"; c18=$((c18+1)); }
[ "$c18" -eq 0 ] && ok "research graph 등록, idea category fanout, harness isolation, tier color 정상"

# ---------------------------------------------------------------------------
echo "== 요약: ERROR=$ERRORS WARN=$WARNINGS =="
[ "$ERRORS" -gt 0 ] && exit 1
exit 0
