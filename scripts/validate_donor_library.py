#!/usr/bin/env python3
"""Validate CppStudio donor-library references and discoverability."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
EXTERNAL_RE = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")
ALLOWED_TIERS = {"safe-donor", "dependency-candidate", "study-only"}


def markdown_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*.md") if ".git" not in path.parts)


def normalize_link_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        target = target[1 : target.index(">")]
    else:
        target = target.split()[0] if target.split() else ""
    return target.split("#", 1)[0]


def is_external_or_empty(target: str) -> bool:
    return not target or target.startswith("#") or EXTERNAL_RE.match(target) is not None


def collect_local_links(files: list[Path], root: Path) -> tuple[list[str], set[str]]:
    errors: list[str] = []
    resolved_targets: set[str] = set()
    root_resolved = root.resolve()

    for path in files:
        text = path.read_text(encoding="utf-8")
        for line_number, line in enumerate(text.splitlines(), 1):
            for match in LINK_RE.finditer(line):
                target = normalize_link_target(match.group(1))
                if is_external_or_empty(target) or target.startswith("/"):
                    continue

                resolved = (path.parent / target).resolve()
                if not resolved.exists():
                    rel_path = path.relative_to(root)
                    errors.append(f"{rel_path}:{line_number}: missing local link target {target!r}")
                    continue

                try:
                    resolved_targets.add(resolved.relative_to(root_resolved).as_posix())
                except ValueError:
                    # Local links may point outside the checked reference root. Existence is enough.
                    pass

    return errors, resolved_targets


def validate_donor_discoverability(donor_root: Path, linked_targets: set[str]) -> list[str]:
    errors: list[str] = []
    readme = donor_root / "README.md"
    selection_policy = donor_root / "selection-policy.md"
    profiles_dir = donor_root / "profiles"

    for required in (readme, selection_policy, profiles_dir):
        if not required.exists():
            errors.append(f"missing required donor-library path: {required}")

    if errors:
        return errors

    readme_text = readme.read_text(encoding="utf-8")
    category_files = sorted(
        path
        for path in donor_root.glob("*.md")
        if path.name not in {"README.md", "selection-policy.md"}
    )
    for category in category_files:
        rel = category.relative_to(donor_root).as_posix()
        if rel not in readme_text:
            errors.append(f"README.md does not link donor category {rel!r}")

    profile_files = sorted(profiles_dir.glob("*.md"))
    for profile in profile_files:
        rel = profile.relative_to(donor_root).as_posix()
        if rel not in linked_targets:
            errors.append(f"donor profile {rel!r} is not linked from donor-library markdown")

    if not profile_files:
        errors.append("donor-library profiles directory is empty")

    return errors


def field_value(text: str, field_name: str) -> str | None:
    prefix = f"{field_name}:"
    for line in text.splitlines():
        if line.startswith(prefix):
            return line[len(prefix) :].strip()
    return None


def normalize_tier(raw: str | None) -> str:
    return (raw or "").strip().strip("`")


def valid_tier_field(raw: str | None) -> bool:
    if not raw:
        return False
    quoted_tiers = re.findall(r"`([^`]+)`", raw)
    if quoted_tiers:
        return all(tier in ALLOWED_TIERS for tier in quoted_tiers)
    return normalize_tier(raw).split()[0] in ALLOWED_TIERS


def validate_profile_schema(donor_root: Path) -> list[str]:
    errors: list[str] = []
    profiles_dir = donor_root / "profiles"
    for profile in sorted(profiles_dir.glob("*.md")):
        rel = profile.relative_to(donor_root).as_posix()
        text = profile.read_text(encoding="utf-8")
        source = field_value(text, "Source") or field_value(text, "Sources")
        tier_raw = field_value(text, "Tier")
        license_signal = field_value(text, "License signal")
        if not source or EXTERNAL_RE.match(source) is None:
            errors.append(f"{rel}: missing or invalid Source URL")
        if not valid_tier_field(tier_raw):
            errors.append(f"{rel}: missing or invalid Tier {tier_raw!r}")
        if not license_signal:
            errors.append(f"{rel}: missing License signal")
    return errors


def validate_category_tiers(donor_root: Path) -> list[str]:
    errors: list[str] = []
    for category in sorted(donor_root.glob("*.md")):
        if category.name in {"README.md", "selection-policy.md"}:
            continue
        rel = category.relative_to(donor_root).as_posix()
        for line_number, line in enumerate(category.read_text(encoding="utf-8").splitlines(), 1):
            if not line.startswith("|"):
                continue
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if len(cells) < 4 or cells[0] in {"Donor", "---"} or set(cells[1]) <= {"-", ":"}:
                continue
            tier = normalize_tier(cells[1])
            if tier not in ALLOWED_TIERS:
                errors.append(f"{rel}:{line_number}: invalid donor tier {tier!r}")
    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("donor_root", type=Path, help="Path to references/donor-library")
    parser.add_argument(
        "--reference-root",
        type=Path,
        default=None,
        help="Markdown root to check for local links; defaults to donor_root parent.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    donor_root = args.donor_root.resolve()
    reference_root = (args.reference_root or donor_root.parent).resolve()

    if not donor_root.is_dir():
        print(f"Missing donor library directory: {donor_root}", file=sys.stderr)
        return 1
    if not reference_root.is_dir():
        print(f"Missing reference root directory: {reference_root}", file=sys.stderr)
        return 1
    if not donor_root.is_relative_to(reference_root):
        print(f"Donor root must live under reference root: {donor_root} not under {reference_root}", file=sys.stderr)
        return 1

    files = markdown_files(reference_root)
    link_errors, linked_targets = collect_local_links(files, reference_root)

    donor_relative_targets = {
        Path(target).relative_to(donor_root.relative_to(reference_root)).as_posix()
        for target in linked_targets
        if Path(target).is_relative_to(donor_root.relative_to(reference_root))
    }

    errors = (
        link_errors
        + validate_donor_discoverability(donor_root, donor_relative_targets)
        + validate_profile_schema(donor_root)
        + validate_category_tiers(donor_root)
    )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        print(f"Donor library validation failed: {len(errors)} error(s)", file=sys.stderr)
        return 1

    print("Donor library validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
