#!/usr/bin/env python3
"""Create a new Vulkan-first C++ app+library project from the bundled template."""

from __future__ import annotations

import argparse
import json
import re
import shutil
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_ROOT = SKILL_ROOT / "assets" / "app-library-template"
RUNTIME_SCRIPTS = [
    "check_dev_tools.sh",
    "select_idle_gpu.sh",
    "run_compute_sanitizer.sh",
    "run_vulkan_validation.sh",
    "dump_vulkan_capabilities.sh",
    "run_nsys_smoke.sh",
    "run_gpu_optimization_loop.py",
    "run_viewport_session_smoke.py",
    "format_check.sh",
    "tidy_check.sh",
    "bootstrap_code_map.py",
    "validate_code_map.py",
    "check_code_map_drift.py",
]
CUDA_RUNTIME_SCRIPTS = {
    "run_compute_sanitizer.sh",
    "select_idle_gpu.sh",
}
CUDA_TEMPLATE_PATHS = {
    "cmake/CudaArchitectures.cmake",
    "docs/SUBSYSTEMS/cuda-lane.md",
    "include/{{PROJECT_NAME}}/cuda_vector_add.hpp",
    "src/cuda/vector_add.cu",
    "tests/unit/cuda_vector_add_test.cpp",
}
CUDA_TEMPLATE_DIRS = {
    "src/cuda",
}
CUDA_PRESET_NAMES = {
    "cuda",
    "cuda-debug",
    "cuda-vulkan-combined",
}
CPP_KEYWORDS = {
    "alignas",
    "alignof",
    "and",
    "and_eq",
    "asm",
    "auto",
    "bitand",
    "bitor",
    "bool",
    "break",
    "case",
    "catch",
    "char",
    "char8_t",
    "char16_t",
    "char32_t",
    "class",
    "compl",
    "concept",
    "const",
    "consteval",
    "constexpr",
    "constinit",
    "const_cast",
    "continue",
    "co_await",
    "co_return",
    "co_yield",
    "decltype",
    "default",
    "delete",
    "do",
    "double",
    "dynamic_cast",
    "else",
    "enum",
    "explicit",
    "export",
    "extern",
    "false",
    "float",
    "for",
    "friend",
    "goto",
    "if",
    "import",
    "inline",
    "int",
    "long",
    "module",
    "mutable",
    "namespace",
    "new",
    "noexcept",
    "not",
    "not_eq",
    "nullptr",
    "operator",
    "or",
    "or_eq",
    "private",
    "protected",
    "public",
    "register",
    "reinterpret_cast",
    "requires",
    "return",
    "short",
    "signed",
    "sizeof",
    "static",
    "static_assert",
    "static_cast",
    "struct",
    "switch",
    "template",
    "this",
    "thread_local",
    "throw",
    "true",
    "try",
    "typedef",
    "typeid",
    "typename",
    "union",
    "unsigned",
    "using",
    "virtual",
    "void",
    "volatile",
    "wchar_t",
    "while",
    "xor",
    "xor_eq",
}
NAMESPACE_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$")


def normalize_project_name(raw: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]", "_", raw.strip())
    cleaned = re.sub(r"_+", "_", cleaned).strip("_")
    if not cleaned or not re.match(r"^[A-Za-z_]", cleaned):
        raise ValueError("project name must contain letters and start with a letter or underscore")
    return cleaned


def lower_name(project_name: str) -> str:
    words = re.findall(r"[A-Z]?[a-z0-9]+|[A-Z]+(?=[A-Z]|$)", project_name)
    if not words:
        words = [project_name]
    return "_".join(word.lower() for word in words)


def namespace_name(raw: str | None, project_lower: str) -> str:
    value = raw.strip() if raw else project_lower
    value = re.sub(r"[^A-Za-z0-9_:]", "_", value)
    if not NAMESPACE_PATTERN.fullmatch(value):
        raise ValueError(
            "namespace must be C++ identifiers separated by '::', for example 'studio' or 'studio::render'"
        )
    keyword_segments = [segment for segment in value.split("::") if segment in CPP_KEYWORDS]
    if keyword_segments:
        raise ValueError(f"namespace segment is a C++ keyword: {keyword_segments[0]}")
    return value


