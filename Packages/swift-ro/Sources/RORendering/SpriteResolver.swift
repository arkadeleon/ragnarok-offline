//
//  SpriteResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated

final class SpriteResolver {
    let resourceManager: ResourceManager

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func resolvePlayerSprites(jobID: UniversalJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        let gender = configuration.gender
        let headID = configuration.headID
        let madoType = configuration.madoType

        var sprites: [SpriteResource] = []

        // Body
        if let outfitID = configuration.outfitID {
            if let bodySpritePath = await ResourcePath.playerBodyAltSprite(jobID: jobID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    let bodySprite = try await resourceManager.spriteResource(at: bodySpritePath)
                    bodySprite.semantic = .playerBody
                    sprites.append(bodySprite)
                } catch {
                    print(error)
                }
            }
        } else {
            if let bodySpritePath = await ResourcePath.playerBodySprite(jobID: jobID, gender: gender, madoType: madoType) {
                do {
                    let bodySprite = try await resourceManager.spriteResource(at: bodySpritePath)
                    bodySprite.semantic = .playerBody
                    sprites.append(bodySprite)
                } catch {
                    print(error)
                }
            }
        }

        // Head
        if let headSpritePath = ResourcePath.playerHeadSprite(jobID: jobID, headID: headID, gender: gender) {
            do {
                let headSprite = try await resourceManager.spriteResource(at: headSpritePath)
                headSprite.semantic = .playerHead
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

        // Shadow

        return sprites
    }
}
