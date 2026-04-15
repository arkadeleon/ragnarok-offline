# Sprite System Redesign: Per-Part GPU Rendering

## Context

The current Metal rendering path bakes all entity parts (body, head, weapon, headgear, garment, shadow) into a single `CGImage` per animation key on the CPU, then uploads pre-baked `[MTLTexture]` frames to the GPU. This design:
- Wastes CPU cycles re-baking textures whenever equipment changes
- Cannot apply per-layer color tints in the GPU shader
- Prevents future per-part effects or shading

The goal is to mirror roBrowserLegacy's approach: each ACT.Layer becomes a separate GPU quad, rendered in correct z-order with its own texture and tint color. No CPU-side image compositing.

---

## Architecture Overview

### New types

| Type | File | Responsibility |
|------|------|----------------|
| `SpriteLayerDrawable` | `Metal/SpriteSnapshot.swift` | One GPU quad: pre-computed vertices + texture + world anchor |
| `SpritePartTextures` | `Metal/Assets/SpritePartTextures.swift` | Per-entity lazy MTLTexture cache keyed by (resource, spriteType, spriteIndex) |
| `SpriteFrameResolver` | `Metal/Assets/SpriteFrameResolver.swift` | Stateless: converts ComposedSprite + animation state → `[SpriteLayerDrawable]` |

### Removed types
- `SpriteAnimationFrames` — replaced by per-frame texture lookup in `SpritePartTextures`
- `SpriteDrawable` — replaced by `SpriteLayerDrawable`
- All animation baking logic in `SpriteAssetStore` (`animations`, `animationLoadTasks`, `ensureAnimationLoaded`, `prefetchAnimationKeys`, `makeAnimationFrames`, `resolvedAnimation`)

### Unchanged (RealityKit path still uses these)
- `SpriteRenderer.swift` (CPU baking)
- `SpriteRenderNode.swift`
- All `ComposedSprite*.swift` files

---

## Step-by-Step Implementation

### Step 1 — Update shaders (`SpriteShaderTypes.h`, `SpriteShaders.metal`)

**`SpriteShaderTypes.h`**: Add `vector_float4 color` to `SpriteVertex`:
```c
typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
    vector_float4 color;   // per-vertex RGBA tint [0..1]
} SpriteVertex;
```

**`SpriteShaders.metal`**: Add `float4 color` to `RasterizerData`, pass through in vertex shader, multiply in fragment shader:
```metal
out.color = float4(in.color);          // vertex shader
return texColor * in.color;            // fragment shader
```

---

### Step 2 — Thread `headDirection` into snapshot pipeline

`headDirection` is received from server but never stored in `MapObjectPresentationState`.

**`MapObjectPresentationState.swift`**: Add `var headDirection: CharacterHeadDirection = .lookForward`

**`MapScene.swift`** — `onMapObjectSpawned`: Store `CharacterHeadDirection(headDirection: headDirection)` in `presentation.headDirection`.  
**`MapScene.swift`** — `onMapObjectDirectionChanged`: Also update `presentation.headDirection`.

**`MapObjectPresentationSampler.swift`** — Add `headDirection: CharacterHeadDirection` to `PresentationSample`; forward from `presentation.headDirection`.

**`SpriteSnapshotBuilder.swift`** — Pass `presentationSample.headDirection` into the snapshot content.

**`SpriteSnapshot.swift`** — Add `headDirection: CharacterHeadDirection` to `SpriteAnimationKey` (or inline in `SpriteSnapshot.Content.mapObject`). Simplest: add it to the `.mapObject` case since it's not part of cache-key semantics in the new system.

---

### Step 3 — `SpriteLayerDrawable` (update `SpriteSnapshot.swift`)

Remove `SpriteAnimationFrames` and `SpriteDrawable`. Add:

```swift
struct SpriteLayerDrawable {
    let objectID: GameObjectID
    var vertices: [SpriteVertex]        // 6 vertices, pixel-space, pre-transformed
    var texture: any MTLTexture
    var worldPosition: SIMD3<Float>     // entity billboard anchor in world space
    var isVisible: Bool
}
```

---

### Step 4 — `SpritePartTextures.swift` (new file)

```swift
@MainActor
final class SpritePartTextures {
    struct Key: Hashable {
        let resourceID: ObjectIdentifier
        let spriteType: Int32
        let spriteIndex: Int32
    }

    private let device: any MTLDevice
    let composedSprite: ComposedSprite
    private var cache: [Key: (any MTLTexture)?] = [:]

    init(composedSprite: ComposedSprite, device: any MTLDevice) { ... }

    func texture(for layer: ACT.Layer, resource: SpriteResource, label: String) -> (any MTLTexture)? {
        // Check cache; on miss call resource.image(for: layer) → MetalTextureFactory.makeTexture
    }
}
```

