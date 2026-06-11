# Feature Gap Implementation Notes — RagnarokGame (Metal) vs roBrowserLegacy

## Scope

Companion to `ragnarokgame-metal-robrowserlegacy-feature-gap-tracker.md`. For each gap in the tracker, this document records **how to implement it concretely**: the roBrowserLegacy reference (files and packets), the implementation approach mapped onto this codebase's architecture, and the files/types to touch. Section numbers match the tracker.

Items already planned in detail elsewhere (water pass, entity shadows, sprite depth, damage-digit depth, animated RSM) are not repeated; see `ragnarokgame-metal-robrowserlegacy-alignment-plan.md`.

---

## 0. How features are wired in this codebase (pattern primer)

Every gameplay-system gap below follows the same skeleton. Established by the existing inventory/skill/NPC-dialog implementations:

1. **Receive**: add a `case let packet as PACKET_ZC_…` to `GameSession.handleMapPacket` (`Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift:686`). State updates go to an `@Observable @MainActor` model in `Core/Models/` (pattern: `Inventory`, `SkillList`, `CharacterStatus`, `NPCDialog`, `MessageCenter`). Presentation goes to `mapScene?.onXxx(…)` implemented in `Metal/MetalMapScene+EventHandler.swift` (and mirrored later in `Reality/RealityMapScene+EventHandler.swift`).
2. **Send**: add a `func` on `GameSession` that builds `PacketFactory.CZ_…` and calls `mapClient?.sendPacket(…)` (pattern: `requestMove`, `useItem`, `talkToNPC`).
3. **UI**: a SwiftUI view in `UI/` built from the `GameWindow`/`GameTitleBar`/`GameButton`/`GameProgressBar` kit, reading the observable model; wired into `GameView`/`MetalOverlayView`. All UI strings in English.
4. **Screen-anchored elements** (text, bars, bubbles): do **not** copy legacy's canvas-texture-in-GL approach. The codebase already projects world positions to screen and renders SwiftUI on top (`MetalGaugeOverlay` in `MetalOverlayState` + `MetalOverlayView`). Name labels, cast bars, chat bubbles, signboards, and announce banners should all be new overlay item kinds in `MetalOverlayState`.
5. **World-anchored drawables** (effects, ground areas, particles): a render resource in `Metal/Renderables/` plus a renderer in `Metal/Renderers/` (patterns: `CombatTextRenderResource`, `STREffectRenderResource`, `TileSelectorRenderResource`), registered in `MetalMapRenderer`'s frame loop.
6. **Sprite attachments** (emotion, status marks, aura): per-object attachment list on `MetalMapObject`, resolved through `SpriteAssetStore`/`SpriteFrameResolver` like body parts but with an independent ACT/SPR file and frame clock.
7. **Client assets** come through `ResourceManager` (`RagnarokResources`) from GRF — same path strings as legacy (`Client.loadFile` calls), e.g. minimap bitmaps under `texture/유저인터페이스/map/`, effect sprites under `sprite/이팩트/`.

### Packet availability

`Packages/RagnarokPackets/Sources/RagnarokPackets/Generated/packets.swift` currently has 632 packet structs generated from swift-rathena. Spot checks for this document:

- **Present**: `ZC_EMOTION`, `CZ_REQ_EMOTION`, `ZC_USESKILL_ACK`, `ZC_ACK_REQNAMEALL`, `ZC_COMPASS`, `ZC_BROADCAST`/`2`, `ZC_WHISPER`/`CZ` whisper family, `ZC_ADD_ITEM_TO_STORE`/`ZC_DELETE_ITEM_FROM_STORE`/`ZC_NOTIFY_STOREITEM_COUNTINFO`, `CZ_SHORTCUT_KEY_CHANGE1/2`, `CZ_MAKE_GROUP`/`CZ_REQ_JOIN_GROUP`/`ZC_ACK_MAKE_GROUP`, quest CZ packets, homunculus/mercenary skill lists, buying-store family.
- **Missing (confirmed)**: `ZC_SKILL_ENTRY` (ground skill units), `ZC_MSG_STATE_CHANGE` (EFST status icons), `ZC_STORE_NORMAL_ITEMLIST`/`ZC_STORE_EQUIPMENT_ITEMLIST` (storage opening lists), `ZC_SHORTCUT_KEY_LIST`.

Rule: before implementing a system, grep `packets.swift` for the ZC/CZ names listed in its section. If absent, add the struct on the swift-rathena side, run `./generate.sh`, and only then write the Swift handling (per CLAUDE.md, never hand-edit generated output).

---

## 1. Map Rendering

### 1.1 Clouds (outdoor sky)

