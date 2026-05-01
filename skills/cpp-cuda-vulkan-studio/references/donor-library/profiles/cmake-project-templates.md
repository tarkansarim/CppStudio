# CMake Project Templates Donor Profile

Sources: https://github.com/friendlyanon/cmake-init https://github.com/cpp-best-practices/cmake_template https://github.com/filipdutescu/modern-cpp-template https://github.com/vector-of-bool/pitchfork
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic
License signal: Mixed permissive template signals; inspect each repository license, generated output
terms, and bundled CI/config files at the exact revision used.

## Use First For

- CMake project layout, presets, app/library separation, examples, tests, and install/export shape.
- Choosing how much infrastructure belongs in a reusable starter versus target-project policy.
- Comparing CMake option, warning, sanitizer, coverage, docs, and packaging patterns.

## First Upstream Areas To Inspect

- Template root layouts, generated CMake entrypoints, and preset organization.
- CI definitions and how they map format, tests, coverage, sanitizer, and packaging lanes.
- Generated project docs, license behavior, and update instructions.
- Pitchfork-style directory conventions only as structure guidance, not as a mandatory standard.

## Integration Notes

- Keep generated projects normal C++ repos; do not force a custom runtime or package manager.
- Prefer CMake presets and explicit options over shell-only build instructions.
- Keep app/library targets, tests, examples, and tools separated so agents can patch small surfaces.
- Preserve target-project dependency policy instead of replacing it with a template default.

## Validation Ideas

- Scaffold a temporary project and run configure, build, and CTest quick presets.
- Confirm `compile_commands.json` can be produced for static analysis.
- Verify install/export rules only when the generated project claims package-install support.

## Caveats

- Template repositories often mix generated output, helper scripts, CI snippets, and docs under
  slightly different license assumptions.
- Do not copy entire template trees without checking whether generated files carry the same terms as
  the template source.
