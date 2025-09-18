//
//  SpriteResourceTests.swift
//  SpriteRenderingTests
//
//  Created by Leon Li on 2025/2/13.
//

import XCTest
import ResourceManagement
import TextEncoding
@testable import SpriteRendering

final class SpriteResourceTests: XCTestCase {
    let resourceManager = ResourceManager(localURL: Bundle.main.resourceURL!)

    func testSpriteResourcePath() async throws {
        let scriptContext = await resourceManager.scriptContext(for: .current)
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
        let path = pathGenerator.generatePlayerBodySpritePath(job: 0, gender: .male)!
        XCTAssertEqual(path.components, ["data", "sprite", K2L("인간족"), K2L("몸통"), K2L("남"), K2L("초보자_남")])
    }
}
