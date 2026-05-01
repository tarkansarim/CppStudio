# Sanitizer And Validation Lanes Donor Profile

Sources: https://clang.llvm.org/docs/AddressSanitizer.html https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html https://clang.llvm.org/docs/ThreadSanitizer.html https://docs.nvidia.com/cuda/compute-sanitizer/index.html
Tier: `dependency-candidate`
Backend signal: api-agnostic, native-cuda
License signal: Toolchain and NVIDIA documentation/tool licenses vary; inspect installed toolchain,
runtime redistribution terms, and CI image terms before packaging anything.

## Use First For

- ASan, UBSan, TSan, Compute Sanitizer, sanitizer presets, runtime options, and failure-artifact
  capture.
- Deciding which sanitizer lanes are safe for quick, GPU, nightly, or maintainer validation.
- Separating CPU sanitizer failures from CUDA memory/race/initcheck/synccheck failures.

## First Upstream Areas To Inspect

- Clang sanitizer documentation for flags, runtime options, suppressions, and platform support.
- NVIDIA Compute Sanitizer documentation for memcheck, racecheck, initcheck, and synccheck.
- Target project build flags and whether CUDA/host compiler combinations support the desired lane.

## Integration Notes

- Keep sanitizer presets explicit and opt-in when they are slow or platform-specific.
- Capture logs in stable paths that CI can upload.
- Do not hide sanitizer failures behind fallback commands.

## Validation Ideas

- Run a tiny ASan/UBSan fixture in a temp build when the compiler supports it.
- Run Compute Sanitizer only on commands or CTest labels that actually exercise CUDA.
- Verify missing tools produce actionable skip/fail messages.

## Caveats

- TSan often conflicts with GPU/runtime/toolchain assumptions and may need a separate preset.
- Compute Sanitizer requires compatible NVIDIA driver/toolkit/runtime access.
