# NVIDIA vk_mini_samples Donor Profile

Source: https://github.com/nvpro-samples/vk_mini_samples  
Tier: `safe-donor`  
Backend signal: native-vulkan
License signal: Apache-2.0; inspect `LICENSE`, `resources/`, and companion `nvpro_core2` dependency
terms at the exact revision used.

## Use First For

- NVIDIA-oriented Vulkan samples for modern graphics, ray tracing, mesh/task shaders, descriptor heap,
  memory budget, shader printf, crash diagnostics, and offscreen rendering.
- Nsight Graphics, Nsight Aftermath, Slang, and NVIDIA extension workflows.
- Compact examples after portable Khronos guidance has been checked.

## First Upstream Areas To Inspect

- `samples/` for feature-specific implementations.
- `common/` for shared helper patterns.
- `docs/` for sample explanations.
- `resources/` for asset and shader inputs.
- `CMakeLists.txt` and `nvpro_core2` setup for dependency expectations.

## Integration Notes

- Use Khronos Vulkan-Samples first for portable correctness, then use vk_mini_samples for NVIDIA
  extension/tooling specifics.
- Keep extension checks and fallback behavior explicit in target code.
- Treat Slang, Nsight Aftermath, and `nvpro_core2` as optional dependencies unless a project explicitly
  accepts them.
- For reusable templates, borrow CI/debugging ideas rather than imposing the donor framework.

## Validation Ideas

- Run validation layers and capability dumps before enabling vendor extension paths.
- Capture extension-heavy paths in Nsight Graphics.
- Add negative tests for missing extension/device-feature cases.
- Keep offscreen render outputs as artifacts when adapting render samples.

## Caveats

- The samples intentionally lean into NVIDIA hardware and tooling.
- Some examples require Vulkan 1.4+, vendor extensions, Slang, or external SDKs.
- Apache-2.0 code licensing does not automatically cover every asset or companion dependency.
