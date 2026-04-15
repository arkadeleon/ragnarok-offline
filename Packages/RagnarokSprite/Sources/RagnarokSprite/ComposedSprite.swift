//
//  ComposedSprite.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/4/29.
//

import RagnarokFileFormats
import RagnarokResources

final public class ComposedSprite: Sendable {
    public let configuration: ComposedSprite.Configuration
    let resourceManager: ResourceManager

    public let parts: [ComposedSprite.Part]
    public let imf: IMF?

    var mainPart: ComposedSprite.Part? {
        parts.first {
            $0.semantic == .main || $0.semantic == .playerBody
        }
    }

    public init(configuration: ComposedSprite.Configuration, resourceManager: ResourceManager) async throws {
        self.configuration = configuration
        self.resourceManager = resourceManager

        let composer = ComposedSprite.Composer(configuration: configuration, resourceManager: resourceManager)

        if configuration.job.isPlayer {
            parts = try await composer.composePlayerSprite()

            let scriptContext = await resourceManager.scriptContext()
            let pathGenerator = SpritePathGenerator(scriptContext: scriptContext)

            if let imfPath = pathGenerator.generateIMFPath(job: configuration.job, gender: configuration.gender) {
                let imfPath = imfPath.appendingPathExtension("imf")
                let imfData = try await resourceManager.contentsOfResource(at: imfPath)
                imf = try IMF(data: imfData)
            } else {
                imf = nil
            }
        } else {
            parts = try await composer.composeNonPlayerSprite()

            imf = nil
        }
    }

    public init(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager,
        parts: [ComposedSprite.Part],
        imf: IMF? = nil
    ) {
        self.configuration = configuration
        self.resourceManager = resourceManager
        self.parts = parts
        self.imf = imf
    }
}

extension ComposedSprite {
    public struct Part: Sendable {
        public enum Semantic: Sendable {
            case main
            case playerBody
            case playerHead
            case weapon
            case shield
            case headgear
            case garment
            case shadow
        }

        public var sprite: SpriteResource
        public var semantic: ComposedSprite.Part.Semantic
        public var orderBySemantic = 0

        public var parent: SpriteResource?

        public var scaleFactor: Double = 1

        public init(sprite: SpriteResource, semantic: ComposedSprite.Part.Semantic, orderBySemantic: Int = 0) {
            self.sprite = sprite
            self.semantic = semantic
            self.orderBySemantic = orderBySemantic
        }
    }
}
