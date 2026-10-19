//
//  NPCModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import Observation
import RagnarokResources
import RagnarokSprite

@Observable
final class NPCModel {
    let npcName: String
    let x: Int
    let y: Int
    let jobID: Int

    private let resourceManager: ResourceManager

    var animatedImage: AnimatedImage?

    var displayName: String {
        String(npcName.prefix(while: { $0 != "#" && $0 != ":" }))
    }

    init(npcName: String, x: Int, y: Int, jobID: Int, resourceManager: ResourceManager) {
        self.npcName = npcName
        self.x = x
        self.y = y
        self.jobID = jobID
        self.resourceManager = resourceManager
    }

    @MainActor
    func fetchAnimatedImage() async {
        if animatedImage != nil {
            return
        }

        let composedSprite: ComposedSprite
        do {
            let configuration = ComposedSprite.Configuration(jobID: jobID)
            composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
        } catch {
            logger.warning("Composed sprite error: \(error)")
            return
        }

        let renderer = SpriteAnimationRenderer()
        let animation = await renderer.render(
            composedSprite: composedSprite,
            actionType: .idle
        )
        animatedImage = AnimatedImage(animation: animation)
    }
}

extension NPCModel: Identifiable {
    var id: String {
        "\(npcName),\(x),\(y)"
    }
}
