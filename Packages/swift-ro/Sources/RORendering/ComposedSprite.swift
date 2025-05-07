//
//  ComposedSprite.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/29.
//

import ROResources

public struct ComposedSprite: Sendable {
    public let configuration: SpriteConfiguration
    public let resourceManager: ResourceManager

    var parts: [ComposedSprite.Part] = []

    var mainPart: ComposedSprite.Part? {
        parts.first {
            $0.semantic == .main || $0.semantic == .playerBody
        }
    }

    public init(configuration: SpriteConfiguration, resourceManager: ResourceManager) async {
        self.configuration = configuration
        self.resourceManager = resourceManager

        if configuration.job.isPlayer {
            await composePlayerSprite()
        } else {
            await composeNonPlayerSprite()
        }
    }

    mutating func composePlayerSprite() async {
        let job = configuration.job
        let gender = configuration.gender
        let hairStyle = configuration.hairStyle
        let hairColor = configuration.hairColor
        let weapon = configuration.weapon
        let shield = configuration.shield
        let madoType = configuration.madoType

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(job: job)
            append(shadowSprite, semantic: .shadow)
        } catch {
            logger.warning("Shadow sprite error: \(error.localizedDescription)")
        }

        // Body
        let bodySprite = await playerBodySprite(job: job, configuration: configuration)
        if let bodySprite {
            append(bodySprite, semantic: .playerBody)
        }

        // Head
        if let headSpritePath = ResourcePath.playerHeadSprite(job: job, hairStyle: hairStyle, gender: gender) {
            var headPalette: PaletteResource?
            if hairColor > -1 {
                if let headPalettePath = ResourcePath.headPalette(job: job, hairStyle: hairStyle, hairColor: hairColor, gender: gender) {
                    do {
                        headPalette = try await resourceManager.palette(at: headPalettePath)
                    } catch {
                        logger.warning("Head palette error: \(error.localizedDescription)")
                    }
                }
            }

            do {
                let headSprite = try await resourceManager.sprite(at: headSpritePath)
                headSprite.parent = bodySprite
                headSprite.palette = headPalette
                append(headSprite, semantic: .playerHead)
            } catch {
                logger.warning("Head sprite error: \(error.localizedDescription)")
            }
        }

        // Weapon
        if weapon > 0 && !job.isMadogear {
            if let weaponSpritePath = await ResourcePath.weaponSprite(job: job, weapon: weapon, isSlash: false, gender: gender, madoType: madoType) {
                do {
                    let weaponSprite = try await resourceManager.sprite(at: weaponSpritePath)
                    append(weaponSprite, semantic: .weapon, order: 0)
                } catch {
                    logger.warning("Weapon sprite error: \(error.localizedDescription)")
                }
            }
        }

        // Weapon Slash
        if weapon > 0 {
            if let weaponSlashSpritePath = await ResourcePath.weaponSprite(job: job, weapon: weapon, isSlash: true, gender: gender, madoType: madoType) {
                do {
                    let weaponSlashSprite = try await resourceManager.sprite(at: weaponSlashSpritePath)
                    append(weaponSlashSprite, semantic: .weapon, order: 1)
                } catch {
                    logger.warning("Weapon sprite error: \(error.localizedDescription)")
                }
            }
        }

        // Shield
        if shield > 0 {
            if let shieldSpritePath = await ResourcePath.shieldSprite(job: job, shield: shield, gender: gender) {
                do {
                    let shieldSprite = try await resourceManager.sprite(at: shieldSpritePath)
                    append(shieldSprite, semantic: .shield)
                } catch {
                    logger.warning("Shield sprite error: \(error.localizedDescription)")
                }
            }
        }

        // Headgears
        for (i, headgear) in configuration.headgears.enumerated() {
            guard headgear > 0 else {
                continue
            }

            guard let headgearSpritePath = await ResourcePath.headgearSprite(headgear: headgear, gender: gender) else {
                continue
            }

            do {
                let headgearSprite = try await resourceManager.sprite(at: headgearSpritePath)
                headgearSprite.parent = bodySprite

                // TODO: Handle headgear offset for Doram

                append(headgearSprite, semantic: .headgear, order: i)
            } catch {
                logger.warning("Headgear sprite error: \(error.localizedDescription)")
            }
        }

        // Garment
    }

    mutating func composeNonPlayerSprite() async {
        let job = configuration.job

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(job: job)
            append(shadowSprite, semantic: .shadow)
        } catch {
            logger.warning("Shadow sprite error: \(error.localizedDescription)")
        }

        if let bodySpritePath = await ResourcePath.nonPlayerSprite(job: job) {
            do {
                let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                append(bodySprite, semantic: .main)
            } catch {
                logger.warning("Body sprite error: \(error.localizedDescription)")
            }
        }
    }

    mutating func append(_ sprite: SpriteResource, semantic: ComposedSprite.Part.Semantic, order: Int = 0) {
        let part = ComposedSprite.Part(sprite: sprite, semantic: semantic, orderBySemantic: order)
        parts.append(part)
    }

    private func shadowSprite(job: UniformJob) async throws -> SpriteResource {
        let shadowSpritePath = ResourcePath.spriteDirectory.appending("shadow")
        let shadowSprite = try await resourceManager.sprite(at: shadowSpritePath)

        if let shadowFactor = await ScriptManager.default.shadowFactor(forJobID: job.rawValue), shadowFactor >= 0 {
            shadowSprite.scaleFactor = shadowFactor
        }

        return shadowSprite
    }

    private func playerBodySprite(job: UniformJob, configuration: SpriteConfiguration) async -> SpriteResource? {
        let gender = configuration.gender
        let clothesColor = configuration.clothesColor
        let outfit = configuration.outfit
        let madoType = configuration.madoType

        var bodySprite: SpriteResource?
        var bodyPalette: PaletteResource?

        if outfit > 0 {
            if let bodySpritePath = await ResourcePath.playerBodyAltSprite(job: job, gender: gender, costumeID: outfit, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                } catch {
                    logger.warning("Body sprite error: \(error.localizedDescription)")
                }
            }

            if clothesColor > -1 {
                if let bodyPalettePath = ResourcePath.bodyAltPalette(job: job, clothesColor: clothesColor, gender: gender, costumeID: outfit, madoType: madoType) {
                    do {
                        bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
                    } catch {
                        logger.warning("Body sprite error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            if let bodySpritePath = await ResourcePath.playerBodySprite(job: job, gender: gender, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                } catch {
                    logger.warning("Body sprite error: \(error.localizedDescription)")
                }
            }

            if clothesColor > -1 {
                if let bodyPalettePath = ResourcePath.bodyPalette(job: job, clothesColor: clothesColor, gender: gender, madoType: madoType) {
                    do {
                        bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
                    } catch {
                        logger.warning("Body sprite error: \(error.localizedDescription)")
                    }
                }
            }
        }

        bodySprite?.palette = bodyPalette

        return bodySprite
    }
}

extension ComposedSprite {
    struct Part {
        enum Semantic {
            case main
            case playerBody
            case playerHead
            case headgear
            case garment
            case weapon
            case shield
            case shadow
        }

        var sprite: SpriteResource
        var semantic: ComposedSprite.Part.Semantic
        var orderBySemantic = 0

        init(sprite: SpriteResource, semantic: ComposedSprite.Part.Semantic, orderBySemantic: Int = 0) {
            self.sprite = sprite
            self.semantic = semantic
            self.orderBySemantic = orderBySemantic
        }
    }
}
