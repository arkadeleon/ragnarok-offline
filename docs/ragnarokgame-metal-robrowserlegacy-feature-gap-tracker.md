# RagnarokGame (Metal) vs roBrowserLegacy — Full Feature Gap Tracker

## Scope

This document tracks the **full feature gap** between the current RagnarokOffline game client (Metal backend in `Packages/RagnarokGame` plus its supporting packages) and `../roBrowserLegacy`, and defines the implementation order for closing it.

It is the umbrella document. Narrower documents stay authoritative for their own areas and are referenced instead of duplicated:

- `ragnarokgame-metal-robrowserlegacy-feature-gap-implementation-notes.md` — per-gap implementation research (legacy references, packets, approach, touch points) for every item below
- `ragnarokgame-metal-implemented-feature-fidelity-audit.md` — fidelity audit of ✅/🟡 items: deviations in already-implemented behavior (sprite depth bias, facing, scale, timing…)
- `ragnarokgame-metal-robrowserlegacy-alignment-plan.md` — rendering-behavior alignment (water, shadows, sprite depth, damage digits, animated RSM)
- `ragnarokgame-login-flow-robrowserlegacy-alignment-plan.md` — login flow alignment
- `ragnarokfileformats-robrowserlegacy-alignment-table.md` — file-format parsing alignment
- `ragnarokgame-metal-reality-parity-plan.md` — Metal ↔ RealityKit backend parity (out of scope here; this tracker is Metal-first)

Status is based on a static survey of both codebases on 2026-06-11. Items marked partial list what exists and what is missing.

Legend:

- ✅ Done — behavior exists and is broadly equivalent in capability (not necessarily pixel-identical)
- 🟡 Partial — some of the behavior exists; the missing part is listed
- 📦 Stubbed — packet subscriptions or types exist but handlers/UI are empty
- ❌ Missing — no equivalent in the current client
- ➖ Not applicable — legacy-only concern that has no meaning in this client (noted with reason)

---

## 1. Map Rendering

Reference roBrowserLegacy sources: `src/Renderer/Map/*`, `src/Renderer/MapRenderer.js`.

| Feature | Legacy source | Status | Notes |
|---|---|---|---|
| Ground mesh + lightmaps | `Ground.js` | ✅ | |
| Static RSM map models | `Models.js` | ✅ | |
| Animated RSM map models | `AnimatedModels.js` | ❌ | Alignment plan Phase 6 |
| Water (data: frames, wave, opacity, GND v1.8+ zones) | `Water.js` | ✅ | Alignment plan Phase 1 done |
| Water (pass order / depth-write semantics) | `Water.js` | 🟡 | Alignment plan Phase 2 |
| Walkable-cell / GAT altitude queries | `Altitude.js` | ✅ | `MapGrid`, `PathFinder` |
| Tile cursor / grid selector | `GridSelector.js` | ✅ | `MetalTileSelectorRenderer` |
| Sky background color + skybox | `Sky.js` (partial) | ✅ | `SkyboxRenderer`, `SkyboxConfiguration` |
| Clouds (sky cloud particles on outdoor maps) | `Sky.js` | ❌ | |
| Fog | `MapRenderer.js` | ❌ | Was declared out of scope in the alignment plan; tracked here as a real gap |
| Map ambient 3D sound objects (RSW sounds) | `Map/Sounds.js` | ❌ | BGM and triggered SFX exist; positional looping map sounds do not |
| Map effect spawners (RSW effect objects: torches, smoke…) | `Map/Effects.js` | ❌ | |
| Vending/chat signboards above map positions | `SignboardManager.js` | ❌ | Depends on vending/chat-room systems (§6) |
| Screen effects (flash, quake…) | `ScreenEffectManager.js` | ❌ | |
| Entity ground shadows (own pass, GAT-anchored, shadow factor) | `EntityRender.js` | ❌ | Alignment plan Phase 3 |
| Selective sprite depth policy (PC writes depth, others test-only) | `EntityRender.js` | 🟡 | Alignment plan Phase 4 |
| Damage-digit overlay depth semantics | `Effects/Damage.js` | 🟡 | Alignment plan Phase 5 |

## 2. Entity Presentation