def render_text(text: str, replacements: dict[str, str]) -> str:
    for key, value in replacements.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def render_path(path: Path, replacements: dict[str, str]) -> Path:
    return Path(*[render_text(part, replacements) for part in path.parts])


def is_cuda_template_path(relative: Path) -> bool:
    relative_text = relative.as_posix()
    return relative_text in CUDA_TEMPLATE_PATHS or any(
        relative_text == directory or relative_text.startswith(f"{directory}/")
        for directory in CUDA_TEMPLATE_DIRS
    )


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def replace_required(text: str, old: str, new: str, path: Path) -> str:
    if old not in text:
        raise RuntimeError(f"expected block not found while pruning CUDA from {path}")
    return text.replace(old, new)


def remove_required_pattern(text: str, pattern: str, path: Path) -> str:
    updated, count = re.subn(pattern, "", text, flags=re.DOTALL)
    if count == 0:
        raise RuntimeError(f"expected pattern not found while pruning CUDA from {path}")
    return updated


def replace_required_pattern(text: str, pattern: str, replacement: str, path: Path) -> str:
    updated, count = re.subn(pattern, replacement, text, flags=re.DOTALL)
    if count == 0:
        raise RuntimeError(f"expected pattern not found while pruning CUDA from {path}")
    return updated


def remove_named_presets(path: Path, blocked_names: set[str]) -> None:
    data = json.loads(read_text(path))
    for key in ("configurePresets", "buildPresets", "testPresets"):
        entries = data.get(key, [])
        if not isinstance(entries, list):
            continue
        data[key] = [
            entry
            for entry in entries
            if not (isinstance(entry, dict) and entry.get("name") in blocked_names)
        ]
    for preset in data.get("configurePresets", []):
        if not isinstance(preset, dict):
            continue
        cache = preset.get("cacheVariables")
        if isinstance(cache, dict):
            cache.pop("PROJECT_ENABLE_CUDA", None)
            cache.pop("PROJECT_CUDA_ARCHITECTURES", None)
    write_text(path, json.dumps(data, indent=2) + "\n")


def remove_manifest_subsystem(path: Path, subsystem_id: str) -> None:
    data = json.loads(read_text(path))
    subsystems = data.get("subsystems")
    if not isinstance(subsystems, list):
        raise RuntimeError(f"expected subsystem list in {path}")
    data["subsystems"] = [
        subsystem
        for subsystem in subsystems
        if not (isinstance(subsystem, dict) and subsystem.get("id") == subsystem_id)
    ]
    write_text(path, json.dumps(data, indent=2) + "\n")