- **Legacy**: `Renderer/Effects/CloudWeatherEffect.js` + per-map weather table (`DB/Map/`). Billboard particles using `data/texture/effect/cloud*.tga`, randomized positions in a band above the ground, slow drift plus alpha pulse-in/out; recycled when behind the camera.
- **Approach**: a `CloudRenderResource` holding N instanced billboard quads (position, phase, scale per instance) and a renderer drawing them with additive-over blending after the skybox, before world geometry. Per-map enablement via a small Swift table (map name → cloud texture set/density), seeded from legacy's weather table. Update positions/alpha on CPU per frame (N ≈ 100–200, negligible).
- **Touch points**: new `Metal/Renderables/CloudRenderResource.swift`, new renderer, hook in `MetalMapRenderer` next to `SkyboxRenderer`; table in `Core/SkyboxConfiguration.swift` or a sibling `WeatherConfiguration.swift`.

### 1.2 Fog

- **Legacy**: linear fog uniforms (`use`, `near`, `far`, `color`) passed to every map shader (`Ground.fs`, `Models`, `Water.fs`, effects); parameters per map from the fog parameter table.
- **Approach**: add fog uniforms to the shared frame-uniform struct consumed by ground/model/water shaders in `RagnarokRenderers`; compute `fogFactor = clamp((far - dist)/(far - near))` in fragment shaders and mix toward fog color. Port the per-map fog table (map name → near/far/color/density) into `Core/` as data. Off by default for maps without an entry.
- **Touch points**: `Packages/RagnarokRenderers` shader sources + uniform structs; `MetalMapRenderer` to feed parameters; new fog table file.

### 1.3 Map ambient 3D sounds

- **Legacy**: `Renderer/Map/Sounds.js`. RSW sound objects (file, position, volume, range, cycle). Per frame: if `distance(player, sound) <= range` and `tick >= sound.tick`, play and set `sound.tick = tick + cycle`.
- **Approach**: RSW sound objects are already parsed by `RagnarokFileFormats` (RSW object list); surface them on the world/render asset if not already exposed. In `MetalMapScene`, keep a `[AmbientSound]` array and drive it from the existing per-frame update; reuse `MetalMapAudioPlayer.playSound(named:)` with volume scaled by distance (legacy default cycle 4s when 0). No new rendering.
- **Touch points**: `MetalMapScene` (load + update loop), `MetalMapAudioPlayer` (optional volume parameter), possibly `RagnarokResources` to expose RSW sounds.

### 1.4 Map effect spawners (RSW effect objects)

- **Legacy**: `Renderer/Map/Effects.js` — each RSW effect object re-emits its effect (`EffectManager.spam`) every `delay` ms at a fixed position (torches, smoke, waterfalls).
- **Approach**: same loop shape as 1.3 but emitting effects: map RSW effect IDs through the existing `EffectTable`/`EffectDefinition` machinery and call the same path `addEffects`/`renderEffect` already used by `MetalMapScene+EventHandler.swift:615`. Effects whose primitives aren't built yet (§3) simply no-op until those land — acceptable.
- **Touch points**: `MetalMapScene` load/update, `Core/Effects/EffectTable.swift` coverage, RSW effect objects from `RagnarokResources`.

### 1.5 Signboards (vending/chat-room titles above positions)

- **Legacy**: `Renderer/SignboardManager.js` — billboarded canvas textures at map positions.
- **Approach**: overlay items (pattern §0.4): a `MetalSignboardOverlay { position, text, kind }` collection in `MetalOverlayState`, projected like gauges, rendered as SwiftUI capsules. Created/destroyed by chat-room (`ZC_ROOM_NEWENTRY`/`ZC_DESTROY_ROOM`) and vending (`ZC_STORE_ENTRY`/`ZC_DISAPPEAR_ENTRY`, `ZC_BUYING_STORE_ENTRY`) packets. Implement together with §6 chat rooms/vending.

### 1.6 Screen effects (flash, quake)

- **Legacy**: `Renderer/ScreenEffectManager.js`.
- **Approach**: two cheap mechanisms instead of a manager: (a) full-screen color flash as a SwiftUI overlay animation triggered via `MetalOverlayState`; (b) quake as a transient camera-offset jitter in `MapCameraState`. Trigger from the few packets/effects that need them (e.g. certain skills, `ZC_NOTIFY_EFFECT` map effects).

---

## 2. Entity Presentation

### 2.0 Shared infrastructure first: overlay item kinds + sprite attachments

Two reusable pieces unlock most of this section:

