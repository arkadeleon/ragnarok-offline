//
//  SpriteResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROConstants
import ROResources

final public class SpriteResolver: Sendable {
    public let resourceManager: ResourceManager

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func resolve(itemID: Int) async -> ResolvedSprite {
        var resolvedSprite = ResolvedSprite()

        if let path = await ResourcePath(itemSpritePathWithItemID: itemID) {
            do {
                let sprite = try await resourceManager.sprite(at: path)
                resolvedSprite.append(sprite, semantic: .main)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        return resolvedSprite
    }

    public func resolve(job: UniformJob, configuration: SpriteConfiguration) async -> ResolvedSprite {
        if job.isPlayer {
            await resolvePlayer(job: job, configuration: configuration)
        } else {
            await resolveNonPlayer(job: job, configuration: configuration)
        }
    }

    func resolvePlayer(job: UniformJob, configuration: SpriteConfiguration) async -> ResolvedSprite {
        let gender = configuration.gender
        let hairStyle = configuration.hairStyle
        let hairColor = configuration.hairColor
        let weapon = configuration.weapon
        let shield = configuration.shield
        let madoType = configuration.madoType

        var resolvedSprite = ResolvedSprite()

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(job: job)
            resolvedSprite.append(shadowSprite, semantic: .shadow)
        } catch {
            logger.warning("Shadow sprite error: \(error.localizedDescription)")
        }

        // Body
        let bodySprite = await playerBodySprite(job: job, configuration: configuration)
        if let bodySprite {
            resolvedSprite.append(bodySprite, semantic: .playerBody)
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
                resolvedSprite.append(headSprite, semantic: .playerHead)
            } catch {
                logger.warning("Head sprite error: \(error.localizedDescription)")
            }
        }

        // Weapon
        if weapon > 0 && !job.isMadogear {
            if let weaponSpritePath = await ResourcePath.weaponSprite(job: job, weapon: weapon, isSlash: false, gender: gender, madoType: madoType) {
                do {
                    let weaponSprite = try await resourceManager.sprite(at: weaponSpritePath)
                    resolvedSprite.append(weaponSprite, semantic: .weapon, order: 0)
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
                    resolvedSprite.append(weaponSlashSprite, semantic: .weapon, order: 1)
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
                    resolvedSprite.append(shieldSprite, semantic: .shield)
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

                resolvedSprite.append(headgearSprite, semantic: .headgear, order: i)
            } catch {
                logger.warning("Headgear sprite error: \(error.localizedDescription)")
            }
        }

        // Garment

        return resolvedSprite
    }

    func resolveNonPlayer(job: UniformJob, configuration: SpriteConfiguration) async -> ResolvedSprite {
        var resolvedSprite = ResolvedSprite()

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(job: job)
            resolvedSprite.append(shadowSprite, semantic: .shadow)
        } catch {
            logger.warning("Shadow sprite error: \(error.localizedDescription)")
        }

        if let bodySpritePath = await ResourcePath.nonPlayerSprite(job: job) {
            do {
                let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                resolvedSprite.append(bodySprite, semantic: .main)
            } catch {
                logger.warning("Body sprite error: \(error.localizedDescription)")
            }
        }

        return resolvedSprite
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