def prune_vulkan_only_cmake(destination: Path, replacements: dict[str, str]) -> None:
    project_name = replacements["PROJECT_NAME"]
    project_lower = replacements["PROJECT_NAME_LOWER"]
    namespace = replacements["CPP_NAMESPACE"]

    cmake_lists = destination / "CMakeLists.txt"
    text = read_text(cmake_lists)
    text = replace_required(text, "include(CudaArchitectures)\n", "", cmake_lists)
    text = remove_required_pattern(
        text,
        r"\nif\(PROJECT_ENABLE_CUDA\)\n    project_enable_cuda_language\(\)\nendif\(\)\n",
        cmake_lists,
    )
    text = remove_required_pattern(
        text,
        rf"\nif\(PROJECT_ENABLE_CUDA\)\n    add_library\({re.escape(project_lower)}_cuda\n.*?"
        rf"project_set_warnings\({re.escape(project_lower)}_cuda\)\nendif\(\)\n",
        cmake_lists,
    )
    text = remove_required_pattern(
        text,
        rf"\nif\(PROJECT_ENABLE_CUDA\)\n    target_link_libraries\({re.escape(project_lower)}_app PRIVATE {re.escape(project_name)}::cuda\)\nendif\(\)\n",
        cmake_lists,
    )
    text = remove_required_pattern(
        text,
        rf"\n    if\(PROJECT_ENABLE_CUDA\)\n        add_executable\({re.escape(project_lower)}_cuda_test\n.*?"
        rf"project_add_labeled_test\({re.escape(project_lower)}_cuda_test {re.escape(project_lower)}_cuda_test \"gpu;cuda\"\)\n    endif\(\)\n",
        cmake_lists,
    )
    write_text(cmake_lists, text)

    options = destination / "cmake" / "ProjectOptions.cmake"
    text = read_text(options)
    text = replace_required(
        text,
        'option(PROJECT_ENABLE_CUDA "Enable CUDA language support and CUDA targets" OFF)\n',
        "",
        options,
    )
    text = replace_required(
        text,
        'set(PROJECT_CUDA_ARCHITECTURES "native" CACHE STRING "CUDA architectures for project CUDA targets")\n',
        "",
        options,
    )
    write_text(options, text)

    warnings = destination / "cmake" / "Warnings.cmake"
    text = read_text(warnings)
    text = replace_required(
        text,
        "                $<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=-Wall,-Wextra>\n",
        "",
        warnings,
    )
    write_text(warnings, text)

    main_cpp = destination / "src" / "app" / "main.cpp"
    text = read_text(main_cpp)
    text = remove_required_pattern(
        text,
        rf'\n#ifdef PROJECT_HAS_CUDA\n#include "{re.escape(project_name)}/cuda_vector_add\.hpp"\n#endif\n',
        main_cpp,
    )
    text = remove_required_pattern(
        text,
        rf"\nint run_cuda_smoke\(\) \{{\n#ifdef PROJECT_HAS_CUDA\n\s*return {re.escape(namespace)}::cuda_vector_add_smoke\(\) \? 0 : 4;\n#else\n\s*std::cerr << \"CUDA smoke requested but CUDA is disabled\\n\";\n\s*return 3;\n#endif\n\}}\n",
        main_cpp,
    )
    text = replace_required_pattern(
        text,
        r'\n\s*if \(has_arg\(argc, argv, "--cuda-smoke"\)\) \{\n\s*return run_cuda_smoke\(\);\n\s*\}\n',
        "\n",
        main_cpp,
    )
    text = replace_required_pattern(
        text,
        r'\n\s*if \(has_arg\(argc, argv, "--gpu-smoke"\)\) \{\n\s*const int vulkan_result = run_vulkan_smoke\(\);\n\s*if \(vulkan_result != 0\) \{\n\s*return vulkan_result;\n\s*\}\n#ifdef PROJECT_HAS_CUDA\n\s*return run_cuda_smoke\(\);\n#else\n\s*return 0;\n#endif\n\s*\}\n',
        '\n    if (has_arg(argc, argv, "--gpu-smoke")) {\n        return run_vulkan_smoke();\n    }\n',
        main_cpp,
    )
    text = remove_required_pattern(
        text,
        rf'#ifdef PROJECT_HAS_CUDA\n\s*std::cout << "CUDA smoke: "\s*<< \({re.escape(namespace)}::cuda_vector_add_smoke\(\) \? "ok"\s*: "failed"\)\s*<< \'\\n\';\n#else\n\s*std::cout << "CUDA: disabled\\n";\n#endif\n',
        main_cpp,
    )
    write_text(main_cpp, text)


