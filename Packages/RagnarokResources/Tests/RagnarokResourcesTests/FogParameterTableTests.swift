//
//  FogParameterTableTests.swift
//  RagnarokResourcesTests
//
//  Created by Leon Li on 2026/8/16.
//

import XCTest
@testable import RagnarokResources

final class FogParameterTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testFogParameterTable() async throws {
        let fogParameterTable = await resourceManager.fogParameterTable()

        let pay_dun00 = try XCTUnwrap(fogParameterTable.fogParameter(forMapName: "pay_dun00.rsw"))
        XCTAssertEqual(pay_dun00.near, 0.1)
        XCTAssertEqual(pay_dun00.far, 0.9)
        XCTAssertEqual(pay_dun00.color.alpha, 0xFF / 255, accuracy: 0.001)
        XCTAssertEqual(pay_dun00.color.red, 0x04 / 255, accuracy: 0.001)
        XCTAssertEqual(pay_dun00.color.green, 0x00 / 255, accuracy: 0.001)
        XCTAssertEqual(pay_dun00.color.blue, 0x9A / 255, accuracy: 0.001)
        XCTAssertEqual(pay_dun00.factor, 0.3)

        let izlude = fogParameterTable.fogParameter(forMapName: "izlude.rsw")
        XCTAssertNil(izlude)
    }
}