Reference: `src/Renderer/Entity/*`.

| Feature | Legacy source | Status | Notes |
|---|---|---|---|
| Body/head/gear sprite composition + actions | `Entity.js`, `EntityAction.js` | ✅ | `SpriteFrameResolver`, `SpriteAssetStore` |
| Walking interpolation | `EntityWalk.js` | ✅ | `MetalMovement`, `MetalMovementPlanner` |
| HP/SP gauges over entities | `EntityLife.js` | ✅ | `MetalGaugeOverlay` |
| Hover name label (entity display name, party/guild line) | `EntityDisplay.js` | ❌ | No name rendering on hover or click |
| Overhead chat bubble | `EntityDialog.js` | ❌ | Chat goes to `ChatBoxView` only |
| Emotion sprites (`/e` emotes) | `EntityAnimations.js` + `Emoticons` UI | ❌ | |
| Cast bar over casting entity | `EntityCast.js` | ❌ | Skill effects render, but no cast progress bar |
| Cast ground circle (magic target area) | `Effects/MagicTarget.js` | ❌ | |
| Level-99 aura | `EntityAura.js` | ❌ | |
| Status-effect visual attachments (stun stars, sleep, freeze tint…) | `EntityAttachments.js`, `EntityState.js` | ❌ | |
| Status color tints (poison, curse, stone) | `EntityState.js` | ❌ | |
| Spirit spheres | `Effects/SpiritSphere.js` | ❌ | |
| Guild emblem over entity | `EntityEmblem.js` | ❌ | Depends on guild system |
| Chat-room sign over owner | `EntityRoom.js` | ❌ | Depends on chat-room system |
| Ground skill units (warp portal, traps, pneuma, songs, LP) | `Entity.js` (`ZC_SKILL_ENTRY`/`ZC_SKILL_DISAPPEAR`) | ❌ | Not handled in `GameSession`; `ZC_SKILL_ENTRY` struct also missing from generated packets — warp portals are invisible |
| Item drop bounce animation | `EntityDropEffect.js` | 🟡 | Items appear/vanish (`MetalMapItem`); no drop arc/bounce |
| Footstep/attack/skill sounds per entity | `EntitySound.js` | ✅ | `WeaponSoundTable`, `WeaponHitSoundTable`, `JobHitSoundTable` |
| Lock-on target marker | `Effects/LockOnTarget.js` | 🟡 | Exists in Reality backend (`LockOnSystem`); not in Metal |

## 3. Effects System

Reference: `src/Renderer/Effects/*`, `src/Renderer/EffectManager.js`, `src/DB/Effects/*`.

| Feature | Legacy source | Status | Notes |
|---|---|---|---|
| Damage digits / MISS / crit combat text | `Damage.js` | ✅ | `MetalCombatText`, depth semantics tracked in §1 |
| STR effect playback | `StrEffect.js` | ✅ | `STREffectRenderResource`, `EffectAssetStore` |
| Skill → effect-ID mapping table | `DB/Effects/EffectTable.js` | 🟡 | `EffectTable` + `SkillEffectTable` exist; coverage is a subset of legacy table |
| 2D sprite effects (non-STR) | `TwoDEffect.js` | 🟡 | Partially covered via `EffectDefinition`; audit against legacy table needed |
| 3D primitive effects (cylinder, quad horn, magic ring…) | `Cylinder.js`, `MagicRing.js`, `QuadHorn.js`, … | ❌ | Needed by many casts/buffs |
| Ground aura / property ground / LP | `GroundAura.js`, `PropertyGround.js`, `LPEffect.js` | ❌ | |
| RSM-model effects | `RsmEffect.js` | ❌ | |
| Weather: rain, snow, sakura, clouds, fireworks | `RainWeather.js`, `SnowWeather.js`, `*WeatherEffect.js` | ❌ | Per-map weather table |
| Poison / spider web / magnum break specials | `PoisonEffect.js`, `SpiderWeb.js`, `MagnumBreak.js` | ❌ | |
| Song/dance area effects | `Songs.js` | ❌ | |
| Post-processing | `PostProcess.js` | ❌ | |

## 4. Controls and Input

Reference: `src/Controls/*`.

