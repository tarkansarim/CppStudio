# Testing Infrastructure Donor Profile

Sources: https://github.com/google/googletest https://github.com/catchorg/Catch2 https://github.com/doctest/doctest https://github.com/google/benchmark https://cmake.org/cmake/help/latest/module/GoogleTest.html
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic
License signal: Mostly permissive framework signals; inspect exact framework versions, CMake modules,
and bundled third-party notices.

## Use First For

- CTest labels, unit tests, GPU tests, render/golden tests, benchmark lanes, and test discovery.
- Choosing GoogleTest, Catch2, doctest, or Google Benchmark for a generated or upgraded repo.
- Separating quick, GPU, Vulkan, CUDA, shader, validation, perf, and nightly test lanes.

## First Upstream Areas To Inspect

- GoogleTest CMake integration and `gtest_discover_tests` behavior.
- Catch2 and doctest single-header or package integration tradeoffs.
- Google Benchmark fixtures, command-line output, and CI suitability.
- Existing CTest label and preset conventions in the target repo.

## Integration Notes

- Keep tests selectable by labels so agents can run narrow evidence-gathering commands.
- Render/golden tests need deterministic fixtures, tolerances, and artifact capture.
- GPU tests should degrade by explicit skip/capability reporting, not silent pass.

## Validation Ideas

- Run `ctest --preset quick --output-on-failure` in generated projects.
- Add a labeled smoke test for each enabled optional GPU lane.
- Verify benchmark lanes are not run as default quick tests.

## Caveats

- Test framework choice is a project policy decision; do not add multiple frameworks without a clear
  reason.
- Golden image tests can be fragile across drivers unless tolerance and baseline policy are explicit.
