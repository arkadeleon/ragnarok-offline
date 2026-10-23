//
//  ItemGroupDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2026/10/23.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class ItemGroupDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = ItemGroupDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let itemGroups = try await database.itemGroups()

        let blueBox = itemGroups.first(where: { $0.group == "BLUEBOX" })!
        XCTAssertEqual(blueBox.subGroups.count, 1)
        XCTAssertEqual(blueBox.subGroups[0].subGroup, 1)
        XCTAssertEqual(blueBox.subGroups[0].algorithm, .random)
        XCTAssertEqual(blueBox.subGroups[0].list.count, 1022)
        XCTAssertEqual(blueBox.subGroups[0].list[0].item, "Red_Potion")
        XCTAssertEqual(blueBox.subGroups[0].list[0].rate, 12)
        XCTAssertEqual(blueBox.subGroups[0].list[0].amount, 1)

        let itemDatabase = ItemDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let items = try await itemDatabase.items()

        let sourceItemIDs = await database.sourceItemIDs(in: items)
        XCTAssertEqual(sourceItemIDs["BLUEBOX"], [603])
    }

    func testRenewal() async throws {
        let database = ItemGroupDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let itemGroups = try await database.itemGroups()

        let acidBombBox = itemGroups.first(where: { $0.group == "ACIDBOMB_10_BOX" })!
        XCTAssertEqual(acidBombBox.subGroups.count, 1)
        XCTAssertEqual(acidBombBox.subGroups[0].subGroup, 0)
        XCTAssertEqual(acidBombBox.subGroups[0].algorithm, .all)
        XCTAssertEqual(acidBombBox.subGroups[0].list.count, 2)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].index, 0)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].item, "Fire_Bottle")
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].rate, 0)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].amount, 10)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].uniqueId, true)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].stacked, true)
        XCTAssertEqual(acidBombBox.subGroups[0].list[0].bound, .none)
        XCTAssertEqual(acidBombBox.subGroups[0].list[1].item, "Acid_Bottle")

        let itemDatabase = ItemDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let items = try await itemDatabase.items()

        let sourceItemIDs = await database.sourceItemIDs(in: items)
        XCTAssertEqual(sourceItemIDs["BLUEBOX"], [603])
    }
}
