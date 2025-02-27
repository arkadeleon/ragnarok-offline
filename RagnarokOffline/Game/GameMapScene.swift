//
//  GameMapScene.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/7.
//

import RODatabase
import ROGame
import ROGenerated
import SpriteKit

class GameMapScene: SKScene {
    var positionTapHandler: ((SIMD2<Int16>) -> Void)?

    private let tileSize = 20

    private let grid: Map.Grid
    private let playerNode: SKNode
    private var objectNodes: [UInt32 : SKNode] = [:]

    init(name: String, grid: Map.Grid, position: SIMD2<Int16>) {
        self.grid = grid

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

        for y in 0..<grid.ys {
            for x in 0..<grid.xs {
                if grid.cell(atX: x, y: y).isWalkable {
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
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let x = Int16(location.x / CGFloat(tileSize))
        let y = Int16(location.y / CGFloat(tileSize))

        positionTapHandler?([x, y])
    }
    #else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let x = Int16(location.x / CGFloat(tileSize))
            let y = Int16(location.y / CGFloat(tileSize))

            positionTapHandler?([x, y])
        }
    }
    #endif

    func movePlayer(from fromPosition: SIMD2<Int16>, to toPosition: SIMD2<Int16>) {
        let location = CGPoint(x: Int(toPosition.x) * tileSize, y: Int(toPosition.y) * tileSize)

        let playerAction = SKAction.move(to: location, duration: 0.2)
        playerNode.run(playerAction)

        let cameraAction = SKAction.move(to: location, duration: 0.2)
        camera?.run(cameraAction)
    }

    func addObject(_ object: MapObject) {
        let objectNode = SKLabelNode()
        objectNode.position = CGPoint(x: Int(object.position.x) * tileSize, y: Int(object.position.y) * tileSize)
        objectNode.zPosition = 1
        objectNode.isHidden = (object.effectState == .cloak)
        objectNode.text = object.name
        objectNodes[object.id] = objectNode
        addChild(objectNode)
    }

    func moveObject(_ objectID: UInt32, from fromPosition: SIMD2<Int16>, to toPosition: SIMD2<Int16>) {
        if let objectNode = objectNodes[objectID] {
            let location = CGPoint(x: Int(toPosition.x) * tileSize, y: Int(toPosition.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0.2)
            objectNode.run(action)
        }
    }

    func moveObject(_ objectID: UInt32, to position: SIMD2<Int16>) {
        if let objectNode = objectNodes[objectID] {
            let location = CGPoint(x: Int(position.x) * tileSize, y: Int(position.y) * tileSize)
            let action = SKAction.move(to: location, duration: 0)
            objectNode.run(action)
        }
    }

    func removeObject(_ objectID: UInt32) {
        if let objectNode = objectNodes[objectID] {
            objectNode.removeFromParent()
            objectNodes.removeValue(forKey: objectID)
        }
    }

    func updateObject(_ objectID: UInt32, effectState: StatusChangeOption) {
        if let objectNode = objectNodes[objectID] {
            objectNode.isHidden = (effectState == .cloak)
        }
    }
}
