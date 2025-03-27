//
//  MapScene2D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/7.
//

import ROConstants
import ROGame
import RORendering
import SpriteKit

class MapScene2D: SKScene, MapSceneProtocol {
    weak var mapSceneDelegate: (any MapSceneDelegate)?

    private let tileSize = 20

    private let mapName: String
    private let world: WorldResource

    private let playerNode: SKNode
    private var objectNodes: [UInt32 : SKNode] = [:]

    init(mapName: String, world: WorldResource, position: SIMD2<Int16>) {
        self.mapName = mapName
        self.world = world

        let playerNode = SKSpriteNode()
        playerNode.position = CGPoint(x: Int(position.x) * tileSize, y: Int(position.y) * tileSize)
        playerNode.zPosition = 2
        playerNode.color = .white
        playerNode.anchorPoint = CGPoint(x: 0, y: 0)
        playerNode.size = CGSize(width: tileSize, height: tileSize)
        self.playerNode = playerNode

        super.init(size: .zero)

        self.scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        size = view.bounds.size

        let cameraNode = SKCameraNode()
        cameraNode.position = playerNode.position
        addChild(cameraNode)
        self.camera = cameraNode

        let width = Int(world.gat.width)
        let height = Int(world.gat.height)

        for y in 0..<width {
            for x in 0..<height {
                if world.gat.tile(atX: x, y: y).isWalkable {
                    let cell = SKSpriteNode()
                    cell.position = CGPoint(x: Int(x) * tileSize, y: Int(y) * tileSize)
                    cell.zPosition = 0
                    cell.color = .green
                    cell.anchorPoint = CGPoint(x: 0, y: 0)
                    cell.size = CGSize(width: tileSize, height: tileSize)
                    addChild(cell)
                }
            }
        }

        addChild(playerNode)

        mapSceneDelegate?.mapSceneDidFinishLoading(self)
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let x = Int16(location.x / CGFloat(tileSize))
        let y = Int16(location.y / CGFloat(tileSize))

        mapSceneDelegate?.mapScene(self, didTapPosition: [x, y])
    }
    #else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let x = Int16(location.x / CGFloat(tileSize))
            let y = Int16(location.y / CGFloat(tileSize))

            mapSceneDelegate?.mapScene(self, didTapPosition: [x, y])
        }
    }
    #endif

    // MARK: - MapSceneProtocol

    func onPlayerMoved(_ event: PlayerEvents.Moved) {
        let location = CGPoint(x: Int(event.toPosition.x) * tileSize, y: Int(event.toPosition.y) * tileSize)

        let playerAction = SKAction.move(to: location, duration: 0.2)
        playerNode.run(playerAction)

        let cameraAction = SKAction.move(to: location, duration: 0.2)
        camera?.run(cameraAction)
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        let objectNode = SKLabelNode()
        objectNode.position = CGPoint(x: Int(event.object.position.x) * tileSize, y: Int(event.object.position.y) * tileSize)
        objectNode.zPosition = 1
        objectNode.isHidden = (event.object.effectState == .cloak)
        objectNode.text = event.object.name
        objectNodes[event.object.id] = objectNode
        addChild(objectNode)
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let objectNode = objectNodes[event.objectID] {
            let location = CGPoint(x: Int(event.toPosition.x) * tileSize, y: Int(event.toPosition.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0.2)
            objectNode.run(action)
        }
    }

    func onMapObjectStopped(_ event: MapObjectEvents.Stopped) {
        if let objectNode = objectNodes[event.objectID] {
            let location = CGPoint(x: Int(event.position.x) * tileSize, y: Int(event.position.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0)
            objectNode.run(action)
        }
    }

    func onMapObjectVanished(_ event: MapObjectEvents.Vanished) {
        if let objectNode = objectNodes[event.objectID] {
            objectNode.removeFromParent()
            objectNodes.removeValue(forKey: event.objectID)
        }
    }

    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged) {
        if let objectNode = objectNodes[event.objectID] {
            objectNode.isHidden = (event.effectState == .cloak)
        }
    }
}
