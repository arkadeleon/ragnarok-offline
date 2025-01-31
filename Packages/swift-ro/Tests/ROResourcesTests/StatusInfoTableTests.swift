//
//  StatusInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
import ROGenerated
@testable import ROResources

final class StatusInfoTableTests: XCTestCase {
    func testIconName() async throws {
        let statusInfoTable = StatusInfoTable(locale: .current)
        let swordclan = await statusInfoTable.iconName(forStatusID: OfficialStatusChangeID.efst_swordclan.rawValue)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }

    func testLocalizedDescription() async throws {
        let statusInfoTable = StatusInfoTable(locale: .current)
        let provoke = await statusInfoTable.localizedDescription(forStatusID: OfficialStatusChangeID.efst_provoke.rawValue)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
