//
//  CharacterSimulator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/20.
//

import Constants
import Observation
import SpriteRendering

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
        var headTop: ItemModel?
        var headMid: ItemModel?
        var headBottom: ItemModel?
        var garment: ItemModel?

        var actionType: CharacterActionType
        var direction: CharacterDirection
        var headDirection: CharacterHeadDirection

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
            headDirection = .lookForward
        }

        mutating func rotateClockwise() {
            let count = CharacterDirection.allCases.count
            let rawValue = (direction.rawValue + 1) % count
            direction = CharacterDirection(rawValue: rawValue)!
        }

        mutating func rotateCounterClockwise() {
            let count = CharacterDirection.allCases.count
            let rawValue = (direction.rawValue + count - 1) % count
            direction = CharacterDirection(rawValue: rawValue)!
        }
    }

    var configuration = CharacterSimulator.Configuration() {
        didSet {
            Task {
                await renderSprite()
            }
        }
    }

    var composedSprite: ComposedSprite?
    var animation: SpriteRenderer.Animation?

    func renderSprite() async {
        let configuration = ComposedSprite.Configuration(configuration: self.configuration)
        if let composedSprite, composedSprite.configuration == configuration {
            // Do nothing
        } else {
            do {
                composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: .shared)
            } catch {
                logger.warning("Composed sprite error: \(error)")
            }
        }

        guard let composedSprite else {
            return
        }

        let spriteRenderer = SpriteRenderer()
        animation = await spriteRenderer.render(
            composedSprite: composedSprite,
            actionType: self.configuration.actionType,
            direction: self.configuration.direction,
            headDirection: self.configuration.headDirection
        )
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
