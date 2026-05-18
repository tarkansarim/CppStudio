#!/usr/bin/env python3
"""Validate Codex skill load-path hygiene.

This checks the skill roots that Codex may scan at startup, not an individual
skill package. It catches backup artifacts that accidentally remain loadable and
guards the description budget that feeds startup skill discovery.
"""

from __future__ import annotations

import argparse
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


DEFAULT_MAX_DESCRIPTION_CHARS = 320
DEFAULT_MAX_TOTAL_DESCRIPTION_CHARS = 14000


@dataclass(frozen=True)
class SkillMetadata:
    path: Path
    name: str
    description: str


def parse_scalar(value: str) -> str:
    value = value.strip()
    if not value:
        return ""
    if value[0] in {'"', "'"}:
        quote = value[0]
        end = len(value) - 1
        while end > 0:
            if value[end] == quote and (end == 0 or value[end - 1] != "\\"):
                return value[1:end]
            end -= 1
        return value[1:]
    comment_at = value.find(" #")
    if comment_at != -1:
        value = value[:comment_at]
    return value.strip()


def parse_frontmatter(skill_file: Path) -> dict[str, str]:
    lines = skill_file.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("missing opening frontmatter marker")
    fields: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fields
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        key, separator, value = line.partition(":")
        if not separator:
            continue
        key = key.strip()
        if key in fields:
            raise ValueError(f"duplicate frontmatter field: {key}")
        fields[key] = parse_scalar(value)
    raise ValueError("missing closing frontmatter marker")


def is_backup_part(part: str) -> bool:
    lowered = part.lower()
    return (
        lowered in {".backups", "backups"}
        or lowered.startswith(".backup")
        or lowered.startswith("backup-")
        or ".bak" in lowered
        or lowered.endswith("~")
    )


def find_backup_artifacts(root: Path) -> list[Path]:
    artifacts: list[Path] = []
    for path in root.rglob("*"):
        try:
            rel_parts = path.relative_to(root).parts
        except ValueError:
            continue
        if any(is_backup_part(part) for part in rel_parts):
            artifacts.append(path)
    return sorted(artifacts)


def iter_loadable_skill_files(root: Path) -> Iterable[Path]:
    for child in sorted(root.iterdir()):
        if not child.is_dir():
            continue
        direct_skill = child / "SKILL.md"
        if direct_skill.is_file():
            yield direct_skill
            continue
        if child.name.startswith("."):
            for nested in sorted(child.iterdir()):
                if nested.is_dir() and (nested / "SKILL.md").is_file():
                    yield nested / "SKILL.md"


def load_skill_metadata(root: Path) -> tuple[list[SkillMetadata], list[str]]:
    entries: list[SkillMetadata] = []
    errors: list[str] = []
    for skill_file in iter_loadable_skill_files(root):
        try:
            fields = parse_frontmatter(skill_file)
        except ValueError as exc:
            errors.append(f"{skill_file}: {exc}")
            continue
        name = fields.get("name", "").strip()
        description = fields.get("description", "").strip()
        if not name:
            errors.append(f"{skill_file}: missing name field")
        if not description:
            errors.append(f"{skill_file}: missing description field")
        entries.append(SkillMetadata(path=skill_file, name=name, description=description))
    return entries, errors


def validate_root(
    root: Path,
    *,
    max_description_chars: int,
    max_total_description_chars: int,
) -> list[str]:
    errors: list[str] = []
    entries, metadata_errors = load_skill_metadata(root)
    errors.extend(metadata_errors)

    backup_artifacts = find_backup_artifacts(root)
    if backup_artifacts:
        errors.append(
            "backup artifacts under skill load root: "
            + ", ".join(str(path.relative_to(root)) for path in backup_artifacts[:20])
            + (" ..." if len(backup_artifacts) > 20 else "")
        )

    seen_names: dict[str, Path] = {}
    for entry in entries:
        if entry.name in seen_names:
            errors.append(
                "duplicate loaded skill name "
                f"{entry.name!r}: {seen_names[entry.name]} and {entry.path}"
            )
        elif entry.name:
            seen_names[entry.name] = entry.path
        if len(entry.description) > max_description_chars:
            errors.append(
                f"{entry.path}: description has {len(entry.description)} chars; "
                f"limit is {max_description_chars}"
            )

    total_description_chars = sum(len(entry.description) for entry in entries)
    if total_description_chars > max_total_description_chars:
        errors.append(
            f"{root}: loaded descriptions total {total_description_chars} chars; "
            f"limit is {max_total_description_chars}"
        )

    longest = max((len(entry.description) for entry in entries), default=0)
    print(
        "skill load hygiene: "
        f"root={root} skills={len(entries)} "
        f"description_chars={total_description_chars} longest={longest}"
    )
    return errors


