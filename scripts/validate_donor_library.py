#!/usr/bin/env python3
"""Validate CppStudio donor-library references and discoverability."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from urllib.parse import unquote


LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
EXTERNAL_RE = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")
URL_RE = re.compile(r"https?://[^\s,;)]+")
SOURCE_START_RE = re.compile(r"^Sources?:\s*(.*)$")
METADATA_START_RE = re.compile(r"^[A-Za-z][A-Za-z0-9 _/-]*:\s")
ALLOWED_TIERS = {"safe-donor", "dependency-candidate", "study-only"}
ALLOWED_BACKEND_SIGNALS = {
    "api-agnostic",
    "dcc-interchange",
    "mixed-backend",
    "native-cpu",
    "native-cuda",
    "native-directx",
    "native-metal",
    "native-opencl",
    "native-opengl",
    "native-vulkan",
    "native-webgpu",
}
SPECIAL_DONOR_FILES = {"README.md", "selection-policy.md", "agent-lookup.md"}
SPECIAL_PROFILE_FILES = {"README.md"}


def markdown_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*.md") if ".git" not in path.parts)


def donor_category_files(donor_root: Path) -> list[Path]:
    return sorted(path for path in donor_root.glob("*.md") if path.name not in SPECIAL_DONOR_FILES)


def donor_profile_files(donor_root: Path) -> list[Path]:
    return sorted(
        path
        for path in (donor_root / "profiles").glob("*.md")
        if path.name not in SPECIAL_PROFILE_FILES
    )


def normalize_link_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        target = target[1 : target.index(">")]
    else:
        target = target.split()[0] if target.split() else ""
    return unquote(target.split("#", 1)[0])


def is_external_or_empty(target: str) -> bool:
    return not target or target.startswith("#") or EXTERNAL_RE.match(target) is not None


def local_link_error(target: str) -> str | None:
    if not target or "\0" in target:
        return "link target is empty or contains a NUL byte"
    if target.startswith(("/", "~")) or Path(target).is_absolute():
        return "local link target must be relative"
    return None


def collect_local_links(files: list[Path], root: Path) -> tuple[list[str], set[str]]:
    errors: list[str] = []
    resolved_targets: set[str] = set()
    root_resolved = root.resolve()

    for path in files:
        text = path.read_text(encoding="utf-8")
        for line_number, line in enumerate(text.splitlines(), 1):
            for match in LINK_RE.finditer(line):
                target = normalize_link_target(match.group(1))
                if is_external_or_empty(target):
                    continue
                link_error = local_link_error(target)
                if link_error:
                    rel_path = path.relative_to(root)
                    errors.append(f"{rel_path}:{line_number}: invalid local link target {target!r}: {link_error}")
                    continue

                resolved = (path.parent / target).resolve()
                try:
                    resolved_rel = resolved.relative_to(root_resolved).as_posix()
                except ValueError:
                    rel_path = path.relative_to(root)
                    errors.append(f"{rel_path}:{line_number}: local link target escapes reference root {target!r}")
                    continue
                if not resolved.exists():
                    rel_path = path.relative_to(root)
                    errors.append(f"{rel_path}:{line_number}: missing local link target {target!r}")
                    continue

                resolved_targets.add(resolved_rel)

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
    for category in donor_category_files(donor_root):
        rel = category.relative_to(donor_root).as_posix()
        if rel not in readme_text:
            errors.append(f"README.md does not link donor category {rel!r}")

    profile_files = donor_profile_files(donor_root)
    for profile in profile_files:
        rel = profile.relative_to(donor_root).as_posix()
        if rel not in linked_targets:
            errors.append(f"donor profile {rel!r} is not linked from donor-library markdown")

    if not profile_files:
        errors.append("donor-library profiles directory is empty")

    return errors


def validate_agent_lookup(donor_root: Path) -> list[str]:
    errors: list[str] = []
    readme = donor_root / "README.md"
    lookup = donor_root / "agent-lookup.md"
    profiles_dir = donor_root / "profiles"

    if not lookup.is_file():
        return ["missing required donor-library path: agent-lookup.md"]

    readme_text = readme.read_text(encoding="utf-8") if readme.is_file() else ""
    lookup_text = lookup.read_text(encoding="utf-8")

    if "agent-lookup.md" not in readme_text:
        errors.append("README.md does not link donor lookup 'agent-lookup.md'")

    for category in donor_category_files(donor_root):
        rel = category.relative_to(donor_root).as_posix()
        if rel not in lookup_text:
            errors.append(f"agent-lookup.md does not link donor category {rel!r}")

    profile_files = {profile.relative_to(donor_root).as_posix() for profile in donor_profile_files(donor_root)}
    for profile_rel in sorted(linked_profile_paths(lookup_text)):
        if profile_rel not in profile_files:
            errors.append(f"agent-lookup.md links unknown donor profile {profile_rel!r}")

    return errors


def field_value(text: str, field_name: str) -> str | None:
    prefix = f"{field_name}:"
    for line in text.splitlines():
        if line.startswith(prefix):
            return line[len(prefix) :].strip()
    return None


def normalize_tier(raw: str | None) -> str:
    return (raw or "").strip().strip("`")


def tier_values(raw: str | None) -> set[str]:
    if not raw:
        return set()
    quoted_tiers = set(re.findall(r"`([^`]+)`", raw))
    if quoted_tiers:
        return quoted_tiers
    first = normalize_tier(raw).split()[0] if normalize_tier(raw).split() else ""
    return {first} if first else set()


def valid_tier_field(raw: str | None) -> bool:
    tiers = tier_values(raw)
    return bool(tiers) and all(tier in ALLOWED_TIERS for tier in tiers)


def normalize_backend_signals(raw: str | None) -> list[str]:
    if not raw:
        return []
    return [part.strip().strip("`") for part in raw.split(",") if part.strip()]


def valid_backend_signal_field(raw: str | None) -> bool:
    signals = normalize_backend_signals(raw)
    return bool(signals) and all(signal in ALLOWED_BACKEND_SIGNALS for signal in signals)


def normalize_url(raw: str) -> str:
    return raw.strip().rstrip(".").rstrip("/")


def source_urls(raw: str | None) -> set[str]:
    if not raw:
        return set()
    return {normalize_url(match.group(0)) for match in URL_RE.finditer(raw)}


def parse_source_urls(text: str) -> set[str]:
    lines = text.splitlines()
    source_blocks: list[str] = []
    index = 0
    while index < len(lines):
        match = SOURCE_START_RE.match(lines[index].strip())
        if match is None:
            index += 1
            continue

        block_parts = [match.group(1)]
        index += 1
        while index < len(lines):
            stripped = lines[index].strip()
            if not stripped or stripped.startswith("#") or SOURCE_START_RE.match(stripped):
                break
            if METADATA_START_RE.match(stripped):
                break
            block_parts.append(stripped)
            index += 1
        source_blocks.append(" ".join(part for part in block_parts if part))
        continue

    urls: set[str] = set()
    for source_block in source_blocks:
        urls.update(normalize_url(match.group(0).rstrip(".,;")) for match in URL_RE.finditer(source_block))
    return urls


def profile_metadata(donor_root: Path) -> dict[str, dict[str, object]]:
    profiles: dict[str, dict[str, object]] = {}
    for profile in donor_profile_files(donor_root):
        rel = profile.relative_to(donor_root).as_posix()
        text = profile.read_text(encoding="utf-8")
        profiles[rel] = {
            "sources": parse_source_urls(text),
            "tiers": tier_values(field_value(text, "Tier")),
            "backend_signals": set(normalize_backend_signals(field_value(text, "Backend signal"))),
        }
    return profiles


def validate_profile_schema(donor_root: Path) -> list[str]:
    errors: list[str] = []
    profiles_dir = donor_root / "profiles"
    for profile in donor_profile_files(donor_root):
        rel = profile.relative_to(donor_root).as_posix()
        text = profile.read_text(encoding="utf-8")
        sources = parse_source_urls(text)
        tier_raw = field_value(text, "Tier")
        backend_signal = field_value(text, "Backend signal")
        license_signal = field_value(text, "License signal")
        if not sources:
            errors.append(f"{rel}: missing or invalid Source URL")
        if not valid_tier_field(tier_raw):
            errors.append(f"{rel}: missing or invalid Tier {tier_raw!r}")
        if not valid_backend_signal_field(backend_signal):
            errors.append(f"{rel}: missing or invalid Backend signal {backend_signal!r}")
        if not license_signal:
            errors.append(f"{rel}: missing License signal")
    return errors


def linked_profile_paths(text: str) -> set[str]:
    profiles: set[str] = set()
    for match in LINK_RE.finditer(text):
        target = normalize_link_target(match.group(1))
        if target.startswith("profiles/"):
            profiles.add(target)
    return profiles


def backend_claims(text: str) -> set[str]:
    lowered = text.lower()
    claims: set[str] = set()
    checks = {
        "native-cuda": ("cuda",),
        "native-vulkan": ("vulkan",),
        "native-directx": ("directx", "dx11", "dx12", "d3d11", "d3d12"),
        "native-metal": ("metal",),
        "native-opencl": ("opencl",),
        "native-opengl": ("opengl",),
        "native-webgpu": ("webgpu",),
        "native-cpu": ("cpu",),
    }
    for signal, needles in checks.items():
        if any(needle in lowered for needle in needles):
            claims.add(signal)
    return claims


def backend_claim_supported(profile_signals: set[str], claim: str) -> bool:
    return claim in profile_signals or "mixed-backend" in profile_signals or "api-agnostic" in profile_signals


def validate_category_profile_routes(donor_root: Path) -> list[str]:
    errors: list[str] = []
    profiles = profile_metadata(donor_root)
    profiles_by_source: dict[str, list[str]] = {}
    for rel, metadata in profiles.items():
        for source in metadata["sources"]:
            profiles_by_source.setdefault(source, []).append(rel)

    for category in donor_category_files(donor_root):
        rel = category.relative_to(donor_root).as_posix()
        text = category.read_text(encoding="utf-8")
        category_profile_links = linked_profile_paths(text)
        for line_number, line in enumerate(text.splitlines(), 1):
            if not line.startswith("|"):
                continue
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if len(cells) < 4 or cells[0] in {"Donor", "---"} or set(cells[1]) <= {"-", ":"}:
                continue
            match = LINK_RE.search(cells[0])
            if not match:
                continue
            target = normalize_link_target(match.group(1))
            matched_profiles = [target] if target.startswith("profiles/") else profiles_by_source.get(normalize_url(target), [])
            for profile_rel in matched_profiles:
                if profile_rel not in profiles:
                    errors.append(f"{rel}:{line_number}: category row links unknown donor profile {profile_rel!r}")
                    continue
                metadata = profiles[profile_rel]
                if profile_rel not in category_profile_links:
                    errors.append(f"{rel}:{line_number}: category row matches {profile_rel!r} but does not link that profile")
                row_tier = normalize_tier(cells[1])
                if row_tier not in metadata["tiers"]:
                    errors.append(
                        f"{rel}:{line_number}: category tier {row_tier!r} conflicts with {profile_rel} "
                        f"tiers {sorted(metadata['tiers'])}"
                    )
                profile_signals = metadata["backend_signals"]
                unsupported = sorted(
                    claim for claim in backend_claims(cells[3]) if not backend_claim_supported(profile_signals, claim)
                )
                if unsupported:
                    errors.append(
                        f"{rel}:{line_number}: category backend claim(s) {unsupported} conflict with "
                        f"{profile_rel} signals {sorted(profile_signals)}"
                    )
    return errors


def validate_category_tiers(donor_root: Path) -> list[str]:
    errors: list[str] = []
    for category in donor_category_files(donor_root):
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
        + validate_agent_lookup(donor_root)
        + validate_profile_schema(donor_root)
        + validate_category_tiers(donor_root)
        + validate_category_profile_routes(donor_root)
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
