//
//  JobDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResources
@testable import RODatabase

final class JobDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = JobDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let novice = await database.jobs().first(where: { $0.id == .novice })!
        XCTAssertEqual(novice.baseASPD[.w_fist], 500)
        XCTAssertEqual(novice.bonusStats[2]![.luk], 1)
        XCTAssertEqual(novice.baseExp[1], 9)
        XCTAssertEqual(novice.jobExp[1], 10)
        XCTAssertEqual(novice.baseHp[1], 40)
        XCTAssertEqual(novice.baseSp[1], 11)
    }

    func testRenewal() async throws {
        let sourceURL = ServerResourceManager.shared.sourceURL
        let database = JobDatabase(sourceURL: sourceURL, mode: .renewal)

        let novice = await database.jobs().first(where: { $0.id == .novice })!
        XCTAssertEqual(novice.baseASPD[.w_fist], 40)
        XCTAssertEqual(novice.bonusStats[2]![.luk], 1)
        XCTAssertEqual(novice.baseExp[1], 548)
        XCTAssertEqual(novice.jobExp[1], 10)
        XCTAssertEqual(novice.baseHp[1], 40)
        XCTAssertEqual(novice.baseSp[1], 11)
    }
}
