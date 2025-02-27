//
//  SkillTreeDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/10.
//

import XCTest
@testable import RODatabase

final class SkillTreeDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = SkillTreeDatabase.prerenewal

        let acolyte = await database.skillTree(forJobID: .acolyte)!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)
    }

    func testRenewal() async throws {
        let database = SkillTreeDatabase.renewal

        let acolyte = await database.skillTree(forJobID: .acolyte)!
        XCTAssertEqual(acolyte.job, .acolyte)
        XCTAssertEqual(acolyte.inherit, [.novice])
        XCTAssertEqual(acolyte.tree?.count, 15)

        let archBishop = await database.skillTree(forJobID: .arch_bishop)!
        XCTAssertEqual(archBishop.job, .arch_bishop)
        XCTAssertEqual(archBishop.inherit, [.novice, .acolyte, .priest])
        XCTAssertEqual(archBishop.tree?.count, 22)
    }
}
