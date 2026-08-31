//
//  WorldViewDataTests.swift
//  RagnarokScriptTests
//
//  Created by Leon Li on 2026/8/30.
//

import RagnarokResources
import XCTest
@testable import RagnarokScript

final class WorldViewDataTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    var worldViewData: WorldViewData {
        get async {
            await resourceManager.worldViewData()
        }
    }

    func testWorlds() async throws {
        let worlds = await worldViewData.worlds
        XCTAssertEqual(worlds.count, 9)

        let midgard = try XCTUnwrap(worlds.first)
        XCTAssertEqual(midgard.name, "Midgard")
        XCTAssertEqual(midgard.imageName, "worldmap.jpg")
        XCTAssertEqual(midgard.maps.count, 275)
        XCTAssertEqual(midgard.dungeonEntrances.count, 34)

        let isgard = try XCTUnwrap(worlds.last)
        XCTAssertEqual(isgard.name, "Isgard")
        XCTAssertEqual(isgard.imageName, "WorldMap_Isgard.jpg")
    }

    func testMap() async throws {
        let worlds = await worldViewData.worlds
        let midgard = try XCTUnwrap(worlds.first)
        let payonCave = try XCTUnwrap(midgard.maps.first(where: { $0.mapName == "pay_dun00.rsw" }))

        XCTAssertEqual(payonCave.groupIndex, 22)
        XCTAssertEqual(payonCave.rect, WorldViewData.Rect(left: 1065, top: 692, right: 1143, bottom: 726))
        XCTAssertEqual(payonCave.name, "페이욘 동굴 1층")
        XCTAssertEqual(payonCave.monsterLevel, "25")

        // Towns have no monster level.
        let prontera = try XCTUnwrap(midgard.maps.first(where: { $0.mapName == "prontera.rsw" }))
        XCTAssertEqual(prontera.monsterLevel, "")
    }

    func testDungeonEntrance() async throws {
        let worlds = await worldViewData.worlds
        let midgard = try XCTUnwrap(worlds.first)
        let payonDungeon = try XCTUnwrap(midgard.dungeonEntrances.first(where: { $0.groupIndex == 22 }))

        XCTAssertEqual(payonDungeon.rect, WorldViewData.Rect(left: 999, top: 702, right: 1019, bottom: 722))
        XCTAssertEqual(payonDungeon.name, "페이욘 던전")
        XCTAssertEqual(payonDungeon.monsterLevel, "60~70")
    }

    func testGroupIndices() async throws {
        for world in await worldViewData.worlds {
            let mapGroupIndices = Set(world.maps.map(\.groupIndex))
            let dungeonEntranceGroupIndices = Set(world.dungeonEntrances.map(\.groupIndex))

            // Every dungeon entrance represents the maps sharing its group index,
            // and only group indices below 100 have a dungeon entrance.
            XCTAssertTrue(dungeonEntranceGroupIndices.isSubset(of: mapGroupIndices), world.name)
            XCTAssertEqual(mapGroupIndices.filter({ $0 < 100 }), dungeonEntranceGroupIndices, world.name)
        }
    }
}
