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
        let database = JobDatabase.prerenewal

        let jobs = try await database.jobs()
        XCTAssertEqual(jobs.count, 74)
    }

    func testRenewal() async throws {
        let database = JobDatabase.renewal

        let jobs = try await database.jobs()
        XCTAssertEqual(jobs.count, 171)
    }
}
