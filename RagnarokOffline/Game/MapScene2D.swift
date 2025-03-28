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
    private var mapObjects: [UInt32 : MapObject] = [:]

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
                    let tileNode = SKSpriteNode()
                    tileNode.name = "tile"
                    tileNode.position = CGPoint(x: Int(x) * tileSize, y: Int(y) * tileSize)
                    tileNode.zPosition = 0
                    tileNode.color = .green
                    tileNode.anchorPoint = CGPoint(x: 0, y: 0)
                    tileNode.size = CGSize(width: tileSize, height: tileSize)
                    addChild(tileNode)
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

        let nodes = nodes(at: location)
        for node in nodes {
            if node is SKLabelNode, let name = node.name, let objectID = UInt32(name) {
                mapSceneDelegate?.mapScene(self, didTapMapObjectWith: objectID)
                break
            }
            if node.name == "tile" {
                mapSceneDelegate?.mapScene(self, didTapTileAt: [x, y])
                break
            }
        }
    }
    #else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }

        let x = Int16(location.x / CGFloat(tileSize))
        let y = Int16(location.y / CGFloat(tileSize))

        let nodes = nodes(at: location)
        for node in nodes {
            if node is SKLabelNode, let name = node.name, let objectID = UInt32(name) {
                mapSceneDelegate?.mapScene(self, didTapMapObjectWith: objectID)
                break
            }
            if node.name == "tile" {
                mapSceneDelegate?.mapScene(self, didTapTileAt: [x, y])
                break
            }
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
        if let objectNode = childNode(withName: "\(event.object.id)") {
            let location = CGPoint(x: Int(event.object.position.x) * tileSize, y: Int(event.object.position.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0)
            objectNode.run(action)
        } else {
            let objectNode = SKLabelNode()
            objectNode.name = "\(event.object.id)"
            objectNode.position = CGPoint(x: Int(event.object.position.x) * tileSize, y: Int(event.object.position.y) * tileSize)
            objectNode.zPosition = 1
            objectNode.isHidden = (event.object.effectState == .cloak)
            objectNode.text = event.object.name
            addChild(objectNode)
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let objectNode = childNode(withName: "\(event.object.id)") {
            let location = CGPoint(x: Int(event.toPosition.x) * tileSize, y: Int(event.toPosition.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0.2)
            objectNode.run(action)
        } else {
            let objectNode = SKLabelNode()
            objectNode.position = CGPoint(x: Int(event.toPosition.x) * tileSize, y: Int(event.toPosition.y) * tileSize)
            objectNode.zPosition = 1
            objectNode.isHidden = (event.object.effectState == .cloak)
            objectNode.text = event.object.name
            addChild(objectNode)
        }
    }

    func onMapObjectStopped(_ event: MapObjectEvents.Stopped) {
        if let objectNode = childNode(withName: "\(event.objectID)") {
            let location = CGPoint(x: Int(event.position.x) * tileSize, y: Int(event.position.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0)
            objectNode.run(action)
        }
    }

    func onMapObjectVanished(_ event: MapObjectEvents.Vanished) {
        if let objectNode = childNode(withName: "\(event.objectID)") {
            objectNode.removeFromParent()
        }
    }

    func onMapObjectStateChanged(_ event: MapObjectEvents.StateChanged) {
        if let objectNode = childNode(withName: "\(event.objectID)") {
            objectNode.isHidden = (event.effectState == .cloak)
        }
    }
}
