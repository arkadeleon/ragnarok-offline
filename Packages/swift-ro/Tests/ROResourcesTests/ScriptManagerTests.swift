//
//  ScriptManagerTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/3/3.
//

import XCTest
@testable import ROResources

final class ScriptManagerTests: XCTestCase {
    let scriptManager = ScriptManager(
        resourceManager: ResourceManager(baseURL: Bundle.module.resourceURL!)
    )

    func testAccessoryNameTable() async throws {
        let goggles = await scriptManager.accessoryName(forAccessoryID: 1)
        XCTAssertEqual(goggles, "_고글")
    }

    func testShadowFactorTable() async throws {
        let warp = await scriptManager.shadowFactor(forJobID: 45)
        XCTAssertEqual(warp, 0)

        let chonchon = await scriptManager.shadowFactor(forJobID: 1011)
        XCTAssertEqual(chonchon, 0.5)
    }
}
