# RagnarokGame Metal vs roBrowserLegacy Alignment Plan

## Scope

This document compares the current Metal map-rendering path in `Packages/RagnarokGame` against `../roBrowserLegacy` and defines the remaining alignment work for behavior that is already partially implemented in Metal.

This plan is intentionally narrower than a full renderer rewrite.

Included:

- water rendering behavior
- entity shadow rendering behavior
- sprite depth and layer ordering behavior
- damage digit depth behavior
- animated RSM map-model support

Explicitly out of scope:

- fog parity
- env lighting parity
- legacy-only systems that do not exist in the current gameplay/runtime surface
- forcing Metal to copy the exact internal architecture of roBrowserLegacy

## Goal

The goal is not pixel-perfect reproduction of every legacy artifact.

The goal is to remove the remaining high-visibility behavioral mismatches where the current Metal backend renders the right feature category, but still renders it with the wrong ordering, depth behavior, animation inputs, or scene semantics.

## Confirmed Gaps

### 1. Water is not behaviorally aligned — partially fixed

The resource/data path is now aligned (Phase 1 done):

- ~~the resource path does not currently preserve legacy water parameters such as animated frame sequence, wave controls, and water-type-driven opacity~~

Still open (Phase 2):

- the render order is wrong relative to sprites and damage digits
- the depth-write behavior is wrong for the intended "water stays behind billboard content" result

Result:

- water can still occlude content that should visually stay in front
- water animation and opacity now match the source map data

Priority: P1

### 2. Entity shadows are not aligned

Current Metal still treats shadow art as a normal billboarded sprite layer.

Legacy behavior is materially different:

- shadow is rendered in its own pass
- shadow is anchored to ground/GAT height, not to the body billboard anchor
- shadow color is modulated by the map shadow factor
- shadow does not participate in the same layering rules as the body/head/gear stack

Result:

- foot-contact looks wrong
- shadow darkness is too uniform
- sloped terrain and ground contact read incorrectly

Priority: P1

### 3. Sprite depth policy is still simplified relative to legacy

Current Metal sorts sprite groups by presentation depth and renders them with one shared depth policy.

Legacy uses a more specific split:

- PC / MERC main sprite pass writes depth
- non-player entities use depth test without depth write
- shadow/cart-shadow/body/head/weapon/shield/garment layers do not all share the same pass semantics
- intra-entity ordering relies on `zIndex`, but inter-entity occlusion still depends on selective depth write

Result:

- crossing player characters can occlude each other incorrectly
- mixed PC / NPC / mob compositions do not always match legacy layering
- some body-part stacks are correct in isolation but still wrong in scene composition

Priority: P1

### 4. Damage digits still differ in depth behavior

Metal already renders damage digits, but not with legacy depth semantics.

Legacy damage digits are effectively overlay-like world billboards:

- no depth test
- no depth write
- depth correction disabled

Current Metal still uses normal depth testing.

Result:

- digits can be clipped or hidden by world geometry and sprite content that should not suppress them

Priority: P2

### 5. Animated RSM map models are still missing

The current Metal map-model path only handles static RSM meshes.

Legacy has a distinct animated-model path for RSM content with node keyframes.

Result:

- maps with animated RSM content still lose visible scene motion in Metal

Priority: P2

## Recommended Plan

### Phase 1: Fix the water data path first — DONE

Completed changes:

- added `GND.Water` and `GND.Water.Zone` parsing for GND v1.8+/v1.9+
- introduced `WaterParameters` struct that resolves GND v1.8+ water override over RSW water
- replaced `ResourceManager.waterTextureImage()` (single atlas) with `waterTextureImages(type:)` (32 per-frame images loaded by water type)
- `WaterRenderAsset` now carries `WaterParameters` and per-frame `[CGImage]`
- `WaterRenderResource` reads all parameters from the asset instead of using hardcoded defaults
- opacity derived from water type: type 4/6 → 1.0, otherwise → 0.8
- fixed `waterOffset` formula in `WaterRenderer` to match legacy: `(frame * waveSpeed) % 360 - 180`
- updated `WaterEntity` (RealityKit) to build its own atlas from per-frame images and use `WaterParameters.opacity`

Remaining water render-order and depth issues are addressed in Phase 2.

### Phase 2: Align the water render pass

Objective:

- make water sit in the scene like legacy water

Changes:

- move the water pass behind sprite and pre-overlay content to match the legacy frame order
- change the Metal water depth state to:
  - depth test enabled
  - depth write disabled