| Feature | Legacy source | Status | Notes |
|---|---|---|---|
| Click-to-move with path preview cursor | `MapControl.js` | ✅ | |
| Click entity to attack / talk / pick up | `EntityControl.js` | ✅ | `requestAction`, `talkToNPC`, `pickUpItem` |
| Hover feedback (cursor change, name display) | `EntityControl.js` | ❌ | Tied to §2 name label |
| Context menu on entity (PM, trade, party invite…) | `ContextMenu` UI | ❌ | Depends on social systems |
| Hotkey bar execution (F-keys / battle mode) | `BattleMode.js`, `KeyEventHandler.js` | ❌ | No shortcut storage or trigger path |
| `/command` processing (`/sit`, `/w`, `/who`, `/effect`…) | `ProcessCommand.js` | 🟡 | `@`-command shortcuts exist (`AtCommandShortcut`); legacy `/` client commands largely absent |
| Touch control pad / virtual joystick | `JoystickUI`, `MobileUI` | ✅ | `ActionControlPadView`, `ThumbstickView` |
| Camera rotate/zoom | `Camera.js` | ✅ | `WorldCamera`, `MapCameraState` |
| Screenshot capture | `ScreenShot.js` | ➖ | OS-level capture; revisit only if in-game capture is wanted |
| Window dragging / item drag-and-drop | `MouseEventHandler.js` | ➖ | Different UI paradigm (SwiftUI windows); equivalent affordances handled per-view |

## 5. Login / Char Flow

Reference: `src/Engine/LoginEngine.js`, `CharEngine.js`. Detailed alignment lives in the login-flow plan; summary here.

| Feature | Status | Notes |
|---|---|---|
| Login, char-server select, char select/create/delete | ✅ | |
| Map-server handoff, keepalives | ✅ | |
| Pincode window | ❌ | `PincodeWindow` in legacy |
| Captcha | ❌ | |

## 6. Gameplay Systems (MapEngine)

Reference: `src/Engine/MapEngine/*`. This is the largest gap area.

| System | Legacy source | Status | Notes |
|---|---|---|---|
| Player status, stat points, exp, death | `Main.js` | ✅ | `CharacterStatus`, `incrementStatusProperty` |
| Entity spawn/move/action/vanish | `Entity.js` | ✅ | |
| Inventory: use/equip/unequip/throw/pick up | `Item.js` | ✅ | |
| NPC dialog: next/menu/input/image/close | `NPC.js` | ✅ | Minimap-mark event received but unused (no minimap) |
| Skills: list, level-up, targeted use, ground use | `Skill.js` | ✅ | Cast bar and target-selection UX tracked in §2/§7 |
| Skill target selection cursor (area highlight) | `SkillTargetSelection` UI | 🟡 | Ground skills usable; no area-size highlight cursor |
| NPC shop buy/sell | `Store.js` | ❌ | |
| Kafra storage | `Storage.js` | ❌ | |
| Player↔player trade | `Trade.js` | ❌ | |
| Whisper / private message | `PrivateMessage.js` | 🟡 | Chat type `private` modeled in events; no send UI, no whisper window |
| Party: create/invite/leave/exp option/party HP | `Group.js` | 🟡 | Chat type `party` modeled; no party system or UI |
| Friends list | `Friends.js` | ❌ | |
| Chat rooms | `ChatRoom.js` | ❌ | |
| Guild: window, members, emblem, notice, skills | `Guild.js` | ❌ | Chat type `guild` modeled only |
| Clan | `Clan.js` | 🟡 | Chat type `clan` modeled only |
| Pet: hatch, feed, performance, intimacy | `Pet.js` | ❌ | |
| Homunculus | `Homun.js` | ❌ | |
| Mercenary | `Mercenary.js` | ❌ | |
| Quest log + objectives | `Quest.js` | ❌ | |
| Mail (legacy) | `Mail.js` | 📦 | `MapSession+Mail.swift` subscriptions commented out / empty |
| Rodex mail | `Rodex.js` | 📦 | Subscribed, handlers empty |
| Bank | `Bank.js` | ❌ | |
| Achievements | `Achievement.js` | 📦 | `AchievementEvents.Listed/Updated` exist; no UI |
| Map state: PvP mode, PvP count/timer | `MapState.js` | ❌ | |
| Cash shop | `CashShop.js` | ❌ | Low value offline |
| Roulette | `Roulette.js` | ❌ | Low value offline |
| PC gold timer | `PCGoldTimer.js` | ❌ | Low value offline |
| Server-driven UI open requests | `UIOpen.js` | ❌ | Needed once attendance/banks exist |
| Vending (open shop, buy from shop, report) | `Vending*` UI | ❌ | |

