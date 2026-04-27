# RagnarokFileFormats vs roBrowserLegacy Alignment Table

This document compares the overlapping file-format implementations in `Packages/RagnarokFileFormats` against `../roBrowserLegacy` and identifies which formats should be aligned to the legacy behavior.

## Alignment Table

| Format | Legacy counterpart | Align to legacy? | Why |
|---|---|---:|---|
| `ACT` | `src/Loaders/Action.js` | No | Binary parse is equivalent. `delay` in JS is already multiplied by 25 (ms); Swift stores it as `animationSpeed` (raw float) and computes `frameInterval = animationSpeed * 25 / 1000` downstream. The default for `version < 2.2` is equivalent (`delay = 150` in JS, `animationSpeed = 6` in Swift). Version is stored as a `FileFormatVersion(major:minor:)` pair in Swift vs a float scalar in JS; all comparisons resolve the same way. |
| `GAT` | `src/Loaders/Altitude.js` | Yes | Two unresolved gaps: (1) JS multiplies each height float by `0.2` before storing; Swift keeps raw values 5× larger. (2) JS maps raw int32 tile types (including `-1` and `0x80000000`–`0x80000009`) to a `WALKABLE`/`WATER`/`SNIPABLE` bitmask via a full type table; Swift uses a plain enum with 7 cases and defaults unknown values (including negative and high-bit values) to `.walkable`. |
| `GND` | `src/Loaders/Ground.js` | Partial | BGRA tile-color byte swap is aligned. Remaining gaps: (1) JS divides all four surface altitude floats by 5 — Swift stores raw values. (2) JS divides top-level `level` and `waveHeight` by 5 — Swift stores raw values (zone sub-entries are consistently raw in both). (3) JS deduplicates texture names and remaps tile `texture` indices to the compacted list — Swift keeps the original texture table and raw indices. (4) JS pre-computes atlas-relative UVs for all tile surfaces — Swift stores raw per-texture UVs. |
| `RSM` | `src/Loaders/Model.js` | Partial | Aligned: Swift accepts `GRSX`, parses pre-`1.6` top-level position keyframes, and preserves `2.3` texture animation groups. Remaining gaps: (1) `alpha` is stored as a raw `UInt8` in Swift vs normalized to `0–1` Float in JS. (2) The `2.2+` `flip: [1, -1, 1]` attribute that JS applies to the main node's instance matrix is absent in Swift. (3) Swift has no `main_node` concept (JS uses it for bounding-box computation and instance transform). (4) Top-level texture vs `additionalTextures` separation in pre-`2.2` and `2.2+` layouts is collapsed in Swift. (5) UV shrink (`* 0.98 + 0.01`) is now applied at render time in `RSMModelRenderAsset.swift` rather than at parse time — behavior aligns with JS output. |
| `RSW` | `src/Loaders/World.js` | Partial | Pre-`1.4` file ordering, the `2.7` extra skip block, `2.6+`/`2.7` extra model bytes, and object-light color semantics are all aligned. Remaining intentional difference: Swift keeps `water.level` and `water.waveHeight` unscaled; JS divides both by 5. Default ambient light for `version < 1.5` also differs (JS `[0, 0, 0]` vs Swift `0.3` per channel), but this only affects very old files. |
| `SPR` | `src/Loaders/Sprite.js` | Partial | Binary parse is equivalent. Post-processing gaps remain: (1) JS eagerly expands RLE-compressed indexed frames into full pixel arrays; Swift stores raw compressed bytes (separate `RLE.swift` exists but is not called at parse time). (2) JS `switchToRGBA()` converts indexed frames to RGBA via palette lookup with Y-flip and index-0 transparency; Swift defers this. (3) JS `compile()` packs sprites into power-of-two textures, handles magenta transparency for indexed frames, fixes premultiplied alpha, and Y-flips RGBA frames; Swift has no equivalent. (4) RGBA frames in the file are stored as `ABGR`; JS reorders to `RGBA` during `compile()`; Swift stores the raw channel order. |
| `STR` | `src/Loaders/Str.js` | Partial | Binary field layout is equivalent. Remaining differences: (1) JS reads the version field as a 32-bit integer and validates it equals `0x94`; Swift splits the same 4 bytes into `minor = 0x94`, `major = 0` and stores a `FileFormatVersion(major: 0, minor: 148)` without asserting the upper bytes. (2) JS prepends `data\texture\effect\` to every texture name in `STRLayer`; Swift stores raw 128-byte names. |
| `RLE` | Inline in `src/Loaders/Sprite.js` | No | `RLE.swift` matches the legacy zero-run expansion logic. |
| `PAL` | Embedded in `src/Loaders/Sprite.js` | No direct target | Legacy has no standalone `.pal` loader; palette behavior is bundled into sprite rendering. |
| `IMF` | None | No direct target | No direct `roBrowserLegacy` counterpart exists. |
| `INI` | None in `src/Loaders/` | No direct target | No direct legacy file-format loader to align against. |

## Priority Order

If the goal is runtime compatibility with `roBrowserLegacy` behavior, the remaining recommended alignment order is:

1. `RSM` — `alpha` normalization, `flip` for `2.2+`, `main_node` selection
2. `GAT` — height scale factor and tile-type bitmask table
3. `GND` — height and water scale, texture deduplication
4. `SPR` — eager RLE expansion, palette-to-RGBA conversion, compile step
5. `STR` — texture name path resolution

`RSW` is mostly aligned; the water-scale difference is intentional.

## Testing Note

There is currently no meaningful regression coverage in `Packages/RagnarokFileFormats/Tests/RagnarokFileFormatsTests/RagnarokFileFormatsTests.swift`.

Fixture-based tests are recommended for any future alignment work, especially `RSM`, `GAT`, `GND`, `SPR`, and `STR`.
