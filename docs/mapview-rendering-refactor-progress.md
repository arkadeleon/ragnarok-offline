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

**Phase 3 — Observable MapScene.**
Introduce `@Observable` on `MapScene` so SwiftUI views can react to `cameraState` changes without polling, and lay the groundwork for the camera follow target (`targetPosition`) field.

---

## Phase 2 — Extract Camera State and Input Intent

**Completed:** 2026-03-20
**Branch:** `feature/mapview-rendering-refactor`

### What was done

Consolidated the three scattered camera properties on `MapScene` (`horizontalAngle`, `verticalAngle`, `distance`) into a single `MapCameraState` value type. Defined typed intent types for input. Made `MapSceneARViewController` an input bridge instead of a camera owner. No rendering behavior changed.

Also fixed a pre-existing visionOS bug: `MapScene.distance` previously defaulted to `100` but was never observed on visionOS (the `WorldCameraComponent` was hard-coded to `radius = 15` in `setupWorldCamera` with no matching source of truth). `MapCameraState.default.distance` is now `15` on visionOS, so the two are in sync.

### New files

All new files live under `Packages/RagnarokGame/Sources/RagnarokGame/Engine/Runtime/`. This directory is new — the three files create it implicitly. No `Package.swift` changes were needed.

#### `MapCameraState.swift`

```swift
public struct MapCameraState: Sendable {
    public var azimuth: Float     // was horizontalAngle
    public var elevation: Float   // was verticalAngle
    public var distance: Float

    public static var `default`: MapCameraState {
        #if os(visionOS)
        MapCameraState(azimuth: 0, elevation: .pi / 12, distance: 15)
        #else
        MapCameraState(azimuth: 0, elevation: .pi / 4, distance: 100)
        #endif
    }
}
```

`Float.pi / 4` = 45° (iOS/macOS default elevation), `Float.pi / 12` = 15° (visionOS). No imports beyond Swift stdlib — avoids pulling SGLMath into the runtime layer. `targetPosition: SIMD3<Float>` is reserved for Phase 3+.

#### `MapInputIntent.swift`

```swift
import CoreGraphics

public struct MapInputIntent: Sendable {
    public var movementValue: CGPoint
}
```

Typed wrapper for thumbstick/joystick input. Makes the view-to-runtime contract explicit.

#### `MapInteractionIntent.swift`

```swift
import simd

public enum MapInteractionIntent: Sendable {
    case raycast(origin: SIMD3<Float>, direction: SIMD3<Float>)
}
```

Type stub for tap/click interactions. Not yet wired into `MapScene` — that happens in Phase 4.

### Modified files

#### `MapScene.swift`

- Removed `horizontalAngle`, `verticalAngle` (both platform variants), and `distance`
- Added `var cameraState: MapCameraState = .default` with a `didSet` that writes only changed fields to `WorldCameraComponent` (per-field guards avoid redundant RealityKit ECS writes during gestures that only move one axis)
- `setupWorldCamera` reads `cameraState.elevation` for the initial elevation
- `onMovementValueChanged` reads `cameraState.azimuth` for the rotation calculation
- Added `func handle(_ intent: MapInputIntent)` as the public input bridge; `onMovementValueChanged` stays `private`

The `didSet` on `cameraState` skips the elevation write on visionOS (`#if !os(visionOS)`) because `WorldCameraComponent.elevation` has no effect in an immersive space — the system controls pitch there.

#### `MapSceneARView.swift`

iOS and macOS blocks both:
- Renamed `horizontalAngle` → `baseAzimuth`, `verticalAngle` → `baseElevation`, `distance` → `baseDistance`. These instance vars are retained because UIKit/AppKit gesture handlers receive `.began` and `.changed` as separate calls with no way to pass state between them. The rename makes their role explicit: they are gesture-start baselines, not camera state.
- All gesture handlers read from and write to `scene.cameraState` directly
- `handleDoubleTap` (iOS) resets `scene.cameraState.azimuth = 0` and `scene.cameraState.elevation = .pi / 4`, then syncs the baselines
- Elevation clamps changed from `radians(15)...radians(60)` to `.pi / 12 ... .pi / 3` — same values, no SGLMath dependency
- Azimuth wrap changed from `radians(360)` to `.pi * 2` — same value, no SGLMath dependency
- Removed `import SGLMath` (no longer used)

#### `MapSceneRealityView.swift`

- Removed `@State private var distance: Float = 100`
- Added `@State private var baseDistance: Float = MapCameraState.default.distance` — seeds from the canonical default (15 on visionOS) rather than the hard-coded 100 that was wrong
- `MagnifyGesture.onChanged` writes to `scene.cameraState.distance`
- `MagnifyGesture.onEnded` snapshots `scene.cameraState.distance` back into `baseDistance`

#### `MapView.swift`

- Thumbstick timer callback changed from `scene.onMovementValueChanged(movementValue:)` to `scene.handle(MapInputIntent(movementValue:))`

### What did not change

- **Rendering behavior** — camera still orbits, zooms, and tilts identically on all platforms
- **`WorldCameraComponent` write path** — still driven by `didSet`; no new observation infrastructure
- **`GameSession` / `GameView`** — neither touches camera state
- **visionOS immersive space** — `MapScene` is loaded the same way; only the distance default is now correct

### Known temporary state

`onMovementValueChanged` is still internal to `MapScene`. It will remain so — `handle(_:)` is the stable public API. `MapInteractionIntent` is defined but not yet wired into `MapScene`; that happens in Phase 4.

### Next phase

**Phase 3 — Observable MapScene.**
Introduce `@Observable` on `MapScene` so SwiftUI views can react to `cameraState` changes without polling, and lay the groundwork for the camera follow target (`targetPosition`) field.
