# Changelog

All notable CppStudio changes should be recorded here before pushing to remote.

## Unreleased

- Made public CI run `./scripts/validate.sh --full`, including generated-project scaffold/build
  validation with hosted-CI CUDA runtime tests skipped only when no CUDA device is available.
- Made public CI discover the installed Lavapipe Vulkan CPU ICD path before running Vulkan runtime
  tests on hosted Ubuntu runners.
- Made the tiny user-level `AGENTS.md` relay install by default during rollout, with
  `SKIP_USER_AGENTS_RELAY=1` as the explicit opt-out.
- Hardened manual install guidance with symlink checks and rollback-on-validation-failure behavior.
- Clarified private-provenance validation so public sample labels remain allowed while compact
  maintainer project codenames stay blocked.
- Fixed generated Vulkan template debug-utils code to compile against Ubuntu packaged Vulkan-Hpp
  headers as well as newer SDK headers.
- Replaced the sample-project poster/link fallback with GitHub uploaded attachment URLs so the
  CUDA Groom Tool and Wetbrush MP4 samples render as inline players on the README page.
- Added a GitHub Pages sample-player page as a fallback/supporting sample view with inline video
  controls and explicit fullscreen buttons.
- Re-encoded README sample MP4s as video-only 720p H.264 files under 10 MB for GitHub-friendly
  uploads and inline playback.
- Added README sample-project videos for CUDA Groom Tool and Wetbrush, with public assets moved under
  `assets/videos/`.
- Tightened active code-map behavior so agents use the architecture index and manifest as the first
  navigation step before code changes, including repos that declare their own maintained map.
- Clarified that target repos with their own maintained maps and repo-local skills are the subsystem
  routing authority, and recorded Wetbrush subagent trigger-lane evidence.
- Moved README code-map details into a dedicated optional section with benefits, invocation examples,
  and enablement behavior.
- Rebalanced README positioning so code maps are described as optional support for durable project
  context, not as a primary reason CppStudio exists.
- Clarified greenfield code-map opt-in: explicit project-creation requests for a code map or
  future-agent map count as acceptance after scaffolding.
- Clarified that code-map routing is part of `cpp-cuda-vulkan-studio`, not a separate skill, and
  added code-map wording to the skill metadata and user relay.
- Added an existing-project code-map readiness protocol and audit mode so agents inspect structure,
  estimate cleanup cost, and ask whether to restructure or preserve layout before enabling maps.
- Documented the code map in the README and explained its purpose for durable project architecture
  context, multi-agent routing, and reduced repeated cold reads.
- Clarified automatic skill relay wording for native C++ GPU/realtime prompts and the distinction
  between copied code-map support files and an enabled maintained code map.
- Added an opt-in CppStudio code-map system with bootstrap and validation scripts, generated-project
  starter map docs, and an enabled maintainer map for this repo.
- Added the requirement that future remote pushes include a concise changelog entry for tracked
  user-visible, validation, CI, generated-template, donor-library, install, or sync changes.
