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
        let monsterSummons = try await database.monsterSummons()

        let bloodyDeadBranch = monsterSummons.first(where: { $0.group == "Bloody_Dead_Branch" })!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 44)
    }

    func testRenewal() async throws {
        let database = MonsterSummonDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let monsterSummons = try await database.monsterSummons()

        let bloodyDeadBranch = monsterSummons.first(where: { $0.group == "BLOODY_DEAD_BRANCH" })!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 46)
    }
}
