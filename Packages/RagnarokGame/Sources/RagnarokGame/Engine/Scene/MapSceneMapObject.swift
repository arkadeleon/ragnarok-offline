//
//  MapSceneMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import simd

final class MapSceneMapObject {
    let objectID: GameObjectID

    var type: MapObjectType
    var name: String
    var speed: Int
    var job: Int
    var gender: Gender
    var hairStyle: Int
    var hairColor: Int
    var clothesColor: Int
    var weaponType: WeaponType
    var shield: Int
    var headTop: Int
    var headMid: Int
    var headBottom: Int
    var garment: Int
    var hp: Int
    var maxHp: Int
    var sp: Int
    var maxSp: Int
    var bodyState: StatusChangeOption1
    var healthState: StatusChangeOption2
    var effectState: StatusChangeOption

    var gridPosition: SIMD2<Int>

    var composedSprite: ComposedSprite?

    var action: SpriteAction
    var movement: MapObjectMovement?
    var death: MapObjectDeath?
    var cast: MapObjectCast?

    /// How long one attack takes.
    var attackDelay: Duration = .milliseconds(300)

    /// What the object is showing right now, rebuilt every update.
    var resolvedAction: ResolvedSpriteAction?

    var isDead: Bool {
        death != nil
    }

    var opacity: Float {
        death?.opacity ?? 1
    }

    init(
        account: AccountInfo,
        character: CharacterInfo,
        gridPosition: SIMD2<Int>,
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

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
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

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )
    }

    func perform(_ actionType: SpriteActionType, completion: SpriteAction.Completion, at time: ContinuousClock.Instant = .now) {
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
        startTime: ContinuousClock.Instant,
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        pathFinder: PathFinder,
        at time: ContinuousClock.Instant = .now
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
            at: time
        )
        planned.update(at: time)
        movement = planned
        return planned
    }

    func truncateMovement(to position: SIMD2<Int>, at time: ContinuousClock.Instant = .now) {
        guard var movement = movement?.truncated(to: position, at: time) else {
            return
        }

        movement.update(at: time)
        self.movement = movement
        perform(.walk, completion: .after(movement.remainingDuration(at: time), nextActionType: .idle), at: time)
        if let finalDirection = movement.finalDirection {
            setDirection(finalDirection)
        }
    }

    func stopMovement(on position: SIMD2<Int>, at time: ContinuousClock.Instant = .now) {
        let planner = MapObjectMovementPlanner()
        movement = planner.stop(existingMovement: movement, on: position, speed: speed, at: time)
        movement?.update(at: time)
        gridPosition = movement?.currentLocation.position ?? position
    }

    func update(at time: ContinuousClock.Instant) {
        let onceDuration: Duration?
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

        action.update(atTime: time, onceDuration: onceDuration)
        movement?.update(at: time)
        death?.update(at: time)

        if cast?.isFinished(at: time) == true {
            cast = nil
        }
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        movement?.nextPosition(at: time)
    }
}
