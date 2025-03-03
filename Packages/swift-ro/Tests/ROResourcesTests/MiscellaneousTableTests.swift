//
//  MiscellaneousTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/1.
//

import XCTest
@testable import ROResources

final class MiscellaneousTableTests: XCTestCase {
    func testItemRandomOptionNameTable() async throws {
        let mhp = await ItemRandomOptionNameTable.current.itemRandomOptionName(forItemRandomOptionID: 1)
        XCTAssertEqual(mhp, "MHP + %d")
    }

    func testMapMP3NameTable() async throws {
        let prontera = await MapMP3NameTable.current.mapMP3Name(forMapName: "prt_fild08")
        XCTAssertEqual(prontera, "12.mp3")
    }
}
