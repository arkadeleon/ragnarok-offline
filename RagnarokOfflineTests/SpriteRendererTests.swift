//
//  SpriteRendererTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/17.
//

import XCTest
import ResourceManagement
@testable import SpriteRendering

final class SpriteRendererTests: XCTestCase {
    func testSpriteRenderer() async throws {
        let configuration = ComposedSprite.Configuration(jobID: 0)
        let composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: .testing)
        XCTAssertEqual(composedSprite.parts.count, 3)

        let spriteRenderer = SpriteRenderer()
        let animation = await spriteRenderer.render(
            composedSprite: composedSprite,
            actionType: .walk,
            direction: .south,
            headDirection: .lookForward
        )
        XCTAssertEqual(animation.frames.count, 8)
        XCTAssertEqual(animation.frameWidth, 40)
        XCTAssertEqual(animation.frameHeight, 95)
        XCTAssertEqual(animation.frameInterval, 75 / 1000)
        XCTAssertEqual(animation.scale, 2)
    }
}
