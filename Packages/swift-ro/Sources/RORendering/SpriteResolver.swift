//
//  SpriteResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import ROGenerated

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
            let shadowSpritePath = ResourcePath.spritePath.appending(component: "shadow")
            let shadowSprite = try await resourceManager.sprite(at: shadowSpritePath)
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
                    headPalette = try await resourceManager.palette(at: headPalettePath)
                } catch {
                    print(error)
                }
            }

            do {
                let headSprite = try await resourceManager.sprite(at: headSpritePath)
                headSprite.parent = bodySprite
                headSprite.semantic = .playerHead
                headSprite.palette = headPalette
                sprites.append(headSprite)
            } catch {
                print(error)
            }
        }

        // Weapon
        if let weaponID = configuration.weaponID, !jobID.isMadogear,
           let weaponSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: false, gender: gender, madoType: madoType) {
            do {
                let weaponSprite = try await resourceManager.sprite(at: weaponSpritePath)
                weaponSprite.semantic = .weapon
                weaponSprite.orderBySemantic = 0
                sprites.append(weaponSprite)
            } catch {
                print(error)
            }
        }

        // Weapon Slash
        if let weaponID = configuration.weaponID,
           let weaponSlashSpritePath = await ResourcePath.weaponSprite(jobID: jobID, weaponID: weaponID, isSlash: true, gender: gender, madoType: madoType) {
            do {
                let weaponSlashSprite = try await resourceManager.sprite(at: weaponSlashSpritePath)
                weaponSlashSprite.semantic = .weapon
                weaponSlashSprite.orderBySemantic = 1
                sprites.append(weaponSlashSprite)
            } catch {
                print(error)
            }
        }

        // Shield
        if let shieldID = configuration.shieldID,
           let shieldSpritePath = await ResourcePath.shieldSprite(jobID: jobID, shieldID: shieldID, gender: gender) {
            do {
                let shieldSprite = try await resourceManager.sprite(at: shieldSpritePath)
                shieldSprite.semantic = .shield
                sprites.append(shieldSprite)
            } catch {
                print(error)
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
                headgearSprite.semantic = .headgear
                headgearSprite.orderBySemantic = i

                // TODO: Handle headgear offset for Doram

                sprites.append(headgearSprite)
            } catch {
                print(error)
            }
        }

        // Garment

        return sprites
    }

    func resolveNonPlayer(jobID: UniformJobID, configuration: SpriteConfiguration) async -> [SpriteResource] {
        var sprites: [SpriteResource] = []

        // Shadow
        do {
            let shadowSpritePath = ResourcePath.spritePath.appending(component: "shadow")
            let shadowSprite = try await resourceManager.sprite(at: shadowSpritePath)
            shadowSprite.semantic = .shadow
            sprites.append(shadowSprite)
        } catch {
            print(error)
        }

        if let bodySpritePath = await ResourcePath.nonPlayerSprite(jobID: jobID) {
            do {
                let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                sprites.append(bodySprite)
            } catch {
                print(error)
            }
        }

        return sprites
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
                    print(error)
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyAltPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, costumeID: outfitID, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
                } catch {
                    print(error)
                }
            }
        } else {
            if let bodySpritePath = await ResourcePath.playerBodySprite(jobID: jobID, gender: gender, madoType: madoType) {
                do {
                    bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                } catch {
                    print(error)
                }
            }

            if let clothesColorID = configuration.clothesColorID,
               let bodyPalettePath = ResourcePath.bodyPalette(jobID: jobID, clothesColorID: clothesColorID, gender: gender, madoType: madoType) {
                do {
                    bodyPalette = try await resourceManager.palette(at: bodyPalettePath)
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
