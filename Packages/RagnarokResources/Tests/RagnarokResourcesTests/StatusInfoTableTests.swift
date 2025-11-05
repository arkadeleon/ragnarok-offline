//
//  StatusInfoTableTests.swift
//  RagnarokResourcesTests
//
//  Created by Leon Li on 2025/1/29.
//

import XCTest
@testable import RagnarokResources

final class StatusInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testIconName() async throws {
        let scriptContext = await resourceManager.scriptContext()
        let swordclan = scriptContext.statusIconName(forStatusID: 762)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }

    func testLocalizedDescription() async throws {
        let statusInfoTable = await resourceManager.statusInfoTable(for: .korean)
        let provoke = statusInfoTable.localizedStatusDescription(forStatusID: 0)
        XCTAssertEqual(provoke, "프로보크(Provoke)")
    }
}
