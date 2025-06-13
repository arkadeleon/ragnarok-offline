//
//  JobDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class JobDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let sourceURL = Bundle.module.resourceURL!
        let database = JobDatabase(sourceURL: sourceURL, mode: .prerenewal)

        let novice = await database.jobs().first(where: { $0.id == .novice })!
        XCTAssertEqual(novice.baseASPD[.w_fist], 500)
        XCTAssertEqual(novice.bonusStats[1][.luk], 1)
        XCTAssertEqual(novice.baseExp[0], 9)
        XCTAssertEqual(novice.jobExp[0], 10)
        XCTAssertEqual(novice.baseHp[0], 40)
        XCTAssertEqual(novice.baseSp[0], 11)
    }

    func testRenewal() async throws {
        let sourceURL = Bundle.module.resourceURL!
        let database = JobDatabase(sourceURL: sourceURL, mode: .renewal)

        let novice = await database.jobs().first(where: { $0.id == .novice })!
        XCTAssertEqual(novice.baseASPD[.w_fist], 40)
        XCTAssertEqual(novice.bonusStats[1][.luk], 1)
        XCTAssertEqual(novice.baseExp[0], 548)
        XCTAssertEqual(novice.jobExp[0], 10)
        XCTAssertEqual(novice.baseHp[0], 40)
        XCTAssertEqual(novice.baseSp[0], 11)
    }
}
