# Project Chrono Donor Profile

Source: https://github.com/projectchrono/chrono  
Tier: `dependency-candidate`  
Backend signal: mixed-backend, native-cpu
License signal: BSD-3-Clause; inspect `LICENSE`, module licenses, optional third-party dependencies,
assets, data files, and build options at the exact revision used.

## Use First For

- Multibody dynamics and high-fidelity multiphysics simulation.
- Vehicle, terrain, granular media, FEA, fluid-solid interaction, robotics, and large simulation
  architecture.
- C++ simulation engine structure when fidelity is more important than dependency footprint.
- Benchmark and validation patterns for physically meaningful simulation scenarios.

## First Upstream Areas To Inspect

- Core Chrono modules for multibody dynamics, collision, constraints, and solver configuration.
- Vehicle, FEA, granular, and fluid modules only when those domains are in scope.
- Demos and validation examples for subsystem-specific setup and expected outputs.
- Build options and dependency docs before recommending Chrono as a target dependency.

## Integration Notes

- Treat Chrono as a deliberate dependency decision. Do not copy broad subsystem code into a target repo.
- Keep unit systems, coordinate conventions, solver configuration, collision models, and terrain/contact
  parameters explicit.
- Use smaller donors such as PositionBasedDynamics for compact interactive constraints when full
  multiphysics is unnecessary.
- Track optional modules and data files separately from core code.

## Validation Ideas

- Run a tiny pendulum or two-body fixture with expected position/energy tolerances.
- Validate unit conversion, gravity, timestep, solver, and contact settings in a minimal scene.
- Add subsystem fixtures only for modules the target project enables.
- Record CPU/GPU, solver, and optional module context with performance results.

## Caveats

- Chrono's strength is fidelity and breadth, which brings dependency and configuration cost.
- Optional modules can have separate dependencies and data surfaces.
- Simulation output may be sensitive to solver/timestep choices; tests should pin those choices.
