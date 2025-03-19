//
//  RSWFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RealityKit
import ROCore
import ROFileFormats
import RORendering
import ROResources
import SwiftUI

struct RSWFilePreviewView: View {
    var file: File

    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView(load: loadRSWFile) { entity in
            ModelViewer(entity: entity)
        }
    }

    nonisolated private func loadRSWFile() async throws -> Entity {
        guard let data = await file.contents() else {
            throw FilePreviewError.invalidRSWFile
        }

        let rsw = try RSW(data: data)

        let gatPath = ResourcePath(components: ["data", rsw.files.gat])
        let gatData = try await ResourceManager.default.contentsOfResource(at: gatPath)
        let gat = try GAT(data: gatData)

        let gndPath = ResourcePath(components: ["data", rsw.files.gnd])
        let gndData = try await ResourceManager.default.contentsOfResource(at: gndPath)
        let gnd = try GND(data: gndData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)

        let worldEntity = try await Entity.worldEntity(world: world)

//        let water = Water(gnd: gnd, rsw: rsw) { textureName in
//            let path = GRFPath(components: ["data", "texture", textureName])
//            guard let data = try? grf.contentsOfEntry(at: path) else {
//                return nil
//            }
//            let texture = textureLoader.newTexture(bmpData: data)
//            return texture
//        }

        let translation = simd_float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 1 / Float(max(gat.width, gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        await MainActor.run {
            worldEntity.transform.matrix = scale * rotation * translation
        }

        let entity = await Entity()
        await entity.addChild(worldEntity)

        return entity
    }
}

#Preview {
    RSWFilePreviewView(file: .previewRSW)
}
