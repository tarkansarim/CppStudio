# Dawn Donor Profile

Source: https://github.com/google/dawn  
Tier: `dependency-candidate`  
Backend signal: mixed-backend, native-webgpu
License signal: BSD-3-Clause; inspect `LICENSE`, `third_party/`, `DEPS`, Tint/WGSL components,
generated headers, tests, samples, and Chromium-related notices at the exact revision used.

## Use First For

- Native WebGPU implementation, `webgpu.h`, C/C++ bindings, WGSL/Tint tooling, and WebGPU conformance
  testing patterns.
- Comparing WebGPU over Vulkan, D3D12, Metal, OpenGL, and sandboxed client-server runtime boundaries.
- Cross-checking Vulkan/WebGPU shader, resource binding, validation, and portability decisions.

## First Upstream Areas To Inspect

- `include/`, `src/dawn/`, `src/tint/`, `docs/`, `samples/`, `test/`, `tools/`, and `webgpu-cts`.
- Build and dependency files before adopting Dawn as a package dependency.
- Tint/WGSL tests when shader translation or validation behavior matters.
- `third_party/` and generated files before copying examples or headers.

## Integration Notes

- Treat Dawn as a native WebGPU dependency candidate, not a minimal renderer framework.
- For Vulkan-first C++ projects, use Dawn as a portability/WebGPU donor without replacing Vulkan lane
  validation unless the user explicitly chooses WebGPU.
- Keep WebGPU device setup, WGSL compilation, shader reflection, swapchain/surface setup, and native
  backend selection separate.
- Prefer package integration or system SDK decisions over vendoring the full tree.

## Validation Ideas

- Run a tiny triangle or compute fixture through the selected WebGPU backend.
- Test missing adapter, unsupported feature, shader validation failure, surface failure, and backend
  selection errors.
- Compare WGSL/Tint outputs or validation diagnostics on minimal shaders.
- Keep WebGPU CTS-style tests separate from target renderer tests.

## Caveats

- Dawn is tightly connected to Chromium infrastructure and moves quickly.
- Native WebGPU portability still requires backend-specific driver/runtime validation.
- WebGPU is not a drop-in substitute for Vulkan synchronization or memory policy in existing projects.
