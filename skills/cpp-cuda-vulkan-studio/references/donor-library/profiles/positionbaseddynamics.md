# PositionBasedDynamics Donor Profile

Source: https://github.com/InteractiveComputerGraphics/PositionBasedDynamics  
Tier: `safe-donor`  
Backend signal: native-cpu, api-agnostic
License signal: MIT; inspect `LICENSE`, examples, dependencies, demo assets, and Python bindings at the
exact revision used.

## Use First For

- C++ position-based dynamics and XPBD constraints.
- Interactive cloth, deformables, rods, rigid bodies, fluids, and soft-body simulation concepts.
- Constraint solver organization that is small enough to study or adapt.
- Collision and signed-distance-field concepts for interactive simulation fixtures.

## First Upstream Areas To Inspect

- Core simulation and constraint code for solver order, stiffness/compliance, and constraint projection.
- Demo scenes for constraint combinations and boundary behavior.
- Tests/examples for rods, cloth, deformable solids, rigid bodies, and fluids.
- Build/dependency files before adopting demos or bindings.

## Integration Notes

- Start with one constraint family and a tiny deterministic fixture before combining systems.
- Keep solver state, collision representation, renderer handoff, and asset import separated.
- Preserve timestep, iteration count, compliance/stiffness, mass, and damping policy in tests.
- Use it as a native C++ donor for compact interactive simulation; use Chrono/SOFA for heavier
  multiphysics architecture.

## Validation Ideas

- Test a two-particle distance constraint, a pinned cloth patch, and a simple collision case.
- Compare constraint residuals before and after solver iterations.
- Test zero mass, fixed particles, degenerate triangles, and large timestep behavior.
- Add small visual/offscreen smoke frames only after numeric fixtures pass.

## Caveats

- Demo scenes are not a replacement for production asset/solver policy.
- Constraint solvers are sensitive to timestep and iteration policy; document those choices.
- Python bindings and sample assets may add dependencies beyond the core C++ library.
