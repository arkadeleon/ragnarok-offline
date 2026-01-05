//
//  StatusChangeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class StatusChangeDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = StatusChangeDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let statusChanges = try await database.statusChanges()

        let stone = statusChanges.first(where: { $0.status == .stone })!
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
        let database = StatusChangeDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let statusChanges = try await database.statusChanges()

        let stone = statusChanges.first(where: { $0.status == .stone })!
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