- **Overlay kinds**: generalize `MetalOverlayState` from `gauges: [GameObjectID: MetalGaugeOverlay]` to also carry name labels, cast bars, chat bubbles, signboards, and banners. Each kind is a small struct with `worldPosition`/`screenPosition` exactly like `MetalGaugeOverlay`; `MetalOverlayView` grows one `ForEach` per kind. The projection plumbing already exists.
- **Sprite attachments**: add `attachments: [SpriteAttachment]` to `MetalMapObject`, where `SpriteAttachment` is `{ actName, sprName, frameOrAction, loop, expiry, yOffset }`. `SpriteFrameResolver`/`MetalSpriteRenderer` render them as extra billboard layers above/at the entity, sharing the body's position but with an independent frame clock. Legacy reference: `Renderer/Entity/EntityAttachments.js` (paths resolve to `sprite/이팩트/<file>.spr/.act`).

### 2.1 Hover/click name label

- **Legacy**: `EntityDisplay.js` + `Engine/MapEngine/Entity.js`. On mouse-over, if name unknown, send `CZ_REQNAME(GID)`; server answers `ZC_ACK_REQNAME` (name only) or `ZC_ACK_REQNAMEALL` (name + party/guild/title lines). Names cached per entity; label drawn under the entity with black outline, colored by party/guild/PvP context.
- **Approach**: add a name cache (`[GameObjectID: ObjectName]`) on `MetalMapScene`. Hit-testing for hover already exists for click handling; on hover (macOS/iPadOS pointer) or tap (touch), call new `GameSession.requestObjectName(objectID:)` → `CZ_REQNAME`; handle `ZC_ACK_REQNAMEALL` in `handleMapPacket`, store, and set a name-label overlay item. Show while hovered, or for ~3 s after tap on touch platforms. Party/guild sub-lines come free once §6 party/guild land.
- **Packets**: `CZ_REQNAME` (verify name; rathena may expose it as `CZ_REQNAME2`/`CZ_REQ_NAME` — check `packets.swift`), `ZC_ACK_REQNAMEALL` (present).

### 2.2 Overhead chat bubble

- **Legacy**: `EntityDialog.js`: white-outlined text above the head for ~5 s, fed by `ZC_NOTIFY_CHAT` (others) and `ZC_NOTIFY_PLAYERCHAT` (self) — the same packets that feed the chat box.
- **Approach**: in the existing chat packet handling, additionally create a bubble overlay item keyed by `objectID` with a 5 s expiry (replace on new message). Trim to ~60 chars like legacy. No new packets.

### 2.3 Emotions

- **Legacy**: `ZC_EMOTION { GID, type }` → attachment `{ file: 'emotion', frame: Emotions.indexes[type] }` (`Engine/MapEngine/Entity.js:447`); one-shot, non-looping. Sent via `CZ_REQ_EMOTION`.
- **Approach**: port the legacy `DB/Emotions.js` index table (emotion ID → `emotion.act` action index) into `Core/`; on `ZC_EMOTION` add a one-shot sprite attachment (`sprite/이팩트/emotion.spr/.act`). UI: an `EmotionPickerView` (grid of common emotes, English labels) calling `GameSession.sendEmotion(_:)` → `CZ_REQ_EMOTION` (present); also accept `/e <name>` from chat input (§4.2).
- **Packets**: both present.

### 2.4 Cast bar + cast circle

- **Legacy**: `ZC_USESKILL_ACK { srcID, destID, x, y, skillID, property, delay }` → `EntityCast.js` 60×6 px progress bar over the caster filling over `delay` ms, plus `MagicTarget` ground circle at the target cell sized by skill, plus cast sound (`ef_beginspell.wav` family by element/property).
- **Approach**: `handleMapPacket` currently `break`s on `PACKET_ZC_USESKILL_ACK` (`GameSession.swift:795`) — implement it: forward to `mapScene?.onSkillCastStarted(…)`. Cast bar = gauge-like overlay item with `startTime`/`duration` (SwiftUI `GameProgressBar` animates; remove on `ZC_NOTIFY_SKILL` from the same caster or on `delay` elapsed). Cast circle = first §3 ground primitive: a textured ring quad on the GAT cell (`magic_target.tga`), depth test on/write off. Element color for the bar from `property`.
- **Packets**: `ZC_USESKILL_ACK` present. `ZC_SKILL_SCALE` (AoE size preview, present) can size the circle later.

### 2.5 Ground skill units (warp portal, traps, pneuma, safety wall, songs, LP) — **tracker addition**

- **Legacy**: `ZC_SKILL_ENTRY{,2..5} { AID, creatorAID, x, y, job(unit id), …}` and `ZC_SKILL_DISAPPEAR { AID }` in `Engine/MapEngine/Entity.js`; unit id → appearance via `DB/SkillUnit.js` (e.g. warp portal = animated effect, traps = sprite, songs = tile area). Survey found `ZC_SKILL_ENTRY` is **not handled** in `GameSession` and the struct is **missing** from generated packets — warp portals are currently invisible.
- **Approach**: (1) add `PACKET_ZC_SKILL_ENTRY` (modern variant rathena sends for the configured packet version) to swift-rathena + regenerate; (2) treat skill units as a lightweight scene object type (`MetalSkillUnit { objectID, position, unitID, expiry }`) on `MetalMapScene`, rendered as: sprite attachment at the cell (trap-like units), STR/effect loop (warp portal — `EffectTable` already has the machinery), or colored tile quads (songs/LP — reuse `TileSelectorRenderResource` geometry with a unit texture); (3) remove on `ZC_SKILL_DISAPPEAR` (struct present).
- This belongs in Phase 1; warp portals are core navigation.

