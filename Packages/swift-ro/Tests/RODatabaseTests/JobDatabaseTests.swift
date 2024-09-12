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
    override func setUp() async throws {
        try ServerResourceManager.default.prepareForServers()
    }

    func testPrerenewal() async throws {
        let database = JobDatabase.prerenewal

        let jobs = try await database.jobs()
        XCTAssertEqual(jobs.count, 73)
    }

    func testRenewal() async throws {
        let database = JobDatabase.renewal

        let jobs = try await database.jobs()
        XCTAssertEqual(jobs.count, 170)
    }
}
