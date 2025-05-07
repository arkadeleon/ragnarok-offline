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

        let configuration = ComposedSprite.Configuration(jobID: 0)
        let composedSprite = await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
        XCTAssertEqual(composedSprite.parts.count, 2)

        let spriteRenderer = SpriteRenderer()
        let animatedImage = await spriteRenderer.render(composedSprite: composedSprite, actionType: .walk, direction: .south, headDirection: .straight)
        XCTAssertEqual(animatedImage.frames.count, 8)
        XCTAssertEqual(animatedImage.frameWidth, 40)
        XCTAssertEqual(animatedImage.frameHeight, 95)
        XCTAssertEqual(animatedImage.frameInterval, 75 / 1000)
        XCTAssertEqual(animatedImage.frameScale, 2)
    }
}
