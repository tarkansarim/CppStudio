# Static Analysis And Formatting Donor Profile

Sources: https://clang.llvm.org/docs/ClangFormat.html https://clang.llvm.org/extra/clang-tidy/ https://include-what-you-use.org/ https://cppcheck.sourceforge.io/
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic
License signal: LLVM/Apache and permissive tool signals; inspect exact tool versions, config files,
and CI images before pinning behavior.

## Use First For

- clang-format, clang-tidy, include-what-you-use, cppcheck, compile database checks, and style gates.
- Deciding which checks belong in quick lanes versus maintainer or nightly lanes.
- Keeping generated code and third-party code out of formatting/linting targets when appropriate.

## First Upstream Areas To Inspect

- clang-format style options and repo-local `.clang-format` behavior.
- clang-tidy checks, `--warnings-as-errors`, and compile database requirements.
- include-what-you-use mappings and false-positive handling.
- cppcheck suppression and configuration mechanisms.

## Integration Notes

- Prefer check-only scripts in reusable templates; do not auto-rewrite user files during validation.
- Require a compile database for semantic checks.
- Keep third-party, generated, and build directories excluded explicitly.

## Validation Ideas

- Run format and tidy scripts in check-only mode.
- Confirm the scripts fail clearly when required tools or compile databases are missing.
- Verify excludes prevent analysis of vendored or generated code.

## Caveats

- Static-analysis defaults can become noisy quickly. Keep default lanes focused and allow stricter
  maintainer lanes separately.
