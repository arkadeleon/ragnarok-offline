//
//  SpriteResourceTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/13.
//

import XCTest
import ROCore
@testable import RORendering
@testable import ROResources

final class SpriteResourceTests: XCTestCase {
    func testSpriteResourcePath() async throws {
        let localURL = Bundle.module.resourceURL!
        let resourceManager = ResourceManager(locale: .current, localURL: localURL, remoteURL: nil)
        let pathGenerator = ResourcePathGenerator(resourceManager: resourceManager)
        let path = await pathGenerator.generatePlayerBodySpritePath(job: 0, gender: .male)!
        XCTAssertEqual(path.components, ["data", "sprite", K2L("인간족"), K2L("몸통"), K2L("남"), K2L("초보자_남")])
    }
}
