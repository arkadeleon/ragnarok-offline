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
    func testPrerenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = MonsterSummonDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let bloodyDeadBranch = await database.monsterSummon(forGroup: "Bloody_Dead_Branch")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 44)
    }

    func testRenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = MonsterSummonDatabase(sourceURL: sourceURL, mode: .renewal)

        let bloodyDeadBranch = await database.monsterSummon(forGroup: "BLOODY_DEAD_BRANCH")!
        XCTAssertEqual(bloodyDeadBranch.default, "BAPHOMET")
        XCTAssertEqual(bloodyDeadBranch.summon.count, 46)
    }
}