- keep alpha blending behavior aligned with the existing sprite-style blending path
- verify that the final ordering is:
  - static world
  - entities
  - water
  - damage / later overlay-like passes

Likely files:

- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift`
- `Packages/RagnarokRendering/Sources/RagnarokMetalRendering/WaterRenderer.swift`

Acceptance:

- water no longer occludes billboard content incorrectly
- maps with shallow water read like legacy during camera rotation and zoom

### Phase 3: Split shadow rendering out of the normal sprite pass

Objective:

- stop treating ground shadows as ordinary body-part billboards

Changes:

- represent shadow layers separately from normal sprite drawables
- add map-shadow sampling support on the Swift side
- expose enough ground/shadow data from render assets to compute a legacy-style shadow factor
- render shadow in its own pass with:
  - ground-aligned anchor
  - depth test enabled
  - depth write disabled
  - no body-style billboard anchoring
- keep body/head/gear rendering unchanged until the dedicated shadow pass is stable

Likely files:

- `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/Ground/GroundRenderAsset.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Sprite/SpriteFrameResolver.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Sprite/SpriteAssetStore.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Renderers/MetalSpriteRenderer.swift`
- new dedicated shadow renderer/resource types if needed

Acceptance:

- entity shadows sit on terrain instead of floating with the body anchor
- shadow darkness varies with the map shadow field
- character ground contact looks stable on flat and sloped cells

### Phase 4: Align selective sprite depth behavior

Objective:

- reproduce the legacy distinction between player-like and non-player-like sprite depth participation

Changes:

- split Metal sprite rendering into at least two depth policies:
  - player / mercenary main pass with depth write
  - non-player pass with depth test only
- preserve per-entity layer ordering using existing `zIndex` logic where it is already correct
- explicitly keep shadow and other special layers out of the main body pass
- verify that selective depth write solves cross-character occlusion without breaking intra-entity ordering

Likely files:

- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Sprite/SpriteAssetStore.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Sprite/SpriteFrameResolver.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Renderers/MetalSpriteRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift`

Acceptance:

- crossing player characters occlude each other more like legacy
- non-player entities no longer inherit player-only depth behavior
- body/head/weapon/shield/cart/garment layering remains stable after the split

### Phase 5: Align damage-digit depth semantics

Objective:

- make already-implemented damage digits behave like legacy overlay billboards

Changes:

- switch damage digits to a depth-disabled pass
- keep depth write disabled
- keep the existing timing and texture-generation path
- validate that `damage` and `MISS` remain readable over water, terrain, and sprites

Likely files:

- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Renderers/MetalDamageEffectRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift`

Acceptance:

- damage digits are no longer hidden by world geometry
- combat readability matches the legacy intent even if animation style remains slightly different

### Phase 6: Add animated RSM support

Objective:

- close the remaining map-model feature gap that is still missing from Metal

Changes:

- detect animated RSM content during asset loading
- add a dedicated animated-model render asset and render resource path
- evaluate node keyframes per frame on the Metal side
- preserve existing static RSM performance for maps without animated content

Likely files:

- `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/WorldAssetLoader.swift`
- `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/RSMModel/*`
- `Packages/RagnarokRendering/Sources/RagnarokMetalRendering/RSMModelRenderer.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift`

Acceptance:

- animated map models visibly animate in Metal on affected maps
- static-model rendering remains unchanged on unaffected maps

## Validation Plan

Validation should be scene-based, not only unit-based.

Minimum checks:

- one map with visible water
- one map with strong ground shadow contrast
- one crowded player / NPC / mob composition to verify selective depth write
- one combat scenario with repeated damage and `MISS`
- one map known to contain animated RSM content

Per phase:

- capture side-by-side screenshots or short recordings against `roBrowserLegacy`
- record whether the remaining difference is:
  - fixed
  - intentionally accepted
  - blocked by missing runtime data

## Recommended Execution Order

1. Phase 1: water data path
2. Phase 2: water pass ordering/depth
3. Phase 3: shadow split
4. Phase 4: selective sprite depth behavior
5. Phase 5: damage-digit depth semantics
6. Phase 6: animated RSM support

Reasoning:

- water and shadows are the highest-visibility mismatches
- sprite depth policy is easier to validate after special-case shadow behavior is removed from the generic sprite path
- damage digits are already functionally present, so their fidelity fix can follow the scene-depth cleanup
- animated RSM support is a larger isolated feature and should not block the earlier rendering-correctness work
