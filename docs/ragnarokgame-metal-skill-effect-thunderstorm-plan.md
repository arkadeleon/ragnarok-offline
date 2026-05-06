# Plan: First Skill Effect on Metal Backend — Thunder Storm (effect 30)

## Context

`RagnarokGame` 的 Metal 后端目前已经能渲染 ground、water、RSM 模型、sprite、damage effect，但还**没有任何 skill / STR effect** 渲染路径。`PACKET_ZC_NOTIFY_GROUNDSKILL` 在 `GameSession.swift:656` 被显式忽略 (`break`)。

我们要实现客户端从看到「魔法师对地面释放 Thunder Storm」的最小可见效果：当 `PACKET_ZC_NOTIFY_GROUNDSKILL`（SKID=21）到达时，在 `(xPos, yPos)` 处播放一次 `data/texture/effect/thunderstorm.str`，并播放 `data/wav/effect/magician_thunderstorm.wav`。这同时建立一套可复用的「skill effect → STR 资源 → Metal 渲染」管线，后续的命中特效（52）、`packet_skill_entry` 持久 ground unit 与 `SKILL_DISAPPEAR` 收尾会在后续 PR 中扩展。

依据 roBrowserLegacy `EffectTable.js:1400`（effect 30）：
```
{ type: 'STR', file: 'thunderstorm', wav: 'effect/magician_thunderstorm', attachedEntity: false }
```

范围仅 Metal 后端；Reality 后端本次不动（Reality 会无视 `state.skillEffects`，等 parity 跟进 PR 处理）。

## Approach

整体复用 damage effect 已经走通的模式：在 `MapSceneState` 上加 `mapEffects`，事件层把 packet 转成 `MapEffect`，Metal backend 每帧增量同步成 `STREffectRenderResource`，由 `MetalMapRenderer` 在 sprite pass 之后绘制。STR + 纹理沿用 `STRFileEffectView.loadSTRFile` 在 `STRFilePreviewView.swift:69` 已经验证过的加载流程，但通过 `ResourceManager`（GRF + 远端兜底），而不是仅 GRF。

## Implementation Steps

### 1. 新增技能 → 特效映射表（`Packages/RagnarokGame`）

新文件 `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime/SkillEffectTable.swift`：
- `enum SkillEffectTable { static func effectID(forSkillID: UInt16) -> Int? }`
- 第一版只填 `21 (mg_thunderstorm) → 30`。

新文件 `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime/EffectAssetTable.swift`：
- `struct EffectAssetSpec { var fileName: String; var soundName: String?; var attachedToTarget: Bool }`
- `enum EffectAssetTable { static func spec(forEffectID: Int) -> EffectAssetSpec? }`
- 第一版只填 entry 30：`{ "thunderstorm.str", "effect/magician_thunderstorm.wav", attachedToTarget: false }`。

注释里附 `// Source: roBrowserLegacy/src/DB/Effects/EffectTable.js entry 30`，便于后续补全。

### 2. 新增运行时模型 `MapEffect`

新文件 `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime/MapEffect.swift`，结构对齐 `MapDamageEffect.swift`：

```swift
public struct MapEffect: Identifiable, Sendable {
    public let id: UUID
    public let creationTime: ContinuousClock.Instant
    public let effectID: Int
    public let assetSpec: EffectAssetSpec
    public let gridPosition: SIMD2<Int>
    public let attachedObjectID: GameObjectID?  // v1 始终 nil（attachedEntity:false）

    func isExpired(at now: ContinuousClock.Instant) -> Bool { ... }
}
```

过期判定先用一个保守上限（如 5 秒），实际寿命由加载完 STR 后的 `frames.count / fps` 决定，会在 render resource 内做精确判定。

### 3. 在 `MapSceneState` 上挂载特效列表

修改 `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime/MapSceneState.swift:18` 附近：
- 新增 `public var mapEffects: [MapEffect] = []`
- 新增 `func pruneExpiredSkillEffects(now:)`，模仿 `pruneExpiredDamageEffects`。
- 在 `MapScene.applySnapshot()`（`MapScene.swift:152`）里同时调用 prune。

### 4. 接 Packet → 事件处理

