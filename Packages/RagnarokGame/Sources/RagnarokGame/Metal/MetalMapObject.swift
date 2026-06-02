//
//  MetalMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import simd

class MetalMapObject {
    let objectID: GameObjectID
    var type: MapObjectType
    var name: String
    var speed: Int
    var job: Int
    var gender: Gender
    var hairStyle: Int
    var hairColor: Int
    var clothesColor: Int
    var weapon: Int
    var shield: Int
    var headTop: Int
    var headMid: Int
    var headBottom: Int
    var garment: Int
    var hp: Int
    var maxHp: Int
    var bodyState: StatusChangeOption1
    var healthState: StatusChangeOption2
    var effectState: StatusChangeOption

    var gridPosition: SIMD2<Int>
    var worldPosition: SIMD3<Float>

    var animation: MetalAnimation
    var movement: MetalMovement?

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) {
        objectID = object.objectID
        type = object.type
        name = object.name
        speed = object.speed
        job = object.job
        gender = object.gender
        hairStyle = object.hairStyle
        hairColor = object.hairColor
        clothesColor = object.clothesColor
        weapon = object.weapon
        shield = object.shield
        headTop = object.headTop
        headMid = object.headMid
        headBottom = object.headBottom
        garment = object.garment
        self.hp = hp
        self.maxHp = maxHp
        bodyState = object.bodyState
        healthState = object.healthState
        effectState = object.effectState

        self.gridPosition = gridPosition
        self.worldPosition = worldPosition

        animation = MetalAnimation(
            action: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )
    }

    func perform(_ action: SpriteActionType, completion: MetalAnimationCompletion, at time: ContinuousClock.Instant = .now) {
        animation.action = action
        animation.startTime = time
        animation.elapsedTime = .zero
        animation.completion = completion
    }

    func turn(direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        animation.direction = direction
        animation.headDirection = headDirection
    }

    func setDirection(_ direction: SpriteDirection) {
        animation.direction = direction
    }

    func replanMovement(
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        pathFinder: PathFinder,
        mapGrid: MapGrid,
        at time: ContinuousClock.Instant = .now
    ) -> MetalMovement {
        let planner = MetalMovementPlanner(pathFinder: pathFinder)
        var planned = planner.replan(
            existingMovement: movement,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            speed: speed,
            at: time
        )
        planned.updateWorldPath { mapGrid.worldPosition(for: $0) }
        planned.update(atTime: time)
        movement = planned
        return planned
    }

    func stopMovement() {
        movement = nil
    }

    func update(at time: ContinuousClock.Instant) {
        animation.update(atTime: time)
        movement?.update(atTime: time)
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        movement?.nextPosition(at: time)
    }
}

extension MetalMapObject {
    static func make(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int = 0,
        maxSp: Int = 0,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) -> MetalMapObject {
        switch object.type {
        case .pc:
            MetalPlayerObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                sp: sp,
                maxSp: maxSp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        case .monster:
            MetalMonsterObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        default:
            MetalNPCObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        }
    }
}

final class MetalPlayerObject: MetalMapObject {
    var sp: Int
    var maxSp: Int

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int,
        maxSp: Int,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) {
        self.sp = sp
        self.maxSp = maxSp
        super.init(
            object: object,
            hp: hp,
            maxHp: maxHp,
            gridPosition: gridPosition,
            worldPosition: worldPosition,
            direction: direction,
            headDirection: headDirection
        )
    }
}

final class MetalMonsterObject: MetalMapObject {}

final class MetalNPCObject: MetalMapObject {}

extension ComposedSprite.Configuration {
    init(object: MetalMapObject) {
        self.init(jobID: object.job)
        self.gender = object.gender
        self.hairStyle = object.hairStyle
        self.hairColor = object.hairColor
        self.clothesColor = object.clothesColor
        self.weapon = object.weapon
        self.shield = object.shield
        self.headgears = [object.headTop, object.headMid, object.headBottom]
        self.garment = object.garment

        self.updateHairStyle()
    }
}
