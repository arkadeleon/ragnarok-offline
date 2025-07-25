//
//  MP3NameTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/1.
//

import XCTest
@testable import ROResources

final class MP3NameTableTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testMP3NameTable() async throws {
        let mp3NameTable = await resourceManager.mp3NameTable()
        let prt_fild08 = mp3NameTable.mp3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prt_fild08, "12.mp3")
    }
}
