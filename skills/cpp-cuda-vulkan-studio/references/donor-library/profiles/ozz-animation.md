# ozz-animation Donor Profile

Source: https://github.com/guillaumeblanc/ozz-animation  
Tier: `safe-donor`  
License signal: MIT; inspect `LICENSE`, samples, converter dependencies, and bundled third-party files
at the exact revision used.

## Use First For

- Data-oriented C++ skeletal animation runtime design.
- Animation sampling, blending, local/model transform jobs, skinning data, and offline conversion.
- SIMD-friendly animation layout and renderer-agnostic runtime boundaries.
- Minimal native animation runtime examples before involving a full engine.

## First Upstream Areas To Inspect

- `include/ozz/animation/runtime/` for runtime data structures and jobs.
- `src/animation/runtime/` for implementation details and edge cases.
- `src/animation/offline/` and tools for import/conversion workflows.
- `samples/` for renderer-agnostic usage patterns.
- Tests and documentation for sampling, blending, and skeleton ownership.

## Integration Notes

- Keep offline conversion and runtime playback separate. Runtime code should consume compact baked data.
- Define project conventions for joint order, coordinate system, scale, bind pose, and clip time units.
- Use ACL or another compression donor only after ozz-style runtime correctness is proven.
- Treat FBX, DCC plugins, and sample animation assets as separate license and dependency surfaces.

## Validation Ideas

- Sample a one-joint, two-key clip at start, middle, end, and outside-range times.
- Test skeleton hierarchy, bind pose, clip looping, additive blending, and zero-weight blend behavior.
- Compare CPU skinning output against a small hand-computed fixture before GPU skinning.
- Add importer fixtures only for formats the project actually supports.

## Caveats

- ozz is a runtime and toolset, not a full animation state-machine or editor.
- Import/conversion can pull in heavier format dependencies than the playback runtime requires.
- Animation bugs often hide in convention mismatches; tests should pin coordinate system and units.
