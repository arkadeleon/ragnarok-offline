//
//  StatusInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
import RagnarokConstants
@testable import ResourceManagement

final class StatusInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testIconName() async throws {
        let scriptContext = await resourceManager.scriptContext()
        let swordclan = scriptContext.statusIconName(forStatusID: OfficialStatusChangeID.efst_swordclan.rawValue)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }

    func testLocalizedDescription() async throws {
        let statusInfoTable = await resourceManager.statusInfoTable(for: .korean)
        let provoke = statusInfoTable.localizedStatusDescription(forStatusID: OfficialStatusChangeID.efst_provoke.rawValue)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