修改 `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift:656`：
```swift
case let packet as PACKET_ZC_NOTIFY_GROUNDSKILL:
    mapScene?.onGroundSkillCast(packet)
```

在 `Packages/RagnarokGame/Sources/RagnarokGame/Core/MapScene+EventHandler.swift` 里新增：
```swift
func onGroundSkillCast(_ packet: PACKET_ZC_NOTIFY_GROUNDSKILL) {
    guard let effectID = SkillEffectTable.effectID(forSkillID: packet.SKID),
          let spec = EffectAssetTable.spec(forEffectID: effectID) else { return }
    let position = SIMD2<Int>(Int(packet.xPos), Int(packet.yPos))
    state.mapEffects.append(MapEffect(
        id: UUID(),
        creationTime: .now,
        effectID: effectID,
        assetSpec: spec,
        gridPosition: position,
        attachedObjectID: nil
    ))
    applySnapshot()
}
```

不在事件层直接放音，统一交给 backend（与 damage effect 的 sound 处理对齐）。

### 5. Metal 渲染资源：`STREffectRenderResource`

新文件 `Packages/RagnarokGame/Sources/RagnarokGame/Metal/Renderables/STREffectRenderResource.swift`，对标 `DamageEffectRenderResource.swift`：

- 持有：`id: UUID`、`creationTime`、`worldPosition: SIMD3<Float>`、`renderer: STREffectRenderer`（来自 `RagnarokMetalRendering`，`STREffectRenderer.swift:32`，已支持任意 STR + texture 字典）。
- 提供 `func render(atTime:, encoder:, matrices:)`：构造 model matrix（按 `worldPosition` 平移，必要时绕 Y 轴朝向相机；对地面特效 v1 先固定平面），然后调用 `STREffectRenderer.render(...)`。
- 提供 `var isExpired(at:) -> Bool`：用 `time = now - creationTime`、`frameCount / fps` 判断单次播完。

### 6. Effect 资源加载与缓存

在 `MetalRenderBackend.swift` 内新增私有 `EffectAssetLoader`（或一个内嵌方法），负责把 `EffectAssetSpec` → `(STREffect, [String: MTLTexture])`：
- 路径：`ResourcePath.effectDirectory.appending(spec.fileName)`（`ResourcePath+CommonPaths.swift:16`）。
- 通过 `resourceManager.contents(at:)` 读取 STR bytes，`STR(data:)` 解析，`STREffect(str:)` 生成动画帧。
- 遍历 `effect.frames[*].sprites[*].textureName`，从 STR 同目录加载 BMP，调用现有 `MetalTextureFactory` 生成 `MTLTexture`（参考 `STRFilePreviewView.swift:79–98` 但替换为 `resourceManager`）。
- 使用 `private var assetCache: [Int: Task<EffectAsset, Error>]` 按 `effectID` 缓存，避免重复加载。

### 7. Backend 帧同步：`updateSkillEffects`

修改 `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalRenderBackend.swift`（参考 `updateDamageEffects` `:201`）：
- 在 `MetalMapRenderer` 上加 `var mapEffectResources: [UUID: STREffectRenderResource] = [:]`。
- `syncFrameState` 增加调用 `updateSkillEffects(state.skillEffects, scene: scene)`。
- `updateSkillEffects` 流程：
  1. 用 `Set(state.skillEffects.map(\.id))` 过滤掉已结束的资源。
  2. 对新出现的 `MapEffect`：占位先记录为「加载中」，启动 `Task` 调用第 6 步的 loader。完成后回到 `@MainActor` 创建 `STREffectRenderResource(device:, effect:, textures:, worldPosition:)` 注入字典；若期间已过期则丢弃。
  3. 同步触发 `audioPlayer.playSound(named: spec.soundName)`（spec 已带文件名）— 仅在创建即时调用一次；与 STR 资源加载并行，不要等纹理加载完。

`worldPosition` 通过 `scene.mapGrid.worldPosition(for: gridPosition)` 计算（已被 `fallbackWorldPosition`、`updateCamera` 等用过）。

### 8. 渲染调用

