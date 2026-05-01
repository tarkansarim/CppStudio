# OpenTimelineIO Donor Profile

Source: https://github.com/AcademySoftwareFoundation/OpenTimelineIO  
Tier: `dependency-candidate`  
Backend signal: dcc-interchange, native-cpu
License signal: Apache-2.0; inspect `LICENSE.txt`, `NOTICE.txt`, adapter/plugin packages, examples,
media-linker behavior, and any application-specific adapter dependencies at the exact revision used.

## Use First For

- Editorial timeline interchange, shot/clip ordering, time ranges, media references, and review or
  virtual-production handoff.
- C++ and Python data-model references for cut lists, tracks, stacks, clips, markers, and rational time.
- Adapter/plugin architecture when a pipeline needs AAF, EDL, FCPXML, or application-specific timeline
  import/export without embedding media.

## First Upstream Areas To Inspect

- `src/`, `examples/`, `tests/`, `docs/`, and schema/data-model documentation.
- Adapter and plugin documentation before promising support for a legacy editorial format.
- Media linker and hook-script behavior when project paths or asset resolution matter.
- `NOTICE.txt` and adapter dependency notices before reuse.

## Integration Notes

- Treat OTIO as a timeline/interchange dependency boundary, not a media container or transcoding tool.
- Keep timeline data, media resolution, asset paths, generated review outputs, and DCC/editor plugins
  separated.
- For C++ tools, decide whether native C++ API use or Python package invocation is the intended boundary.
- Record frame rate, timecode, drop-frame policy, and missing-media behavior in project tests.

## Validation Ideas

- Add tiny timeline fixtures with one clip, nested tracks, gaps, transitions, and external media refs.
- Test frame-rate conversion, missing media, invalid time ranges, empty tracks, and adapter failure modes.
- Round-trip only the formats the project claims to support.
- Keep adapter/plugin tests separate from core `.otio` data-model tests.

## Caveats

- OTIO stores editorial structure and references to media; it is not a media container.
- Adapter support and dependencies can move outside the core package.
- Editorial timelines can hide frame-rate, timecode, and path-resolution edge cases.
