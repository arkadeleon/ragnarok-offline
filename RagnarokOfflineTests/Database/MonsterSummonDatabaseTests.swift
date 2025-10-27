//
//  MonsterSummonDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/9.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class MonsterSummonDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = MonsterSummonDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)

        let bloodyDeadBranch = await database.monsterSummon(forGroup: "Bloody_Dead_Branch")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 44)
    }

    func testRenewal() async throws {
        let database = MonsterSummonDatabase(baseURL: serverResourceBaseURL, mode: .renewal)

        let bloodyDeadBranch = await database.monsterSummon(forGroup: "BLOODY_DEAD_BRANCH")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 46)
    }
}
