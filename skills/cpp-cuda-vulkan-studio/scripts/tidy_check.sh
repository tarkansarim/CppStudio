#!/usr/bin/env bash
set -euo pipefail

build_dir="${BUILD_DIR:-build/dev}"
compile_db="${COMPILE_COMMANDS:-${build_dir}/compile_commands.json}"

if [[ ! -f "${compile_db}" ]]; then
    echo "compile database not found: ${compile_db}" >&2
    echo "Run cmake with CMAKE_EXPORT_COMPILE_COMMANDS=ON first." >&2
    exit 1
fi

if command -v run-clang-tidy >/dev/null 2>&1; then
    run-clang-tidy -p "$(dirname "${compile_db}")"
    exit 0
fi

if ! command -v clang-tidy >/dev/null 2>&1; then
    echo "clang-tidy or run-clang-tidy is required" >&2
    exit 1
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    mapfile -t files < <(git ls-files 'src/*.cpp' 'include/*.hpp' 'include/*.h' 'tests/*.cpp')
else
    mapfile -t files < <(find include src tests -type f \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) 2>/dev/null | sort)
fi

if (( ${#files[@]} == 0 )); then
    echo "No C++ files found"
    exit 0
fi

clang-tidy -p "$(dirname "${compile_db}")" "${files[@]}"
