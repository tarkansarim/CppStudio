## Donor References

When choosing external 3D, graphics, GPU, AI-runtime, or ML-kernel dependencies, read:

- `{{DONOR_ROOT}}/README.md`
- `{{DONOR_ROOT}}/selection-policy.md`
- `{{REFERENCE_ROOT}}/project-archetypes.md`

Use permissive donors for reusable code. Keep study-only references out of templates and shared
infrastructure.

Donors are domain references first, not lane locks. A donor's CUDA, Vulkan, OpenCL, DirectX, CPU, or
DCC backend signal describes upstream implementation context only. Keep the target project's selected
lane and dependency policy intact, and route backend-specific translation through `cpp-cuda-vulkan-studio`
plus the active CUDA or Vulkan companion skill.
