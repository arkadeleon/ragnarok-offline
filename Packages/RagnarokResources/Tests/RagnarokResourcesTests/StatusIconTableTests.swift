//
//  StatusIconTableTests.swift
//  RagnarokResourcesTests
//
//  Created by Leon Li on 2026/10/15.
//

import XCTest
@testable import RagnarokResources

final class StatusIconTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testStatusIconName() async throws {
        let statusIconTable = await resourceManager.statusIconTable()

        let blessing = statusIconTable.statusIconName(forStatusID: 10)
        XCTAssertEqual(blessing, "블레싱.tga")

        let swordclan = statusIconTable.statusIconName(forStatusID: 762)
        XCTAssertEqual(swordclan, "SWORDCLAN.TGA")
    }
}
