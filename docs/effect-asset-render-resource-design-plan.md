# Effect Asset and Render Resource Design Plan

## Problem

`EffectTable` represents one effect as a list of `EffectDefinition` values. The current asset path treats `EffectAsset` as the loaded asset for one definition, so one logical effect can produce several separate per-definition assets and several separately-owned runtime effects.

That makes the naming and ownership misleading:

- `EffectAsset` sounds like the asset for an effect, but currently represents one effect definition.
- `EffectRenderResource` sounds like the render resource for an effect, but currently represents one renderable definition resource.
- `MetalMapEffect` is created once per definition, even though the game event spawned one effect reference.
- Runtime timing such as `creationTime` and combat/skill delay is mixed too closely with definition-level render setup.

The target model is:

- `EffectDefinition` describes one static visual component from `EffectTable`.
- `EffectAsset` represents loaded reusable component data produced from a whole ordered `[EffectDefinition]` array.
- `EffectRenderResource` represents render resources for one spawned effect instance.
- Component-level asset and render resources remain available internally, but they are no longer the top-level effect concepts.

## Naming

Use **Component** for the per-definition items.

Avoid **Part** because the public concept should remain a whole effect asset/resource. A component is the implementation unit produced from one `EffectDefinition`.

Recommended names:

- `EffectAsset`
- `EffectAssetComponent`
- `EffectRenderResource`
- `EffectRenderResourceComponent`

`EffectAssetComponent` should be the renamed form of the old per-definition `EffectAsset` enum. The primitive-specific loaded asset names and structures should remain as concrete component payloads.

## Data Model

### EffectAsset

`EffectAsset` is loaded once from an ordered `[EffectDefinition]` array. An `EffectReference` may be used by callers to find definitions, but the asset loader should not own reference resolution as part of the asset identity. After loading, `EffectAsset` should not retain the original definition array; definitions live inside the typed component payloads.

```swift
public struct EffectAsset: Sendable {
    public let components: [EffectAssetComponent]
}

public enum EffectAssetComponent: @unchecked Sendable {
    case `3D`(Effect3DAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)
}
```

The component is the old per-definition `EffectAsset`, renamed so the top-level `EffectAsset` can aggregate all loaded components without owning the source definition array. The primitive asset types keep the exact static definition they were loaded from:

```swift
public struct Effect3DAsset: Sendable {
    public struct Texture: Sendable {
        public let image: CGImage
        public let sizeFactor: SIMD2<Float>
    }

    public let definition: Effect3DDefinition
    public let textures: [Effect3DAsset.Texture]
}

public struct CylinderEffectAsset: Sendable {
    public let definition: CylinderEffectDefinition
    public let textureImage: CGImage
}

public struct SPREffectAsset: Sendable {
    public let definition: SPREffectDefinition
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: CGSize
}

public struct STREffectAsset {
    public let definition: STREffectDefinition
    public let effect: STREffect
    public let textureImages: [String : CGImage]
}
```

The primitive asset types own reusable loaded data plus their typed definition:

- images
- frame data
- STR effect data
- frame interval
- frame size
- texture source images
- typed effect definition

They should not own `creationTime`, runtime delay, world position, attached object IDs, or the whole `EffectReference`.

`EffectAssetComponent.definition` should expose the untyped `EffectDefinition` by wrapping the typed definition stored in the payload. This keeps sound scheduling, timing expansion, and renderer setup from needing to switch over component cases just to recover the authored definition.

### MetalMapEffect

`MetalMapEffect` is one runtime occurrence spawned by game events.

```swift
final class MetalMapEffect: Identifiable {
    let id: UUID
    let reference: EffectReference
    let creationTime: TimeInterval
    let delay: TimeInterval
    let gridPosition: SIMD2<Int>
    let attachedObjectID: GameObjectID?

    var renderResource: EffectRenderResource?
}
```

`creationTime` and the event-level `delay` belong here because they describe when this spawned occurrence starts. They are not static asset data and are not properties of an `EffectDefinition`.

Definition-level timing remains on `EffectDefinition` when it describes authored behavior inside the effect:

- duplicate interval
- `delayOffset`
- `delayLate`
- frame delay
- duration
- repeat/stops-at-end behavior

The final start time for a component resource is:

```swift
effect.creationTime + effect.delay + definition.delay(duplicateID: duplicateID)
```