`SpriteResource.image(for:)` is already thread-safe. `MetalTextureFactory.makeTexture` runs on MainActor (consistent with current practice).

---

### Step 5 — `SpriteFrameResolver.swift` (new file)

Stateless struct. Core method:

```swift
struct SpriteFrameResolver {
    func resolve(
        objectID: GameObjectID,
        composedSprite: ComposedSprite,
        animationKey: SpriteAnimationKey,
        headDirection: CharacterHeadDirection,
        elapsed: Duration,
        partTextures: SpritePartTextures,
        scriptContext: ScriptContext?,
        worldPosition: SIMD3<Float>,
        isVisible: Bool
    ) -> [SpriteLayerDrawable]
}
```

**Algorithm:**

1. Compute `actionIndex = animationKey.action.calculateActionIndex(forJobID:direction:)` — reuse existing method.

2. For each `part` in `composedSprite.parts`:

   a. **Frame range** — port from `SpriteRenderNode.actionNodeWithPart` lines 64–87:
   - Shadow: always actionIndex 0
   - Body idle/sit: single frame at `headDirection.rawValue`
   - Head/headgear idle/sit: `frameCount/3` frames at `headDirection.rawValue * (frameCount/3)`
   - Others: all frames

   b. **Frame index** — `min(Int(elapsed / frameInterval), range.count - 1)` for one-shot; `%` for repeating. `frameInterval = action.animationSpeed * 25 / 1000`.

   c. **Absolute frame index** = `range.lowerBound + localFrameIndex`

   d. **Z-index** — port `SpriteRenderer.zIndex(forComposedSprite:part:direction:actionIndex:frameIndex:scriptContext:)` verbatim.

   e. **Parent anchor offset** — port from `SpriteRenderNode.frameNodeWithPart` lines 99–115:
   ```
   offset = body.act.frame(actionIndex, parentFrameIndex).anchorPoints[0]
   offset -= part.sprite.act.frame(actionIndex, absFrameIndex).anchorPoints[0]
   ```
   For headgear idle: `parentFrameIndex = absFrameIndex / (frameCount/3)`

   f. For each `ACT.Layer` in `act.frame(actionIndex, absFrameIndex).layers`:
   - Skip if `layer.color.alpha == 0`
   - Get `(width, height)` from `resource.image(for: layer)` (nil → skip)
   - Get texture via `partTextures.texture(for: layer, resource: part.sprite, label:)`
   - Build 6 vertices via `makeVertices(...)` (see below)
   - Accumulate `(vertices, texture, zIndex)`

3. Sort all accumulated tuples by `zIndex` ascending.

4. Map each to `SpriteLayerDrawable`.

**Vertex generation** (Y-flip: sprite y-down → Metal y-up):

```swift
func makeVertices(layer: ACT.Layer, parentOffset: SIMD2<Int32>,
                  partScale: Float, width: Int, height: Int) -> [SpriteVertex] {
    let ps = partScale
    let cx  = Float(layer.offset.x + parentOffset.x) * ps
    let cy  = Float(layer.offset.y + parentOffset.y) * ps
    let halfW = Float(width)  * layer.scale.x * ps / 2
    let halfH = Float(height) * layer.scale.y * ps / 2
    let mirrorX: Float = layer.isMirrored == 0 ? 1 : -1
    let a = Float(layer.rotationAngle) * .pi / 180
    let (cosA, sinA) = (cos(a), sin(a))

    // Rotate in sprite space, then flip Y for Metal (y-up)
    func p(_ lx: Float, _ ly: Float) -> SIMD2<Float> {
        [lx * cosA - ly * sinA + cx,
        -(lx * sinA + ly * cosA + cy)]   // Y-flip
    }

    let color = SIMD4<Float>(layer.color) / 255  // normalize

    let tl = p(-halfW * mirrorX, -halfH)  // UV (0,0) — sprite top-left
    let tr = p(+halfW * mirrorX, -halfH)  // UV (1,0) — sprite top-right
    let bl = p(-halfW * mirrorX, +halfH)  // UV (0,1) — sprite bottom-left
    let br = p(+halfW * mirrorX, +halfH)  // UV (1,1) — sprite bottom-right

    return [
        SpriteVertex(position: tl, textureCoordinate: [0,0], color: color),
        SpriteVertex(position: tr, textureCoordinate: [1,0], color: color),
        SpriteVertex(position: bl, textureCoordinate: [0,1], color: color),
        SpriteVertex(position: tr, textureCoordinate: [1,0], color: color),
        SpriteVertex(position: br, textureCoordinate: [1,1], color: color),
        SpriteVertex(position: bl, textureCoordinate: [0,1], color: color),
    ]
}
```

