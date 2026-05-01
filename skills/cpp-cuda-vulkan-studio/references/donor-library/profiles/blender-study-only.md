# Blender Study-Only Donor Profile

Sources: https://projects.blender.org/blender/blender and https://docs.blender.org/manual/en/latest/modeling/geometry_nodes/hair/index.html  
Tier: `study-only`  
Backend signal: dcc-interchange, mixed-backend
License signal: Blender source is GPL-family; docs, bundled assets, add-ons, and example files have
their own notices. Use as workflow/UX reference only unless the target project explicitly accepts the
license and dependency shape.

## Use First For

- DCC UX, import/export workflow, geometry nodes, grooming workflows, animation authoring, and editor
  architecture concepts.
- Understanding artist-facing hair curve operations such as guide/follow, interpolate, trim, clump,
  attach, and surface deformation workflows.
- Studying how DCC tools expose scene, material, animation, and geometry-processing operations to users.

## First Upstream Areas To Inspect

- Official manual pages for the feature or workflow being studied.
- Source modules only for behavioral understanding after confirming GPL implications.
- Add-ons, sample files, brushes, node groups, and bundled assets as separate license surfaces.
- Import/export workflow docs before translating DCC behavior into runtime tools.

## Integration Notes

- Do not copy Blender code into reusable CppStudio templates or permissive project code.
- Convert observations into independent UX requirements, data-model notes, fixtures, or test behavior.
- Prefer OpenUSD, Alembic, MaterialX, OpenSubdiv, TressFX, or other permissive/dependency candidates for
  implementation patterns when they cover the needed behavior.
- Keep DCC authoring behavior separate from runtime renderer or simulation lanes.

## Validation Ideas

- Recreate tiny independent fixtures that capture the workflow concept without importing Blender assets.
- Document the user-facing behavior studied and the independent implementation target.
- Test groom/geometry concepts with project-owned curves, meshes, and materials.
- Confirm no GPL source or bundled asset was copied.

## Caveats

- Blender is a study-only source for this reusable package.
- Documentation and source behavior can inspire design, but code reuse requires explicit license approval.
- DCC workflows often rely on implicit scene context that runtime tools must model explicitly.