### 2.6 Status icons + status attachments/tints

- **Legacy**: `ZC_MSG_STATE_CHANGE{,2..5} { index(EFST), AID, state, remainMS }` → `StatusIcons` UI for the player (icon textures `texture/effect/status-*.tga` via the status DB), `EntityAttachments`/color tints for entities (stun stars, sleep zzz, frozen body color, poison purple tint in `EntityState.js`).
- **Approach**: (1) add `ZC_MSG_STATE_CHANGE` to swift-rathena + regenerate; (2) `ActiveStatusList` observable model (player) with EFST id → icon + remaining time; an icon strip view in the HUD corner with tooltips (EFST names from `RagnarokConstants`/`RagnarokLocalization`); (3) per-entity: small EFST→attachment table (start with stun/sleep/freeze/stone/poison) using §2.0 attachments; tints need a per-object color multiplier on the sprite pipeline — check whether `MetalSpriteRenderer` already supports per-instance color; if not, add one `simd_float4` to its instance data.
- Stage it: player icon strip first (pure UI), entity visuals second.

### 2.7 Aura (level ≥ 99)

- **Legacy**: `EntityAura.js`: two looping attachment layers (`aura.spr`-style ring + floating particles) drawn under/over the entity when `clevel >= 99`.
- **Approach**: two looping sprite attachments toggled by the entity's level (known for the player; for others only when provided). Low priority within Phase 1; depends only on §2.0 attachments.

### 2.8 Spirit spheres / item drop bounce / lock-on marker

- **Spirit spheres** (`ZC_SPIRITS`): count of orbiting billboards; small dedicated renderable orbiting the entity anchor (angle = f(time, index)). Defer until monk gameplay matters.
- **Drop bounce**: in `MetalMapItem` spawn (on `ItemEvents.Spawned`/`ZC_ITEM_FALL_ENTRY`), animate a one-shot parabolic y-offset (~0.3 s, ~1 cell height) before settling — pure presentation in the item's renderable update.
- **Lock-on marker**: port the Reality backend behavior (`Reality/System/LockOnSystem.swift`) as either an overlay ring at the target's projected position (cheapest) or a small renderable; clear on target death/vanish.

### 2.9 Guild emblem / chat-room sign over entities

Implement with §6 guild (emblem bitmap from `ZC_GUILD_EMBLEM_IMG`, drawn next to the name-label overlay) and §6 chat rooms (sign = §1.5 signboard overlay keyed to the owner entity).

---

## 3. Effects System

### 3.1 Strategy

Legacy's effect layer is: `EffectManager` + per-effect-ID descriptors (`DB/Effects/EffectTable.js`) composing a small set of **primitives** (STR playback, 2D billboard sprite, 3D cylinder, ring/ground quad, RSM model, particles). This codebase already has the descriptor side (`EffectDefinition`, `EffectTable`, `SkillEffectTable`) and one primitive (STR). The work is therefore: **add primitives one by one, on demand**, each as a render-resource + renderer pair, then widen `EffectTable` coverage by porting legacy descriptor rows.

Primitive build order (driven by Phase 1/4 consumers):

1. **Ground ring/quad** (`MagicTarget`, `PropertyGround`, `GroundAura`, LP) — single textured quad/ring on GAT cells; consumer: cast circle (§2.4), songs/LP (§2.5).
2. **2D billboard effect** (`TwoDEffect.js`) — textured quad facing camera with scale/alpha/rotation keyed over lifetime; consumer: many `EffectTable` rows; closes most "skill looks empty" cases.
3. **Cylinder** (`Cylinder.js`) — open-ended textured cylinder with animated height/radius/alpha, additive blend; consumer: teleport/resurrection/holy casts.
4. **Orbiting billboards** (spirit spheres, `SwirlingAura`).
5. **Particle emitters** (weather §3.2, `PoisonEffect`, hit sparks).
6. **RSM-model effects** (`RsmEffect.js`) — reuse the static RSM mesh path with a transform animation; rare, last.

