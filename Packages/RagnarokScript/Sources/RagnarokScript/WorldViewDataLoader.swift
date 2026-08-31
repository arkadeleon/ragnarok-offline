//
//  WorldViewDataLoader.swift
//  RagnarokScript
//
//  Created by Leon Li on 2026/8/30.
//

import RagnarokCore
import RagnarokLua
import RagnarokResources

struct WorldViewDataLoader {
    private let scriptNames = [
        "worldviewdata_Language",
        "worldviewdata_table",
        "worldviewdata_list",
    ]

    func worldViewData(using resourceManager: ResourceManager) async -> WorldViewData {
        let context = LuaContext()

        for scriptName in scriptNames {
            guard let script = await resourceManager.script(at: ["worldviewdata", scriptName]) else {
                return WorldViewData()
            }

            do {
                try context.load(script)
            } catch {
                logger.warning("\(error)")
                return WorldViewData()
            }
        }

        guard let worldList = context["World_List"].arrayValue else {
            logger.warning("World_List not found")
            return WorldViewData()
        }

        let worlds = worldList.compactMap { value in
            world(from: value, in: context)
        }
        return WorldViewData(worlds: worlds)
    }

    // A world is `{name, map table name, dungeon entrance table name, image name}`.
    private func world(from value: LuaValue, in context: LuaContext) -> WorldViewData.World? {
        guard let columns = value.arrayValue, columns.count >= 4,
              let name = columns[0].stringValue,
              let mapTableName = columns[1].stringValue,
              let dungeonEntranceTableName = columns[2].stringValue,
              let imageName = columns[3].stringValue else {
            return nil
        }

        let maps = (context[mapTableName].arrayValue ?? []).compactMap { value in
            map(from: value)
        }
        let dungeonEntrances = (context[dungeonEntranceTableName].arrayValue ?? []).compactMap { value in
            dungeonEntrance(from: value)
        }

        return WorldViewData.World(
            name: name,
            imageName: imageName,
            maps: maps,
            dungeonEntrances: dungeonEntrances
        )
    }

    // A map is `{group, map name, left, top, right, bottom, name, monster level}`.
    private func map(from value: LuaValue) -> WorldViewData.Map? {
        guard let columns = value.arrayValue, columns.count >= 8,
              let groupIndex = columns[0].intValue,
              let mapName = columns[1].stringValue,
              let rect = rect(from: columns[2...5]) else {
            return nil
        }

        return WorldViewData.Map(
            groupIndex: groupIndex,
            mapName: mapName,
            rect: rect,
            name: name(from: columns[6]),
            monsterLevel: columns[7].stringValue ?? ""
        )
    }

    // A dungeon entrance is `{group, left, top, right, bottom, name, monster level}`.
    private func dungeonEntrance(from value: LuaValue) -> WorldViewData.DungeonEntrance? {
        guard let columns = value.arrayValue, columns.count >= 7,
              let groupIndex = columns[0].intValue,
              let rect = rect(from: columns[1...4]) else {
            return nil
        }

        return WorldViewData.DungeonEntrance(
            groupIndex: groupIndex,
            rect: rect,
            name: name(from: columns[5]),
            monsterLevel: columns[6].stringValue ?? ""
        )
    }

    private func rect(from columns: ArraySlice<LuaValue>) -> WorldViewData.Rect? {
        let edges = columns.compactMap(\.intValue)
        guard edges.count == 4 else {
            return nil
        }

        return WorldViewData.Rect(left: edges[0], top: edges[1], right: edges[2], bottom: edges[3])
    }

    private func name(from value: LuaValue) -> String {
        value.string(using: .koreanEUC) ?? value.stringValue ?? ""
    }
}
