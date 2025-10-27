//
//  FileFormatTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/10/12.
//

import RagnarokResources
import XCTest
@testable import RagnarokFileFormats

final class FileFormatTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testACT() async throws {
        let data = try await resourceManager.contentsOfResource(at: ["data", "sprite", "cursors.act"])
        let act = try ACT(data: data)

        XCTAssertEqual(act.header, "AC")
        XCTAssertEqual(act.version, "2.5")
        XCTAssertEqual(act.actions.count, 14)
        XCTAssertEqual(act.actions[0].frames.count, 11)
    }
}
