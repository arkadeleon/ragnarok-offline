//
//  SpritePathTests.swift
//  RagnarokSpriteTests
//
//  Created by Leon Li on 2025/2/13.
//

import RagnarokResources
import TextEncoding
import XCTest
@testable import RagnarokSprite

final class SpritePathTests: XCTestCase {
    let resourceManager = ResourceManager.testing

    func testSpriteResourcePath() async throws {
        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = SpritePathGenerator(scriptContext: scriptContext)
        let path = pathGenerator.generatePlayerBodySpritePath(job: 0, gender: .male)!
        XCTAssertEqual(path.components, ["data", "sprite", K2L("인간족"), K2L("몸통"), K2L("남"), K2L("초보자_남")])
    }
}