def prune_vulkan_only_docs(destination: Path) -> None:
    readme = destination / "README.md"
    text = read_text(readme)
    text = replace_required(
        text,
        """This project is scaffolded as a Vulkan-first C++ app and library with optional CUDA and combined
CUDA plus Vulkan lanes. Real CUDA/Vulkan external-memory or semaphore interop should be added only
when the project defines that contract deliberately.
""",
        "This project is scaffolded as a Vulkan-only C++ app and library.\n",
        readme,
    )
    text = remove_required_pattern(
        text,
        r"\nOptional CUDA lane:\n\n```bash\ncmake --preset cuda-debug\ncmake --build --preset cuda-debug\nctest --preset cuda --output-on-failure\n```\n\nOptional combined CUDA plus Vulkan lane:\n\n```bash\ncmake --preset cuda-vulkan-combined\ncmake --build --preset cuda-vulkan-combined\n```\n",
        readme,
    )
    text = replace_required(
        text,
        "For CUDA kernels, Vulkan compute shaders, render passes, simulations, or frame-time work, use the\n",
        "For Vulkan compute shaders, render passes, simulations, or frame-time work, use the\n",
        readme,
    )
    write_text(readme, text)

    docs = {
        "docs/DEVELOPMENT_ENVIRONMENT.md": """# Development Environment

This project follows the reusable Vulkan-only C++ studio backbone.

## Required Local Tools

- CMake 3.25+
- Ninja
- A C++20 compiler
- Git
- Vulkan loader, headers, and SDK tools such as `glslc` and `spirv-val`

Optional but useful tools:

- `nsys` for frame and queue scheduling traces
- RenderDoc or Nsight Graphics for frame inspection
- `clang-format`, `clang-tidy`, and `run-clang-tidy` for style/static checks

## Presets

- `dev`: default debug build.
- `release`: optimized release build with warnings as errors.
- `profile`: `RelWithDebInfo` build for profiling.
- `asan-ubsan`: host sanitizer build with Vulkan disabled.
- `vulkan-debug`: Vulkan runtime and shader smoke build.
- `vulkan-portability`: Vulkan portability-enumeration build.
- `vulkan-validation`: Vulkan validation-layer build.
- `benchmark`: benchmark smoke build.
- `ci-gpu`: self-hosted GPU CI build.

Use `scripts/check_dev_tools.sh` before the first configure.
""",
        "docs/VALIDATION_PIPELINE.md": """# Validation Pipeline

Recommended local gate:

```bash
scripts/check_dev_tools.sh
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

Host sanitizer gate:

```bash
cmake --preset asan-ubsan
cmake --build --preset asan-ubsan
ctest --preset asan-ubsan-quick --output-on-failure
```

Vulkan shader gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan-shader --output-on-failure
```

Vulkan runtime gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan --output-on-failure
```

Viewport-session smoke gate:

```bash
scripts/run_viewport_session_smoke.py --build-dir build/dev
```

For visible UI, viewport, brush, paint, sculpt, groom, timeline, node, camera, or gizmo bugs, record
or replay a user-equivalent viewport session and compare before/after `report.json`, state files,
semantic traces, and fresh captures before claiming the bug is fixed.

Vulkan validation gate:

```bash
cmake --preset vulkan-validation
cmake --build --preset vulkan-validation
scripts/run_vulkan_validation.sh
```

Use `scripts/dump_vulkan_capabilities.sh` when a Vulkan runtime lane fails before changing code.
Classify missing SDK tools, missing loader, missing ICD, no physical devices, unavailable features,
shader validation failures, and validation-layer messages separately.

Profiling smoke gate:

```bash
scripts/run_nsys_smoke.sh
```

Benchmark and profiling result records should follow [BENCHMARKS.md](BENCHMARKS.md). Do not add
timing thresholds to CI until baselines are recorded for the exact runner hardware.
""",
        "docs/BENCHMARKS.md": """# Benchmarks

Record benchmark context with every performance claim:

- preset, build type, and commit
- selected GPU, driver, Vulkan loader/ICD, and Vulkan device name
- operating system and compiler
- workload size and command line
- median, min, max, and sample count

Use Nsight Systems for whole-frame CPU/GPU scheduling and queue overlap questions. Use RenderDoc or
Nsight Graphics for frame event inspection and visual correctness.
""",
        "docs/GPU_RUNNER_CI.md": """# GPU Runner CI

Use self-hosted GPU runners for Vulkan runtime, validation, and profiling jobs. Hosted CPU runners are
acceptable for lint-only or build-only lanes when they do not claim realtime GPU readiness.

Minimum runner expectations:

- Vulkan loader and SDK tools
- A hardware Vulkan 1.3 device for realtime viewport/runtime validation
- CMake, Ninja, C++ compiler, and Git
- Optional RenderDoc, Nsight Graphics, or Nsight Systems for diagnostic jobs

Keep generated build outputs, screenshots, profiler captures, and logs out of git unless the project
intentionally tracks them.
""",
        "docs/GPU_OPTIMIZATION_LOOP.md": """# GPU Optimization Loop

Use this loop when improving Vulkan compute shaders, render passes, simulation kernels, frame-time
work, or CPU/GPU scheduling.

Start with fixed evidence:

1. Choose the end-to-end workload and success criteria.
2. Record a baseline command and validation command.
3. Profile before editing.
4. Make one focused change per attempt.
5. Keep the change only when validation still passes and the representative metric improves.
6. Stop when the result converges or the bottleneck has moved.

Example target table row:

```text
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	success_criteria	validation_passes	metric_name	direction	notes
vulkan_compute	vulkan	Vulkan compute smoke	50	ctest --preset benchmark --output-on-failure	ctest --preset vulkan --output-on-failure	scripts/run_nsys_smoke.sh	src/render;shaders	correctness stays green and elapsed_ms improves on the representative workload	2	elapsed_ms	lower	replace share with profiler evidence
```

Run `scripts/run_gpu_optimization_loop.py --help` for the command surface.
""",
    }
    for relative, content in docs.items():
        write_text(destination / relative, content)

    index = destination / "docs" / "CODEBASE_ARCHITECTURE_INDEX.md"
    text = read_text(index)
    text = replace_required(
        text,
        "- CUDA lane: [SUBSYSTEMS/cuda-lane.md](./SUBSYSTEMS/cuda-lane.md)\n",
        "",
        index,
    )
    write_text(index, text)

    build_doc = destination / "docs" / "SUBSYSTEMS" / "build-and-presets.md"
    text = read_text(build_doc).replace("Vulkan/CUDA enablement", "Vulkan enablement")
    write_text(build_doc, text)

    remove_manifest_subsystem(destination / "docs" / "CODEBASE_SUBSYSTEM_MANIFEST.json", "cuda_lane")


