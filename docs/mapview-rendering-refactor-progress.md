# MapView Rendering Refactor Progress

## Phase 1 — Render-Engine Entry Point and Type Boundaries

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Introduced the abstraction layer that lets `MapView` hand off rendering to an engine-specific host without knowing about concrete render views. No rendering behavior changed — `MapRenderHost` still routes every request to `MapSceneARView` (RealityKit/ARView) on iOS and macOS. The visionOS path continues to open an immersive space and show a placeholder.

### New files

All new files live under `Packages/RagnarokGame/Sources/RagnarokGame/Client/Rendering/`.

#### `MapRenderEngine.swift`

```swift
public enum MapRenderEngine: CaseIterable, Sendable {
    case metal
    case realityKit
}
```

Two cases only. `CaseIterable` is there for a future settings UI picker. There is no `.automatic` case — platform default is expressed through `MapRenderConfiguration.default` instead.

#### `MapRenderConfiguration.swift`

```swift
public struct MapRenderConfiguration: Sendable {
    public static var `default`: MapRenderConfiguration {
        #if os(visionOS)
        MapRenderConfiguration(engine: .realityKit)
        #else
        MapRenderConfiguration(engine: .metal)
        #endif
    }

    public var engine: MapRenderEngine

    public init(engine: MapRenderEngine) { ... }
}
```

`default` is a computed `static var` so the `#if os(visionOS)` check happens at each call site rather than at module initialisation time. This is the single platform-dispatch point — nothing else in the stack needs to import `#if os(visionOS)` to pick an engine.

#### `MapRenderingSurface.swift`

Marker protocol (`View` subtype) that concrete surface views will conform to in later phases. Has no requirements yet.

#### `MapRenderHost.swift`

```swift
struct MapRenderHost: View {
    var scene: MapScene
    var configuration: MapRenderConfiguration

    #if !os(visionOS)
    var onSceneUpdate: (ARView) -> Void
    #endif

    var body: some View {
        switch configuration.engine {
        case .metal:    metalSurface
        case .realityKit: realityKitSurface
        }
    }
    ...
}
```

Pure routing view — no `@State`, no `AnyView`. Both `metalSurface` and `realityKitSurface` currently resolve to `MapSceneARView` on iOS/macOS and a `Text("Game")` placeholder on visionOS. The Metal branch will be rewired in Phase 9.

`import RealityKit` is retained because `onSceneUpdate: (ARView) -> Void` is still needed until Phase 5 removes the `ARView.project`-based overlay path.

### Modified files

#### `MapView.swift`

- Added `var renderConfiguration: MapRenderConfiguration = .default`
- Replaced the inline `#if os(visionOS) / MapSceneARView` block with `MapRenderHost(scene:configuration:onSceneUpdate:)`
- `updateOverlay(arView:)` and `import RealityKit` are untouched — still needed for HUD projection

#### `GameView.swift`

- Added `public var renderConfiguration: MapRenderConfiguration = .default`
- Added `renderConfiguration` parameter to `init` (default `.default` so all existing call sites compile without changes)
- Passes `renderConfiguration` down to `MapView`

### What did not change

- **`SettingsModel`** — engine selection is not exposed in the settings UI yet
- **`GameClientView` / `macOSApp`** — both call `GameView` without a `renderConfiguration` argument and pick up `.default` automatically
- **`GameSession`** — holds `MapScene` only; engine selection is a view-layer concern
- **Runtime behavior** — map loads, camera, thumbstick, overlays, and visionOS immersive space are all identical to before

### Known temporary state

`MapRenderHost` routes `.metal` to `MapSceneARView` on iOS/macOS. This is intentional scaffolding. The Metal backend (`MTKView`-based) will replace this in Phase 9. Until then, selecting `.metal` or `.realityKit` produces the same result on iOS/macOS.

### Next phase

**Phase 2 — Extract Camera State and Input Intent.**
Move `horizontalAngle`, `verticalAngle`, and `distance` out of `MapSceneARViewController` into a shared `MapCameraState` on `MapScene`, so both the future Metal backend and the existing RealityKit path read from the same source of truth.
