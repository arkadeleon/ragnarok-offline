# RagnarokFileFormats vs roBrowserLegacy Alignment Table

This document compares the overlapping file-format implementations in `Packages/RagnarokFileFormats` against `../roBrowserLegacy` and identifies which formats should be aligned to the legacy behavior.

## Alignment Table

| Format | Legacy counterpart | Align to legacy? | Why |
|---|---|---:|---|
| `ACT` | `src/Loaders/Action.js` | No | `ACT.swift` is structurally very close. The main difference is naming and representation of per-action timing (`delay` in legacy vs `animationSpeed` and `frameInterval` in Swift), not the binary parsing itself. |
| `GAT` | `src/Loaders/Altitude.js` | Yes | `GAT.swift` keeps raw heights, while legacy normalizes them by `0.2`. Swift also collapses tile types into a small enum and defaults unknown values to `.walkable`, while legacy has a richer type table including weird negative and high-bit values plus water and snipable semantics. |
| `GND` | `src/Loaders/Ground.js` | Partial | The `BGRA` tile color byte issue is now aligned, including the downstream tile-color texture path. Remaining differences are the same major ones as before: legacy scales surface heights and water values by `1/5`, and it dedupes texture names and remaps texture indices while Swift still keeps the original texture table and raw values. |
| `RSM` | `src/Loaders/Model.js` | Yes | `RSM.swift` is one of the largest gaps. Legacy accepts `GRSX`, keeps version-dependent transform and runtime semantics for `2.2+`, and stores `2.3` texture animation groups. Swift currently drops that animation data and also interprets pre-`1.6` model-level keyframes differently from legacy. |
| `RSW` | `src/Loaders/World.js` | Partial | The main parser mismatches are now aligned: pre-`1.4` file ordering, the `2.7` extra skip block, the `2.6+` and `2.7` extra model bytes, and object-light color semantics. The remaining intentional difference is that Swift keeps water values unscaled, while legacy divides some water values by `5`. |
| `SPR` | `src/Loaders/Sprite.js` | Partial | `SPR.swift` is mostly aligned at binary parse level. The main gap is post-processing: legacy eagerly expands RLE frames and has important palette and RGBA conversion, orientation, power-of-two texture packing, magenta transparency, and alpha cleanup logic that Swift only partially mirrors. |
| `STR` | `src/Loaders/Str.js` | Partial | Field parsing in `STR.swift` is close, but Swift models the version as a `major.minor` pair from 2 bytes instead of validating the 32-bit `0x94` value like legacy. Swift also leaves texture names raw, while legacy resolves them under `data\\texture\\effect\\...`. |
| `RLE` | Inline in `src/Loaders/Sprite.js` | No | `RLE.swift` matches the legacy zero-run expansion logic. |
| `PAL` | Embedded in `src/Loaders/Sprite.js` | No direct target | Legacy has no standalone `.pal` loader; palette behavior is bundled into sprite rendering. |
| `IMF` | None | No direct target | No direct `roBrowserLegacy` counterpart exists. |
| `INI` | None in `src/Loaders/` | No direct target | No direct legacy file-format loader to align against. |

## Priority Order

If the goal is runtime compatibility with `roBrowserLegacy` behavior, the remaining recommended alignment order is:

1. `RSM`
2. `GAT`
3. `GND`
4. `SPR`
5. `STR`

`RSW` is mostly aligned already, with the current exception being the intentionally preserved water-value scale difference.

## Testing Note

`Packages/RagnarokFileFormats/Tests/RagnarokFileFormatsTests/RagnarokFileFormatsTests.swift` now includes focused regression coverage for the recent `GND` and `RSW` alignment work, including:

- `GND` surface tile color decoding from `BGRA`
- `RSW` pre-`1.4` file ordering
- `RSW` `2.7` skip and extra model bytes
- `RSW` object-light color decoding

Additional fixture-based tests are still recommended for the remaining formats, especially `RSM`, `GAT`, `SPR`, and `STR`.
