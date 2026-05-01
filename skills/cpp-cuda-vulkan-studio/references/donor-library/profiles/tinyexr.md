# TinyEXR Donor Profile

Source: https://github.com/syoyo/tinyexr  
Tier: `safe-donor`  
Backend signal: native-cpu
License signal: BSD-3-Clause; inspect `LICENSE`, bundled `miniz`/compression code, sample EXR files,
test data, and optional zlib/stb configuration at the exact revision used.

## Use First For

- Minimal EXR/HDR image loading and writing when OpenImageIO is too heavy.
- Small renderer tests, HDR fixtures, image comparison tools, and dependency-minimal EXR utilities.
- Understanding EXR compression, scanline/tiled/deep-image support boundaries for compact tools.

## First Upstream Areas To Inspect

- `tinyexr.h`, C/C++ wrapper files, examples, and tests.
- Compression/backend configuration around miniz, system zlib, or stb zlib.
- README feature tables before promising support for multipart, tiled, or deep EXR paths.
- Sample EXR files before using them as fixtures.

## Integration Notes

- Keep tiny EXR IO separate from color management, texture conversion, and production image pipelines.
- Prefer OpenImageIO when broad image formats, metadata, color workflows, or production conversion are
  required.
- Validate untrusted image inputs defensively; image IO sits on a common fuzzing/security boundary.
- Track pixel type, channel order, compression, image dimensions, and metadata explicitly in fixtures.

## Validation Ideas

- Test tiny RGB, RGBA, half-float, float, single-channel, empty, malformed, and large-dimension fixtures.
- Exercise missing files, unsupported compression, bad headers, and truncated data.
- Compare loaded values against small known arrays with tolerance.
- Keep sample image licenses separate from code license.

## Caveats

- TinyEXR is intentionally narrower than OpenImageIO.
- EXR feature support varies by version and configuration.
- Bundled sample images and compression code need separate provenance review.
