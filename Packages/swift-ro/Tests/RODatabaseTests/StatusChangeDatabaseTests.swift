//
//  StatusChangeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResource
@testable import RODatabase

final class StatusChangeDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testPrerenewal() async throws {
        let database = StatusChangeDatabase.prerenewal

        let stone = try await database.statusChange(forName: "Stone")!
        XCTAssertEqual(stone.status, "Stone")
        XCTAssertEqual(stone.icon, "EFST_BLANK")
        XCTAssertEqual(stone.durationLookup, "NPC_PETRIFYATTACK")
        XCTAssertEqual(stone.states, ["NoMove", "NoCast", "NoAttack"])
        XCTAssertEqual(stone.calcFlags, ["Def_Ele", "Def", "Mdef"])
        XCTAssertEqual(stone.opt1, "Stone")
        XCTAssertEqual(stone.flags, ["SendOption", "BossResist", "StopAttacking", "StopCasting", "RemoveOnDamaged"])
        XCTAssertEqual(stone.fail, ["Refresh", "Inspiration", "Power_Of_Gaia", "Gvg_Stone", "Freeze", "Stun", "Sleep", "Burning"])
        XCTAssertEqual(stone.endOnStart, ["Aeterna"])
        XCTAssertEqual(stone.endReturn, ["StoneWait", "Stone"])
    }

    func testRenewal() async throws {
        let database = StatusChangeDatabase.renewal

        let stone = try await database.statusChange(forName: "Stone")!
        XCTAssertEqual(stone.status, "Stone")
        XCTAssertEqual(stone.icon, "EFST_BLANK")
        XCTAssertEqual(stone.durationLookup, "NPC_PETRIFYATTACK")
        XCTAssertEqual(stone.states, ["NoMove", "NoCast", "NoAttack"])
        XCTAssertEqual(stone.calcFlags, ["Def_Ele", "Def", "Mdef"])
        XCTAssertEqual(stone.opt1, "Stone")
        XCTAssertEqual(stone.flags, ["SendOption", "BossResist", "StopAttacking", "StopCasting", "RemoveOnDamaged"])
        XCTAssertEqual(stone.fail, ["Refresh", "Inspiration", "Power_Of_Gaia", "Gvg_Stone", "Whiteimprison", "Freeze", "Stun", "Sleep", "Burning"])
        XCTAssertEqual(stone.endOnStart, ["Aeterna"])
        XCTAssertEqual(stone.endReturn, ["StoneWait", "Stone"])
    }
}