## 7. UI Components

Reference: `src/UI/Components/*`. Only gameplay-relevant components listed; viewer/dev tools (`GrfViewer`, `ModelViewer`, `StrViewer`, `EffectViewer`, …) are ➖ because RagnarokOffline ships separate native browser/viewer apps for that.

Implemented (✅): `WinLogin`→`LoginView`, `CharSelect`→`CharacterSelectView`, `CharCreate`→`CharacterMakeView`, `BasicInfo`→`BasicInfoView`, `WinStats`→`StatusView`, `Inventory`→`InventoryView`, `Equipment`→`EquipmentView`, `SkillList`→`SkillListView`, `NpcBox`/`NpcMenu`→`NPCDialogView`, `ChatBox`→`ChatBoxView`, `Escape`→`MenuView`, `Error`/`WinPopup`→`MessageBoxView`, `JoystickUI`→`ActionControlPadView`, sound/graphics options → `OptionsView` (subset).

| Missing component | Status | Notes |
|---|---|---|
| `MiniMap` | ❌ | Highest-value missing HUD element; NPC mark event already received |
| `ShortCut` / `ShortCuts` / `ShortCutOption` (hotbar) | ❌ | Pairs with battle-mode hotkeys (§4) |
| `ItemInfo` (item description window) | ❌ | Long-press/click item anywhere |
| `ItemObtain` (pickup toast) | ❌ | `MessageCenter` has `item` category; no toast UI |
| `Announce` (broadcast banner) | ❌ | |
| `StatusIcons` (active buff/debuff icons) | ❌ | Pairs with §2 status attachments |
| `Emoticons` picker | ❌ | |
| `ContextMenu` | ❌ | |
| `MapName` (map-name flash on enter) | 🟡 | Shown during loading; no in-map flash |
| `WhisperBox` | ❌ | |
| `PartyFriends` | ❌ | |
| `Guild` | ❌ | |
| `Storage` | ❌ | |
| `NpcStore` (buy/sell) | ❌ | |
| `Trade` | ❌ | |
| `Vending` / `VendingShop` / `VendingReport` | ❌ | |
| `Quest` | ❌ | |
| `WorldMap` / `Navigation` | ❌ | |
| `PetInformations` / `PetEvolution` | ❌ | |
| `HomunInformations` / `SkillListMH` | ❌ | |
| `MercenaryInformations` | ❌ | |
| `Mail` / `Rodex` | ❌ | |
| `Bank` | ❌ | |
| `Achievement` | ❌ | |
| `CheckAttendance` | ❌ | |
| `Refine` / `Enchant` / item-reform family | ❌ | |
| `SkillDescription` | ❌ | |
| `MakeArrowSelection` / `MakeItemSelection` / `MakeReadBook` | ❌ | |
| `Sense` (mob info) | ❌ | |
| `CardIllustration` | ❌ | |
| `ChatRoom` / `ChatRoomCreate` | ❌ | |
| `PincodeWindow` / `Captcha` | ❌ | |
| `PvPCount` / `PvPTimer` / `Reputation` / `SlotMachine` / `Roulette` / `CashShop` | ❌ | Low priority offline |

## 8. Audio

Reference: `src/Audio/*`.

| Feature | Status | Notes |
|---|---|---|
| BGM per map, login BGM | ✅ | `MetalMapAudioPlayer`, `LoginFlowAudioPlayer` |
| Triggered sound effects (attack, hit, skill) | ✅ | |
| Map ambient positional sounds | ❌ | See §1 |
| Volume options | 🟡 | Verify `OptionsView` exposes separate BGM/SFX volume like `SoundOption` |

---

## Implementation Order

