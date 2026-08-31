# World Map Plan (2026-08)

Add a world map window to `RagnarokGame`, built on the client's own
`worldviewdata` lua tables instead of the hand-written table roBrowserLegacy
ships in `src/DB/Map/WorldMap.js`.

Reference implementation: `roBrowserLegacy/src/UI/Components/WorldMap/`.
Where this plan differs from it, the difference is called out.

## Data source

Five files under `data/luafiles514/lua files/worldviewdata/`, all Lua 5.1
bytecode, same format as the scripts `ContextLoader` already loads:

| File | Global | Contents |
| --- | --- | --- |
| `worldviewdata_Language.lub` | `WORLD_MSGID` | name id → name string |
| `worldviewdata_table.lub` | `worldtable_*` | map sections and dungeon entrance boxes |
| `worldviewdata_list.lub` | `World_List` | the nine world maps |
| `worldviewdata_info.lub` | `worldview_info` | box colors, alphas, font sizes |
| `worldviewdata_f.lub` | query functions | thin accessors, not needed |

`worldtable_*` reads `WORLD_MSGID` while it is being built, so Language must
load first, then table, then list.

`World_List` is an array of `{name, mapTable, dungeonTable, image}`:

| Name | Map table | Image |
| --- | --- | --- |
| Midgard | `worldtable_main` | `worldmap.jpg` |
| Midgard North | `worldtable_north` | `midgard_north.jpg` |
| Midgard Pw02 | `WorldMap_Pw02` | `WorldMap_Pw-02.jpg` |
| Dimension | `worldtable_dimensions` | `worldmap_dimension.bmp` |
| Crack | `worldtable_Crack_of_Dimension1` | `Crack_of_Dimension1.jpg` |
| localizing 01 | `worldtable_localizing1` | `worldmap_localizing1.bmp` |
| localizing 02 | `worldtable_localizing2` | `worldmap_localizing2.bmp` |
| Far-Star | `worldtable_Doram` | `pasta.jpg` |
| Isgard | `worldtable_Isgard` | `WorldMap_Isgard.jpg` |

A map table row has eight columns:

```lua
{1, "tha_t01.rsw", 552, 3, 646, 37, WORLD_MSGID.MSI_1_THA_T01, "110"}
-- group, rsw name, left, top, right, bottom, name, monster level
```

A dungeon entrance table row (`<mapTable>_Dun`) has seven, and no rsw name:

```lua
{1, 725, 17, 745, 37, WORLD_MSGID.MSI_DUN1, "110~130"}
-- group, left, top, right, bottom, name, monster level range
```

Rows sharing a group number belong to one dungeon: the `_Dun` row is its
entrance box drawn on the world map, and the map rows are its floors. Groups
numbered 100 and up have no `_Dun` row — those are standalone fields and towns.

367 sections and 51 dungeon entrance boxes across the nine maps, against 209
sections across four maps in the roBrowser table.

Rects are pixels in a 1280x1024 space, and every world map image is 1280x1024,
so a rect maps to the drawn image by a single scale factor. Note the columns are
left/top/right/bottom, not roBrowser's left/top/width/height.

Images live in `ResourcePath.userInterfaceDirectory`. GRF lookup is
case insensitive, so `WorldMap_Pw-02.jpg` is safe; the remote client provider
serves over HTTP, where the case has to match what is on the server.

## Names are the one hard part

`WORLD_MSGID` strings are CP949 in a kRO client. The pinned `ragnarok-lua`
(`bc82609`) converts Lua strings with `NSASCIIStringEncoding`, so every name
with a Korean byte comes back as `NSNull`. Numbers, rsw names, and level strings
are ASCII and survive.

So section names come from `RagnarokLocalization.MapNameTable`, which is
localized and covers 332 of the 367 rsw names. The 35 it misses are newer maps:
`lasagna`/`lasa_*`, `jor_*`, `hem_*`, `ch1_*`, `oz_dun0*`, `icecastle`,
`odin_past`, `ygg_roots`, `prt_mk`, `abyss_04`, `bif_fild0*`, `gw_fild0*`,
`dic_dun03`, `ein_dun03`, `mag_dun03`.

Dungeon entrance boxes have no rsw name at all, so `MapNameTable` cannot name
them. Their only source is `WORLD_MSGID`.

Two ways out, decided before Step 3:

1. Bump `ragnarok-lua` to `master`, which replaces the Objective-C context with
   a Swift one whose `LuaValue.string(using:)` decodes CP949. `ScriptContext`
   and `ContextLoader` need migrating to the new API — small, but its own change.
2. Leave dungeon entrance boxes unnamed for now and show only the level range.

## Not in scope

- Navigation and cross-map path finding. roBrowser opens `Navigation` when a
  section is clicked; nothing equivalent exists here, so clicking selects a
  section and shows its information instead.
- Party member markers, which need party packets.
- Monster overlays (`worldmap_mob.bmp`, the `Sreach*` colors in
  `worldview_info`) and the airplane.
- Episode filtering. roBrowser filters by `Configs.worldMapSettings.episode`;
  the client tables carry no episode, so every section is shown.

## Steps

Each step is one reviewable change.

1. **Data layer.** `WorldViewData` model plus a loader in `RagnarokScript` that
   parses the three lub files into Swift values, reached through
   `ResourceManager.worldViewData()` like `scriptContext()`. Its own Lua context,
   loaded on demand — the global `ContextLoader` runs at startup and nothing else
   needs these tables. Tests cover the row shapes and the map/entrance pairing.
2. **Static map.** `WorldMapView`: aspect-fit background, world map switcher,
   section rects drawn with `Canvas`. No interaction yet.
3. **Dungeons.** Dungeon entrance boxes, floor-to-entrance connector lines (the
   geometry in `WorldMap.js` `createWorldMapView` carries over), and the current
   map highlighted from `MapScene.mapName`.
4. **Selection.** Tap or hover a section to show its name, rsw name, monster
   level, and the `map/<rsw>.bmp` thumbnail, loaded the way `MinimapView` does.
5. **Zoom and pan.** A 1280x1024 map scaled to an iPhone screen leaves sections
   a few points wide, so pinch and drag are needed. roBrowser has neither.
6. **Wire up.** Enable the existing `bt_map.bmp` button in `MenuView` and present
   the view as a full-screen layer over `MapSceneView`.

## Open decisions

- Which way out of the name problem above.
- Whether to dim sections whose map is missing from the rAthena `map_index`.
  Sensible for an offline client, and a deliberate difference from roBrowser.
