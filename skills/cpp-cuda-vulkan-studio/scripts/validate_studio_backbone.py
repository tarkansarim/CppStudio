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
    "cuda-vulkan-interop",
    "vulkan-debug",
    "vulkan-portability",
    "vulkan-validation",
    "ci-gpu",
}
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
}


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
    parser.add_argument("--integration", action="store_true", help="Also configure, build, and inspect CTest registration")
    parser.add_argument(
        "--expected-test-label",
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
            configure = {item.get("name") for item in presets.get("configurePresets", [])}
            tests = {item.get("name") for item in presets.get("testPresets", [])}
            missing_configure = REQUIRED_CONFIGURE_PRESETS - configure
            missing_tests = REQUIRED_TEST_PRESETS - tests
            if missing_configure:
                failures.append("missing configure presets: " + ", ".join(sorted(missing_configure)))
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

    if args.integration and not failures:
        commands = [
            ["cmake", "--preset", "dev"],
            ["cmake", "--build", "--preset", "dev"],
            ["ctest", "--preset", "quick", "--show-only=json-v1"],
        ]
        for command in commands:
            result = subprocess.run(command, cwd=repo, text=True, capture_output=True, check=False)
            if result.returncode != 0:
                failures.append(
                    f"integration command failed ({' '.join(command)}):\n{result.stdout}{result.stderr}"
                )
                break
            if command[0] == "ctest":
                failures.extend(validate_ctest_json(result.stdout, set(args.expected_test_label)))

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print(f"Studio backbone validation passed: {repo}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
