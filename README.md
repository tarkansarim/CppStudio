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

### Bundled Skills

- `cpp-cuda-vulkan-studio`: installed user-level skill for Vulkan-first C++ GPU, CUDA, explicit
  CUDA/Vulkan interop, project scaffolding, validation lanes, and donor routing.
- `cppstudio-repo-onboarding`: repo-local onboarding skill for agents editing this CppStudio repo.
  It is not the public user-level C++ GPU skill.

### Companion Skill Links

CppStudio can add donor-library links to these companion skills when they are already installed:

- `modern-cpp-cmake`: CMake, target layout, presets, tests, and native C++ project hygiene.
- `vulkan-compute-sync`: Vulkan compute/render setup, descriptors, barriers, synchronization, and
  frame lifetime.
- `cuda-kernel-authoring`: CUDA kernels, launch wrappers, numerical tests, and Compute Sanitizer
  planning.

### Donor Index Files

The donor library is a reference map, not a vendored source tree. Agents use it to choose
architecture patterns, APIs, tests, algorithms, and dependency candidates.

- [Donor library entrypoint](skills/cpp-cuda-vulkan-studio/references/donor-library/README.md)
- [Selection policy](skills/cpp-cuda-vulkan-studio/references/donor-library/selection-policy.md)
- [Agent lookup guide](skills/cpp-cuda-vulkan-studio/references/donor-library/agent-lookup.md)

### Donor Category Files

3D, graphics, simulation, and XR category files:

- [Animation and rigging](skills/cpp-cuda-vulkan-studio/references/donor-library/animation-rigging.md)
- [CAD and precision geometry](skills/cpp-cuda-vulkan-studio/references/donor-library/cad-precision-geometry.md)
- [DCC scene pipelines](skills/cpp-cuda-vulkan-studio/references/donor-library/dcc-scene-pipeline.md)
- [Geometry and simulation](skills/cpp-cuda-vulkan-studio/references/donor-library/geometry-simulation.md)
- [glTF runtime assets](skills/cpp-cuda-vulkan-studio/references/donor-library/gltf-runtime-assets.md)
- [Graphics and rendering](skills/cpp-cuda-vulkan-studio/references/donor-library/graphics-rendering.md)
- [Hair, grooming, and fur](skills/cpp-cuda-vulkan-studio/references/donor-library/hair-grooming-fur.md)
- [Neural 3D](skills/cpp-cuda-vulkan-studio/references/donor-library/neural-3d.md)
- [GPU simulation](skills/cpp-cuda-vulkan-studio/references/donor-library/simulation-gpu.md)
- [Surfaces and subdivision](skills/cpp-cuda-vulkan-studio/references/donor-library/surfaces-subdivision.md)
- [Texture, material, and color](skills/cpp-cuda-vulkan-studio/references/donor-library/texture-material-color.md)
- [Volumes and voxels](skills/cpp-cuda-vulkan-studio/references/donor-library/volumes-voxels.md)
- [Vulkan foundation tooling](skills/cpp-cuda-vulkan-studio/references/donor-library/vulkan-foundation-tooling.md)
- [XR and spatial computing](skills/cpp-cuda-vulkan-studio/references/donor-library/xr-spatial.md)

Other GPU, AI, and ML category files:

- [AI runtimes and kernels](skills/cpp-cuda-vulkan-studio/references/donor-library/ai-runtimes-kernels.md)

### Donor Profile Caveats

Some donors are direct C/C++ implementation references, some are dependency-scale references, and
some are explicitly reference-only or study-only. Study-only donors are concept references, not code
donors. Browser, Python, notebook, DCC, service, JIT/DSL, or non-C++ donors can still guide
algorithms, behavior, tests, UX, and architecture, but agents should port the idea through the active
C++/Vulkan/CUDA lane instead of copying code directly unless the user explicitly chooses that runtime
and license shape.

### 3D, Graphics, Simulation, And XR Donor Profiles

#### Vulkan And Shader Tooling

- [Khronos Vulkan-Samples](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/khronos-vulkan-samples.md)
- [NVIDIA vk_mini_samples](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/nvidia-vk-mini-samples.md)
- [Vulkan Memory Allocator](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/vulkan-memory-allocator.md)
- [volk](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/volk.md)
- [vk-bootstrap](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/vk-bootstrap.md)
- [SPIR-V Toolchain](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/spirv-toolchain.md)
- [Slang](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/slang.md)

