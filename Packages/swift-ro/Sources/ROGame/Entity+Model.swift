//
//  Entity+Model.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import RealityKit
import RORenderers
import RORendering

extension Entity {
    public static func modelEntity(model: ModelResource) async throws -> Entity {
        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let modelEntity = try await Entity.loadModel(rsm: model.rsm, instance: instance) { textureName in
            let components = textureName.split(separator: "\\").map(String.init)
            let texturePath = ResourcePath.texturePath.appending(components: components)
            let texture = try await ResourceManager.default.image(at: texturePath, removesMagentaPixels: true)
            return texture
        }

        return modelEntity
    }
}
