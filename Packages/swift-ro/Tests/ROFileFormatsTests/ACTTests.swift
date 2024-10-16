//
//  ACTTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/10/12.
//

import XCTest
@testable import ROFileFormats

final class ACTTests: XCTestCase {
    func testACT() throws {
        let url = Bundle.module.url(forResource: "cursors", withExtension: "act")!
        let data = try Data(contentsOf: url)
        let act = try ACT(data: data)

        XCTAssertEqual(act.header, "AC")
        XCTAssertEqual(act.version, "2.5")
        XCTAssertEqual(act.actions.count, 14)
        XCTAssertEqual(act.actions[0].frames.count, 11)
    }
}