### EffectRenderResource

`EffectRenderResource` represents the whole render resource for one spawned effect.

```swift
public final class EffectRenderResource {
    public let creationTime: TimeInterval
    public let delay: TimeInterval
    public let components: [EffectRenderResourceComponent]

    public init(
        device: any MTLDevice,
        asset: EffectAsset,
        worldPosition: SIMD3<Float>,
        spritePosition: SIMD3<Float>,
        creationTime: TimeInterval,
        delay: TimeInterval = 0
    )
}

public enum EffectRenderResourceComponent {
    case `3D`(Effect3DRenderResource)
    case cylinder(CylinderEffectRenderResource)
    case spr(SPREffectRenderResource)
    case str(STREffectRenderResource)
}
```

The current enum-style `EffectRenderResource` should become `EffectRenderResourceComponent`. The new top-level `EffectRenderResource` should provide the same aggregate conveniences that callers need:

```swift
public var rendersBeforeEntities: Bool
public var creationTime: TimeInterval
public func isExpired(atTime time: TimeInterval) -> Bool
```

`isExpired` should return true only when all component resources have expired.

## Loading Flow

`EffectAssetLoader` should load by definition array:

```swift
public func loadAsset(for definitions: [EffectDefinition]) async throws -> EffectAsset
```

Implementation outline:

```swift
let components = try await definitions.asyncMap { definition in
    try await loadComponent(for: definition)
}
return EffectAsset(components: components)
```

`EffectAssetStore` should expose:

```swift
func asset(for reference: EffectReference) async throws -> EffectAsset
```

It should cache top-level `EffectAsset` values by `EffectReference`. The store is responsible for resolving the reference through `EffectTable`, then passing the ordered resolved `[EffectDefinition]` array to `EffectAssetLoader`.

A second lower-level cache by primitive file or texture key is still useful to deduplicate shared decoded images and STR data. That cache should store the raw reusable resource payloads, not `EffectAsset` or `EffectAssetComponent`, because components include their typed definition.

## MetalMapScene Flow

`MetalMapScene` should create one `MetalMapEffect` for each spawned `EffectReference`.

Current flow:

```swift
for definition in EffectTable.definitions(for: effectReference) {
    let effect = MetalMapEffect(effectReference: effectReference, effectDefinition: definition, ...)
    addEffect(effect)
}
```

Target flow:

```swift
let effect = MetalMapEffect(
    reference: effectReference,
    creationTime: creationTime,
    delay: delay,
    gridPosition: gridPosition,
    attachedObjectID: attachedObjectID
)
addEffect(effect)
```

During loading:

```swift
let asset = try await effectAssetStore.asset(for: effect.reference)
let worldPosition = effect.attachedObjectID.flatMap { objects[$0]?.worldPosition } ?? effectWorldPosition
let spritePosition = SIMD3<Float>(
    Float(effect.gridPosition.x),
    Float(effect.gridPosition.y),
    effectWorldPosition.y
)
let renderResource = EffectRenderResource(
    device: renderer.device,
    asset: asset,
    worldPosition: worldPosition,
    spritePosition: spritePosition,
    creationTime: effect.creationTime,
    delay: effect.delay
)
effect.renderResource = renderResource
```

`RagnarokGame` is responsible for calculating runtime placement from map/object state. `EffectRenderResource` is responsible for expanding the loaded whole-effect asset and runtime timing into component render resources. `EffectViewerEffectRenderer` should use the same `EffectRenderResource(device:asset:worldPosition:spritePosition:creationTime:delay:)` initializer with zero positions.

Sound scheduling should iterate `asset.components` and use each component definition's `soundName`, delayed by `effect.delay`.

## Renderer Flow

`MetalMapRenderer` should store whole-effect resources:

```swift
var effectRenderResources: [EffectRenderResource] = []
```

`EffectRenderer` should render a whole `EffectRenderResource`:

```swift
public func render(
    resource: EffectRenderResource,
    atTime time: TimeInterval,
    renderCommandEncoder: any MTLRenderCommandEncoder,
    modelMatrix: simd_float4x4,
    viewMatrix: simd_float4x4,
    projectionMatrix: simd_float4x4,
    cameraAzimuth: Float
)
```

Internally, it iterates `resource.components` and dispatches to the primitive renderers.

