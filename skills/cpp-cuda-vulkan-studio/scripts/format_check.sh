#!/usr/bin/env bash
set -euo pipefail

if ! command -v clang-format >/dev/null 2>&1; then
    echo "clang-format is required" >&2
    exit 1
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    mapfile -t files < <(git ls-files --cached --others --exclude-standard '*.cpp' '*.hpp' '*.h' '*.cu' '*.cuh')
else
    mapfile -t files < <(find include src tests benchmarks tools -type f \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' -o -name '*.cu' -o -name '*.cuh' \) 2>/dev/null | sort)
fi

if (( ${#files[@]} == 0 )); then
    echo "No C++/CUDA files found"
    exit 0
fi

clang-format --dry-run --Werror "${files[@]}"
