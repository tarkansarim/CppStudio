#!/usr/bin/env python3
"""Validate the packaged CppStudio skill file inventory.

The manifest is intentionally deterministic: it records every shipped skill file
except the manifest itself, including size, SHA-256, package role, and lazy-load
group. This gives sync/rollout scripts a cheap integrity check without needing a
remote registry.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path, PurePosixPath
from typing import Any


MANIFEST_NAME = "package-manifest.json"
SCHEMA_VERSION = 1
HASH_ALGORITHM = "sha256"
MANIFEST_KEYS = {"schema_version", "package", "hash_algorithm", "files"}
FILE_ENTRY_KEYS = {"path", "role", "disclosure_group", "size", "sha256"}
ALLOWED_TOP_LEVEL = {
    ".skill-source",
    "SKILL.md",
    "agents",
    "assets",
    "package-manifest.json",
    "references",
    "scripts",
}
FORBIDDEN_FILE_NAMES = {
    ".ds_store",
    ".env",
    ".envrc",
    "desktop.ini",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
    "id_rsa",
    "thumbs.db",
}
FORBIDDEN_DIR_NAMES = {
    ".cache",
    ".git",
    ".hg",
    ".idea",
    ".jj",
    ".mypy_cache",
    ".nox",
    ".pytest_cache",
    ".ruff_cache",
    ".svn",
    ".tox",
    ".venv",
    ".vscode",
    "__pycache__",
    "node_modules",
    "venv",
}
FORBIDDEN_SUFFIXES = (
    ".7z",
    ".bak",
    ".bz2",
    ".cer",
    ".crt",
    ".der",
    ".gz",
    ".key",
    ".log",
    ".orig",
    ".p12",
    ".pem",
    ".pfx",
    ".pyc",
    ".pyo",
    ".rar",
    ".rej",
    ".swo",
    ".swp",
    ".tar",
    ".tar.gz",
    ".temp",
    ".tgz",
    ".tmp",
    ".xz",
    ".zip",
    "~",
)


def normalize_relative_path(path: Path, root: Path) -> str:
    rel = path.relative_to(root).as_posix()
    validate_manifest_path(rel)
    return rel


def validate_manifest_path(path_text: str) -> None:
    if not path_text or "\0" in path_text:
        raise ValueError("manifest path is empty or contains a NUL byte")
    pure = PurePosixPath(path_text)
    if pure.is_absolute():
        raise ValueError(f"manifest path must be relative: {path_text}")
    if any(part in {"", ".", ".."} for part in pure.parts):
        raise ValueError(f"manifest path must not contain empty, '.', or '..' segments: {path_text}")
    if "\\" in path_text:
        raise ValueError(f"manifest path must use POSIX separators: {path_text}")


def is_forbidden_package_path(rel_path: str) -> str | None:
    pure = PurePosixPath(rel_path)
    if pure.parts and pure.parts[0] not in ALLOWED_TOP_LEVEL:
        return f"unsupported top-level package entry: {rel_path}"
    lowered_parts = [part.lower() for part in pure.parts]
    if any(part in FORBIDDEN_DIR_NAMES for part in lowered_parts):
        return f"forbidden package directory in path: {rel_path}"
    name = pure.name.lower()
    if name in FORBIDDEN_FILE_NAMES or name.startswith(".env.") or name.startswith(".env-"):
        return f"forbidden package file: {rel_path}"
    rel_lower = rel_path.lower()
    if any(rel_lower.endswith(suffix) for suffix in FORBIDDEN_SUFFIXES):
        return f"forbidden package artifact file: {rel_path}"
    return None


def classify_file(rel_path: str) -> tuple[str, str]:
    if rel_path == ".skill-source":
        return "metadata", "source"
    if rel_path == "SKILL.md":
        return "main", "entrypoint"
    if rel_path == "agents/openai.yaml":
        return "metadata", "entrypoint"
    if rel_path.startswith("scripts/"):
        return "script", "script"
    if rel_path.startswith("assets/app-library-template/"):
        return "asset", "generated-project-template"
    if rel_path.startswith("assets/"):
        return "asset", "asset"
    if rel_path == "references/project-archetypes.md":
        return "reference", "entrypoint"
    if rel_path.startswith("references/donor-library/profiles/"):
        return "reference", "donor-profile"
    if rel_path.startswith("references/donor-library/production/"):
        return "reference", "production-overlay"
    if rel_path.startswith("references/donor-library/"):
        name = PurePosixPath(rel_path).name
        if name in {"README.md", "selection-policy.md", "agent-lookup.md"}:
            return "reference", "donor-router"
        return "reference", "donor-category"
    if rel_path.startswith("references/"):
        return "reference", "reference"
    return "metadata", "package"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def iter_package_files(skill_dir: Path, manifest_path: Path) -> list[Path]:
    if not skill_dir.is_dir():
        raise ValueError(f"skill directory does not exist: {skill_dir}")
    files: list[Path] = []
    manifest_resolved = manifest_path.resolve()
    for path in sorted(skill_dir.rglob("*")):
        rel_path = normalize_relative_path(path, skill_dir)
        forbidden = is_forbidden_package_path(rel_path)
        if forbidden:
            raise ValueError(forbidden)
        if path.is_symlink():
            raise ValueError(f"symlink inside skill package is not allowed: {rel_path}")
        if path.is_dir():
            continue
        if not path.is_file():
            raise ValueError(f"unsupported package entry type: {rel_path}")
        if rel_path == MANIFEST_NAME or path.resolve() == manifest_resolved:
            continue
        files.append(path)
    return files


def build_manifest(skill_dir: Path, manifest_path: Path) -> dict[str, Any]:
    files = []
    for file_path in iter_package_files(skill_dir, manifest_path):
        rel_path = normalize_relative_path(file_path, skill_dir)
        role, disclosure_group = classify_file(rel_path)
        stat = file_path.stat()
        files.append(
            {
                "path": rel_path,
                "role": role,
                "disclosure_group": disclosure_group,
                "size": stat.st_size,
                "sha256": sha256_file(file_path),
            }
        )
    files.sort(key=lambda item: item["path"])
    return {
        "schema_version": SCHEMA_VERSION,
        "package": skill_dir.name,
        "hash_algorithm": HASH_ALGORITHM,
        "files": files,
    }


def load_manifest(manifest_path: Path) -> dict[str, Any]:
    if not manifest_path.is_file():
        raise ValueError(f"missing package manifest: {manifest_path}")
    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ValueError(f"invalid package manifest JSON: {exc}") from exc
    if not isinstance(data, dict):
        raise ValueError("package manifest must be a JSON object")
    return data


def validate_manifest_shape(data: dict[str, Any], skill_dir: Path) -> list[dict[str, Any]]:
    missing = sorted(MANIFEST_KEYS - set(data))
    if missing:
        raise ValueError(f"package manifest missing fields: {', '.join(missing)}")
    unexpected = sorted(set(data) - MANIFEST_KEYS)
    if unexpected:
        raise ValueError(f"package manifest has unexpected fields: {', '.join(unexpected)}")
    if data["schema_version"] != SCHEMA_VERSION:
        raise ValueError(f"unsupported package manifest schema_version: {data['schema_version']!r}")
    if data["package"] != skill_dir.name:
        raise ValueError(f"package manifest package mismatch: {data['package']!r} != {skill_dir.name!r}")
    if data["hash_algorithm"] != HASH_ALGORITHM:
        raise ValueError(f"unsupported package hash_algorithm: {data['hash_algorithm']!r}")
    files = data["files"]
    if not isinstance(files, list):
        raise ValueError("package manifest files must be a list")
    seen: set[str] = set()
    normalized: list[dict[str, Any]] = []
    for index, entry in enumerate(files):
        if not isinstance(entry, dict):
            raise ValueError(f"package manifest files[{index}] must be an object")
        entry_missing = sorted(FILE_ENTRY_KEYS - set(entry))
        if entry_missing:
            raise ValueError(
                f"package manifest files[{index}] missing fields: {', '.join(entry_missing)}"
            )
        entry_unexpected = sorted(set(entry) - FILE_ENTRY_KEYS)
        if entry_unexpected:
            raise ValueError(
                f"package manifest files[{index}] has unexpected fields: {', '.join(entry_unexpected)}"
            )
        path_text = entry["path"]
        if not isinstance(path_text, str):
            raise ValueError(f"package manifest files[{index}].path must be a string")
        validate_manifest_path(path_text)
        if path_text == MANIFEST_NAME:
            raise ValueError("package manifest must not list itself")
        forbidden = is_forbidden_package_path(path_text)
        if forbidden:
            raise ValueError(forbidden)
        if path_text in seen:
            raise ValueError(f"duplicate package manifest path: {path_text}")
        seen.add(path_text)
        role, disclosure_group = classify_file(path_text)
        if entry["role"] != role:
            raise ValueError(f"manifest role mismatch for {path_text}: {entry['role']!r} != {role!r}")
        if entry["disclosure_group"] != disclosure_group:
            raise ValueError(
                f"manifest disclosure group mismatch for {path_text}: "
                f"{entry['disclosure_group']!r} != {disclosure_group!r}"
            )
        if not isinstance(entry["size"], int) or entry["size"] < 0:
            raise ValueError(f"manifest size must be a non-negative integer for {path_text}")
        if not isinstance(entry["sha256"], str) or len(entry["sha256"]) != 64:
            raise ValueError(f"manifest sha256 must be a 64-character hex string for {path_text}")
        try:
            int(entry["sha256"], 16)
        except ValueError as exc:
            raise ValueError(f"manifest sha256 is not hex for {path_text}") from exc
        normalized.append(entry)
    if [entry["path"] for entry in normalized] != sorted(entry["path"] for entry in normalized):
        raise ValueError("package manifest file entries must be sorted by path")
    return normalized


def validate_manifest(skill_dir: Path, manifest_path: Path) -> None:
    data = load_manifest(manifest_path)
    manifest_entries = validate_manifest_shape(data, skill_dir)
    actual_manifest = build_manifest(skill_dir, manifest_path)
    actual_by_path = {entry["path"]: entry for entry in actual_manifest["files"]}
    manifest_by_path = {entry["path"]: entry for entry in manifest_entries}

    missing = sorted(set(manifest_by_path) - set(actual_by_path))
    if missing:
        raise ValueError(f"missing manifested file: {missing[0]}")
    extra = sorted(set(actual_by_path) - set(manifest_by_path))
    if extra:
        raise ValueError(f"unmanifested package file: {extra[0]}")

    for path_text in sorted(manifest_by_path):
        expected = manifest_by_path[path_text]
        actual = actual_by_path[path_text]
        if expected["size"] != actual["size"]:
            raise ValueError(
                f"size mismatch for {path_text}: manifest {expected['size']} != actual {actual['size']}"
            )
        if expected["sha256"] != actual["sha256"]:
            raise ValueError(f"hash mismatch for {path_text}")


def write_manifest(skill_dir: Path, manifest_path: Path) -> None:
    manifest = build_manifest(skill_dir, manifest_path)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=False) + "\n", encoding="utf-8")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_dir", type=Path)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=None,
        help="Manifest path. Defaults to <skill_dir>/package-manifest.json.",
    )
    parser.add_argument(
        "--write-manifest",
        action="store_true",
        help="Rewrite the deterministic manifest instead of validating the existing one.",
    )
    args = parser.parse_args(argv)

    skill_dir = args.skill_dir.resolve()
    manifest_path = (args.manifest or (skill_dir / MANIFEST_NAME)).resolve()
    try:
        if args.write_manifest:
            write_manifest(skill_dir, manifest_path)
            print(f"Wrote package manifest: {manifest_path}")
        else:
            validate_manifest(skill_dir, manifest_path)
            print(f"Skill package manifest is valid: {skill_dir}")
    except (OSError, ValueError) as exc:
        print(f"{skill_dir}: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
