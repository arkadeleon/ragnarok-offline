//
//  NPCModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import Observation
import RagnarokDatabase
import RagnarokResources
import RagnarokSprite

@Observable
final class NPCModel {
    struct ShopItem: Identifiable {
        var index: Int
        var item: ItemModel
        var price: Int
        var stock: Int?
        var shopType: ShopNPC.ShopType

        var id: Int {
            index
        }

        var badges: [DatabaseBadge] {
            [.price(price, shopType: shopType)]
        }
    }

    let npcName: String
    let map: MapModel
    let x: Int
    let y: Int
    let jobID: Int

    /// The code of a script NPC, or of the script NPC that a duplicate copies.
    let code: String?

    /// The shop of a shop NPC, or of the shop NPC that a duplicate copies.
    let shopNPC: ShopNPC?

    private let resourceManager: ResourceManager

    var animatedImage: AnimatedImage?

    var displayName: String {
        String(npcName.prefix(while: { $0 != "#" && $0 != ":" }))
    }

    init(npcName: String, map: MapModel, x: Int, y: Int, jobID: Int, code: String? = nil, shopNPC: ShopNPC? = nil, resourceManager: ResourceManager) {
        self.npcName = npcName
        self.map = map
        self.x = x
        self.y = y
        self.jobID = jobID
        self.code = code
        self.shopNPC = shopNPC
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

extension NPCModel: Equatable {
    static func == (lhs: NPCModel, rhs: NPCModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension NPCModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NPCModel: Identifiable {
    var id: String {
        "\(npcName),\(map.name),\(x),\(y)"
    }
}
