//
//  SpriteResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated

final public class SpriteResolver {
    public let resourceManager: ResourceManager

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func resolvePlayerSprites(jobID: UniversalJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        let gender = configuration.gender
        let hairStyleID = configuration.hairStyleID
        let madoType = configuration.madoType

        var sprites: [SpriteResource] = []

        // Shadow
        do {
            let shadowSprite = try await resourceManager.spriteResource(at: ["shadow"])
            shadowSprite.semantic = .shadow
            sprites.append(shadowSprite)
        } catch {
            print(error)
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
                    headPalette = try await resourceManager.paletteResource(at: headPalettePath)
                } catch {
                    print(error)
                }
            }

            do {
                let headSprite = try await resourceManager.spriteResource(at: headSpritePath)
                headSprite.parent = bodySprite
                headSprite.semantic = .playerHead
                headSprite.palette = headPalette
                sprites.append(headSprite)
            } catch {
                print(error)
            }
        }

        // Weapon
        if let weaponID = configuration.weaponID, !jobID.isMadogear {
            if let weaponSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: false, gender: gender, madoType: madoType) {
                do {
                    let weaponSprite = try await resourceManager.spriteResource(at: weaponSpritePath)
                    weaponSprite.semantic = .weapon
                    weaponSprite.orderBySemantic = 0
                    sprites.append(weaponSprite)
                } catch {
                    print(error)
                }
            }
        }

        // Weapon Slash
        if let weaponID = configuration.weaponID {
            if let weaponSlashSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: true, gender: gender, madoType: madoType) {
                do {
                    let weaponSlashSprite = try await resourceManager.spriteResource(at: weaponSlashSpritePath)
                    weaponSlashSprite.semantic = .weapon
                    weaponSlashSprite.orderBySemantic = 1
                    sprites.append(weaponSlashSprite)
                } catch {
                    print(error)
                }
            }
        }

        // Shield
        if let shieldID = configuration.shieldID {
            if let shieldSpritePath = await ResourcePath.shieldSprite(jobID: jobID, shieldID: shieldID, gender: gender) {
                do {
                    let shieldSprite = try await resourceManager.spriteResource(at: shieldSpritePath)
                    shieldSprite.semantic = .shield
                    sprites.append(shieldSprite)
                } catch {
                    print(error)
                }
            }
        }

        // Headgears

        // Garment

        return sprites
    }

    private func playerBodySprite(jobID: UniversalJobID, configuration: SpriteConfiguration) async -> SpriteResource? {
        let gender = configuration.gender
        let madoType = configuration.madoType

        var bodySprite: SpriteResource?
        var bodyPalette: PaletteResource?

        if let outfitID = configuration.outfitID {
            if let bodySpritePath = await ResourcePath.playerBodyAltSprite(jobID: jobID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.spriteResource(at: bodySpritePath)
                } catch {
                    print(error)
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyAltPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.paletteResource(at: bodyPalettePath)
                } catch {
                    print(error)
                }
            }
        } else {
            if let bodySpritePath = await ResourcePath.playerBodySprite(jobID: jobID, gender: gender, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.spriteResource(at: bodySpritePath)
                } catch {
                    print(error)
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.paletteResource(at: bodyPalettePath)
                } catch {
                    print(error)
                }
            }
        }

        bodySprite?.semantic = .playerBody
        bodySprite?.palette = bodyPalette

        return bodySprite
    }
}