def prune_vulkan_only_scripts(destination: Path) -> None:
    format_check = destination / "scripts" / "format_check.sh"
    text = read_text(format_check)
    text = text.replace(" '*.cpp' '*.hpp' '*.h' '*.cu' '*.cuh'", " '*.cpp' '*.hpp' '*.h'")
    text = text.replace(" -o -name '*.cu' -o -name '*.cuh'", "")
    text = text.replace("No C++/CUDA files found", "No C++ files found")
    write_text(format_check, text)

    check_dev_tools = destination / "scripts" / "check_dev_tools.sh"
    text = read_text(check_dev_tools)
    text = remove_required_pattern(
        text,
        r'\nrequire_cuda="\$\{REQUIRE_CUDA:-0\}"\n',
        check_dev_tools,
    )
    text = remove_required_pattern(
        text,
        r'\nrequire_cuda_profiling="\$\{REQUIRE_CUDA_PROFILING:-0\}"\n',
        check_dev_tools,
    )
    text = remove_required_pattern(
        text,
        r'\nif \[\[ "\$\{require_cuda\}" == "1" \]\]; then\n    need_cmd nvcc\n    need_cmd nvidia-smi\n    need_cmd compute-sanitizer\nelse\n    want_cmd nvcc\n    want_cmd nvidia-smi\n    want_cmd compute-sanitizer\nfi\n',
        check_dev_tools,
    )
    text = remove_required_pattern(
        text,
        r'\nif \[\[ "\$\{require_cuda_profiling\}" == "1" \]\]; then\n    need_cmd ncu\nelse\n    want_cmd ncu\nfi\n',
        check_dev_tools,
    )
    write_text(check_dev_tools, text)

    run_nsys = destination / "scripts" / "run_nsys_smoke.sh"
    text = read_text(run_nsys)
    text = remove_required_pattern(
        text,
        r'\nif \[\[ "\$\{REQUIRE_CUDA_PROFILING:-0\}" == "1" \]\] && ! command -v ncu >/dev/null 2>&1; then\n    echo "ncu is required when REQUIRE_CUDA_PROFILING=1" >&2\n    exit 1\nfi\n',
        run_nsys,
    )
    text = remove_required_pattern(
        text,
        r'\nprofile_lane="\$\{PROFILE_LANE:-vulkan\}"\n',
        run_nsys,
    )
    text = remove_required_pattern(
        text,
        r'\ncase "\$\{profile_lane\}" in\n    vulkan\)\n        default_trace="vulkan,nvtx,osrt"\n        default_app_arg="--vulkan-smoke"\n        ;;\n    cuda\)\n        default_trace="cuda,nvtx,osrt"\n        default_app_arg="--cuda-smoke"\n        ;;\n    all\)\n        default_trace="cuda,vulkan,nvtx,osrt"\n        default_app_arg="--gpu-smoke"\n        ;;\n    \*\)\n        echo "PROFILE_LANE must be one of: vulkan, cuda, all" >&2\n        exit 2\n        ;;\nesac\ntrace="\$\{NSYS_TRACE:-\$\{default_trace\}\}"\n',
        run_nsys,
    )
    text = text.replace('trace="${NSYS_TRACE:-${default_trace}}"\n', 'trace="${NSYS_TRACE:-vulkan,nvtx,osrt}"\n')
    text = remove_required_pattern(
        text,
        r'\nif \[\[ -z "\$\{CUDA_VISIBLE_DEVICES:-\}" && \( -n "\$\{GPU_ALLOWED_INDICES:-\}" \|\| "\$\{GPU_AUTO_SELECT:-0\}" == "1" \) \]\]; then\n.*?echo "CUDA_VISIBLE_DEVICES=\$\{CUDA_VISIBLE_DEVICES\}"\nfi\n',
        run_nsys,
    )
    text = text.replace('    command_to_run=("${app_candidate}" "${default_app_arg}")\n', '    command_to_run=("${app_candidate}" "--vulkan-smoke")\n')
    text = remove_required_pattern(
        text,
        r'\ncase "\$\{profile_lane\}" in\n    vulkan\)\n        preferred_reports=\(vulkan_api_sum osrt_sum nvtx_sum\)\n        ;;\n    cuda\)\n        preferred_reports=\(cuda_api_gpu_sum cuda_gpu_kern_sum osrt_sum nvtx_sum\)\n        ;;\n    all\)\n        preferred_reports=\(cuda_api_gpu_sum cuda_gpu_kern_sum vulkan_api_sum osrt_sum nvtx_sum\)\n        ;;\nesac\n',
        run_nsys,
    )
    text = text.replace('        echo "nsys profile succeeded but no compatible stats reports were found for PROFILE_LANE=${profile_lane}."\n', '        echo "nsys profile succeeded but no compatible Vulkan stats reports were found."\n')
    write_text(run_nsys, text)

    bootstrap = destination / "scripts" / "bootstrap_code_map.py"
    text = read_text(bootstrap)
    text = text.replace('    ".cu",\n    ".cuh",\n', "")
    text = remove_required_pattern(
        text,
        r'\n    \{\n        "id": "cuda_lane",\n        "name": "CUDA Lane",\n        "router_doc": "docs/SUBSYSTEMS/cuda-lane.md",\n        "canonical_docs": \["docs/DEVELOPMENT_ENVIRONMENT.md", "docs/VALIDATION_PIPELINE.md"\],\n        "primary_paths": \["src/cuda", "include/\*/cuda_vector_add.hpp"\],\n        "summary": "Explicit CUDA-only work, kernels, launch wrappers, CUDA architecture policy, and Compute Sanitizer lanes.",\n    \},\n',
        bootstrap,
    )
    text = text.replace(
        "Consider adding presets for quick, Vulkan, CUDA, sanitizer, benchmark, and validation lanes before freezing the map.",
        "Consider adding presets for quick, Vulkan, sanitizer, benchmark, and validation lanes before freezing the map.",
    )
    text = text.replace(
        "Consider moving implementation code into `src/` with app, library, render, cuda, or domain-specific subdirectories.",
        "Consider moving implementation code into `src/` with app, library, render, or domain-specific subdirectories.",
    )
    text = remove_required_pattern(
        text,
        r'    if has_cuda and not has_path\(repo, "src/cuda"\):\n        cuda_files = \[path for path in source_files if path.suffix in \{".cu", ".cuh"\}\]\n        findings.append\(\n            AuditFinding\(\n                "medium",\n                "CUDA files are not isolated under `src/cuda`",\n                f"CUDA-like files found: \{sample_paths\(cuda_files\)\}.",\n                "Consider isolating CUDA kernels and launch wrappers behind explicit CUDA build options before enabling the map.",\n            \)\n        \)\n',
        bootstrap,
    )
    text = remove_required_pattern(
        text,
        r'\n    has_cuda = any\(path.suffix in \{".cu", ".cuh"\} for path in source_files\)\n',
        bootstrap,
    )
    text = text.replace('        "CUDA files present": "yes" if has_cuda else "no",\n', "")
    write_text(bootstrap, text)

    validate_map = destination / "scripts" / "validate_code_map.py"
    text = read_text(validate_map).replace('    "cuda_lane",\n', "")
    write_text(validate_map, text)

    drift = destination / "scripts" / "check_code_map_drift.py"
    text = read_text(drift).replace('    ".cu",\n    ".cuh",\n', "")
    write_text(drift, text)


