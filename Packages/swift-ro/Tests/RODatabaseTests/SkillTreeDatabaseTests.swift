//
//  SkillTreeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
import rAthenaResource
@testable import RODatabase

final class SkillTreeDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testPrerenewal() async throws {
        let database = SkillTreeDatabase.prerenewal

        let acolyte = try await database.skillTree(forJobID: Job.acolyte.id)!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)
    }

    func testRenewal() async throws {
        let database = SkillTreeDatabase.renewal

        let acolyte = try await database.skillTree(forJobID: Job.acolyte.id)!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)

        let archBishop = try await database.skillTree(forJobID: Job.archBishop.id)!
        XCTAssertEqual(archBishop.job, .archBishop)
        XCTAssertEqual(archBishop.inherit, [.novice, .acolyte, .priest])
        XCTAssertEqual(archBishop.tree?.count, 22)
    }
}
