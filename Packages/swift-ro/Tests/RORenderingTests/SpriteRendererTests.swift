//
//  SpriteRendererTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/17.
//

import XCTest
@testable import RORendering
@testable import ROResources

final class SpriteRendererTests: XCTestCase {
    func testSpriteRenderer() async throws {
        let baseURL = Bundle.module.resourceURL!
        let resourceManager = ResourceManager(baseURL: baseURL)
        let spriteResolver = SpriteResolver(resourceManager: resourceManager)

        let configuration = SpriteConfiguration()
        let resolvedSprite = await spriteResolver.resolve(job: 0, configuration: configuration)
        XCTAssertEqual(resolvedSprite.parts.count, 2)

        let spriteRenderer = SpriteRenderer(resolvedSprite: resolvedSprite)
        let actionIndex = PlayerActionType.walk.rawValue * 8 + BodyDirection.south.rawValue
        let animatedImage = await spriteRenderer.renderAction(at: actionIndex, headDirection: .straight)
        XCTAssertEqual(animatedImage.frames.count, 8)
        XCTAssertEqual(animatedImage.frameWidth, 40)
        XCTAssertEqual(animatedImage.frameHeight, 95)
        XCTAssertEqual(animatedImage.frameInterval, 75 / 1000)
        XCTAssertEqual(animatedImage.frameScale, 2)
    }
}
