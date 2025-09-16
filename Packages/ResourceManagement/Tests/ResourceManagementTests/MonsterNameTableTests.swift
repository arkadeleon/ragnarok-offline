//
//  MonsterNameTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ResourceManagement

final class MonsterNameTableTests: XCTestCase {
    let resourceManager = ResourceManager(localURL: Bundle.module.resourceURL!)

    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let monsterNameTable = await resourceManager.monsterNameTable(for: locale)
        let poring = monsterNameTable.localizedMonsterName(forMonsterID: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let monsterNameTable = await resourceManager.monsterNameTable(for: locale)
        let poring = monsterNameTable.localizedMonsterName(forMonsterID: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let monsterNameTable = await resourceManager.monsterNameTable(for: locale)
        let poring = monsterNameTable.localizedMonsterName(forMonsterID: 1002)
        XCTAssertNil(poring)
    }
}
