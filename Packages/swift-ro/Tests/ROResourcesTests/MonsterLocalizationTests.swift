//
//  MonsterLocalizationTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROResources

final class MonsterLocalizationTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let monsterLocalization = MonsterLocalization(locale: locale)
        let poring = await monsterLocalization.localizedName(for: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let monsterLocalization = MonsterLocalization(locale: locale)
        let poring = await monsterLocalization.localizedName(for: 1002)
        XCTAssertEqual(poring, "波利")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let monsterLocalization = MonsterLocalization(locale: locale)
        let poring = await monsterLocalization.localizedName(for: 1002)
        XCTAssertNil(poring)
    }
}
