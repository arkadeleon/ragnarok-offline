//
//  ItemRandomOptionNameTableTests.swift
//  RagnarokLocalizationTests
//
//  Created by Leon Li on 2025/12/30.
//

import XCTest
@testable import RagnarokLocalization

final class ItemRandomOptionNameTableTests: XCTestCase {
    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let itemRandomOptionNameTable = ItemRandomOptionNameTable(locale: locale)
        let mhp = itemRandomOptionNameTable.localizedItemRandomOptionName(forID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }
}
