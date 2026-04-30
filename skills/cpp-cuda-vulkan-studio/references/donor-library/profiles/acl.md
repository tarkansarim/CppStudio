# Animation Compression Library Donor Profile

Source: https://github.com/nfrechette/acl  
Tier: `safe-donor`  
License signal: MIT; inspect `LICENSE`, `external/`, test data, benchmark data, and tool dependencies at
the exact revision used.

## Use First For

- Skeletal animation compression and decompression policy.
- Clip accuracy, memory footprint, and sampling-performance tradeoffs.
- Header-only C++ animation compression integration in game/runtime engines.
- Benchmark and regression-test structure for animation codecs.

## First Upstream Areas To Inspect

- `includes/acl/` for public compression, decompression, track, and clip APIs.
- `tests/` for accuracy checks, edge cases, and codec regression patterns.
- `tools/` for compression, benchmarking, and conversion workflows.
- `docs/` for integration guidance and algorithm notes.
- `test_data/` only after checking asset provenance and license expectations.

## Integration Notes

- Use ACL after a runtime animation representation is defined; it complements ozz-style playback rather
  than replacing skeleton, clip, and blend ownership.
- Keep raw imported clips, compressed clips, decompression cache, and runtime sampling code separated.
- Decide error metrics, acceptable precision loss, rotation/translation/scale track policy, and metadata
  preservation before compressing real content.
- Preserve uncompressed reference clips for tests and debugging.

## Validation Ideas

- Compress and decompress a tiny fixture with translation, rotation, and scale tracks, then compare
  sampled poses against an uncompressed reference.
- Test constant tracks, empty tracks, one-sample clips, looping clips, and high-frequency motion.
- Record compressed size, decompression speed, and maximum error for representative clips.
- Run regression tests before changing codec settings or version pins.

## Caveats

- Compression settings are content- and runtime-dependent. Do not treat one benchmark corpus as a
  universal production threshold.
- Test data and third-party code need their own provenance checks.
- Animation compression bugs can look like rigging or skinning bugs; keep reference playback fixtures
  available when debugging.
