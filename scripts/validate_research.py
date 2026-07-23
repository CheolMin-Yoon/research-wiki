#!/usr/bin/env python3
"""Validate the typed research domain without third-party dependencies."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


RESEARCH_TYPES = {
    "concepts": "concept",
    "methods": "method",
    "tasks": "task",
    "papers": "paper",
    "sources": "source",
    "comparisons": "comparison",
    "ideas": "idea",
    "experiments": "experiment",
}
STABLE_TYPES = {"concept", "method", "task", "paper", "source", "comparison"}
COMMON_STATUSES = {"draft", "active", "curator-review", "superseded", "obsolete"}
EXPERIMENT_STATUSES = {"planned", "active", "running", "done", "invalid", "archived"}
WIKILINK_RE = re.compile(r"\[\[([^\]]+)\]\]")


@dataclass(frozen=True, order=True)
class Finding:
    code: str
    path: str
    message: str

    def render(self) -> str:
        location = f"{self.path}: " if self.path else ""
        return f"ERROR  [{self.code}] {location}{self.message}"


def _scalar(value: str) -> Any:
    value = value.strip()
    if not value:
        return ""
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [_scalar(item) for item in inner.split(",")]
    if value in {"true", "false"}:
        return value == "true"
    return value


def parse_frontmatter(path: Path) -> tuple[dict[str, Any], str]:
    """Parse the flat YAML subset used by the vault and return body text."""
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text
    try:
        closing = next(index for index, line in enumerate(lines[1:], 1) if line.strip() == "---")
    except StopIteration:
        return {}, text

    data: dict[str, Any] = {}
    current_list: str | None = None
    for raw in lines[1:closing]:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        list_match = re.match(r"^\s+-\s+(.+?)\s*$", raw)
        if list_match and current_list:
            data.setdefault(current_list, []).append(_scalar(list_match.group(1)))
            continue
        key_match = re.match(r"^([A-Za-z0-9_-]+):(?:\s*(.*))?$", raw)
        if not key_match:
            current_list = None
            continue
        key, raw_value = key_match.group(1), key_match.group(2) or ""
        value = _scalar(raw_value)
        data[key] = value
        current_list = key if raw_value == "" else None
        if current_list:
            data[key] = []
    return data, "\n".join(lines[closing + 1 :]) + "\n"


def load_topic_registry(path: Path) -> tuple[set[str], set[str], set[str]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    active = set(payload["active"])
    aliases = set(payload["aliases"])
    invalid_alias_targets = set(payload["aliases"].values()) - active
    if invalid_alias_targets:
        raise ValueError(f"alias targets are not active topics: {sorted(invalid_alias_targets)}")
    pending: set[str] = set()
    for entry in payload.get("pending", []):
        pending.add(entry if isinstance(entry, str) else entry["id"])
    return active, aliases, pending


def resolve_wikilink(root: Path, target: str) -> bool:
    target = target.split("|", 1)[0].split("#", 1)[0].strip()
    if not target or "<" in target or ">" in target:
        return True
    candidate = root / (target if target.endswith(".md") or target.endswith(".base") else f"{target}.md")
    return candidate.is_file()


def _strip_code(text: str) -> str:
    output: list[str] = []
    in_fence = False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if not in_fence:
            output.append(re.sub(r"`[^`]*`", "", line))
    return "\n".join(output)


def _validate_all_wikilinks(root: Path) -> list[Finding]:
    wiki = root / "AI-Sessions/wiki"
    candidates = list(root.rglob("*.md")) + list(root.rglob("*.base"))
    by_stem: dict[str, list[Path]] = {}
    for candidate in candidates:
        if ".git" in candidate.parts:
            continue
        by_stem.setdefault(candidate.stem, []).append(candidate)

    findings: list[Finding] = []
    for path in sorted(wiki.rglob("*.md")):
        rel = path.relative_to(root).as_posix()
        for match in WIKILINK_RE.finditer(_strip_code(path.read_text(encoding="utf-8"))):
            raw_target = match.group(1)
            target = raw_target.split("|", 1)[0].split("#", 1)[0].strip()
            if not target or "<" in target or ">" in target:
                continue
            suffix = "" if target.endswith((".md", ".base")) else ".md"
            if (root / f"{target}{suffix}").is_file():
                continue
            stem = Path(target).stem
            if not by_stem.get(stem):
                findings.append(Finding("wikilink", rel, f"target does not exist: [[{raw_target}]]"))
    return findings


def relation_sections(body: str) -> Iterable[str]:
    lines = body.splitlines()
    start: int | None = None
    for index, line in enumerate(lines):
        if line.strip() == "## Relations":
            start = index + 1
            continue
        if start is not None and line.startswith("## "):
            yield "\n".join(lines[start:index])
            start = None
    if start is not None:
        yield "\n".join(lines[start:])


def _validate_note(
    root: Path,
    path: Path,
    expected_type: str,
    active_topics: set[str],
    aliases: set[str],
    pending: set[str],
) -> list[Finding]:
    rel = path.relative_to(root).as_posix()
    frontmatter, body = parse_frontmatter(path)
    findings: list[Finding] = []

    if frontmatter.get("type") != expected_type:
        findings.append(Finding("folder-type", rel, f"expected type '{expected_type}', found {frontmatter.get('type')!r}"))
    for key in ("type", "date", "status", "topics"):
        if key not in frontmatter or frontmatter[key] in ("", []):
            findings.append(Finding("required-frontmatter", rel, f"missing non-empty '{key}'"))

    status = frontmatter.get("status")
    allowed_statuses = EXPERIMENT_STATUSES if expected_type == "experiment" else COMMON_STATUSES
    if status and status not in allowed_statuses:
        findings.append(Finding("status", rel, f"status '{status}' is not allowed for {expected_type}"))

    for forbidden in ("category", "primary_category"):
        if forbidden in frontmatter:
            findings.append(Finding("legacy-category", rel, f"forbidden frontmatter field '{forbidden}'"))

    topics = frontmatter.get("topics", [])
    if topics and not isinstance(topics, list):
        findings.append(Finding("topics-shape", rel, "topics must be a YAML list"))
        topics = []
    for topic in topics:
        if topic in aliases:
            findings.append(Finding("topic-alias", rel, f"alias '{topic}' is forbidden; use its canonical ID"))
        elif topic in pending:
            findings.append(Finding("topic-pending", rel, f"pending topic '{topic}' requires curator approval"))
        elif topic not in active_topics:
            findings.append(Finding("topic-unknown", rel, f"unknown topic '{topic}'"))

    if expected_type in {"paper", "source", "idea", "experiment"} and not frontmatter.get("source"):
        findings.append(Finding("provenance", rel, f"{expected_type} requires a non-empty source"))
    if expected_type == "source" and frontmatter.get("source"):
        source = str(frontmatter["source"])
        if not re.match(r"^https?://", source) and not (root / source).is_file():
            findings.append(Finding("provenance", rel, f"source path does not exist: {source}"))

    for section in relation_sections(body):
        for match in WIKILINK_RE.finditer(section):
            raw_target = match.group(1)
            target = raw_target.split("|", 1)[0].split("#", 1)[0].strip()
            if not target.startswith("AI-Sessions/wiki/"):
                findings.append(Finding("relation-path", rel, f"relation must use a full wiki path: [[{raw_target}]]"))
            elif not resolve_wikilink(root, target):
                findings.append(Finding("relation-target", rel, f"relation target does not exist: [[{raw_target}]]"))
            if "/categories/" in target:
                findings.append(Finding("legacy-category", rel, f"category relation is forbidden: [[{raw_target}]]"))
    return findings


def _validate_graph(root: Path) -> list[Finding]:
    path = root / ".obsidian/graph.json"
    rel = path.relative_to(root).as_posix()
    findings: list[Finding] = []
    try:
        graph = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [Finding("graph-config", rel, f"cannot parse graph configuration: {exc}")]

    search = str(graph.get("search", ""))
    for note_type in sorted(STABLE_TYPES):
        if f"[type:{note_type}]" not in search:
            findings.append(Finding("graph-filter", rel, f"missing stable type filter [type:{note_type}]"))
    for forbidden in ("/categories/", "[type:idea]", "[type:experiment]", "tier/"):
        if forbidden in search:
            findings.append(Finding("graph-filter", rel, f"default graph contains forbidden filter '{forbidden}'"))
    if graph.get("showOrphans") is not False:
        findings.append(Finding("graph-filter", rel, "showOrphans must be false"))

    queries = {group.get("query") for group in graph.get("colorGroups", [])}
    for note_type in sorted(STABLE_TYPES):
        if f"[type:{note_type}]" not in queries:
            findings.append(Finding("graph-colors", rel, f"missing type color group [type:{note_type}]"))
    if any(query and "tier/" in query for query in queries):
        findings.append(Finding("graph-colors", rel, "research graph color groups must not use tier tags"))
    return findings


def _validate_base(root: Path) -> list[Finding]:
    path = root / "AI-Sessions/wiki/research/research-library.base"
    rel = path.relative_to(root).as_posix()
    if not path.is_file():
        return [Finding("bases", rel, "research library is missing")]
    text = path.read_text(encoding="utf-8")
    expected = (
        "Stable Knowledge",
        "Evidence",
        "Comparisons",
        "Active Ideas",
        "Experiments",
        "Draft/Curator Review",
    )
    return [Finding("bases", rel, f"missing view '{view}'") for view in expected if f"name: {view}" not in text]


def _validate_active_contract(root: Path) -> list[Finding]:
    findings: list[Finding] = []
    category_dir = root / "AI-Sessions/wiki/research/categories"
    if category_dir.exists():
        findings.append(Finding("legacy-category", category_dir.relative_to(root).as_posix(), "category directory must not exist"))

    active_paths = [root / "architecture.md", root / "research.md", root / "harness.md"]
    active_paths.extend((root / "prompts").glob("*.md"))
    active_paths.extend((root / "AI-Sessions/wiki/harness/policies").glob("*.md"))
    active_paths.extend((root / "AI-Sessions/wiki/harness/templates").glob("*.md"))
    active_paths.extend((root / "AI-Sessions/wiki/maps").glob("*.md"))
    patterns = {
        "research/categories": re.compile(r"research/categories"),
        "category wikilink": re.compile(r"\[\[[^\]]*categories/"),
    }
    for path in active_paths:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(root).as_posix()
        for label, pattern in patterns.items():
            if pattern.search(text):
                findings.append(Finding("legacy-category", rel, f"active document contains {label}"))
    return findings


def validate_repository(root: Path) -> list[Finding]:
    root = root.resolve()
    registry = root / "schema/research-topics.json"
    if not registry.is_file():
        return [Finding("topic-registry", "schema/research-topics.json", "registry is missing")]
    try:
        active_topics, aliases, pending = load_topic_registry(registry)
    except (json.JSONDecodeError, KeyError, TypeError, ValueError) as exc:
        return [Finding("topic-registry", "schema/research-topics.json", f"invalid registry: {exc}")]
    findings: list[Finding] = []
    research_root = root / "AI-Sessions/wiki/research"
    for folder, expected_type in RESEARCH_TYPES.items():
        directory = research_root / folder
        if not directory.is_dir():
            findings.append(Finding("research-folder", directory.relative_to(root).as_posix(), "required folder is missing"))
            continue
        for path in sorted(directory.glob("*.md")):
            findings.extend(_validate_note(root, path, expected_type, active_topics, aliases, pending))
    findings.extend(_validate_graph(root))
    findings.extend(_validate_base(root))
    findings.extend(_validate_active_contract(root))
    findings.extend(_validate_all_wikilinks(root))
    return sorted(set(findings))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args(argv)
    findings = validate_repository(args.root)
    for finding in findings:
        print(finding.render())
    print(f"research-schema: ERROR={len(findings)} WARN=0")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