UV convention: V=0 at sprite top (high in Metal world), V=1 at sprite bottom (low in Metal world). Mirroring is handled by flipping vertex X positions (not UVs).

---

### Step 6 — Redesign `SpriteAssetStore.swift`

**Keep:** entity lifecycle (add/remove), async `ComposedSprite` loading, task management.  
**Remove:** `ObjectAssetEntry.animations`, all animation baking tasks.  
**Add:** `ObjectAssetEntry.partTextures: SpritePartTextures?`

When `ComposedSprite` finishes loading, immediately create `SpritePartTextures(composedSprite: cs, device: device)`.

Add `cachedScriptContext: ScriptContext?` loaded once asynchronously on init/world load.

**`drawables(for:) -> [SpriteLayerDrawable]`** (return type changes from `[GameObjectID: SpriteDrawable]`):

```
1. For each snapshot, call SpriteFrameResolver.resolve(...)
2. Group results by entity with entity's worldPosition.z as depth key
3. Sort entities by depth (smaller z = further from camera = paint first)
4. Flatmap layers per entity (layers already sorted by z-index within entity)
5. Return flat [SpriteLayerDrawable]
```

Items: keep item loading but use `SpriteFrameResolver` with a minimal `ComposedSprite` wrapping the item `SpriteResource` (semantic `.main`).

---

### Step 7 — Update `MetalSpriteRenderer.swift`

Change signature: `drawables: [SpriteLayerDrawable]` (was `[GameObjectID: SpriteDrawable]`).

Loop body simplifies to: build vertex buffer from `drawable.vertices`, build uniform buffer with `drawable.worldPosition`, bind texture, `drawPrimitives(type: .triangle, vertexCount: 6)`.

No changes to shader uniforms struct or vertex/fragment shader billboard logic.

---

### Step 8 — Update `MapRuntimeRenderer.swift`

```swift
private(set) var spriteDrawables: [SpriteLayerDrawable] = []  // was [GameObjectID: SpriteDrawable]
```

In `updateObjects`: `spriteDrawables = spriteAssetStore?.drawables(for: snapshots) ?? []`

Any code that keyed into `spriteDrawables[objectID]` for world-position lookup (e.g., damage effect positioning) should switch to `spriteSnapshots[objectID]?.worldPosition` instead (already available).

---

## Critical Files

| File | Change |
|------|--------|
| `RagnarokShaders/Sprite/SpriteShaderTypes.h` | Add `color` to `SpriteVertex` |
| `RagnarokShaders/Sprite/SpriteShaders.metal` | Pass + apply color tint |
| `Core/Runtime/MapObjectPresentationState.swift` | Add `headDirection` field |
| `Core/MapScene.swift` | Store headDirection on spawn/direction change |
| `Core/Runtime/MapObjectPresentationSampler.swift` | Forward headDirection in sample |
| `Metal/SpriteSnapshot.swift` | Replace `SpriteAnimationFrames`+`SpriteDrawable` with `SpriteLayerDrawable` |
| `Metal/SpriteSnapshotBuilder.swift` | Include headDirection in snapshot |
| `Metal/Assets/SpritePartTextures.swift` | **New file** |
| `Metal/Assets/SpriteFrameResolver.swift` | **New file** |
| `Metal/Assets/SpriteAssetStore.swift` | Remove baking; add partTextures + resolver |
| `Metal/Renderers/MetalSpriteRenderer.swift` | Accept `[SpriteLayerDrawable]` |
| `Metal/MapRuntimeRenderer.swift` | Update type + drawables lookup |

---

## Verification

1. **Build after Step 1** — any `SpriteVertex` construction without `color` fails at compile time, making all breakage immediately visible.
2. **Items first** — simplest case (1 part, action 0, no anchors). Verify appearance matches old system.
3. **Monsters/NPCs** — single `.main` part. Verify billboard dimensions match.
4. **Player body+head** — verify head snaps correctly to body anchor (parentOffset non-zero).
5. **Player with weapon** — verify z-order flips north vs. south.
6. **Headgear idle** — change `headDirection` and verify hat follows head movement (doridori).
7. **One-shot animations** (hurt/die) — verify they stop at last frame, not wrap.
