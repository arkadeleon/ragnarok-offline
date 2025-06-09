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
        let localURL = Bundle.module.resourceURL!
        let resourceManager = ResourceManager(localURL: localURL, remoteURL: nil)
        let mapMP3NameTable = MapMP3NameTable(resourceManager: resourceManager)

        let prt_fild08 = await mapMP3NameTable.mapMP3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prt_fild08, "12.mp3")
    }
}
