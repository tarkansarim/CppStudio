![CppStudio banner](assets/cppstudio-banner.png)

# CppStudio

CppStudio is an agentic ChatGPT Codex skills package for native C++ GPU engineering. It gives Codex
a reusable Vulkan-first C++/CUDA project backbone, lane discipline, validation hooks, and a curated
donor-reference library for 3D, rendering, simulation, AI runtimes, CUDA, and Vulkan work.

Use it when you want Codex to create, audit, or upgrade native C++ GPU projects without turning every
new repo into a one-off build-system and donor-research exercise.

## Install

CppStudio is meant to be installed by your coding agent. If your agent has shell access to the
machine, ask it:

```text
Install this CppStudio repo into my ChatGPT Codex home. Use the repo scripts, preserve my existing
AGENTS.md content, and report what changed.
```

The normal agent command is:

```bash
cd /path/to/CppStudio
./scripts/rollout_to_codex.sh
```

That installs the main skill and donor-library links into the Codex home on the machine where the
command runs. The default Codex home is `${HOME}/.codex`. Restart Codex after installation so changed
skill metadata is discovered.

You do not need CUDA, Vulkan, CMake, or a compiler just to install CppStudio into Codex. Install GPU
toolchains only when you want this machine to build or validate generated C++ GPU projects.

## What Gets Installed

- Main skill:
  `${HOME}/.codex/skills/cpp-cuda-vulkan-studio`
- Optional companion donor links for installed companion skills such as `cuda-kernel-authoring`,
  `vulkan-compute-sync`, and `modern-cpp-cmake`
- Optional tiny user-level `AGENTS.md` relay that tells agents to load `cpp-cuda-vulkan-studio` for
  C++ Vulkan, C++ CUDA, or mixed CUDA/Vulkan work

Existing user content is preserved. CppStudio scripts only replace content inside their own marked
blocks:

- `<!-- cppstudio-user-agents-relay:begin -->` through
  `<!-- cppstudio-user-agents-relay:end -->`
- `<!-- cppstudio-donor-library:begin -->` through
  `<!-- cppstudio-donor-library:end -->`

## Use It

After installation and a Codex restart, you usually do not need to name the skill. Ask Codex for
native C++ GPU, Vulkan, CUDA, renderer, realtime 3D, simulation, or donor-reference work, and Codex
should load `cpp-cuda-vulkan-studio` automatically.

```text
Create a Vulkan-first C++ application called RayLab.
```

```text
Upgrade this C++ renderer repo with the CppStudio backbone; use Vulkan by default unless CUDA is explicitly needed.
```

```text
Find suitable donors for a real-time grooming and fur simulation tool, then wire the selected
patterns into this C++/Vulkan project.
```

Mention `$cpp-cuda-vulkan-studio` explicitly only when automatic skill routing is unavailable or did
not trigger.

## What The Skill Does

- Prefer Vulkan for unspecified native C++ GPU, rendering, realtime, XR, simulation-visualization, or
  cross-platform work.
- Keep CUDA explicit and separate unless the user chooses CUDA, requirements force CUDA, or a
  deliberate CUDA/Vulkan interop lane is needed.
- Scaffold or upgrade C++ app+library repos with CMake presets, CTest labels, shader tooling,
  optional CUDA lanes, validation scripts, and self-hosted GPU CI hooks.
- Route agents to donor references for graphics, glTF/runtime assets, WebGPU/WebGL, renderer
  backbones, path tracing, engine architecture, mesh pipelines, AI runtimes, neural 3D, Gaussian
  splatting, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, simulation, and
  XR.
- Coordinate companion skills for CMake, Vulkan synchronization, CUDA kernels, and verification.

## Skills And Donors Included

Bundled skills:

- `cpp-cuda-vulkan-studio`: the installed user-level skill for Vulkan-first C++ GPU, CUDA, explicit
  CUDA/Vulkan interop, project scaffolding, validation lanes, and donor routing.
- `cppstudio-repo-onboarding`: a repo-local onboarding skill for agents editing this CppStudio repo.
  It is not the public user-level C++ GPU skill.

Companion skills that CppStudio can link to when they are already installed:

- `modern-cpp-cmake`: CMake, target layout, presets, tests, and native C++ project hygiene.
- `vulkan-compute-sync`: Vulkan compute/render setup, descriptors, barriers, synchronization, and
  frame lifetime.
- `cuda-kernel-authoring`: CUDA kernels, launch wrappers, numerical tests, and Compute Sanitizer
  planning.

The donor library is a reference map, not a vendored source tree. Agents use it to choose
architecture patterns, APIs, tests, algorithms, and dependency candidates. Some donors are direct
C/C++ implementation references, some are dependency-scale references, and some are explicitly
reference-only or study-only.

Donor category files:

- Vulkan foundation tooling
- graphics/rendering
- glTF/runtime assets
- geometry/simulation
- AI runtimes/kernels
- neural 3D
- hair/grooming/fur
- DCC scene pipelines
- volumes/voxels
- animation/rigging
- surfaces/subdivision
- texture/material/color
- CAD/precision geometry
- GPU simulation
- XR/spatial

All current donor profiles, grouped by domain:

- Vulkan and shader tooling: Khronos Vulkan-Samples, NVIDIA vk_mini_samples, Vulkan Memory
  Allocator, volk, vk-bootstrap, SPIR-V Toolchain, Slang.
- CUDA, AI runtimes, and ML compilers: CUTLASS, FlashAttention, Triton, llama.cpp/ggml, ONNX
  Runtime, TensorRT-LLM, vLLM, MLC-LLM, tiny-cuda-nn, Apache TVM, PyTorch.
- Rendering, graphics, and browser 3D: Google Filament, Diligent Engine, bgfx, Magnum, Google Dawn,
  three.js, Babylon.js, pbrt-v4, Mitsuba 3, NVIDIA Falcor, THREE.js PathTracing Renderer, Embree,
  OSPRay, madmann91/bvh.
- Assets, materials, textures, and DCC interchange: glTF C/C++ Loaders
  (fastgltf/cgltf/tinygltf), meshoptimizer, assimp, KTX-Software/Basis Universal, OpenColorIO,
  OpenImageIO, TinyEXR, OpenUSD, Alembic, MaterialX, OpenTimelineIO.
- Geometry, surfaces, and CAD: OpenSubdiv, libigl, CGAL, Open CASCADE Technology, FreeCAD
  Study-Only.
- Neural 3D and reconstruction: gsplat, Nerfstudio, NVIDIA Kaolin, PyTorch3D, Open3D, Neural
  Graphics Study-Only references.
- Hair, grooming, and fur: AMD TressFX, NVIDIA HairWorks Study-Only, Blender Study-Only.
- Volumes and scientific visualization: OpenVDB/NanoVDB, fVDB, VTK.
- Animation: ozz-animation, Animation Compression Library.
- Engines, physics, and simulation: Godot Engine, Open 3D Engine, Jolt Physics, Bullet Physics,
  NVIDIA Warp, Taichi, PositionBasedDynamics, Project Chrono, SOFA, NVIDIA PhysX.
- XR and spatial computing: OpenXR SDK, OpenXR-Hpp, Monado, Godot OpenXR Vendors.

Study-only donors are concept references, not code donors. Browser, Python, notebook, DCC, service,
JIT/DSL, or non-C++ donors can still guide algorithms, behavior, tests, UX, and architecture, but
agents should port the idea through the active C++/Vulkan/CUDA lane instead of copying code directly
unless the user explicitly chooses that runtime and license shape.

## When To Install GPU Tools

Install extra host tools only for lanes you want to build or validate on the current machine:

| Need | Install |
|------|---------|
| Use CppStudio as a Codex skill | Nothing beyond the install command above |
| Validate generated C++ projects locally | CMake, Ninja or another build tool, and a C++ compiler |
| Work on Vulkan projects locally | Vulkan SDK tools such as `glslc`, `spirv-val`, `vulkaninfo`, and validation layers |
| Work on CUDA projects locally | NVIDIA driver, CUDA Toolkit, `nvcc`, and Compute Sanitizer |
| Run optional quality/profiling lanes | `clang-format`, `clang-tidy`, RenderDoc, Nsight tools, or platform-specific profilers |

Detailed setup commands live in [docs/host-toolchain-setup.md](docs/host-toolchain-setup.md).

## Repository Layout

- `skills/cpp-cuda-vulkan-studio/`: source of truth for the user-level Codex skill
- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`: generated-project template
- `skills/cpp-cuda-vulkan-studio/references/`: project archetypes and donor-reference guidance
- `companion-skill-snippets/`: managed donor-link snippets for companion skills and user-level relay
- `research/`: source research and trigger-test notes
- `scripts/`: validation, sync, rollout, and watch helpers
- `.codex/skills/cppstudio-repo-onboarding/`: project-level onboarding skill for agents editing this
  repo

The installed copy at `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` is a deployment target, not the
source of truth. Edit this repo, then have an agent publish with the repo scripts.

## More Docs

- [Manual install reference](docs/manual-install.md): copy steps for agents that cannot run rollout
- [Host toolchain setup](docs/host-toolchain-setup.md): Linux, macOS, and Windows C++/Vulkan/CUDA
  setup notes
- [Maintainer guide](docs/maintainer-guide.md): validation, sync, rollout, generated-project, donor,
  and troubleshooting details for agents editing this repo
- [Donor library](skills/cpp-cuda-vulkan-studio/references/donor-library/README.md): curated donor
  selection entrypoint

## License

CppStudio is released under [The Unlicense](LICENSE) for unrestricted reuse.
