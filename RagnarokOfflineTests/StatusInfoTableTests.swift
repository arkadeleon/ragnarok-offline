//
//  StatusInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
import ROConstants
@testable import ROResources

final class StatusInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testIconName() async throws {
        let scriptContext = await resourceManager.scriptContext(for: .current)
        let swordclan = scriptContext.statusIconName(forStatusID: OfficialStatusChangeID.efst_swordclan.rawValue)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }

    func testLocalizedDescription() async throws {
        let scriptContext = await resourceManager.scriptContext(for: .korean)
        let provoke = scriptContext.localizedStatusDescription(forStatusID: OfficialStatusChangeID.efst_provoke.rawValue)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
