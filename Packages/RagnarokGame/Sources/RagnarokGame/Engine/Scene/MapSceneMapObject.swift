//
//  MapSceneMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import QuartzCore
import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import simd

final class MapSceneMapObject {
    let objectID: GameObjectID

    var type: MapObjectType
    var name: String
    var speed: Int

    var job: Int {
        didSet { spriteVersion &+= 1 }
    }

    var gender: Gender {
        didSet { spriteVersion &+= 1 }
    }

    var hairStyle: Int {
        didSet { spriteVersion &+= 1 }
    }

    var hairColor: Int {
        didSet { spriteVersion &+= 1 }
    }

    var clothesColor: Int {
        didSet { spriteVersion &+= 1 }
    }

    var weaponType: WeaponType {
        didSet { spriteVersion &+= 1 }
    }

    var shield: Int {
        didSet { spriteVersion &+= 1 }
    }

    var headTop: Int {
        didSet { spriteVersion &+= 1 }
    }

    var headMid: Int {
        didSet { spriteVersion &+= 1 }
    }

    var headBottom: Int {
        didSet { spriteVersion &+= 1 }
    }

    var garment: Int {
        didSet { spriteVersion &+= 1 }
    }

    var hp: Int
    var maxHp: Int
    var sp: Int
    var maxSp: Int

    var bodyState: StatusChangeOption1
    var healthState: StatusChangeOption2
    var effectState: StatusChangeOption

    var gridPosition: SIMD2<Int>
    var worldPosition: SIMD3<Float>

    var showsHPSPBar = false

    var spriteVersion: UInt64 = 0
    var composedSprite: ComposedSprite?
    var loadedSpriteVersion: UInt64?

    var action: SpriteAction
    var movement: MapObjectMovement?
    var death: MapObjectDeath?
    var cast: MapObjectCast?
    var effectModifiers = MapObjectEffectModifiers()

    /// How long one attack takes.
    var attackDelay: TimeInterval = 0.3

    /// What the object is showing right now, rebuilt every update.
    var resolvedAction: ResolvedSpriteAction?

    var isDead: Bool {
        death != nil
    }

    var opacity: Float {
        (death?.opacity ?? 1) * effectModifiers.effectiveAlphaMultiplier
    }

