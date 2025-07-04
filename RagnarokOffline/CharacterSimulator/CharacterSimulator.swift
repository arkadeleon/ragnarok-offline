//
//  CharacterSimulator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/20.
//

import Observation
import ROConstants
import ROCore
import RORendering

@MainActor
@Observable
final class CharacterSimulator {
    struct Configuration {
        var jobID: JobID
        var gender: Gender
        var hairStyle: Int
        var hairColor: Int
        var clothesColor: Int
        var weaponType: WeaponType
        var shield: Int
        var headTop: ObservableItem?
        var headMid: ObservableItem?
        var headBottom: ObservableItem?
        var garment: ObservableItem?

        var actionType: ComposedSprite.ActionType
        var direction: ComposedSprite.Direction
        var headDirection: ComposedSprite.HeadDirection

        var headgears: [Int] {
            [headTop, headMid, headBottom].map {
                $0?.view ?? 0
            }
        }

        init() {
            jobID = .novice
            gender = .male
            hairStyle = 1
            hairColor = -1
            clothesColor = -1
            weaponType = .w_fist
            shield = 0
            headTop = nil
            headMid = nil
            headBottom = nil
            garment = nil

            actionType = .idle
            direction = .south
            headDirection = .straight
        }

        mutating func rotateClockwise() {
            let count = ComposedSprite.Direction.allCases.count
            let rawValue = (direction.rawValue + 1) % count
            direction = ComposedSprite.Direction(rawValue: rawValue)!
        }

        mutating func rotateCounterClockwise() {
            let count = ComposedSprite.Direction.allCases.count
            let rawValue = (direction.rawValue + count - 1) % count
            direction = ComposedSprite.Direction(rawValue: rawValue)!
        }
    }

    var configuration = CharacterSimulator.Configuration() {
        didSet {
            renderSprite()
        }
    }

    var composedSprite: ComposedSprite?
    var animatedImage: AnimatedImage?

    func renderSprite() {
        Task {
            let configuration = ComposedSprite.Configuration(configuration: self.configuration)
            if let composedSprite, composedSprite.configuration == configuration {
                // Do nothing
            } else {
                composedSprite = await ComposedSprite(configuration: configuration, resourceManager: .shared)
            }

            guard let composedSprite else {
                return
            }

            let spriteRenderer = SpriteRenderer()
            animatedImage = await spriteRenderer.render(
                composedSprite: composedSprite,
                actionType: self.configuration.actionType,
                direction: self.configuration.direction,
                headDirection: self.configuration.headDirection
            )
        }
    }
}

@MainActor
extension ComposedSprite.Configuration {
    init(configuration: CharacterSimulator.Configuration) {
        self.init(jobID: configuration.jobID.rawValue)
        self.gender = configuration.gender
        self.hairStyle = configuration.hairStyle
        self.hairColor = configuration.hairColor
        self.clothesColor = configuration.clothesColor
        self.weapon = configuration.weaponType.rawValue
        self.shield = configuration.shield
        self.headgears = configuration.headgears
        self.garment = configuration.garment?.view ?? 0
    }
}
