//
//  ItemComboDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2026/10/24.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class ItemComboDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = ItemComboDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let itemCombos = try await database.itemCombos()
        XCTAssertEqual(itemCombos.count, 105)

        let dragonBreath = itemCombos[0]
        XCTAssertEqual(dragonBreath.combos.count, 3)
        XCTAssertEqual(dragonBreath.combos[0].combo, ["Dragon_Slayer", "Dragon_Breath"])
        XCTAssertEqual(dragonBreath.combos[2].combo, ["Dragon_Breath", "Dragon_Killer"])
        XCTAssertEqual(dragonBreath.script, "bonus2 bAddRace,RC_Dragon,5;\n")
        XCTAssertEqual(dragonBreath.clear, false)
    }

    func testRenewal() async throws {
        let database = ItemComboDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let itemCombos = try await database.itemCombos()
        XCTAssertEqual(itemCombos.count, 5114)

        let dragonBreath = itemCombos[0]
        XCTAssertEqual(dragonBreath.combos.count, 6)
        XCTAssertEqual(dragonBreath.combos[0].combo, ["Dragon_Slayer", "Dragon_Breath"])
        XCTAssertEqual(dragonBreath.combos[5].combo, ["Dragon_Breath", "Dragon_Killer_"])
        XCTAssertEqual(dragonBreath.script, "bonus2 bAddRace,RC_Dragon,5;\n")
        XCTAssertEqual(dragonBreath.clear, false)
    }
}