Each primitive: `Metal/Renderables/<X>RenderResource.swift` + renderer registered in `MetalMapRenderer`, instantiated through `addEffects` in `MetalMapScene+EventHandler.swift`. Port legacy descriptor rows incrementally into `EffectDefinition` (add fields as primitives appear: `blendMode`, `duplicate`, `timeBetweenDup`, `posOffset`, `rotation` …), auditing against `DB/Effects/EffectTable.js`.

### 3.2 Weather (rain, snow, sakura, fireworks)

- **Legacy**: `RainWeather.js` (oriented streak billboards + splash on ground + sound), `SnowWeather.js`/`SakuraWeatherEffect.js` (drifting particles), enabled per map by weather tables.
- **Approach**: one `WeatherParticleRenderResource` parameterized by texture, count, fall vector, drift, respawn volume around the camera; per-map table selects preset. Build after primitive 5; purely additive to the frame loop.

### 3.3 Post-processing

Legacy uses it sparsely. Skip until a concrete consumer appears; note that `MetalMapRenderer` would need an offscreen color target + composite pass — design only when needed.

---

## 4. Controls and Input

### 4.1 Hotbar + battle-mode hotkeys

- **Legacy**: `UI/Components/ShortCut` + `Controls/BattleMode.js`. Server persists the bar: `ZC_SHORTCUT_KEY_LIST*` (38 slots of `{ type: skill|item, ID, level }`) on login; client updates slots with `CZ_SHORTCUT_KEY_CHANGE1/2`; F1–F12 (rows toggled) trigger slot execution: skill → target-selection or self-cast; item → `useItem`.
- **Approach**: (1) add `ZC_SHORTCUT_KEY_LIST` to swift-rathena + regenerate (`CZ_SHORTCUT_KEY_CHANGE1/2` already present); (2) `ShortcutBar` observable model in `Core/Models/`; (3) `ShortcutBarView` — a horizontal strip above `GameBottomBar` showing skill/item icons (sprite/item icons already renderable via `RagnarokSprite`/database thumbnails), tap = execute, drag/long-press = assign from `SkillListView`/`InventoryView`; (4) keyboard: `.keyboardShortcut`/key-press handlers on macOS/iPadOS mapping F1–F9 to slots; (5) execution funnels into existing `GameSession.useSkill`/`useItem`.
- Skill execution needs a target-pick mode for targeted skills: set a "pending skill" on `MetalMapScene` so the next entity/tile tap completes `useSkill` — same flow the `SkillListView` use-button should share.

### 4.2 `/command` processing

- **Legacy**: `Controls/ProcessCommand.js` — client-side commands (`/sit`, `/stand`, `/w` whisper shorthand, `/who`, `/effect`, `/bgm`, `/sound`, `/noctrl`, `/emotion names` …).
- **Approach**: intercept in the chat send path (`GameSession.sendMessage`, `GameSession.swift:1184`): if message starts with `/`, route to a `ClientCommandProcessor` in `Core/` that switches on the verb and calls existing session/scene APIs (`requestAction(.sit)`, settings toggles, `MessageCenter` feedback for unknown commands). Mirrors the existing `@`-command path (`AtCommandShortcut`). Add commands lazily; start with `/sit /stand /doridori /bangbang /e /w /who /effect /bgm /sound`.

### 4.3 Context menu on entity

SwiftUI `contextMenu`/long-press on the entity hit-test result, listing actions gated by available systems: Whisper (§6.4), Trade (§6.3), Invite to party (§6.5), View equipment. Build the menu shell when the first action (whisper) lands.

---

## 5. Login / Char Flow

- **Pincode**: char-server packets `HC_SECOND_PASSWD_LOGIN` family; a numeric-pad `GameWindow` between char-server connect and char list. Only worth implementing if the embedded server enables pincode — check rAthena `char_athena.conf`; otherwise leave ❌ deliberately.
- **Captcha**: legacy `Captcha.js`; rAthena's captcha is disabled by default offline — same gating decision.

---

## 6. Gameplay Systems (MapEngine)

Every system below follows §0 (handler cases → model → UI → send funcs). Listed per system: legacy packets (from `src/Engine/MapEngine/*.js`), model/UI shape, and notable wrinkles.

### 6.1 NPC shop buy/sell (`Store.js`)

- **Flow**: NPC script triggers `ZC_SELECT_DEALTYPE` (buy-or-sell choice → `CZ_ACK_SELECT_DEALTYPE`); buy: `ZC_PC_PURCHASE_ITEMLIST` (id/price/discount list) → `CZ_PC_PURCHASE_ITEMLIST` (name/amount pairs) → `ZC_PC_PURCHASE_RESULT`; sell: `ZC_PC_SELL_ITEMLIST` (inventory indices + prices) → `CZ_PC_SELL_ITEMLIST` → `ZC_PC_SELL_RESULT`.
- **Build**: `NPCStore` observable (mode, item rows, cart, zeny check against `playerStatus`); `NpcStoreView` two-pane (catalog/cart) using database item icons + localized names (`RagnarokDatabase`/`RagnarokLocalization` already power the Database browser — reuse the record-lookup API). Wrinkle: sell uses **inventory index**, buy uses **item id**; keep both in the row struct. Market/barter variants (`ZC_NPC_MARKET_OPEN` …) are a later sub-phase.

