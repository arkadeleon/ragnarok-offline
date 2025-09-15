//
//  ComposedSprite.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/29.
//

import ROFileFormats
import ROResources

final public class ComposedSprite: Sendable {
    public let configuration: ComposedSprite.Configuration
    package let resourceManager: ResourceManager

    let parts: [ComposedSprite.Part]
    let imf: IMF?

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

            let scriptContext = await resourceManager.scriptContext(for: .current)
            let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

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
}

extension ComposedSprite {
    struct Part {
        enum Semantic {
            case main
            case playerBody
            case playerHead
            case weapon
            case shield
            case headgear
            case garment
            case shadow
        }

        var sprite: SpriteResource
        var semantic: ComposedSprite.Part.Semantic
        var orderBySemantic = 0

        var parent: SpriteResource?

        init(sprite: SpriteResource, semantic: ComposedSprite.Part.Semantic, orderBySemantic: Int = 0) {
            self.sprite = sprite
            self.semantic = semantic
            self.orderBySemantic = orderBySemantic
        }
    }
}
