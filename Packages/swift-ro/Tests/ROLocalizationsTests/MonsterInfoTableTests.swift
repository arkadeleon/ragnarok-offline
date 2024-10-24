//
//  MonsterInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROLocalizations

final class MonsterInfoTableTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let monsterLocalization = MonsterInfoTable(locale: locale)
        let poring = monsterLocalization.localizedMonsterName(forMonsterID: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let monsterLocalization = MonsterInfoTable(locale: locale)
        let poring = monsterLocalization.localizedMonsterName(forMonsterID: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let monsterLocalization = MonsterInfoTable(locale: locale)
        let poring = monsterLocalization.localizedMonsterName(forMonsterID: 1002)
        XCTAssertNil(poring)
    }
}
