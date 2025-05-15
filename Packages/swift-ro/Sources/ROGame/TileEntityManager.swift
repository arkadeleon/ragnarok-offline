//
//  TileEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/20.
//

import RealityKit
import ROFileFormats

@MainActor
public class TileEntityManager {
    public let gat: GAT
    public let rootEntity: Entity

    private let range: Int = 17
    private var tileEntities: [SIMD2<Int> : ModelEntity] = [:]

    public init(gat: GAT, rootEntity: Entity) {
        self.gat = gat
        self.rootEntity = rootEntity
    }

    public func addTileEntities(for position: SIMD2<Int16>) {
        for relativeX in (-range)...(range) {
            for relativeY in (-range)...(range) {
                let x = Int(position.x) + relativeX
                let y = Int(position.y) + relativeY

                let tileEntity = ModelEntity()
                tileEntity.name = "tile"

                let mesh = MeshResource.generatePlane(width: 1, depth: 1)

                var material = SimpleMaterial()
                material.color = SimpleMaterial.BaseColor(tint: .yellow)
                material.triangleFillMode = .lines

                tileEntity.components.set(ModelComponent(mesh: mesh, materials: [material]))
                tileEntity.components.set(CollisionComponent(shapes: [
                    .generateBox(width: 1, height: 0, depth: 1)
                ]))
                tileEntity.components.set(InputTargetComponent())
                tileEntity.components.set(TileComponent(x: x, y: y))

                if 0..<Int(gat.width) ~= x && 0..<Int(gat.height) ~= y {
                    let tile = gat.tileAt(x: x, y: y)
                    let altitude = tile.averageAltitude / 5
                    tileEntity.position = [Float(x) + 0.5, -altitude, -(Float(y) + 0.5)]

                    if tile.isWalkable {
                        tileEntity.isEnabled = true
                    } else {
                        tileEntity.isEnabled = false
                    }
                } else {
                    tileEntity.position = [Float(x) + 0.5, 0, -(Float(y) + 0.5)]
                    tileEntity.isEnabled = false
                }

                tileEntities[SIMD2(x: relativeX, y: relativeY)] = tileEntity

                rootEntity.addChild(tileEntity)
            }
        }
    }

    public func updateTileEntities(for position: SIMD2<Int16>) {
        for relativeX in (-range)...(range) {
            for relativeY in (-range)...(range) {
                let x = Int(position.x) + relativeX
                let y = Int(position.y) + relativeY

                let tileEntity = tileEntities[SIMD2(x: relativeX, y: relativeY)]!

                tileEntity.components.set(TileComponent(x: x, y: y))

                if 0..<Int(gat.width) ~= x && 0..<Int(gat.height) ~= y {
                    let tile = gat.tileAt(x: x, y: y)
                    let altitude = tile.averageAltitude / 5
                    tileEntity.position = [Float(x) + 0.5, -altitude, -(Float(y) + 0.5)]

                    if tile.isWalkable {
                        tileEntity.isEnabled = true
                    } else {
                        tileEntity.isEnabled = false
                    }
                } else {
                    tileEntity.position = [Float(x) + 0.5, 0, -(Float(y) + 0.5)]
                    tileEntity.isEnabled = false
                }
            }
        }
    }
}