Ordering principle: **minute-to-minute playability first, then the economy loop, then social, then companions/progression, then extended systems.** Rendering-correctness work continues on its own track because it shares few files with the systems work.

### Track R (parallel): finish rendering alignment

Execute the existing alignment plan (Phases 2–6: water pass, shadow split, sprite depth, damage-digit depth, animated RSM), then fold in the leftover §1 items in this order:

R1. Map ambient sounds (small, isolated)
R2. Map effect spawners (RSW effects; reuses STR/2D effect machinery)
R3. Fog, clouds
R4. Screen effects, weather effects

### Phase 1 — Core combat/HUD playability

The player feels these every minute of play; none depend on new server systems.

1. Entity hover/click name display (`EntityDisplay`) + hover feedback
2. Minimap (`MiniMap`) with player/party/NPC marks (consumes the already-received minimap-mark event)
3. Shortcut hotbar (`ShortCuts`) + hotkey execution (`BattleMode`) for skills/items
4. Cast bar (`EntityCast`) + cast ground circle + skill area-size highlight in target selection
4b. Ground skill units (`ZC_SKILL_ENTRY`) — warp portals, traps, song/LP areas
5. Status icons (`StatusIcons`) + status visual attachments/tints on entities
6. Overhead chat bubbles (`EntityDialog`) + emotion sprites and `Emoticons` picker
7. Item obtain toast (`ItemObtain`), announce banner (`Announce`), in-map map-name flash
8. Item info window (`ItemInfo`), skill description (`SkillDescription`)

### Phase 2 — Economy loop

Makes towns functional.

1. NPC store buy/sell (`Store.js` + `NpcStore`)
2. Kafra storage (`Storage.js` + `Storage`)
3. Item drop bounce effect (small polish, item-flow adjacent)
4. Refine/enchant family (later sub-phase; only after buy/sell/storage are stable)

### Phase 3 — Social

1. Whisper UI (`WhisperBox`) + context menu on entities (`ContextMenu`)
2. Party: create/invite/options/HP display (`Group.js` + `PartyFriends`)
3. Friends list
4. Player↔player trade (`Trade.js` + `Trade`)
5. Chat rooms (`ChatRoom.js` + `ChatRoom*` + entity room signs)
6. Guild basics: window, members, notice, emblem display (`Guild.js` + `Guild` + `EntityEmblem`)
7. Vending: buy from shops first, open own shop second (+ signboards)

### Phase 4 — Companions and progression

1. Quest log (`Quest.js` + `Quest`), then `WorldMap`/`Navigation`
2. Pet system (`Pet.js` + `PetInformations`)
3. Homunculus (`Homun.js` + `HomunInformations` + `SkillListMH`)
4. Mercenary (`Mercenary.js` + `MercenaryInformations`)

### Phase 5 — Extended systems

1. Rodex mail (fill the existing stubbed handlers; prefer Rodex over legacy mail)
2. Bank
3. Achievements UI (events already modeled)
4. Attendance check + server-driven UI open (`UIOpen.js`)
5. PvP map state, PvP count/timer
6. Pincode/captcha (only if the embedded server config enables them)

### Phase 6 — Deliberately last / optional offline

Cash shop, roulette, slot machine, PC gold timer, reputation, `Sense`, card illustration, make-arrow/item selections. Several may be permanently skipped for an offline single-player product; decide per item when reached.

### Effect-primitive buildout (on demand)

3D effect primitives (`Cylinder`, `MagicRing`, `GroundAura`, `SpiritSphere`, …) are not a phase. Build each primitive the first time a Phase-1/Phase-4 feature needs it (cast circle → `MagicTarget`; monk/sage gameplay → `SpiritSphere`; songs → `Songs`), expanding `EffectTable` coverage incrementally with an audit against `src/DB/Effects/EffectTable.js`.

## Tracking Conventions

- When an item lands, change its status in the tables above and note the implementing types.
- When a phase finishes, record any intentionally-skipped sub-items with the reason.
- New gaps discovered during implementation get a row in the matching section, not a new document.
- Per-feature validation follows the alignment plan's convention: side-by-side against roBrowserLegacy on a representative map, recording fixed / accepted-difference / blocked.