    init(
        account: AccountInfo,
        character: CharacterInfo,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        objectID = account.accountID

        type = .pc
        name = character.name
        speed = character.speed
        job = character.job
        gender = Gender(rawValue: character.sex) ?? .female
        hairStyle = character.head
        hairColor = character.headPalette
        clothesColor = character.bodyPalette
        weaponType = WeaponType(rawValue: character.weapon) ?? .w_fist
        shield = character.shield
        headTop = character.accessory2
        headMid = character.accessory3
        headBottom = character.accessory
        garment = character.robePalette
        hp = character.hp
        maxHp = character.maxHp
        sp = character.sp
        maxSp = character.maxSp
        bodyState = StatusChangeOption1(rawValue: character.bodyState) ?? .none
        healthState = StatusChangeOption2(rawValue: character.healthState) ?? .none
        effectState = StatusChangeOption(rawValue: character.effectState) ?? .nothing

        self.gridPosition = gridPosition
        self.worldPosition = worldPosition

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: CACurrentMediaTime(),
            completion: .indefinite
        )
    }

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int = 0,
        maxSp: Int = 0,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
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
        weaponType = ItemWeaponTypeTable.weaponType(for: object.weapon) ?? .w_fist
        shield = object.shield
        headTop = object.headTop
        headMid = object.headMid
        headBottom = object.headBottom
        garment = object.garment
        self.hp = hp
        self.maxHp = maxHp
        self.sp = sp
        self.maxSp = maxSp
        bodyState = object.bodyState
        healthState = object.healthState
        effectState = object.effectState

        self.gridPosition = gridPosition
        self.worldPosition = worldPosition

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: CACurrentMediaTime(),
            completion: .indefinite
        )
    }

    func perform(_ actionType: SpriteActionType, completion: SpriteAction.Completion, atTime time: TimeInterval = CACurrentMediaTime()) {
        action.actionType = actionType
        action.startTime = time
        action.elapsedTime = .zero
        action.completion = completion
    }

    func turn(direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        action.direction = direction
        action.headDirection = headDirection
    }

    func setDirection(_ direction: SpriteDirection) {
        action.direction = direction
    }

    /// Turns the head toward `targetPosition` first, and the body only when the head cannot turn any further.
    func look(at targetPosition: SIMD2<Int>) {
        let delta = targetPosition &- gridPosition
        let targetDirection = switch (delta.x.signum(), delta.y.signum()) {
        case (1, 1): 5
        case (1, 0): 6
        case (1, _): 7
        case (0, 1): 4
        case (0, _): 0
        case (_, 1): 3
        case (_, 0): 2
        default: 1
        }

        var direction = action.direction.rawValue
        var headDirection = action.headDirection

        if direction == targetDirection {
            headDirection = .lookForward
        } else {
            switch (direction - targetDirection + 8) % 8 {
            case 1 where headDirection == .lookLeft, 7 where headDirection == .lookRight:
                direction = targetDirection
                headDirection = .lookForward
            case 1, 2, 3:
                direction = (targetDirection + 1) % 8
                headDirection = .lookLeft
            case 5, 6, 7:
                direction = (targetDirection + 7) % 8
                headDirection = .lookRight
            default:
                switch headDirection {
                case .lookForward:
                    direction = targetDirection
                case .lookRight:
                    direction = (targetDirection + 7) % 8
                case .lookLeft:
                    direction = (targetDirection + 1) % 8
                }
            }
        }

        turn(direction: SpriteDirection(rawValue: direction)!, headDirection: headDirection)
    }

    func replanMovement(
        startTime: TimeInterval,
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        pathFinder: PathFinder,
        atTime currentTime: TimeInterval = CACurrentMediaTime()
    ) -> MapObjectMovement {
        let planner = MapObjectMovementPlanner()
        var planned = planner.replan(
            existingMovement: movement,
            currentPosition: gridPosition,
            incomingStartTime: startTime,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            speed: speed,
            pathFinder: pathFinder,
            atTime: currentTime
        )
        planned.update(atTime: currentTime)
        movement = planned
        return planned
    }

    func truncateMovement(to position: SIMD2<Int>, atTime time: TimeInterval = CACurrentMediaTime()) {
        guard var movement = movement?.truncated(to: position, atTime: time) else {
            return
        }

        movement.update(atTime: time)
        self.movement = movement
        perform(.walk, completion: .after(movement.remainingDuration(atTime: time), nextActionType: .idle), atTime: time)
        if let finalDirection = movement.finalDirection {
            setDirection(finalDirection)
        }
    }

    func stopMovement(on position: SIMD2<Int>, atTime time: TimeInterval = CACurrentMediaTime()) {
        let planner = MapObjectMovementPlanner()
        movement = planner.stop(existingMovement: movement, on: position, speed: speed, atTime: time)
        movement?.update(atTime: time)
        gridPosition = position
    }

    func update(atTime currentTime: TimeInterval, deltaTime: TimeInterval = 0, mapGrid: MapGrid) {
        effectModifiers.update(deltaTime: deltaTime)

        let onceDuration: TimeInterval?
        if case .once = action.completion {
            onceDuration = composedSprite?.duration(
                forActionType: action.actionType,
                direction: action.direction,
                headDirection: action.headDirection,
                attackDelay: attackDelay
            )
        } else {
            onceDuration = nil
        }

        action.update(atTime: currentTime, onceDuration: onceDuration)
        movement?.update(atTime: currentTime)
        if let movement {
            gridPosition = movement.currentLocation.position
        }
        worldPosition = if let movement, movement.isMoving {
            mapGrid.worldPosition(at: movement.currentLocation.point)
        } else {
            mapGrid.worldPosition(for: gridPosition)
        }
        death?.update(atTime: currentTime)

        if cast?.isFinished(atTime: currentTime) == true {
            cast = nil
        }
    }

    func resolveAction(cameraAzimuth: Float) -> ResolvedSpriteAction? {
        guard let composedSprite else {
            return nil
        }

        var action = action

        if let movement, movement.isMoving {
            action.actionType = .walk
            action.direction = movement.direction ?? action.direction
            action.elapsedTime = movement.animationElapsedTime
            action.completion = .indefinite
        }

        action.direction = action.direction.adjustedForCameraAzimuth(cameraAzimuth)

        if !SpriteActionType.availableActionTypes(forJobID: job).contains(action.actionType) {
            action.actionType = .idle
        }

        let frameIndex = composedSprite.mainFrameIndex(
            forActionType: action.actionType,
            direction: action.direction,
            headDirection: action.headDirection,
            elapsedTime: action.elapsedTime,
            attackDelay: attackDelay
        )

        return ResolvedSpriteAction(
            actionType: action.actionType,
            direction: action.direction,
            headDirection: action.headDirection,
            elapsedTime: action.elapsedTime,
            frameIndex: frameIndex ?? 0
        )
    }

    func nextPosition(atTime time: TimeInterval) -> SIMD2<Int>? {
        movement?.upcomingPositions(atTime: time).first
    }
}
