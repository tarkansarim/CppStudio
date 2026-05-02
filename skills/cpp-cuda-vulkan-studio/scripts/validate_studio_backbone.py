#!/usr/bin/env python3
"""Validate that a repository has the reusable C++/CUDA/Vulkan studio backbone."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


REQUIRED_FILES = [
    "CMakeLists.txt",
    "CMakePresets.json",
    "cmake/ProjectOptions.cmake",
    "cmake/Warnings.cmake",
    "cmake/Sanitizers.cmake",
    "cmake/CudaArchitectures.cmake",
    "cmake/ProjectVulkan.cmake",
    "cmake/Testing.cmake",
    ".clang-format",
    ".clang-tidy",
    ".gitignore",
    ".github/workflows/gpu-cpp.yml",
    "docs/DEVELOPMENT_ENVIRONMENT.md",
    "docs/VALIDATION_PIPELINE.md",
    "docs/BENCHMARKS.md",
    "docs/GPU_RUNNER_CI.md",
    "scripts/check_dev_tools.sh",
    "scripts/select_idle_gpu.sh",
    "scripts/run_compute_sanitizer.sh",
    "scripts/run_vulkan_validation.sh",
    "scripts/dump_vulkan_capabilities.sh",
    "scripts/run_nsys_smoke.sh",
    "scripts/format_check.sh",
    "scripts/tidy_check.sh",
    "shaders/compute.comp",
    "shaders/offscreen_triangle.vert",
    "shaders/offscreen_triangle.frag",
]
REQUIRED_CONFIGURE_PRESETS = {
    "dev",
    "release",
    "profile",
    "asan-ubsan",
    "cuda-debug",
    "cuda-vulkan-combined",
    "vulkan-debug",
    "vulkan-portability",
    "vulkan-validation",
    "benchmark",
    "ci-gpu",
}
REQUIRED_BUILD_PRESETS = REQUIRED_CONFIGURE_PRESETS
REQUIRED_TEST_PRESETS = {
    "quick",
    "gpu",
    "cuda",
    "vulkan-shader",
    "vulkan",
    "vulkan-compute",
    "vulkan-render",
    "vulkan-validation",
    "asan-ubsan-quick",
    "benchmark",
}


def named_presets(presets: object, key: str) -> tuple[set[str], list[str]]:
    errors: list[str] = []
    names: set[str] = set()

    if not isinstance(presets, dict):
        return names, ["CMakePresets.json root must be an object"]

    entries = presets.get(key, [])
    if not isinstance(entries, list):
        return names, [f"CMakePresets.json {key} must be a list"]

    for index, entry in enumerate(entries, 1):
        if not isinstance(entry, dict):
            errors.append(f"CMakePresets.json {key}[{index}] must be an object")
            continue
        name = entry.get("name")
        if not isinstance(name, str) or not name.strip():
            errors.append(f"CMakePresets.json {key}[{index}] must have a non-empty string name")
            continue
        names.add(name)
    return names, errors


def labels_for_test(test: dict[str, object]) -> set[str]:
    labels: set[str] = set()
    properties = test.get("properties", [])
    if not isinstance(properties, list):
        return labels
    for property_item in properties:
        if not isinstance(property_item, dict):
            continue
        if property_item.get("name") != "LABELS":
            continue
        value = property_item.get("value")
        if isinstance(value, list):
            labels.update(str(item) for item in value if str(item))
        elif isinstance(value, str):
            labels.update(item for item in value.split(";") if item)
    return labels


def validate_ctest_json(output: str, required_labels: set[str]) -> list[str]:
    failures: list[str] = []
    try:
        report = json.loads(output)
    except json.JSONDecodeError as error:
        return [f"ctest --show-only=json-v1 did not emit valid JSON: {error}"]

    tests = report.get("tests")
    if not isinstance(tests, list) or not tests:
        return ["ctest --show-only=json-v1 registered no tests"]

    label_to_tests: dict[str, list[str]] = {label: [] for label in required_labels}
    for test in tests:
        if not isinstance(test, dict):
            continue
        name = str(test.get("name", "<unnamed>"))
        labels = labels_for_test(test)
        for label in required_labels & labels:
            label_to_tests[label].append(name)

    for label, names in sorted(label_to_tests.items()):
        if not names:
            failures.append(f"no registered CTest test has required label {label!r}")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", help="Repository root to validate")
    parser.add_argument("--strict-source-layout", action="store_true")
    parser.add_argument("--code-map", action="store_true", help="Also require and validate an enabled CppStudio code map")
    parser.add_argument("--integration", action="store_true", help="Also configure, build, and inspect CTest registration")
    parser.add_argument("--integration-configure-preset", default="dev", help="CMake configure preset used by --integration")
    parser.add_argument("--integration-build-preset", help="CMake build preset used by --integration; defaults to configure preset")
    parser.add_argument("--integration-test-preset", default="quick", help="CTest preset inspected by --integration")
    parser.add_argument(
        "--integration-required-label",
        action="append",
        default=["quick"],
        help="CTest label that must appear in --integration show-only JSON. Repeat for multiple labels.",
    )
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    failures: list[str] = []

    for relative in REQUIRED_FILES:
        if not (repo / relative).exists():
            failures.append(f"missing {relative}")

    presets_path = repo / "CMakePresets.json"
    if presets_path.exists():
        try:
            presets = json.loads(presets_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as error:
            failures.append(f"CMakePresets.json is invalid JSON: {error}")
        else:
            configure, configure_errors = named_presets(presets, "configurePresets")
            builds, build_errors = named_presets(presets, "buildPresets")
            tests, test_errors = named_presets(presets, "testPresets")
            failures.extend(configure_errors)
            failures.extend(build_errors)
            failures.extend(test_errors)
            missing_configure = REQUIRED_CONFIGURE_PRESETS - configure
            missing_builds = REQUIRED_BUILD_PRESETS - builds
            missing_tests = REQUIRED_TEST_PRESETS - tests
            if missing_configure:
                failures.append("missing configure presets: " + ", ".join(sorted(missing_configure)))
            if missing_builds:
                failures.append("missing build presets: " + ", ".join(sorted(missing_builds)))
            if missing_tests:
                failures.append("missing test presets: " + ", ".join(sorted(missing_tests)))

    if args.strict_source_layout:
        for relative in [
            "include",
            "src/core",
            "src/app",
            "src/cuda",
            "src/render",
            "tests/unit",
            "benchmarks",
            "shaders",
        ]:
            if not (repo / relative).is_dir():
                failures.append(f"missing directory {relative}")

    for relative in [
        "scripts/check_dev_tools.sh",
        "scripts/select_idle_gpu.sh",
        "scripts/run_compute_sanitizer.sh",
        "scripts/run_vulkan_validation.sh",
        "scripts/dump_vulkan_capabilities.sh",
        "scripts/run_nsys_smoke.sh",
        "scripts/format_check.sh",
        "scripts/tidy_check.sh",
    ]:
        path = repo / relative
        if path.exists() and (path.stat().st_mode & 0o111) == 0:
            failures.append(f"script is not executable: {relative}")

    if args.code_map:
        for relative in [
            ".cppstudio/code-map-state.json",
            "docs/CODEBASE_ARCHITECTURE_INDEX.md",
            "docs/CODEBASE_SUBSYSTEM_MANIFEST.json",
            "scripts/bootstrap_code_map.py",
            "scripts/validate_code_map.py",
        ]:
            if not (repo / relative).exists():
                failures.append(f"missing code map file {relative}")
        validator = repo / "scripts/validate_code_map.py"
        if validator.exists() and not failures:
            result = subprocess.run(
                ["python3", str(validator), str(repo), "--require-enabled"],
                cwd=repo,
                text=True,
                capture_output=True,
                check=False,
            )
            if result.returncode != 0:
                failures.append(f"code map validation failed:\n{result.stdout}{result.stderr}")

    if args.integration and not failures:
        build_preset = args.integration_build_preset or args.integration_configure_preset
        commands = [
            ["cmake", "--preset", args.integration_configure_preset],
            ["cmake", "--build", "--preset", build_preset],
            ["ctest", "--preset", args.integration_test_preset, "--show-only=json-v1"],
        ]
        for command in commands:
            result = subprocess.run(command, cwd=repo, text=True, capture_output=True, check=False)
            if result.returncode != 0:
                failures.append(
                    f"integration command failed ({' '.join(command)}):\n{result.stdout}{result.stderr}"
                )
                break
            if command[0] == "ctest":
                failures.extend(validate_ctest_json(result.stdout, set(args.integration_required_label)))

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print(f"Studio backbone validation passed: {repo}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
