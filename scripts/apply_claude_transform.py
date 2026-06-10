#!/usr/bin/env python3
"""Apply the CppStudio Claude-lane install transform to a staged skill copy.

The CppStudio skill sources under ``skills/`` are Codex-flavored (the Codex lane installs
them verbatim). The Claude lane installs ``source -> transform`` so that the copy under
``~/.claude/skills`` is Claude-provider-specific: host-provider skill-home self-references
(``${CODEX_HOME:-$HOME/.codex}/skills/...``, ``~/.codex/skills``, bare ``.codex/skills/``)
are flipped to their ``~/.claude`` equivalents, while supervised-worker lore and Codex-based
external tools (``codex-code-map-sidecar``, ``Codex worker``, ``codex exec``,
``codex -m gpt-5.5``) are intentionally KEPT -- a Claude host legitimately drives those.

Rules live in ``claude_install_transform.json`` (auditable rewrite table) next to this script.

Modes:
  apply (default):  rewrite files in place under <skill-dir>.
  --check:          verify a copy is fully transformed -- no host-provider Codex paths
                    survive AND the transform is idempotent (re-applying changes nothing).
                    Exit non-zero on violation. Used as the Claude-lane install guard.

The package manifest (``package-manifest.json``) is never transformed; regenerate it with
``validate_skill_package.py --write-manifest`` after an apply (file SHAs change).
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

RULES_PATH = Path(__file__).resolve().parent / "claude_install_transform.json"

SKIP_FILE_NAMES = {"package-manifest.json", ".DS_Store"}
SKIP_DIR_NAMES = {"__pycache__", ".git"}
BINARY_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".pdf", ".zip", ".gz",
    ".tar", ".so", ".o", ".a", ".bin", ".spv", ".pyc", ".woff", ".woff2", ".ttf",
}


def load_rules(rules_path: Path = RULES_PATH) -> dict:
    try:
        rules = json.loads(rules_path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise SystemExit(f"Cannot read transform rules: {rules_path}: {exc}")
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Malformed transform rules: {rules_path}: {exc}")
    if not rules.get("ordered_replacements"):
        raise SystemExit(f"Transform rules have no ordered_replacements: {rules_path}")
    return rules


def iter_text_files(skill_dir: Path):
    for path in sorted(skill_dir.rglob("*")):
        if not path.is_file() or path.is_symlink():
            continue
        if any(part in SKIP_DIR_NAMES for part in path.relative_to(skill_dir).parts):
            continue
        if path.name in SKIP_FILE_NAMES:
            continue
        if path.suffix.lower() in BINARY_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue  # binary or unreadable -> not a transform target
        yield path, text


def apply_replacements(text: str, replacements: list[dict]) -> tuple[str, int]:
    total = 0
    for rule in replacements:
        find = rule["find"]
        if find in text:
            total += text.count(find)
            text = text.replace(find, rule["replace"])
    return text, total


def find_survivors(text: str, patterns: list[str]) -> list[str]:
    return [p for p in patterns if p in text]


def cmd_apply(skill_dir: Path, rules: dict) -> int:
    replacements = rules["ordered_replacements"]
    must_not_survive = rules.get("must_not_survive", [])
    changed_files = 0
    total_subs = 0
    survivors: list[str] = []
    for path, text in iter_text_files(skill_dir):
        new_text, subs = apply_replacements(text, replacements)
        if subs:
            path.write_text(new_text, encoding="utf-8")
            changed_files += 1
            total_subs += subs
        leftover = find_survivors(new_text, must_not_survive)
        if leftover:
            rel = path.relative_to(skill_dir)
            survivors.append(f"{rel}: {sorted(set(leftover))}")
    rel_root = skill_dir.name
    print(f"[claude-transform] {rel_root}: rewrote {total_subs} occurrence(s) "
          f"across {changed_files} file(s)")
    if survivors:
        print(f"[claude-transform] FAIL: host-provider Codex paths survived in {rel_root}:",
              file=sys.stderr)
        for line in survivors:
            print(f"  {line}", file=sys.stderr)
        return 1
    return 0


def cmd_check(skill_dir: Path, rules: dict) -> int:
    replacements = rules["ordered_replacements"]
    must_not_survive = rules.get("must_not_survive", [])
    survivors: list[str] = []
    not_idempotent: list[str] = []
    for path, text in iter_text_files(skill_dir):
        rel = path.relative_to(skill_dir)
        leftover = find_survivors(text, must_not_survive)
        if leftover:
            survivors.append(f"{rel}: {sorted(set(leftover))}")
        _, subs = apply_replacements(text, replacements)
        if subs:
            not_idempotent.append(f"{rel}: {subs} un-applied replacement(s)")
    ok = True
    if survivors:
        ok = False
        print(f"[claude-transform --check] FAIL: host-provider Codex paths present "
              f"in {skill_dir.name}:", file=sys.stderr)
        for line in survivors:
            print(f"  {line}", file=sys.stderr)
    if not_idempotent:
        ok = False
        print(f"[claude-transform --check] FAIL: transform not fully applied "
              f"in {skill_dir.name}:", file=sys.stderr)
        for line in not_idempotent:
            print(f"  {line}", file=sys.stderr)
    if ok:
        print(f"[claude-transform --check] OK: {skill_dir.name} is Claude-provider-specific "
              f"(no Codex host-paths, transform idempotent)")
        return 0
    return 1


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("skill_dir", type=Path, help="Staged or installed skill directory")
    parser.add_argument("--check", action="store_true",
                        help="Verify-only: fail if Codex host-paths survive or transform is "
                             "not idempotent. Does not modify files.")
    parser.add_argument("--rules", type=Path, default=RULES_PATH,
                        help=f"Transform rules JSON (default: {RULES_PATH})")
    args = parser.parse_args(argv)

    skill_dir = args.skill_dir.expanduser().resolve()
    if not skill_dir.is_dir():
        print(f"Not a directory: {skill_dir}", file=sys.stderr)
        return 2

    rules = load_rules(args.rules)
    if args.check:
        return cmd_check(skill_dir, rules)
    return cmd_apply(skill_dir, rules)


if __name__ == "__main__":
    raise SystemExit(main())