def write_skill(path: Path, name: str, description: str) -> None:
    path.mkdir(parents=True, exist_ok=True)
    (path / "SKILL.md").write_text(
        f"---\nname: {name}\ndescription: {description}\n---\n# {name}\n",
        encoding="utf-8",
    )


def run_self_test() -> None:
    with tempfile.TemporaryDirectory(prefix="cppstudio_skill_load_hygiene.") as tmp:
        root = Path(tmp)
        good = root / "good"
        write_skill(good, "good", "A compact skill.")
        write_skill(root / ".system" / "system-skill", "system-skill", "A system skill.")
        errors = validate_root(
            root,
            max_description_chars=100,
            max_total_description_chars=1000,
        )
        if errors:
            raise SystemExit(f"self-test good root failed: {errors}")

        write_skill(root / ".backups" / "good.20260516", "good", "Backup copy.")
        errors = validate_root(
            root,
            max_description_chars=100,
            max_total_description_chars=1000,
        )
        if not any("backup artifacts" in error for error in errors):
            raise SystemExit("self-test did not detect backup artifacts")
        for backup_path in reversed(sorted((root / ".backups").rglob("*"))):
            if backup_path.is_file():
                backup_path.unlink()
            elif backup_path.is_dir():
                backup_path.rmdir()
        (root / ".backups").rmdir()

        write_skill(root / "duplicate", "good", "Duplicate name.")
        errors = validate_root(
            root,
            max_description_chars=100,
            max_total_description_chars=1000,
        )
        if not any("duplicate loaded skill name" in error for error in errors):
            raise SystemExit("self-test did not detect duplicate skill names")
        for path in (root / "duplicate").iterdir():
            path.unlink()
        (root / "duplicate").rmdir()

        write_skill(root / "too-long", "too-long", "x" * 101)
        errors = validate_root(
            root,
            max_description_chars=100,
            max_total_description_chars=1000,
        )
        if not any("description has 101 chars" in error for error in errors):
            raise SystemExit("self-test did not detect a too-long description")
    print("skill load hygiene self-test passed")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skills-root",
        action="append",
        default=[],
        help="Required Codex skills root to validate.",
    )
    parser.add_argument(
        "--optional-skills-root",
        action="append",
        default=[],
        help="Optional Codex skills root; skipped if missing.",
    )
    parser.add_argument(
        "--max-description-chars",
        type=int,
        default=DEFAULT_MAX_DESCRIPTION_CHARS,
    )
    parser.add_argument(
        "--max-total-description-chars",
        type=int,
        default=DEFAULT_MAX_TOTAL_DESCRIPTION_CHARS,
    )
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        run_self_test()
        if not args.skills_root and not args.optional_skills_root:
            return 0

    roots: list[Path] = []
    for root_arg in args.skills_root:
        root = Path(root_arg).expanduser().resolve()
        if not root.is_dir():
            print(f"missing required skills root: {root}")
            return 1
        roots.append(root)
    for root_arg in args.optional_skills_root:
        root = Path(root_arg).expanduser().resolve()
        if root.is_dir():
            roots.append(root)
        else:
            print(f"skill load hygiene skipped missing optional root: {root}")

    if not roots:
        print("no skill roots supplied")
        return 2

    all_errors: list[str] = []
    for root in roots:
        all_errors.extend(
            validate_root(
                root,
                max_description_chars=args.max_description_chars,
                max_total_description_chars=args.max_total_description_chars,
            )
        )
    if all_errors:
        for error in all_errors:
            print(f"ERROR: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
