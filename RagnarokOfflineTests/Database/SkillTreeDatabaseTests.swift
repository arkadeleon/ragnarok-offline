//
//  SkillTreeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class SkillTreeDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = SkillTreeDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let skillTrees = try await database.skillTrees()

        let acolyte = skillTrees.first(where: { $0.job == .acolyte })!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)
    }

    func testRenewal() async throws {
        let database = SkillTreeDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let skillTrees = try await database.skillTrees()

        let acolyte = skillTrees.first(where: { $0.job == .acolyte })!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)

        let archBishop = skillTrees.first(where: { $0.job == .arch_bishop })!
        XCTAssertEqual(archBishop.job, .arch_bishop)
        XCTAssertEqual(archBishop.inherit, [.novice, .acolyte, .priest])
        XCTAssertEqual(archBishop.tree?.count, 22)
    }
}
