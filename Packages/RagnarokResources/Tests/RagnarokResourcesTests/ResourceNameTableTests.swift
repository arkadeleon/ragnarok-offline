//
//  ResourceNameTableTests.swift
//  RagnarokResourcesTests
//
//  Created by Leon Li on 2025/10/30.
//

import Testing
@testable import RagnarokResources

struct ResourceNameTableTests {
    let resourceManager = ResourceManager.testing

    @Test func testResourceNameTable() async throws {
        let resourceNameTable = await resourceManager.resourceNameTable()
        let new11 = resourceNameTable.resourceName(forAlias: "new_1-1.rsw")
        #expect(new11 == "new_zone01.rsw")
    }
}
