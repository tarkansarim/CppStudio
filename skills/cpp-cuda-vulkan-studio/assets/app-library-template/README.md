# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

This project is scaffolded as a Vulkan-first C++ app and library with optional CUDA and explicit
CUDA/Vulkan interop lanes.

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

Optional CUDA plus Vulkan interop lane:

```bash
cmake --preset cuda-vulkan-interop
cmake --build --preset cuda-vulkan-interop
```
