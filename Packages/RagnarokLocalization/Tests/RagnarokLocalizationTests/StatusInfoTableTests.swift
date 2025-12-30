//
//  StatusInfoTableTests.swift
//  RagnarokLocalizationTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
@testable import RagnarokLocalization

final class StatusInfoTableTests: XCTestCase {
    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let statusInfoTable = StatusInfoTable(locale: locale)
        let provoke = statusInfoTable.localizedStatusDescription(forStatusID: 0)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
