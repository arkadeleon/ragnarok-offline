//
//  TileEntityManager.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/20.
//

import RealityKit

@MainActor
final class TileEntityManager {
    let mapGrid: MapGrid
    let rootEntity: Entity

    private let range: Int = 17
    private var tileEntities: [SIMD2<Int> : Entity] = [:]

    init(mapGrid: MapGrid, rootEntity: Entity) {
        self.mapGrid = mapGrid
        self.rootEntity = rootEntity
    }

    func addTileEntities(forCenter center: SIMD2<Int>) {
        #if os(visionOS)
        for offsetX in (-range)...(range) {
            for offsetY in (-range)...(range) {
                let x = center.x + offsetX
                let y = center.y + offsetY

                let tileEntity = Entity()
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
                tileEntity.components.set(HoverEffectComponent())
                tileEntity.components.set(TileComponent(position: [x, y]))

                if 0..<mapGrid.width ~= x && 0..<mapGrid.height ~= y {
                    let cell = mapGrid[[x, y]]
                    let altitude = cell.averageAltitude
                    tileEntity.position = [
                        Float(x) + 0.5,
                        altitude + 0.0001,
                        -Float(y) - 0.5,
                    ]

                    if cell.isWalkable {
                        tileEntity.isEnabled = true
                    } else {
                        tileEntity.isEnabled = false
                    }
                } else {
                    tileEntity.position = [
                        Float(x) + 0.5,
                        0,
                        -Float(y) - 0.5,
                    ]
                    tileEntity.isEnabled = false
                }

                tileEntities[[offsetX, offsetY]] = tileEntity

                rootEntity.addChild(tileEntity)
            }
        }
        #endif
    }

    func updateTileEntities(forCenter center: SIMD2<Int>) {
        #if os(visionOS)
        for offsetX in (-range)...(range) {
            for offsetY in (-range)...(range) {
                let x = center.x + offsetX
                let y = center.y + offsetY

                let tileEntity = tileEntities[[offsetX, offsetY]]!

                tileEntity.components.set(TileComponent(position: [x, y]))

                if 0..<mapGrid.width ~= x && 0..<mapGrid.height ~= y {
                    let cell = mapGrid[[x, y]]
                    let altitude = cell.averageAltitude
                    tileEntity.position = [
                        Float(x) + 0.5,
                        altitude + 0.0001,
                        -Float(y) - 0.5,
                    ]

                    if cell.isWalkable {
                        tileEntity.isEnabled = true
                    } else {
                        tileEntity.isEnabled = false
                    }
                } else {
                    tileEntity.position = [
                        Float(x) + 0.5,
                        0,
                        -Float(y) - 0.5,
                    ]
                    tileEntity.isEnabled = false
                }
            }
        }
        #endif
    }
}
