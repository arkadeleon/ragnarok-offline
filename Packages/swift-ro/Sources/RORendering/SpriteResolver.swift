//
//  SpriteResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated
import ROResources

final public class SpriteResolver: Sendable {
    public let resourceManager: ResourceManager

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func resolve(jobID: UniformJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        if jobID.isPlayer {
            await resolvePlayer(jobID: jobID, configuration: configuration)
        } else {
            await resolveNonPlayer(jobID: jobID, configuration: configuration)
        }
    }

    func resolvePlayer(jobID: UniformJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        let gender = configuration.gender
        let hairStyleID = configuration.hairStyleID
        let madoType = configuration.madoType

        var sprites: [SpriteResource] = []

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(jobID: jobID)
            sprites.append(shadowSprite)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        // Body
        let bodySprite = await playerBodySprite(jobID: jobID, configuration: configuration)
        if let bodySprite {
            sprites.append(bodySprite)
        }

        // Head
        if let headSpritePath = ResourcePath.playerHeadSprite(jobID: jobID, hairStyleID: hairStyleID, gender: gender) {
            var headPalette: PaletteResource?
            if let hairColorID = configuration.hairColorID,
               let headPalettePath = ResourcePath.headPalette(jobID: jobID, hairStyleID: hairStyleID, hairColorID: hairColorID, gender: gender) {
                do {
                    headPalette = try await resourceManager.palette(at: headPalettePath)
                } catch {
                    logger.warning("\(error.localizedDescription)")
                }
            }

            do {
                let headSprite = try await resourceManager.sprite(at: headSpritePath)
                headSprite.parent = bodySprite
                headSprite.part = .playerHead
                headSprite.palette = headPalette
                sprites.append(headSprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        // Weapon
        if let weaponID = configuration.weaponID, !jobID.isMadogear,
           let weaponSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: false, gender: gender, madoType: madoType) {
            do {
                let weaponSprite = try await resourceManager.sprite(at: weaponSpritePath)
                weaponSprite.part = .weapon
                weaponSprite.orderByPart = 0
                sprites.append(weaponSprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        // Weapon Slash
        if let weaponID = configuration.weaponID,
           let weaponSlashSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: true, gender: gender, madoType: madoType) {
            do {
                let weaponSlashSprite = try await resourceManager.sprite(at: weaponSlashSpritePath)
                weaponSlashSprite.part = .weapon
                weaponSlashSprite.orderByPart = 1
                sprites.append(weaponSlashSprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        // Shield
        if let shieldID = configuration.shieldID,
           let shieldSpritePath = await ResourcePath.shieldSprite(jobID: jobID, shieldID: shieldID, gender: gender) {
            do {
                let shieldSprite = try await resourceManager.sprite(at: shieldSpritePath)
                shieldSprite.part = .shield
                sprites.append(shieldSprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        // Headgears
        for (i, headgearID) in configuration.headgearIDs.enumerated() {
            guard let headgearSpritePath = await ResourcePath.headgearSprite(headgearID: headgearID, gender: gender) else {
                continue
            }

            do {
                let headgearSprite = try await resourceManager.sprite(at: headgearSpritePath)
                headgearSprite.parent = bodySprite
                headgearSprite.part = .headgear
                headgearSprite.orderByPart = i

                // TODO: Handle headgear offset for Doram

                sprites.append(headgearSprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        // Garment

        return sprites
    }

    func resolveNonPlayer(jobID: UniformJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        var sprites: [SpriteResource] = []

        // Shadow
        do {
            let shadowSprite = try await shadowSprite(jobID: jobID)
            sprites.append(shadowSprite)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }

        if let bodySpritePath = await ResourcePath.nonPlayerSprite(jobID: jobID) {
            do {
                let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                sprites.append(bodySprite)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        return sprites
    }

    private func shadowSprite(jobID: UniformJobID) async throws -> SpriteResource {
        let shadowSpritePath = ResourcePath.spritePath.appending(component: "shadow")
        let shadowSprite = try await resourceManager.sprite(at: shadowSpritePath)
        shadowSprite.part = .shadow

        if let shadowFactor = await ScriptManager.default.shadowFactor(forJobID: jobID.rawValue), shadowFactor >= 0 {
            shadowSprite.scaleFactor = shadowFactor
        }

        return shadowSprite
    }

    private func playerBodySprite(jobID: UniformJobID, configuration: SpriteConfiguration) async -> SpriteResource? {
        let gender = configuration.gender
        let madoType = configuration.madoType

        var bodySprite: SpriteResource?
        var bodyPalette: PaletteResource?

        if let outfitID = configuration.outfitID {
            if let bodySpritePath = await ResourcePath.playerBodyAltSprite(jobID: jobID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                } catch {
                    logger.warning("\(error.localizedDescription)")
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyAltPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
                } catch {
                    logger.warning("\(error.localizedDescription)")
                }
            }
        } else {
            if let bodySpritePath = await ResourcePath.playerBodySprite(jobID: jobID, gender: gender, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                } catch {
                    logger.warning("\(error.localizedDescription)")
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
                } catch {
                    logger.warning("\(error.localizedDescription)")
                }
            }
        }

        bodySprite?.part = .playerBody
        bodySprite?.palette = bodyPalette

        return bodySprite
    }
}
