# Terrain, Geospatial, And 3D Tiles Profile

Sources: https://github.com/CesiumGS/cesium-native https://github.com/CesiumGS/3d-tiles https://github.com/CesiumGS/quantized-mesh https://github.com/CesiumGS/3d-tiles-validator https://github.com/CesiumGS/3d-tiles-tools https://github.com/OSGeo/gdal https://github.com/OSGeo/PROJ https://github.com/PDAL/PDAL https://github.com/LASzip/LASzip https://github.com/pelicanmapping/osgearth https://github.com/maplibre/maplibre-native
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic, native-cpu
License signal: Apache-2.0, MIT/BSD-style, and spec/reference sources; inspect each repo license,
third-party format drivers, data samples, and geospatial dataset terms at the exact revision used.

## Use First For

- Native 3D Tiles/terrain streaming, quantized terrain, CRS/geodesy correctness, GeoTIFF/vector/point
  cloud conversion, and map/vector-tile rendering.
- Large-world coordinate transforms, ECEF/local frame handoff, tile selection, LOD, screen-space error,
  and runtime streaming architecture.

## Integration Notes

- Prefer Cesium Native for native 3D Tiles and terrain runtime architecture.
- Use GDAL/PROJ/PDAL as conversion/import infrastructure unless runtime IO is explicitly required.
- Keep geospatial source data, coordinate transforms, tile payload formats, renderer upload, and cache
  invalidation as separate implementation surfaces.
- Treat validators and TypeScript tools as conformance references for native C++ agents.

## Validation Ideas

- Use tiny public fixtures for one tileset, one quantized terrain tile, one raster/elevation source,
  one point cloud, and one vector-tile style rule.
- Assert units, handedness, ellipsoid/ECEF/local transform correctness, and LOD selection separately.