def postprocess_vulkan_only(destination: Path, replacements: dict[str, str]) -> None:
    prune_vulkan_only_cmake(destination, replacements)
    prune_vulkan_only_docs(destination)
    prune_vulkan_only_scripts(destination)
    remove_named_presets(destination / "CMakePresets.json", CUDA_PRESET_NAMES)


def copy_template(destination: Path, replacements: dict[str, str], force: bool, gpu_lane: str) -> None:
    for source in sorted(TEMPLATE_ROOT.rglob("*")):
        relative = source.relative_to(TEMPLATE_ROOT)
        if gpu_lane == "vulkan" and is_cuda_template_path(relative):
            continue
        target = destination / render_path(relative, replacements)
        if source.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        if target.exists() and not force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        target.parent.mkdir(parents=True, exist_ok=True)
        try:
            text = source.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            shutil.copy2(source, target)
        else:
            target.write_text(render_text(text, replacements), encoding="utf-8")


def copy_runtime_scripts(destination: Path, force: bool, gpu_lane: str) -> None:
    scripts_dir = destination / "scripts"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    for script_name in RUNTIME_SCRIPTS:
        if gpu_lane == "vulkan" and script_name in CUDA_RUNTIME_SCRIPTS:
            continue
        source = SKILL_ROOT / "scripts" / script_name
        target = scripts_dir / script_name
        if target.exists() and not force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        shutil.copy2(source, target)
        target.chmod(target.stat().st_mode | 0o111)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--name", required=True, help="Project name, e.g. RayLab")
    parser.add_argument("--output", required=True, help="Destination directory")
    parser.add_argument("--namespace", help="C++ namespace; defaults to snake_case project name")
    parser.add_argument("--description", default="Vulkan-only C++ app+library project")
    parser.add_argument(
        "--gpu-lane",
        choices=("vulkan", "cuda", "cuda-vulkan"),
        default="vulkan",
        help="Generated GPU lane. Defaults to a clean Vulkan-only project; CUDA lanes require an explicit choice.",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite files that already exist")
    args = parser.parse_args()

    project_name = normalize_project_name(args.name)
    project_lower = lower_name(project_name)
    cpp_namespace = namespace_name(args.namespace, project_lower)
    destination = Path(args.output).expanduser().resolve()

    if destination.exists() and any(destination.iterdir()) and not args.force:
        raise SystemExit(f"destination is not empty; pass --force to write into it: {destination}")
    destination.mkdir(parents=True, exist_ok=True)

    replacements = {
        "PROJECT_NAME": project_name,
        "PROJECT_NAME_LOWER": project_lower,
        "PROJECT_NAME_UPPER": project_lower.upper(),
        "CPP_NAMESPACE": cpp_namespace,
        "PROJECT_DESCRIPTION": args.description,
    }

    copy_template(destination, replacements, args.force, args.gpu_lane)
    copy_runtime_scripts(destination, args.force, args.gpu_lane)
    if args.gpu_lane == "vulkan":
        postprocess_vulkan_only(destination, replacements)

    print(f"Created {project_name} at {destination}")
    print(f"GPU lane: {args.gpu_lane}")
    print("Next commands:")
    print(f"  cd {destination}")
    print("  scripts/check_dev_tools.sh")
    print("  cmake --preset dev")
    print("  cmake --build --preset dev")
    print("  ctest --preset quick --output-on-failure")
    if args.gpu_lane != "vulkan":
        print("CUDA lane:")
        print("  cmake --preset cuda-debug && cmake --build --preset cuda-debug && ctest --preset cuda --output-on-failure")
        print("Combined CUDA plus Vulkan lane:")
        print("  cmake --preset cuda-vulkan-combined && cmake --build --preset cuda-vulkan-combined")
    print("Optional GPU optimization loop:")
    print("  read docs/GPU_OPTIMIZATION_LOOP.md and run scripts/run_gpu_optimization_loop.py --help")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (FileExistsError, ValueError) as error:
        raise SystemExit(str(error)) from None