#### Rendering, Ray Tracing, And Graphics Frameworks

- [Google Filament](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/filament.md)
- [Diligent Engine](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/diligent-engine.md)
- [bgfx](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/bgfx.md)
- [Magnum](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/magnum.md)
- [pbrt-v4](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/pbrt-v4.md)
- [Mitsuba 3](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/mitsuba3.md)
- [NVIDIA Falcor](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/falcor.md)
- [Embree](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/embree.md)
- [OSPRay](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/ospray.md)
- [madmann91/bvh](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/madmann91-bvh.md)

#### Browser 3D, WebGPU, And WebGL References

- [Google Dawn](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/dawn.md)
- [three.js](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/threejs.md)
- [Babylon.js](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/babylonjs.md)
- [THREE.js PathTracing Renderer](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/threejs-pathtracing.md)

#### Assets, Meshes, Materials, And Texture IO

- [glTF C/C++ Loaders](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/fastgltf-cgltf-tinygltf.md)
- [meshoptimizer](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/meshoptimizer.md)
- [assimp](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/assimp.md)
- [KTX-Software and Basis Universal](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/ktx-basis.md)
- [OpenColorIO and OpenImageIO](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/opencolorio-openimageio.md)
- [TinyEXR](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/tinyexr.md)
- [MaterialX](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/materialx.md)

#### DCC Scene And Editorial Pipelines

- [OpenUSD](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/openusd.md)
- [Alembic](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/alembic.md)
- [OpenTimelineIO](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/opentimelineio.md)
- [Blender Study-Only](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/blender-study-only.md)

#### Geometry, Surfaces, And CAD

- [OpenSubdiv](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/opensubdiv.md)
- [libigl](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/libigl.md)
- [CGAL](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/cgal.md)
- [Open CASCADE Technology](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/open-cascade.md)
- [FreeCAD Study-Only](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/freecad-study-only.md)

#### Neural 3D And Reconstruction

These are AI-adjacent, but they are grouped here because their primary domain is 3D reconstruction,
3D data, or neural rendering rather than general AI runtime infrastructure.

- [gsplat](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/gsplat.md)
- [Nerfstudio](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/nerfstudio.md)
- [NVIDIA Kaolin](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/kaolin.md)
- [PyTorch3D](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/pytorch3d.md)
- [Open3D](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/open3d.md)
- [Neural Graphics Study-Only References](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/neural-graphics-study-only.md)

#### Hair, Grooming, And Fur

- [AMD TressFX](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/tressfx.md)
- [NVIDIA HairWorks Study-Only](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/hairworks-study-only.md)

#### Volumes, Voxels, And Scientific Visualization

- [OpenVDB and NanoVDB](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/openvdb-nanovdb.md)
- [fVDB](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/fvdb.md)
- [VTK](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/vtk.md)

#### Animation

- [ozz-animation](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/ozz-animation.md)
- [Animation Compression Library](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/acl.md)

#### Engines

- [Godot Engine](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/godot-engine.md)
- [Open 3D Engine](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/open-3d-engine.md)

#### Physics And Simulation

- [Jolt Physics](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/jolt-physics.md)
- [Bullet Physics](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/bullet-physics.md)
- [NVIDIA Warp](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/warp.md)
- [Taichi](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/taichi.md)
- [PositionBasedDynamics](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/positionbaseddynamics.md)
- [Project Chrono](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/project-chrono.md)
- [SOFA](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/sofa.md)
- [NVIDIA PhysX](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/physx.md)

#### XR And Spatial Computing

- [OpenXR SDK](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/openxr-sdk.md)
- [OpenXR-Hpp](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/openxr-hpp.md)
- [Monado](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/monado.md)
- [Godot OpenXR Vendors](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/godot-openxr-vendors.md)

### Other GPU, AI, And ML Runtime Donor Profiles

#### CUDA Kernels, AI Runtimes, And ML Compilers

- [CUTLASS](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/cutlass.md)
- [FlashAttention](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/flashattention.md)
- [Triton](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/triton.md)
- [llama.cpp and ggml](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/llama-ggml.md)
- [ONNX Runtime](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/onnx-runtime.md)
- [TensorRT-LLM](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/tensorrt-llm.md)
- [vLLM](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/vllm.md)
- [MLC-LLM](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/mlc-llm.md)
- [tiny-cuda-nn](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/tiny-cuda-nn.md)
- [Apache TVM](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/tvm.md)
- [PyTorch](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/pytorch.md)

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
