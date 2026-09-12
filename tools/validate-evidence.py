#!/usr/bin/env python3
"""Validate deterministic zOS evidence fixtures using only the Python standard library."""
from __future__ import annotations

import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

JSONL_FILES = {
    "analyzer": ROOT / "evidence/corpus/analyzer/golden.jsonl",
    "rag": ROOT / "evidence/corpus/rag/ranking.jsonl",
    "pr_salvage": ROOT / "evidence/corpus/pr-salvage/cases.jsonl",
    "discussions": ROOT / "evidence/corpus/discussions/triage.jsonl",
    "ci": ROOT / "evidence/ci/failure-modes.jsonl",
}


def load_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    for line_no, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw.strip():
            continue
        try:
            row = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise AssertionError(f"{path}:{line_no}: invalid JSON: {exc}") from exc
        if not isinstance(row, dict):
            raise AssertionError(f"{path}:{line_no}: row must be an object")
        rows.append(row)
    if not rows:
        raise AssertionError(f"{path}: corpus is empty")
    ids = [row.get("id") for row in rows]
    if any(not value for value in ids):
        raise AssertionError(f"{path}: every row needs a non-empty id")
    if len(ids) != len(set(ids)):
        raise AssertionError(f"{path}: duplicate ids found")
    return rows


def validate_analyzer(rows: list[dict]) -> None:
    for row in rows:
        expected = row.get("expected", {})
        if expected.get("severity") not in {"low", "medium", "high", "critical"}:
            raise AssertionError(f"{row['id']}: invalid analyzer severity")
        if not expected.get("codes"):
            raise AssertionError(f"{row['id']}: analyzer codes required")


def validate_rag(rows: list[dict]) -> None:
    for row in rows:
        candidates = row.get("candidates", [])
        expected = row.get("expected", {})
        top1 = expected.get("top1")
        if top1 not in candidates:
            raise AssertionError(f"{row['id']}: expected top1 must be a candidate")
        prefix = expected.get("ordered_prefix", [])
        if any(item not in candidates for item in prefix):
            raise AssertionError(f"{row['id']}: ordered_prefix contains unknown candidate")
        if prefix and prefix[0] != top1:
            raise AssertionError(f"{row['id']}: ordered_prefix must start with top1")


def validate_actions(rows: list[dict], allowed: set[str]) -> None:
    for row in rows:
        action = row.get("expected", {}).get("action")
        if action not in allowed:
            raise AssertionError(f"{row['id']}: unsupported expected action {action!r}")


def validate_harness() -> None:
    path = ROOT / "evidence/harness/compatibility.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("canonical_contract") != "AGENTS.md":
        raise AssertionError("harness canonical contract must be AGENTS.md")
    surfaces = data.get("surfaces", [])
    expected_names = {"Claude", "Codex", "Gemini", "OpenCode", "Zed", "dmux"}
    names = {item.get("name") for item in surfaces}
    if names != expected_names:
        raise AssertionError(f"harness surfaces mismatch: {names} != {expected_names}")
    for item in surfaces:
        contract = item.get("contract")
        if not contract or not (ROOT / contract).is_file():
            raise AssertionError(f"missing harness contract: {contract}")
        must_reference = item.get("must_reference")
        if must_reference:
            text = (ROOT / contract).read_text(encoding="utf-8")
            if must_reference not in text:
                raise AssertionError(f"{contract} must reference {must_reference!r}")


def main() -> int:
    corpora = {name: load_jsonl(path) for name, path in JSONL_FILES.items()}
    validate_analyzer(corpora["analyzer"])
    validate_rag(corpora["rag"])
    validate_actions(
        corpora["pr_salvage"],
        {"close_duplicate", "resolve_outdated_then_recheck", "reopen_for_review", "salvage_safe_commits"},
    )
    validate_actions(
        corpora["discussions"],
        {"answer_or_link_docs", "no_followup_required", "queue_for_maintainer_reply", "convert_to_issue_or_fix"},
    )
    for row in corpora["ci"]:
        if not row.get("signature") or not row.get("expected", {}).get("diagnosis"):
            raise AssertionError(f"{row['id']}: CI signature and diagnosis required")
    validate_harness()
    total = sum(len(rows) for rows in corpora.values())
    print(f"Evidence validation PASS: {total} corpus rows + harness matrix")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"Evidence validation FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
