//
//  MonsterSummonDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/9.
//

import XCTest
import rAthenaResources
@testable import RODatabase

final class MonsterSummonDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try await ServerResourceBundle.shared.load()
    }

    func testPrerenewal() async throws {
        let database = MonsterSummonDatabase.prerenewal

        let bloodyDeadBranch = try await database.monsterSummon(forGroup: "Bloody_Dead_Branch")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 44)
    }

    func testRenewal() async throws {
        let database = MonsterSummonDatabase.renewal

        let bloodyDeadBranch = try await database.monsterSummon(forGroup: "BLOODY_DEAD_BRANCH")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 46)
    }
}