### 6.2 Kafra storage (`Storage.js`)

- **Flow**: opening pushes `ZC_STORE_NORMAL_ITEMLIST` + `ZC_STORE_EQUIPMENT_ITEMLIST` (missing from generated packets — add first) and `ZC_NOTIFY_STOREITEM_COUNTINFO` (present); moves via `CZ_MOVE_ITEM_FROM_BODY_TO_STORE`/`…_STORE_TO_BODY` answered by `ZC_ADD_ITEM_TO_STORE`/`ZC_DELETE_ITEM_FROM_STORE` (present); close with `CZ_CLOSE_STORE`.
- **Build**: `Storage` model mirroring `Inventory` (same item struct; count/capacity header). UI: side-by-side Inventory ↔ Storage lists with amount steppers. Wrinkle: storage stays "open" server-side until `CZ_CLOSE_STORE` — tie it to window dismissal.

### 6.3 Player↔player trade (`Trade.js`)

- **Flow**: `CZ_REQ_EXCHANGE_ITEM(AID)` → other side gets `ZC_REQ_EXCHANGE_ITEM2` → accept `CZ_ACK_EXCHANGE_ITEM` → both add items/zeny (`CZ_ADD_EXCHANGE_ITEM` / `ZC_ADD_EXCHANGE_ITEM*`) → conclude (`CZ_CONCLUDE_EXCHANGE_ITEM`, lock) → exec (`CZ_EXEC_EXCHANGE_ITEM`) / cancel.
- **Build**: `TradeSession` model with the classic two-column window and per-side conclude/locked flags. Strict state machine — disable item changes after conclude, exactly as legacy. Entry point: context menu (§4.3).

### 6.4 Whisper (`PrivateMessage.js`)

- **Flow**: send `CZ_WHISPER { name, message }`; receive `ZC_WHISPER { name, message }`; delivery result `ZC_ACK_WHISPER`. All present.
- **Build**: extend `MessageCenter` with conversation threading keyed by partner name; `ChatBoxView` gains a recipient mode (`/w name msg` from §4.2 sets it); unread badge. This is the smallest social feature — do it first to validate the context-menu + chat plumbing.

### 6.5 Party (`Group.js`)

- **Flow**: create `CZ_MAKE_GROUP`; invite `CZ_PARTY_JOIN_REQ`/answer `CZ_PARTY_JOIN_REQ_ACK`; roster `ZC_GROUP_LIST`; member add/remove `ZC_ADD_MEMBER_TO_GROUP*`/`ZC_DELETE_MEMBER_FROM_GROUP`; live HP `ZC_NOTIFY_HP_TO_GROUPM`; minimap dots `ZC_NOTIFY_POSITION_TO_GROUPM`; options `ZC_REQ_GROUPINFO_CHANGE_V2`/`ZC_PARTY_CONFIG`; party chat `ZC_NOTIFY_CHAT_PARTY` (chat type already modeled).
- **Build**: `Party` observable (members: name, map, hp/maxHp, online); `PartyView` window + compact member HP strip on the HUD; invite via context menu; position packets feed minimap (§7.1). Wrinkle: member identity is `(AID, GID)` pairs — key by account id like legacy.

### 6.6 Friends (`Friends.js`)

Small: `ZC_FRIENDS_LIST`, `ZC_FRIENDS_STATE` (online toggle), add/delete handshake (`CZ_ADD_FRIENDS` → `ZC_REQ_ADD_FRIENDS` → `CZ_ACK_REQ_ADD_FRIENDS`). One list view; pairs naturally with the whisper window.

### 6.7 Chat rooms (`ChatRoom.js`)

`CZ_CREATE_CHATROOM`/`ZC_ACK_CREATE_CHATROOM`; public signs from `ZC_ROOM_NEWENTRY` → signboard overlay (§1.5); join `CZ_REQ_ENTER_ROOM`/`ZC_ENTER_ROOM` (member list), member events, owner role change, `ZC_DESTROY_ROOM`. Offline value is low (no other players except via the remote-play setup) — implement the **receive/sign** side first so NPC-script chatrooms render; defer the full room UI.

### 6.8 Guild (`Guild.js`)

