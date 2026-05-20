//
//  ItemCommonInfoTableTests.swift
//  RagnarokResourcesTests
//
//  Created by Leon Li on 2026/5/20.
//

import XCTest
@testable import RagnarokResources

final class ItemCommonInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testItemResourceName() async throws {
        let itemCommonInfoTable = await resourceManager.itemCommonInfoTable()
        let redPotion = itemCommonInfoTable.identifiedItemResourceName(forItemID: 501)
        XCTAssertEqual(redPotion, "빨간포션")
    }
}
