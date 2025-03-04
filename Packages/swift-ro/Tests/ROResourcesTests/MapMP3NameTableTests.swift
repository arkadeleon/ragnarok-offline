//
//  MapMP3NameTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/1.
//

import XCTest
@testable import ROResources

final class MapMP3NameTableTests: XCTestCase {
    func testMapMP3NameTable() async throws {
        let resourceManager = ResourceManager(baseURL: Bundle.module.resourceURL!)
        let mapMP3NameTable = MapMP3NameTable(resourceManager: resourceManager)

        let prontera = await mapMP3NameTable.mapMP3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prontera, "12.mp3")
    }
}
