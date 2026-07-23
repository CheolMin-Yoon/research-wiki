from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))
SPEC = importlib.util.spec_from_file_location("analyze_research_graph", SCRIPTS / "analyze_research_graph.py")
assert SPEC and SPEC.loader
graph = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = graph
SPEC.loader.exec_module(graph)


class LouvainTests(unittest.TestCase):
    def test_deterministic_partition(self) -> None:
        adjacency = {
            "a": {"b", "c"},
            "b": {"a", "c"},
            "c": {"a", "b", "d"},
            "d": {"c", "e", "f"},
            "e": {"d", "f"},
            "f": {"d", "e"},
            "orphan": set(),
        }
        first = graph.louvain_communities(adjacency, resolution=1.15)
        second = graph.louvain_communities(dict(reversed(list(adjacency.items()))), resolution=1.15)
        self.assertEqual(first, second)
        self.assertEqual(sorted(node for group in first for node in group), sorted(adjacency))

    def test_report_is_byte_deterministic(self) -> None:
        self.assertEqual(graph.serialized_report(ROOT), graph.serialized_report(ROOT))

    def test_scope_excludes_ideas_and_experiments(self) -> None:
        nodes = graph.stable_nodes(ROOT)
        self.assertTrue(nodes)
        self.assertFalse(any("/ideas/" in node or "/experiments/" in node for node in nodes))


if __name__ == "__main__":
    unittest.main()
