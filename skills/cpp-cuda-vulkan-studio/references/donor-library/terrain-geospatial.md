# Terrain, Geospatial, And 3D Tiles Donors

Use these donors for geospatial C++ runtimes, terrain tiles, 3D Tiles, quantized mesh, raster/vector
geodata, point clouds, coordinate transforms, and map/vector-tile rendering.

## Geospatial Runtime And Tile Formats

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Cesium Native](https://github.com/CesiumGS/cesium-native) | dependency-candidate | Apache-2.0 | Native C++ 3D Tiles traversal, terrain, raster overlays, ECEF/local transforms, large-world streaming. |
| [3D Tiles Specification](https://github.com/CesiumGS/3d-tiles) | dependency-candidate | Spec/reference; verify exact repo license | Tileset schema, bounding volumes, HLOD, screen-space error, implicit tiling, metadata, conformance. |
| [Quantized Mesh Specification](https://github.com/CesiumGS/quantized-mesh) | dependency-candidate | Spec/reference; verify exact repo license | Terrain payload semantics, quantized terrain tile decoding, terrain LOD. |
| [Cesium 3D Tiles Validator](https://github.com/CesiumGS/3d-tiles-validator) | dependency-candidate | Apache-2.0 | Validation expectations, test corpus design, and CLI validation flow references. |
| [Cesium 3D Tiles Tools](https://github.com/CesiumGS/3d-tiles-tools) | dependency-candidate | Apache-2.0 | Conversion pipeline ideas and tooling behavior; TypeScript reference-only for native C++. |

## Geospatial Data IO And Coordinates

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [GDAL](https://github.com/OSGeo/gdal) | dependency-candidate | MIT-style overall with bundled third-party terms | GeoTIFF/elevation rasters, vector data, metadata, reprojection-aware import/export. |
| [PROJ](https://github.com/OSGeo/PROJ) | dependency-candidate | MIT-style | CRS conversion, map projections, datum transforms, vertical/horizontal coordinate correctness. |
| [PDAL](https://github.com/PDAL/PDAL) | dependency-candidate | BSD-style | Point-cloud IO and processing, LAS/LAZ/EPT-style pipelines, filters, reprojection. |
| [LASzip](https://github.com/LASzip/LASzip) | safe-donor | Apache-2.0 | Narrow LAS/LAZ compression and decompression when PDAL is too heavy. |

## Map And Terrain Rendering References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [osgEarth](https://github.com/pelicanmapping/osgearth) | dependency-candidate | MIT | Terrain/map engine architecture, terrain layer composition, elevation/imagery layers, earth-view rendering. |
| [MapLibre Native](https://github.com/maplibre/maplibre-native) | dependency-candidate | BSD-2-Clause | C++ vector tile map rendering, style-driven maps, tile cache patterns, basemap overlays. |

## Deferred Or Narrow Routes

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Entwine](https://github.com/connormanning/entwine) | dependency-candidate | LGPL signal | EPT/massive point-cloud organization only when license constraints are acceptable. |
| [iTowns](https://github.com/iTowns/itowns) | dependency-candidate | CeCILL-B/MIT signal | Web geospatial visualization concepts; JavaScript/WebGL reference-only for native C++. |
| [GeographicLib](https://github.com/geographiclib/geographiclib) | safe-donor | MIT | Precise geodesics/geoid/magnetic/gravity calculations when CesiumGeospatial or PROJ are insufficient. |
| [S2 Geometry](https://github.com/google/s2geometry) | safe-donor | Apache-2.0 | Spherical indexing and geofence partitioning. |
| [H3](https://github.com/uber/h3) | safe-donor | Apache-2.0 | Hex-grid spatial indexing and aggregation. |

## Selection Notes

- Use Cesium Native first for native 3D Tiles/terrain runtime architecture.
- Use GDAL/PROJ/PDAL as import/conversion infrastructure; keep them out of tight render loops unless
  runtime IO is explicitly required.
- Keep terrain, CRS, raster/vector data, tiled mesh payloads, and renderer upload as separate design
  surfaces.
- Treat TypeScript validators/tools as reference-only for native C++ agents.
- Do not bundle geospatial datasets, DEMs, imagery, OSM extracts, or point-cloud samples without
  explicit provenance and data-license review.

## Deep Profiles

- [Terrain, Geospatial, And 3D Tiles](profiles/terrain-geospatial-3dtiles.md): read before designing 3D Tiles, terrain, CRS, geospatial IO, point-cloud, or vector-tile pipelines.
