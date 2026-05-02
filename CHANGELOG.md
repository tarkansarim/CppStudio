# Changelog

All notable CppStudio changes should be recorded here before pushing to remote.

## Unreleased

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
