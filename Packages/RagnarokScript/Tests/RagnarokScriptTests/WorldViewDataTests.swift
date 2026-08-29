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
        XCTAssertEqual(midgard.dungeons.count, 34)

        let isgard = try XCTUnwrap(worlds.last)
        XCTAssertEqual(isgard.name, "Isgard")
        XCTAssertEqual(isgard.imageName, "WorldMap_Isgard.jpg")
    }

    func testMap() async throws {
        let worlds = await worldViewData.worlds
        let midgard = try XCTUnwrap(worlds.first)
        let thanatosTower = try XCTUnwrap(midgard.maps.first)

        XCTAssertEqual(thanatosTower.groupIndex, 1)
        XCTAssertEqual(thanatosTower.mapName, "tha_t01.rsw")
        XCTAssertEqual(thanatosTower.rect, WorldViewData.Rect(left: 552, top: 3, right: 646, bottom: 37))
        XCTAssertEqual(thanatosTower.name, "타나토스 타워 하층부 박물관 입구")
        XCTAssertEqual(thanatosTower.monsterLevel, "110")

        // Towns have no monster level.
        let prontera = try XCTUnwrap(midgard.maps.first(where: { $0.mapName == "prontera.rsw" }))
        XCTAssertEqual(prontera.monsterLevel, "")
    }

    func testDungeon() async throws {
        let worlds = await worldViewData.worlds
        let midgard = try XCTUnwrap(worlds.first)
        let thanatosTower = try XCTUnwrap(midgard.dungeons.first)

        XCTAssertEqual(thanatosTower.groupIndex, 1)
        XCTAssertEqual(thanatosTower.rect, WorldViewData.Rect(left: 725, top: 17, right: 745, bottom: 37))
        XCTAssertEqual(thanatosTower.name, "타나토스 타워")
        XCTAssertEqual(thanatosTower.monsterLevel, "110~130")
    }

    func testGroupIndices() async throws {
        for world in await worldViewData.worlds {
            let mapGroupIndices = Set(world.maps.map(\.groupIndex))
            let dungeonGroupIndices = Set(world.dungeons.map(\.groupIndex))

            // Every dungeon is the entrance of the maps sharing its group index,
            // and only group indices below 100 have a dungeon.
            XCTAssertTrue(dungeonGroupIndices.isSubset(of: mapGroupIndices), world.name)
            XCTAssertEqual(mapGroupIndices.filter({ $0 < 100 }), dungeonGroupIndices, world.name)
        }
    }
}