修改 `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift:134` 之后，在 sprite pass 之后（`spriteRenderer.render(...)` 后）增加：
```swift
let now = ContinuousClock.now
let activeEffects = mapEffectResources.values
    .filter { !$0.isExpired(at: now) }
    .sorted { $0.creationTime < $1.creationTime }
for resource in activeEffects {
    resource.render(
        atTime: time,
        renderCommandEncoder: renderCommandEncoder,
        matrices: matrices
    )
}
```
透明 / 加色混合由 `STREffectRenderer` 内的 per-blend-key pipeline state 自行处理；无需新 pipeline。

### 9. 资源清理

`MetalRenderBackend.clearRenderResources()`（`:170`）里增加 `renderer.mapEffectResources.removeAll()` 与 effect asset cache 清空，避免切图后残留。

## Critical Files

要修改的文件：
- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift:656` — 接 packet。
- `Packages/RagnarokGame/Sources/RagnarokGame/Core/MapScene+EventHandler.swift` — 新增 `onGroundSkillCast`。
- `Packages/RagnarokGame/Sources/RagnarokGame/Core/Runtime/MapSceneState.swift` — 新增 `skillEffects` + prune。
- `Packages/RagnarokGame/Sources/RagnarokGame/Core/MapScene.swift:152` — `applySnapshot` 里 prune。
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalRenderBackend.swift` — sync + asset loader + clear。
- `Packages/RagnarokGame/Sources/RagnarokGame/Metal/MetalMapRenderer.swift` — 渲染调用 + 资源字典。

要新建的文件（全部在 `Packages/RagnarokGame` 内）：
- `Sources/RagnarokGame/Core/Runtime/SkillEffectTable.swift`
- `Sources/RagnarokGame/Core/Runtime/EffectAssetTable.swift`
- `Sources/RagnarokGame/Core/Runtime/MapEffect.swift`
- `Sources/RagnarokGame/Metal/Renderables/STREffectRenderResource.swift`

可复用而**不**修改的现成资产：
- `Packages/RagnarokRendering/Sources/RagnarokMetalRendering/STREffectRenderer.swift:32` — 已能渲染任意 STR + textures。
- `Packages/RagnarokRendering/Sources/RagnarokRenderAssets/STREffect/STREffect.swift` — STR → 帧化。
- `Packages/RagnarokFileFormats/Sources/RagnarokFileFormats/STR.swift` — STR 解析。
- `Packages/RagnarokResources/Sources/RagnarokResources/ResourcePath+CommonPaths.swift:16` — `effectDirectory`。
- `STRFilePreviewView.swift:69–101` — 纹理批量加载流程的参考实现。
- `MetalTextureFactory`（已用于 damage effect）。

## Verification

1. **本地包编译**：`swift build --package-path Packages/RagnarokGame` 与 `swift build --package-path Packages/RagnarokRenderers`，确认新类型与新调用全部编过。
2. **Xcode build**：在 Xcode 跑 `RagnarokOffline` scheme，目标 macOS（不必跑全 xctestplan，避免重）。
3. **端到端手测**：
   - 启动嵌入式服务器，登录到角色 → 进图。
   - 切到魔法师角色（或用 `@job 2` 等 GM 命令）。
   - 学/装好 Thunder Storm（SKID 21）。
   - 用现有 ground-targeted skill UI 对地面 cast → 期待画面在选定格子播放一次 `thunderstorm.str` 动画并响一次 `magician_thunderstorm.wav`。
   - 控制台不应出现「failed to load STR / texture」之类 warning（除非缺资源；缺资源时也只是不渲染、不应 crash）。
4. **效果文件单测预跑**：现有 `STRFilePreviewView` 已可独立预览 `thunderstorm.str`，先在 Files 浏览器里点开确认渲染效果是否符合预期，再回到游戏内验证。
5. **回归**：再跑一场普通近战攻击，确认 damage effect、sprite 渲染、音效未受影响。

## Out of Scope (后续 PR)

- 命中特效 effect 52（`windhit%d.str`，attachedEntity）— 等 `MapEffect.attachedObjectID` 通路验证后接。
- `packet_skill_entry` (2506) → 持久 ground unit 实体与对应 `SkillUnit` 视觉。
- `PACKET_ZC_SKILL_DISAPPEAR` (288) 显式收尾。
- Reality 后端的 STR effect 渲染。
- 完整 EffectTable / SkillEffect 数据迁移。
