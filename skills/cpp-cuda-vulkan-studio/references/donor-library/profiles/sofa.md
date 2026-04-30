# SOFA Donor Profile

Source: https://github.com/sofa-framework/sofa  
Tier: `dependency-candidate`  
License signal: LGPL-2.1 for the main framework with plugin/module license variation; inspect `LICENSE`,
plugin licenses, bundled data, optional dependencies, and scene assets at the exact revision used.

## Use First For

- Medical, robotics, deformable, and multiphysics simulation architecture.
- Scene graph and component-style simulation organization.
- Constraint, collision, solver, and visualization architecture references for complex simulation tools.
- Understanding plugin boundaries in a large simulation framework.

## First Upstream Areas To Inspect

- Core framework and component modules for scene graph, simulation loop, collision, constraints, and
  solver organization.
- Plugin directories and module metadata before adopting any subsystem.
- Example scenes only after checking asset/data provenance.
- Build and packaging docs for optional dependencies and plugin availability.

## Integration Notes

- Treat SOFA primarily as an architecture/reference donor unless the target project explicitly accepts
  LGPL/plugin dependency constraints.
- Keep target project simulation data models independent from SOFA scene files unless SOFA is a chosen
  runtime dependency.
- Document every enabled plugin/module and its license.
- Use narrower donors for compact cloth/soft-body work when SOFA's framework scope is unnecessary.

## Validation Ideas

- Validate minimal scene loading, timestep stepping, solver selection, and collision setup when SOFA is a
  real dependency.
- Use tiny deformable/collision scenes with expected qualitative and numeric checks.
- Test plugin availability and missing-plugin errors explicitly.
- Keep representative medical/robotic datasets out of reusable templates unless provenance is clear.

## Caveats

- LGPL/GPL/plugin mix needs exact module-level review before use in reusable or proprietary-compatible
  projects.
- Large framework architecture can overwhelm small tools.
- Example scenes and datasets may have different provenance from framework code.