Largest social system; stage it: (a) passive info — `ZC_GUILD_INFO*`, `ZC_UPDATE_GDID`, guild chat (modeled), notice `ZC_GUILD_NOTICE`; (b) member manager — `ZC_MEMBERMGR_INFO`, positions; (c) emblem — `CZ_REQ_GUILD_EMBLEM_IMG`/`ZC_GUILD_EMBLEM_IMG` (BMP bytes → `CGImage` cache keyed by `(guildID, version)`; show beside name labels §2.1); (d) management actions (invite/leave/expel/notice edit/ally). Skills tab reuses `SkillListView` with `ZC_GUILD_SKILLINFO`.

### 6.9 Pet (`Pet.js`)

Capture: `ZC_START_CAPTURE` → pick target → `CZ_TRYCAPTURE_MONSTER` → `ZC_TRYCAPTURE_MONSTER` result; egg select `ZC_PETEGG_LIST`/`CZ_SELECT_PETEGG`; status `ZC_PROPERTY_PET` (name, level, hunger, intimacy); actions `CZ_PET_ACT`, state `ZC_CHANGESTATE_PET`; feed/perform via `CZ_COMMAND_PET`. The pet **entity** already spawns via normal entry packets — only the management window (`PetInformationsView`: hunger/intimacy bars, feed/perform/rename/return-egg buttons) and capture targeting mode are new.

### 6.10 Homunculus / Mercenary (`Homun.js`, `Mercenary.js`)

Shared shape: init/property (`ZC_PROPERTY_HOMUN*` / `ZC_MER_INIT` + `ZC_MER_PROPERTY`), stat deltas (`ZC_HO_PAR_CHANGE` / `ZC_MER_PAR_CHANGE`), skill list (`ZC_HOSKILLINFO_LIST` / `ZC_MER_SKILLINFO_LIST` — present), commands (`CZ_COMMAND_MER`, move/attack via `CZ_REQUEST_MOVENPC`/`CZ_REQUEST_ACTNPC` — present). Build one `CompanionStatus` model + window parameterized for both; skill tab reuses `SkillListView` machinery. AESIR/feeding quirks can wait.

### 6.11 Quest log (`Quest.js`)

`ZC_ALL_QUEST_LIST_V*` on login (active quests + hunt objectives), `ZC_ADD_QUEST*`, `ZC_DEL_QUEST`, `ZC_ACTIVE_QUEST` (toggle), `ZC_UPDATE_MISSION_HUNT*` (kill counts). Quest titles/summaries come from the quest db (`swift-rathena/db` quest YAML via `RagnarokDatabase`). `QuestView`: list with active toggle + objective counters. NPC quest marks: `ZC_QUEST_NOTIFY_EFFECT` → attachment over the NPC (§2.0). `CZ_ACTIVE_QUEST`/`CZ_QUEST_STATUS_REQ` present.

### 6.12 Bank (`Bank.js`)

`ZC_ACK_OPEN_BANKING`/`ZC_BANKING_CHECK` (balance), deposit/withdraw acks. Trivial window (balance + amount field + two buttons). Gate: requires `ZC_UI_OPEN` dispatch (§6.15) because rAthena opens it via UI-open.

### 6.13 Achievements (`Achievement.js`)

`ZC_ALL_ACH_LIST`, `ZC_ACH_UPDATE`, reward ack. Note: the game path is `GameSession.handleMapPacket`, not the separate `RagnarokNetwork` `MapSession` events (those serve the chat client) — add cases in `GameSession` regardless of `AchievementEvents` existing. Definitions from `achievement_db.yml` via `RagnarokDatabase`; UI = category list + progress + toast on update.

### 6.14 Map state / PvP (`MapState.js`)

`ZC_MAPPROPERTY_R2`/`ZC_NOTIFY_MAPPROPERTY2` → flags (pvp, gvg, siege…) on a `MapState` model; consumers: name-label coloring (§2.1), PvP rank counter from `ZC_NOTIFY_RANKING`. Small; do when PvP maps matter.

### 6.15 Server-driven UI open (`UIOpen.js`)

`ZC_UI_OPEN { type, data }` → switch mapping `UI_TYPE` (bank, attendance, macro/captcha…) to opening the corresponding window. Implement the dispatch when the first consumer (bank or attendance) lands.

### 6.16 Vending

Receive side first (see §1.5 signboards + `ZC_PC_PURCHASE_ITEMLIST_FROMMC` buy window → `CZ_PC_PURCHASE_ITEMLIST_FROMMC`), open-own-shop second (`ZC_OPENSTORE` slot count → item pick → `CZ_REQ_OPENSTORE2`). Buying-store family is fully present in generated packets.

### 6.17 Mail — prefer Rodex

The legacy mail packets are half-commented in `MapSession+Mail.swift`; for the in-game client implement **Rodex only** (rAthena default): list `ZC_ACK_MAIL_LIST`, read `ZC_ACK_READ_RODEX`, attachments (`ZC_ACK_ITEM_FROM_MAIL`), write result, unread notify (these are the structs already subscribed in the chat-client path). Model `Mailbox` + two-pane `MailView`. Low urgency offline.

