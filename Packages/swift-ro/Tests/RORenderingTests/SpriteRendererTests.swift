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

        let jobID = 0
        let configuration = SpriteConfiguration(jobID: jobID)
        let resolvedSprite = await spriteResolver.resolveSprite(with: configuration)
        XCTAssertEqual(resolvedSprite.parts.count, 2)

        let spriteRenderer = SpriteRenderer(resolvedSprite: resolvedSprite)
        let actionIndex = SpriteActionType.walk.calculateActionIndex(forJobID: jobID, direction: .south)
        let animatedImage = await spriteRenderer.renderAction(at: actionIndex, headDirection: .straight)
        XCTAssertEqual(animatedImage.frames.count, 8)
        XCTAssertEqual(animatedImage.frameWidth, 40)
        XCTAssertEqual(animatedImage.frameHeight, 95)
        XCTAssertEqual(animatedImage.frameInterval, 75 / 1000)
        XCTAssertEqual(animatedImage.frameScale, 2)
    }
}