This keeps callers from knowing whether one effect is made of one STR, several 3D billboards, a cylinder, or a mixture of primitives.

### STRFilePreviewRenderer

`STRFilePreviewRenderer` previews an arbitrary `.str` file from the file browser. It does not start from an `EffectReference`, does not have an `EffectTable` entry, and should not synthesize a fake reference just to fit the whole-effect asset/store path.

When the current enum-style `EffectRenderResource.str(...)` case becomes `EffectRenderResourceComponent.str(...)`, `STRFilePreviewRenderer` should migrate to the primitive STR path:

```swift
let resource = STREffectRenderResource(
    device: device,
    effect: effect,
    textureImages: textureImages,
    spritePosition: .zero,
    creationTime: CACurrentMediaTime()
)

strEffectRenderer.render(
    resource: resource,
    atTime: time,
    renderCommandEncoder: renderCommandEncoder,
    modelMatrix: modelMatrix,
    viewMatrix: viewMatrix,
    projectionMatrix: projectionMatrix
)
```

That means `STREffectRenderer` and `STREffectRenderResource` should remain usable directly by file-preview tooling. `STRFilePreviewRenderer` should not use `EffectAssetStore`, because that store is intentionally keyed by `EffectReference`.

If sharing dispatch code is valuable, add a small primitive/component rendering API such as `EffectRenderer.render(component: EffectRenderResourceComponent, ...)`. The existing whole-effect `render(resource: EffectRenderResource, ...)` API should remain the normal game/effect-viewer path.

## Layer Responsibilities

`RagnarokEffects`
: Static effect definitions, effect references, skill-effect mapping, and `EffectTable`.

`RagnarokRenderAssets`
: Load reusable asset data from resources. `EffectAssetStore` should expose the reference-keyed cache/API, resolve references into ordered definition arrays, and call `EffectAssetLoader`. `EffectAssetLoader` should load from caller-provided `[EffectDefinition]` arrays and should not retain the definition array after loading.

`RagnarokRenderers`
: Own Metal render resources and primitive renderers. The public effect render resource should represent a whole spawned effect. Primitive render resources are implementation details exposed only as needed.

`RagnarokGame`
: Own runtime effect occurrences in `MetalMapEffect`, including spawn time, external delay, attachment, grid/world placement, ownership by map objects, and effect lifecycle.

## Migration Steps

1. Rename the current per-definition `EffectAsset` enum to `EffectAssetComponent`.
2. Add the new top-level `EffectAsset` struct that owns only `components: [EffectAssetComponent]`.
3. Keep primitive asset structures as `Effect3DAsset`, `CylinderEffectAsset`, `SPREffectAsset`, and `STREffectAsset`, with their typed `definition` fields intact.
4. Change `EffectAssetLoader` to load `EffectAsset` from `[EffectDefinition]`.
5. Change `EffectAssetStore` to load and cache top-level `EffectAsset` values by `EffectReference`, resolving definitions before calling `EffectAssetLoader`.
6. Change `MetalMapEffect` to hold one `EffectReference` and one optional `EffectRenderResource`.
7. Rename the current `EffectRenderResource` enum to `EffectRenderResourceComponent`.
8. Add the new top-level `EffectRenderResource` that owns `[EffectRenderResourceComponent]`.
9. Move component expansion into an `EffectRenderResource` initializer or a small builder/factory.
10. Update `EffectRenderer` to accept a whole `EffectRenderResource`.
11. Update `MetalMapRenderer` and `EffectViewerEffectRenderer` to work with whole-effect resources.
12. Update `STRFilePreviewRenderer` to render `STREffectRenderResource` through `STREffectRenderer` directly, or through a primitive/component render helper, instead of wrapping it as a whole `EffectRenderResource`.

## Expected Result

After this refactor, the model reads naturally:

```text
EffectReference
  -> EffectAssetStore
     -> EffectDefinition[]
     -> EffectAsset
        -> EffectAssetComponent[]
           -> typed EffectDefinition + loaded component data

MetalMapEffect runtime occurrence
  + EffectAsset
  -> EffectRenderResource
     -> EffectRenderResourceComponent[]
```

The top-level names represent whole effects. Component names represent the per-definition implementation details. Runtime timing stays with spawned effects and render resources, while static authored timing stays with definitions.
