# Agent-Skills Packaging Hygiene Mapping

Research target: <https://github.com/tech-leads-club/agent-skills>

Inspected revision: `81e7e0dd3abe314aa004ec276c1d64643d2bd6c0`

## Useful Upstream Ideas

- Strong package boundaries: safe relative paths, symlink checks, and no accidental traversal out of
  the install/cache root.
- Integrity metadata: published skill metadata includes file inventories and content hashes; local
  lock/cache entries can compare hashes to decide whether an update is needed.
- Progressive disclosure: MCP tools expose a search/read/fetch flow so agents first see the skill
  body and a compact reference list, then fetch only specific reference files.
- Cache/update ergonomics: remote registry and skill downloads are cached separately from installed
  skill targets; forced refresh and cache-clearing are explicit operations.
- Audit trail: install/remove/update actions write JSONL entries that can be inspected later.

## CppStudio Adaptation

CppStudio should not copy the upstream CLI, registry, MCP server, or marketplace architecture. This
repo has one canonical source skill and local rollout scripts, so the useful adaptation is smaller:

- deterministic `package-manifest.json` in the source skill directory
- SHA-256 and byte-size checks for every shipped skill file
- file roles and disclosure groups to document lazy-loading boundaries
- source, staged, and installed package validation during sync
- installed-skill package validation during rollout
- best-effort sync/rollout JSONL audit records

## Deliberately Not Adopted

- No remote CDN registry.
- No public cache downloader.
- No lockfile format for multiple arbitrary skills.
- No MCP fetch layer.
- No copied source code from the upstream project.

These can be revisited if CppStudio later becomes a distributed public package with versioned
releases and remote install/update flows.
