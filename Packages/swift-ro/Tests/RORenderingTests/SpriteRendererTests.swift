//
//  SpriteRendererTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/2/17.
//

import XCTest
@testable import RORendering

final class SpriteRendererTests: XCTestCase {
    func testSpriteRenderer() async throws {
        let url = Bundle.module.resourceURL!
        let resourceManager = ResourceManager(url: url)
        let spriteResolver = SpriteResolver(resourceManager: resourceManager)

        let configuration = SpriteConfiguration()
        let sprites = await spriteResolver.resolvePlayerSprites(jobID: 0, configuration: configuration)
        XCTAssertEqual(sprites.count, 2)

        let spriteRenderer = SpriteRenderer()
        let images = spriteRenderer.drawPlayerSprites(sprites: sprites, actionType: .walk, direction: .south, headDirection: .straight)
        XCTAssertEqual(images.count, 8)
        XCTAssertEqual(images[0].width, 40 * 2)
        XCTAssertEqual(images[0].height, 95 * 2)
    }
}
