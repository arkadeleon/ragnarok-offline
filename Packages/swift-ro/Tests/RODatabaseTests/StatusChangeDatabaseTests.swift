//
//  StatusChangeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class StatusChangeDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let sourceURL = Bundle.module.resourceURL!
        let database = StatusChangeDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let stone = await database.statusChange(for: .stone)!
        XCTAssertEqual(stone.status, .stone)
        XCTAssertEqual(stone.icon, .efst_blank)
        XCTAssertEqual(stone.durationLookup, "NPC_PETRIFYATTACK")
        XCTAssertEqual(stone.states, [.nomove, .nocast, .noattack])
        XCTAssertEqual(stone.calcFlags, ["Def_Ele", "Def", "Mdef"])
        XCTAssertEqual(stone.opt1, .stone)
        XCTAssertEqual(stone.flags, ["SendOption", "BossResist", "StopAttacking", "StopCasting", "RemoveOnDamaged"])
        XCTAssertEqual(stone.fail, [.refresh, .inspiration, .power_of_gaia, .gvg_stone, .freeze, .stun, .sleep, .burning])
        XCTAssertEqual(stone.endOnStart, [.aeterna])
        XCTAssertEqual(stone.endReturn, [.stonewait, .stone])
    }

    func testRenewal() async throws {
        let sourceURL = Bundle.module.resourceURL!
        let database = StatusChangeDatabase(sourceURL: sourceURL, mode: .renewal)

        let stone = await database.statusChange(for: .stone)!
        XCTAssertEqual(stone.status, .stone)
        XCTAssertEqual(stone.icon, .efst_blank)
        XCTAssertEqual(stone.durationLookup, "NPC_PETRIFYATTACK")
        XCTAssertEqual(stone.states, [.nomove, .nocast, .noattack])
        XCTAssertEqual(stone.calcFlags, ["Def_Ele", "Def", "Mdef"])
        XCTAssertEqual(stone.opt1, .stone)
        XCTAssertEqual(stone.flags, ["SendOption", "BossResist", "StopAttacking", "StopCasting", "RemoveOnDamaged"])
        XCTAssertEqual(stone.fail, [.refresh, .inspiration, .power_of_gaia, .gvg_stone, .whiteimprison, .freeze, .stun, .sleep, .burning, .protection])
        XCTAssertEqual(stone.endOnStart, [.aeterna])
        XCTAssertEqual(stone.endReturn, [.stonewait, .stone])
    }
}
