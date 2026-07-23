#!/usr/bin/env python3
"""Build a deterministic Louvain report for explicit stable research links."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import deque
from pathlib import Path

from validate_research import STABLE_TYPES, WIKILINK_RE, parse_frontmatter


RESOLUTION = 1.15
MAX_ITERATIONS = 30


def stable_nodes(root: Path) -> dict[str, tuple[Path, str]]:
    research = root / "AI-Sessions/wiki/research"
    nodes: dict[str, tuple[Path, str]] = {}
    for path in sorted(research.rglob("*.md")):
        frontmatter, body = parse_frontmatter(path)
        if frontmatter.get("type") not in STABLE_TYPES:
            continue
        node_id = path.relative_to(root).as_posix()
        nodes[node_id] = (path, body)
    return nodes


def build_graph(root: Path) -> dict[str, set[str]]:
    nodes = stable_nodes(root)
    adjacency = {node_id: set() for node_id in nodes}
    by_stem: dict[str, list[str]] = {}
    for node_id in nodes:
        by_stem.setdefault(Path(node_id).stem, []).append(node_id)

    for source_id, (_, body) in nodes.items():
        for match in WIKILINK_RE.finditer(body):
            target = match.group(1).split("|", 1)[0].split("#", 1)[0].strip()
            if not target:
                continue
            if target.endswith(".md"):
                target = target[:-3]
            direct = f"{target}.md"
            target_id: str | None = direct if direct in nodes else None
            if target_id is None:
                candidates = by_stem.get(Path(target).stem, [])
                if len(candidates) == 1:
                    target_id = candidates[0]
            if target_id is None or target_id == source_id:
                continue
            adjacency[source_id].add(target_id)
            adjacency[target_id].add(source_id)
    return adjacency


def louvain_communities(
    adjacency: dict[str, set[str]],
    resolution: float = RESOLUTION,
) -> list[list[str]]:
    """Pure-Python deterministic local-moving Louvain for an unweighted graph."""
    nodes = sorted(adjacency)
    if not nodes:
        return []
    total_edges = sum(len(neighbors) for neighbors in adjacency.values()) / 2
    if total_edges == 0:
        return [[node] for node in nodes]

    m2 = 2 * total_edges
    degrees = {node: len(adjacency[node]) for node in nodes}
    node_to_comm = {node: index for index, node in enumerate(nodes)}
    comm_degree = {index: float(degrees[node]) for index, node in enumerate(nodes)}

    improved = True
    iteration = 0
    while improved and iteration < MAX_ITERATIONS:
        improved = False
        iteration += 1
        for node in nodes:
            current_comm = node_to_comm[node]
            neighbor_weights: dict[int, int] = {}
            for neighbor in sorted(adjacency[node]):
                neighbor_comm = node_to_comm[neighbor]
                neighbor_weights[neighbor_comm] = neighbor_weights.get(neighbor_comm, 0) + 1

            comm_degree[current_comm] -= degrees[node]
            current_links = neighbor_weights.get(current_comm, 0)
            best_comm = current_comm
            best_gain = current_links - resolution * comm_degree[current_comm] * degrees[node] / m2

            for candidate, internal_links in sorted(neighbor_weights.items()):
                if candidate == current_comm:
                    continue
                gain = internal_links - resolution * comm_degree.get(candidate, 0.0) * degrees[node] / m2
                if gain > best_gain + 1e-12:
                    best_gain = gain
                    best_comm = candidate

            comm_degree[best_comm] = comm_degree.get(best_comm, 0.0) + degrees[node]
            node_to_comm[node] = best_comm
            if best_comm != current_comm:
                improved = True

    groups: dict[int, list[str]] = {}
    for node, community in node_to_comm.items():
        groups.setdefault(community, []).append(node)
    return sorted(
        (sorted(members) for members in groups.values()),
        key=lambda members: (-len(members), members[0]),
    )


def modularity(partition: list[list[str]], adjacency: dict[str, set[str]]) -> float:
    edge_count = sum(len(neighbors) for neighbors in adjacency.values()) / 2
    if edge_count == 0:
        return 0.0
    degrees = {node: len(neighbors) for node, neighbors in adjacency.items()}
    score = 0.0
    for members in partition:
        member_set = set(members)
        internal_degree = sum(len(adjacency[node] & member_set) for node in members)
        total_degree = sum(degrees[node] for node in members)
        score += internal_degree / (2 * edge_count) - (total_degree / (2 * edge_count)) ** 2
    return score


def connected_components(adjacency: dict[str, set[str]]) -> list[list[str]]:
    remaining = set(adjacency)
    components: list[list[str]] = []
    while remaining:
        start = min(remaining)
        queue = deque([start])
        remaining.remove(start)
        members: list[str] = []
        while queue:
            node = queue.popleft()
            members.append(node)
            for neighbor in sorted(adjacency[node]):
                if neighbor in remaining:
                    remaining.remove(neighbor)
                    queue.append(neighbor)
        components.append(sorted(members))
    return sorted(components, key=lambda members: (-len(members), members[0]))


def build_report(root: Path, resolution: float = RESOLUTION) -> dict[str, object]:
    adjacency = build_graph(root)
    partition = louvain_communities(adjacency, resolution=resolution)
    degrees = {node: len(neighbors) for node, neighbors in adjacency.items()}
    community_of = {
        node: community_id
        for community_id, members in enumerate(partition)
        for node in members
    }

    communities: list[dict[str, object]] = []
    for community_id, members in enumerate(partition):
        hub = min(members, key=lambda node: (-degrees[node], node))
        communities.append(
            {
                "id": community_id,
                "label": Path(hub).stem,
                "hub": hub,
                "size": len(members),
                "members": members,
            }
        )

    bridges: list[dict[str, object]] = []
    for node, neighbors in adjacency.items():
        foreign = sorted(neighbor for neighbor in neighbors if community_of[neighbor] != community_of[node])
        if foreign:
            bridges.append(
                {
                    "node": node,
                    "cross_community_edges": len(foreign),
                    "connected_communities": sorted({community_of[neighbor] for neighbor in foreign}),
                }
            )
    bridges.sort(key=lambda item: (-int(item["cross_community_edges"]), str(item["node"])))

    hubs = [
        {"node": node, "degree": degree}
        for node, degree in sorted(degrees.items(), key=lambda item: (-item[1], item[0]))
        if degree > 0
    ]
    edge_count = sum(degrees.values()) // 2
    return {
        "schema_version": 1,
        "scope": "stable research types and explicit wikilinks only",
        "resolution": resolution,
        "node_count": len(adjacency),
        "edge_count": edge_count,
        "connected_component_count": len(connected_components(adjacency)),
        "modularity": round(modularity(partition, adjacency), 6),
        "communities": communities,
        "hubs": hubs,
        "bridges": bridges,
        "orphans": sorted(node for node, degree in degrees.items() if degree == 0),
    }


def serialized_report(root: Path, resolution: float = RESOLUTION) -> str:
    return json.dumps(build_report(root, resolution), ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, default=Path("exports/research-communities.json"))
    parser.add_argument("--resolution", type=float, default=RESOLUTION)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)

    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    expected = serialized_report(root, args.resolution)
    if args.check:
        if not output.is_file() or output.read_text(encoding="utf-8") != expected:
            print(f"stale research community report: {output}", file=sys.stderr)
            return 1
        return 0
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(expected, encoding="utf-8")
    print(f"wrote {output.relative_to(root)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
