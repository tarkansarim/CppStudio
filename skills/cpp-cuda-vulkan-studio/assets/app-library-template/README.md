# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

This project is scaffolded as a Vulkan-first C++ app and library with optional CUDA and combined
CUDA plus Vulkan lanes. Real CUDA/Vulkan external-memory or semaphore interop should be added only
when the project defines that contract deliberately.

## Code Map

This template includes opt-in CppStudio code-map docs and scripts. The map is maintained only after
`.cppstudio/code-map-state.json` says `enabled`.

Enable it after the user accepts:

```bash
scripts/bootstrap_code_map.py --enable
scripts/validate_code_map.py --require-enabled
```

Record a decline so agents stop prompting:

```bash
scripts/bootstrap_code_map.py --decline
```

## Validate

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

Optional CUDA lane:

```bash
cmake --preset cuda-debug
cmake --build --preset cuda-debug
ctest --preset cuda --output-on-failure
```

Optional combined CUDA plus Vulkan lane:

```bash
cmake --preset cuda-vulkan-combined
cmake --build --preset cuda-vulkan-combined
```
