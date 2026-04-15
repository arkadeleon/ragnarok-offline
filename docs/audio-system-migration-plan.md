# Plan: Migrate Full Audio System — Attack, Hurt, Monster Walk Sounds

## Context

RagnarokGame currently only plays BGM in both the Metal and Reality backends. The roBrowserLegacy project (JS) has a complete sound effect system including attack sounds (by weapon type), hurt/damage sounds (by weapon type and job class), and per-ACT-frame sounds. This plan migrates attack and hurt sounds to RagnarokGame, with:

- **Metal backend**: Normal audio via `AVAudioEngine`, full volume (no attenuation)
- **Reality backend**: Spatial (3D) audio via RealityKit entity-attached audio
- Monster walking sounds are **deferred** (requires ACT frame-event infrastructure not yet present)

---

## Files to Create

### `Core/Sound/AVAudioPCMBuffer+Data.swift`
Shared helper for both backends. Extracts `audioBuffer(with:)` logic already in `RealityRenderBackend` into a reusable extension:
```swift
extension AVAudioPCMBuffer {
    static func load(from data: Data) -> AVAudioPCMBuffer? { ... }
}
```
Writes data to a temp file, reads via `AVAudioFile`, loads into `AVAudioPCMBuffer`.

### `Core/Sound/WeaponSoundTable.swift`
Port of `roBrowserLegacy/src/DB/Items/WeaponSoundTable.js`.  
`enum WeaponSoundTable` with `static func attackSoundFilenames(for: WeaponType) -> [String]`.  
Maps each `WeaponType` case to its attack WAV filename(s). Dual-wield entries (no Swift enum cases) are omitted.

### `Core/Sound/WeaponHitSoundTable.swift`
Port of `roBrowserLegacy/src/DB/Items/WeaponHitSoundTable.js`.  
`enum WeaponHitSoundTable` with `static func hitSoundFilenames(for: WeaponType) -> [String]`.

### `Core/Sound/JobHitSoundTable.swift`
Port of `roBrowserLegacy/src/DB/Jobs/JobHitSoundTable.js`.  
`enum JobHitSoundTable` with `static func hitSoundFilenames(forJob job: Int) -> [String]`.  
The JS file maps hundreds of JobID integers to three strings: `player_metal.wav`, `player_wooden_male.wav`, `player_clothes.wav`.  
Use a `switch` on the raw `Int` job value; default to `["player_clothes.wav"]`.

### `Metal/MetalRenderBackend+Sound.swift`
Extension on `MetalRenderBackend` implementing sound playback:
- Adds `AVAudioEngine` + pool of 8 `AVAudioPlayerNode`s (lazy setup on first call)
- Caches `AVAudioPCMBuffer` by filename in `[String: AVAudioPCMBuffer]`
- Overrides `playSound(_:at:)` — plays at full volume, no attenuation
- Loads WAV: `ResourcePath(components: ["data", "wav", filename])` → `resourceManager.contentsOfResource(at:)` → `AVAudioPCMBuffer.load(from:)`
- Round-robin node pool; schedules buffer on next node, plays if not already playing
- Cleans up pool/cache in `detach()`

### `Reality/RealityRenderBackend+Sound.swift`
Extension on `RealityRenderBackend` implementing spatial sound:
- Caches `AudioBufferResource` by filename in `[String: AudioBufferResource]`
- Overrides `playSound(_:at:)`:
  - Creates a transient `Entity`, positions it at `scene.position(for: gridPosition)`
  - Adds it under `rootEntity`, calls `entity.playAudio(resource)`
  - `Task.sleep(for: .seconds(3))` then `removeFromParent()` to clean up
- RealityKit spatializes based on entity world position vs. listener (camera) — no manual attenuation needed
- Loads WAV the same way as Metal but wraps in `AudioBufferResource(buffer:configuration:)` where `shouldLoop = false`
- Clears cache in `unload()`

---

## Files to Modify

### `Core/GameRenderBackend.swift`
Add the new protocol method with a default no-op extension:
```swift
func playSound(_ filename: String, at position: SIMD2<Int>)
```
Add `import simd` if not already transitively imported.

### `Core/MapScene.swift` — `onMapObjectActionPerformed`
After the existing presentation state update, insert two sound-dispatch blocks:

**Attack sound** (fired immediately):
```swift
if isAttackAction, let sourceObject = sourceMapObject {
    let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
    if let filename = WeaponSoundTable.attackSoundFilenames(for: weaponType).randomElement() {
        let sourcePosition = /* state.player.gridPosition or state.objects[sourceID]?.gridPosition */
        renderBackend?.playSound(filename, at: sourcePosition)
    }
}
```

**Hit sound** (fired after `sourceSpeed` ms delay, matching damage effect timing):
```swift
if isAttackAction, objectAction.damage > 0 {
    // Capture positions and hit filename at action-receipt time
    let hitFilename: String? = /* WeaponHitSoundTable lookup → fallback JobHitSoundTable */
    Task { @MainActor [weak self] in
        try? await Task.sleep(for: .milliseconds(objectAction.sourceSpeed))
        guard let self else { return }
        self.renderBackend?.playSound(hitFilename, at: targetPosition)
    }
}
```

Hit sound lookup logic:
- If target is a player (`CharacterJob(rawValue: targetObject.job).isPlayer`): use `JobHitSoundTable`
- Otherwise: try `WeaponHitSoundTable` for attacker's weapon; fall back to `JobHitSoundTable` for target job

### `Reality/RealityRenderBackend.swift`
- Remove or replace the existing private `audioBuffer(with:)` method to use the new `AVAudioPCMBuffer.load(from:)` extension.
- Add `sfxResourceCache` cleanup in `unload()`.

### `Metal/MetalRenderBackend.swift`
- Add `sfxBufferCache` cleanup in `detach()`.

---

## Monster Walking Sound — Deferred

ACT animation frames contain a `soundIndex` (into `ACT.sounds: [String]`) that triggers sounds at specific frames. The current rendering path discards these indices. The clean fix:

1. Expose `soundEvents: [(timeOffset: TimeInterval, filename: String)]` on `SpriteAnimation`
2. In Reality backend's `SpriteAnimationSystem`, schedule `Task.sleep` callbacks for each event
3. In Metal backend, fire sounds during the walk timeline

This is a **follow-up task** after attack/hurt sounds are working.

---

## Implementation Order (resolves dependencies)

1. `AVAudioPCMBuffer+Data.swift`
2. `WeaponSoundTable.swift`, `WeaponHitSoundTable.swift`, `JobHitSoundTable.swift` (in parallel)
3. `GameRenderBackend.swift` — add protocol method
4. `Metal/MetalRenderBackend+Sound.swift`
5. `Reality/RealityRenderBackend+Sound.swift`
6. `MapScene.swift` — add sound dispatch in `onMapObjectActionPerformed`
7. Cleanup additions to `MetalRenderBackend.detach()` and `RealityRenderBackend.unload()`

---

## Verification

1. Build project — no compilation errors
2. In Metal mode: attack a monster → hear attack swing sound; monster attacks player → hear impact sound at full volume
3. In Reality (visionOS) mode: same events produce 3D-positioned audio that pans and attenuates as you move your head
4. In Reality mode: walk away from a combat event → sound attenuates naturally via RealityKit's spatial audio
