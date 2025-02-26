//
//  ResourcePathTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/13.
//

import XCTest
@testable import RORendering

final class ResourcePathTests: XCTestCase {
    func testSpriteResourcePath() async throws {
        let path = await ResourcePath.playerBodySprite(jobID: 0, gender: .male)!
        XCTAssertEqual(path.components, ["data", "sprite", "인간족", "몸통", "남", "초보자_남"])
    }
}
