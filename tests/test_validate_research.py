from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_research", ROOT / "scripts/validate_research.py")
assert SPEC and SPEC.loader
validate_research = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = validate_research
SPEC.loader.exec_module(validate_research)


class ResearchSchemaTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        research = self.root / "AI-Sessions/wiki/research"
        for folder in validate_research.RESEARCH_TYPES:
            (research / folder).mkdir(parents=True, exist_ok=True)
        (self.root / "schema").mkdir()
        (self.root / ".obsidian").mkdir()
        (self.root / "prompts").mkdir()
        for folder in ("policies", "templates"):
            (self.root / f"AI-Sessions/wiki/harness/{folder}").mkdir(parents=True)
        (self.root / "AI-Sessions/wiki/maps").mkdir(parents=True)
        for filename in ("architecture.md", "research.md", "harness.md"):
            (self.root / filename).write_text("# clean\n", encoding="utf-8")

        registry = {
            "schema_version": 1,
            "active": ["humanoid", "reinforcement-learning"],
            "aliases": {"rl": "reinforcement-learning"},
            "pending": [{"id": "candidate-topic"}],
        }
        (self.root / "schema/research-topics.json").write_text(json.dumps(registry), encoding="utf-8")
        stable = sorted(validate_research.STABLE_TYPES)
        graph = {
            "search": " ".join(f"[type:{item}]" for item in stable),
            "showOrphans": False,
            "colorGroups": [{"query": f"[type:{item}]"} for item in stable],
        }
        (self.root / ".obsidian/graph.json").write_text(json.dumps(graph), encoding="utf-8")
        views = "\n".join(
            f"name: {name}"
            for name in (
                "Stable Knowledge",
                "Evidence",
                "Comparisons",
                "Active Ideas",
                "Experiments",
                "Draft/Curator Review",
            )
        )
        (research / "research-library.base").write_text(views, encoding="utf-8")

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def write_note(
        self,
        folder: str = "concepts",
        note_type: str = "concept",
        topics: tuple[str, ...] = ("humanoid",),
        extra: str = "",
        body: str = "# Note\n",
    ) -> Path:
        topic_lines = "\n".join(f"  - {topic}" for topic in topics)
        text = (
            "---\n"
            f"type: {note_type}\n"
            "date: 2026-07-24\n"
            "status: active\n"
            f"topics:\n{topic_lines}\n"
            f"{extra}"
            "---\n\n"
            f"{body}"
        )
        path = self.root / f"AI-Sessions/wiki/research/{folder}/note.md"
        path.write_text(text, encoding="utf-8")
        return path

    def codes(self) -> set[str]:
        return {finding.code for finding in validate_research.validate_repository(self.root)}

    def test_canonical_topic_is_accepted(self) -> None:
        self.write_note()
        self.assertEqual(self.codes(), set())

    def test_alias_unknown_and_pending_topics_are_rejected(self) -> None:
        self.write_note(topics=("rl", "not-registered", "candidate-topic"))
        self.assertTrue({"topic-alias", "topic-unknown", "topic-pending"}.issubset(self.codes()))

    def test_folder_type_mismatch_is_rejected(self) -> None:
        self.write_note(note_type="paper")
        self.assertIn("folder-type", self.codes())

    def test_legacy_category_field_and_directory_are_rejected(self) -> None:
        self.write_note(extra="primary_category: old\n")
        (self.root / "AI-Sessions/wiki/research/categories").mkdir()
        self.assertIn("legacy-category", self.codes())

    def test_relation_requires_full_existing_path(self) -> None:
        self.write_note(body="# Note\n\n## Relations\n\n- [[missing]]\n")
        self.assertIn("relation-path", self.codes())

    def test_external_source_is_valid(self) -> None:
        self.write_note(
            folder="sources",
            note_type="source",
            extra="source: https://example.com/repo\n",
        )
        self.assertEqual(self.codes(), set())

    def test_missing_local_source_is_rejected(self) -> None:
        self.write_note(
            folder="sources",
            note_type="source",
            extra="source: AI-Sessions/raw/repos/missing.md\n",
        )
        self.assertIn("provenance", self.codes())


if __name__ == "__main__":
    unittest.main()
