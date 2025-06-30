//
//  MapScene2D.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/7.
//

import ROConstants
import ROGame
import RONetwork
import RORendering
import SpriteKit

private let tileSize = 32

class MapObjectNode: SKSpriteNode {
    var gridPosition: SIMD2<Int>

    init(mapObject: MapObject, position: SIMD2<Int>) {
        self.gridPosition = position

        let color: SKColor =
        switch mapObject.type {
        case .pc: .cyan
        case .monster: .red
        case .npc, .npc2: .yellow
        default: .cyan
        }

        let size = CGSize(width: tileSize, height: tileSize)

        super.init(texture: nil, color: color, size: size)

        self.position = CGPoint(x: position.x * tileSize, y: position.y * tileSize)
        self.zPosition = 1
        self.isHidden = (mapObject.effectState == .cloak)
        self.name = "\(mapObject.objectID)"
        self.anchorPoint = CGPoint(x: 0, y: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func move(through path: [SIMD2<Int>]) {
        var actions: [SKAction] = []

        for position in path.dropFirst() {
            let location = CGPoint(
                x: position.x * tileSize,
                y: position.y * tileSize
            )

            actions.append(.move(to: location, duration: 0.2))
            actions.append(.run {
                self.gridPosition = position
            })
        }

        removeAction(forKey: "move")
        run(SKAction.sequence(actions), withKey: "move")
    }
}

class MapScene2D: SKScene, MapSceneProtocol {
    let mapName: String
    let world: WorldResource
    let player: MapObject
    let playerPosition: SIMD2<Int>

    weak var mapSceneDelegate: (any MapSceneDelegate)?

    private let playerNode: MapObjectNode
    private var mapObjects: [UInt32 : MapObject] = [:]

    private let pathfinder: Pathfinder

    init(mapName: String, world: WorldResource, player: MapObject, playerPosition: SIMD2<Int>) {
        self.mapName = mapName
        self.world = world
        self.player = player
        self.playerPosition = playerPosition

        let playerNode = MapObjectNode(mapObject: player, position: playerPosition)
        playerNode.color = .blue
        playerNode.zPosition = 2
        self.playerNode = playerNode

        self.pathfinder = Pathfinder(gat: world.gat)

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
                if world.gat.tileAt(x: x, y: y).isWalkable {
                    let tileNode = SKSpriteNode()
                    tileNode.name = "tile"
                    tileNode.position = CGPoint(x: x * tileSize, y: y * tileSize)
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

        let x = Int(location.x / CGFloat(tileSize))
        let y = Int(location.y / CGFloat(tileSize))

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

        let x = Int(location.x / CGFloat(tileSize))
        let y = Int(location.y / CGFloat(tileSize))

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
        let playerNode = playerNode
        let startPosition = playerNode.gridPosition
        let endPosition = event.endPosition
        let path = pathfinder.findPath(from: startPosition, to: endPosition)

        var playerActions: [SKAction] = []
        var cameraActions: [SKAction] = []

        for position in path.dropFirst() {
            let location = CGPoint(x: position.x * tileSize, y: position.y * tileSize)

            let playerAction = SKAction.move(to: location, duration: 0.2)
            playerActions.append(playerAction)
            playerActions.append(SKAction.run {
                playerNode.gridPosition = position
            })

            let cameraAction = SKAction.move(to: location, duration: 0.2)
            cameraActions.append(cameraAction)
        }

        playerNode.removeAction(forKey: "move")
        playerNode.run(SKAction.sequence(playerActions), withKey: "move")

        camera?.removeAction(forKey: "move")
        camera?.run(SKAction.sequence(cameraActions), withKey: "move")
    }

    func onMapObjectSpawned(_ event: MapObjectEvents.Spawned) {
        if let objectNode = childNode(withName: "\(event.object.objectID)") as? MapObjectNode {
            let location = CGPoint(x: event.position.x * tileSize, y: event.position.y * tileSize)
            let action = SKAction.move(to: location, duration: 0)
            objectNode.run(action)
        } else {
            let objectNode = MapObjectNode(mapObject: event.object, position: event.position)
            addChild(objectNode)
        }
    }

    func onMapObjectMoved(_ event: MapObjectEvents.Moved) {
        if let objectNode = childNode(withName: "\(event.object.objectID)") as? MapObjectNode {
            let startPosition = objectNode.gridPosition
            let endPosition = event.endPosition
            let path = pathfinder.findPath(from: startPosition, to: endPosition)

            objectNode.move(through: path)
        } else {
            let objectNode = MapObjectNode(mapObject: event.object, position: event.endPosition)
            addChild(objectNode)
        }
    }

    func onMapObjectStopped(_ event: MapObjectEvents.Stopped) {
        if let objectNode = childNode(withName: "\(event.objectID)") {
            let location = CGPoint(x: event.position.x * tileSize, y: event.position.y * tileSize)
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

    func onMapObjectActionPerformed(_ event: MapObjectEvents.ActionPerformed) {
    }

    func onItemSpawned(_ event: ItemEvents.Spawned) {
    }

    func onItemVanished(_ event: ItemEvents.Vanished) {
    }
}