---

## 7. UI Components

### 7.1 MiniMap

- **Legacy**: `UI/Components/MiniMap/` — map image `texture/유저인터페이스/map/<mapname>.bmp` (`DB.INTERFACE_PATH + 'map/'`), `map_arrow.bmp` player arrow rotated by camera/direction, party dots from `ZC_NOTIFY_POSITION_TO_GROUPM`, NPC marks from `ZC_COMPASS`, zoom levels, grid→pixel scale from map dimensions.
- **Approach**: load the BMP via `ResourceManager` (fall back to "no minimap" gracefully — some maps lack the file); SwiftUI view in a screen corner: `Image` + `Canvas` overlay for marks. Coordinate transform: `pixel = gridPos / mapSize * imageSize`, y-flipped — map dimensions are already known from GAT/`MapGrid`. Player position updates from the scene's existing position stream; the `ZC_COMPASS` data already flows (`NPCEvents.MinimapMarkPositionReceived`) — consume it at last. Tap-to-request-move is a nice later addition.

### 7.2 Item info window

- **Legacy**: `ItemInfo` reads the client item description tables.
- **Approach**: `ItemInfoView` opened from long-press/secondary-click on any item slot (inventory/equipment/storage/shop). Data from `RagnarokDatabase` item record + `RagnarokLocalization` localized name/description — the Database browser already renders this; extract/reuse its lookup rather than re-implementing. Show slots, card compounding, weight, equip locations.

### 7.3 Item-obtain toast and announce banner

- `ItemObtain`: hook the existing inventory-add handling; render a transient stack of "Item × n obtained" rows above the chat box (`MessageCenter` already has an `item` category — add a `toast` surface to it).
- `Announce`: `ZC_BROADCAST`/`ZC_BROADCAST2` (present; `2` carries color) → banner text centered at top with scroll/fade, plus a chat-box copy in broadcast color.

### 7.4 Map-name flash

On `PACKET_ZC_NPCACK_MAPMOVE`/map load completion, show the localized map name (`RagnarokLocalization` map-name table) centered for ~3 s — trivial overlay state flag.

### 7.5 Skill description window

Like §7.2 but for skills: `SkillDescriptionView` from long-press on `SkillListView`/hotbar slots; data from skill db + localized description tables.

### 7.6 Remaining windows

Each later-phase system's window is described with its system in §6. Refine/enchant family (`Refine`, `Enchant`, `LaphineSys` …), `Sense`, `CardIllustration`, make-arrow selections: all are simple list/grid `GameWindow`s whose triggering packets arrive via NPC/skill flows; implement opportunistically when the triggering content is actually reachable in the embedded server.

---

## 8. Audio

- **NPC-triggered sound/BGM**: `ZC_SOUND { name, act, term }` and `ZC_PLAY_NPC_BGM` (from `NPC.js`) → route to `MetalMapAudioPlayer.playSound`/`playBGM`. Tiny; add with NPC polish.
- **Ambient sounds**: §1.3.
- **Volume options**: ensure `OptionsView` exposes independent BGM / SFX sliders persisted in settings, consumed by `MetalMapAudioPlayer` and `LoginFlowAudioPlayer`.

---

## 9. Suggested build sequence inside Phase 1

The tracker fixes the phase order; within Phase 1 the dependency-cheapest sequence is:

1. **Overlay-kind generalization** (§2.0) — unlocks 2.1/2.2/2.4/7.3/7.4.
2. **Name labels** (2.1) → **chat bubbles** (2.2) → **map-name flash** (7.4) → **announce/obtain toasts** (7.3) — all pure overlay + existing packets.
3. **Sprite attachments** (§2.0) → **emotions** (2.3) → **quest/NPC marks** (6.11 partial) → **aura** (2.7).
4. **swift-rathena packet additions in one batch** (`ZC_SKILL_ENTRY`, `ZC_MSG_STATE_CHANGE`, `ZC_SHORTCUT_KEY_LIST`, `ZC_STORE_*_ITEMLIST`) + one `./generate.sh` run — avoids repeated regenerate cycles.
5. **Cast bar + ground ring primitive** (2.4, 3.1-1) → **ground skill units** (2.5) — warp portals become visible.
6. **Status icon strip** (2.6 player half) → entity status visuals later.
7. **Minimap** (7.1) and **hotbar** (4.1) — independent of 1–6, can run in parallel.
8. **Item info** (7.2) + **`/commands`** (4.2) — closes Phase 1.

Validation per item follows the tracker convention: side-by-side against roBrowserLegacy, plus a focused `swift build --package-path Packages/RagnarokGame` and existing test suites for touched packages.
