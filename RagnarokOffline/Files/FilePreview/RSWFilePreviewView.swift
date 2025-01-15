//
//  RSWFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RealityKit
import ROCore
import ROFileFormats
import RORenderers
import SwiftUI

struct RSWFilePreviewView: View {
    var file: ObservableFile

    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView(load: loadRSWFile) { entity in
            ModelViewer(entity: entity)
        }
    }

    nonisolated private func loadRSWFile() async throws -> Entity {
        guard case .grfEntry(let grf, _) = file.file, let data = file.file.contents() else {
            throw FilePreviewError.invalidRSWFile
        }

        let rsw = try RSW(data: data)

        let gatPath = GRF.Path(components: ["data", rsw.files.gat])
        let gatData = try grf.contentsOfEntry(at: gatPath)
        let gat = try GAT(data: gatData)

        let gndPath = GRF.Path(components: ["data", rsw.files.gnd])
        let gndData = try grf.contentsOfEntry(at: gndPath)
        let gnd = try GND(data: gndData)

        let groundEntity = try await Entity.loadGround(gat: gat, gnd: gnd) { textureName in
            let path = GRF.Path(components: ["data", "texture", textureName])
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = CGImageCreateWithData(data)
            return texture
        }

//        let water = Water(gnd: gnd, rsw: rsw) { textureName in
//            let path = GRF.Path(components: ["data", "texture", textureName])
//            guard let data = try? grf.contentsOfEntry(at: path) else {
//                return nil
//            }
//            let texture = textureLoader.newTexture(bmpData: data)
//            return texture
//        }

        var modelEntitiesByName: [String : Entity] = [:]

        for model in rsw.models {
            if modelEntitiesByName[model.modelName] == nil {
                do {
                    let path = GRF.Path(components: ["data", "model", model.modelName])
                    let data = try grf.contentsOfEntry(at: path)
                    let rsm = try RSM(data: data)

                    let instance = Model.createInstance(
                        position: .zero,
                        rotation: .zero,
                        scale: .one,
                        width: 0,
                        height: 0
                    )

                    let modelEntity = try await Entity.loadModel(rsm: rsm, instance: instance) { textureName in
                        let path = GRF.Path(components: ["data", "texture", textureName])
                        let data = try grf.contentsOfEntry(at: path)
                        let texture = CGImageCreateWithData(data)
                        return texture?.removingMagentaPixels()
                    }

                    modelEntitiesByName[model.modelName] = modelEntity
                } catch {
                }
            }

            guard let modelEntity = modelEntitiesByName[model.modelName] else {
                continue
            }

            let modelEntityClone = await modelEntity.clone(recursive: true)

            await MainActor.run {
                modelEntityClone.position = [
                    model.position.x + Float(gnd.width),
                    model.position.y,
                    model.position.z + Float(gnd.height),
                ]
                modelEntityClone.orientation = simd_quatf(angle: radians(model.rotation.z), axis: [0, 0, 1]) * simd_quatf(angle: radians(model.rotation.x), axis: [1, 0, 0]) * simd_quatf(angle: radians(model.rotation.y), axis: [0, 1, 0])
                modelEntityClone.scale = model.scale
            }

            await groundEntity.addChild(modelEntityClone)
        }

        let translation = float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = float4x4(rotationX: radians(-90))
        let scaleFactor = 1 / Float(max(gat.width, gat.height))
        let scale = float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        await MainActor.run {
            groundEntity.transform.matrix = scale * rotation * translation
        }

        let entity = await Entity()
        await entity.addChild(groundEntity)

        return entity
    }
}

#Preview {
    RSWFilePreviewView(file: .previewRSW)
}
