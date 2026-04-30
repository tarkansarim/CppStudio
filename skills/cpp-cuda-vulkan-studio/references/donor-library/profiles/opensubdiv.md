# OpenSubdiv Donor Profile

Source: https://github.com/PixarAnimationStudios/OpenSubdiv  
Tier: `safe-donor`  
License signal: Tomorrow Open Source Technology License, Apache-2.0-style with trademark differences;
inspect `LICENSE.txt`, optional GPU backends, examples, and third-party notices at the exact revision
used.

## Use First For

- Catmull-Clark subdivision, feature-adaptive subdivision, creases, face-varying data, and DCC-compatible
  smooth surface evaluation.
- CPU and GPU subdivision evaluation architecture.
- Runtime or offline tessellation decisions where production subdivision semantics matter.
- Interchange checks for USD or DCC-authored subdivision surfaces.

## First Upstream Areas To Inspect

- `opensubdiv/far/` for topology refinement and feature-adaptive representation.
- `opensubdiv/osd/` for CPU/GPU evaluator interfaces.
- `opensubdiv/sdc/` for subdivision scheme and crease behavior.
- `examples/` and regression tests for topology and evaluator usage.
- Build options for optional CUDA, OpenGL, Metal, TBB, and platform-specific pieces.

## Integration Notes

- Keep subdivision semantics separate from mesh import and renderer upload. A target repo needs a clear
  boundary between authored control cage and evaluated geometry.
- Preserve crease weights, face-varying attributes, UVs, normals, and boundary interpolation settings in
  tests.
- Prefer dependency integration over copying evaluator code.
- Use meshoptimizer after subdivision only for final runtime mesh conditioning, not as a replacement for
  subdivision semantics.

## Validation Ideas

- Evaluate a tiny quad cage, a creased edge case, and a boundary case with expected vertex positions.
- Compare CPU and GPU evaluator outputs for small fixtures when both backends are enabled.
- Test UV/face-varying propagation separately from position evaluation.
- Add import/export fixtures when USD or another DCC scene format carries subdivision metadata.

## Caveats

- GPU evaluator support can depend on optional backends and driver/toolchain availability.
- Subdivision is topology-sensitive; mesh cleanup or triangulation before evaluation can destroy intended
  behavior.
- Example assets and optional backends may have separate dependency or license surfaces.
