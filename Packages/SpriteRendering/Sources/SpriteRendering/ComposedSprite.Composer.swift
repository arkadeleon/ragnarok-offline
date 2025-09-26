//
//  ComposedSprite.Composer.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/5/12.
//

import ResourceManagement

extension ComposedSprite {
    final class Composer {
        let configuration: ComposedSprite.Configuration
        let resourceManager: ResourceManager

        init(configuration: ComposedSprite.Configuration, resourceManager: ResourceManager) {
            self.configuration = configuration
            self.resourceManager = resourceManager
        }

        func composePlayerSprite() async throws -> [ComposedSprite.Part] {
            let configuration = configuration
            let resourceManager = resourceManager

            let parts = try await withThrowingTaskGroup(
                of: ComposedSprite.Part?.self,
                returning: [ComposedSprite.Part].self
            ) { taskGroup in
                var parts: [ComposedSprite.Part] = []

                // Body
                let bodyPart = try await ComposedSprite.Part.generatePlayerBodyPart(
                    configuration: configuration,
                    resourceManager: resourceManager
                )
                if let bodyPart {
                    parts.append(bodyPart)
                }

                // Head
                taskGroup.addTask {
                    var headPart = try await ComposedSprite.Part.generatePlayerHeadPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                    headPart?.parent = bodyPart?.sprite
                    return headPart
                }

                // Weapon
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateWeaponPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                // Weapon Slash
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateWeaponSlashPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                // Shield
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateShieldPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                // Headgears
                for headgearIndex in 0..<configuration.headgears.count {
                    taskGroup.addTask {
                        var headgearPart = try await ComposedSprite.Part.generateHeadgearPart(
                            configuration: configuration,
                            headgearIndex: headgearIndex,
                            resourceManager: resourceManager
                        )
                        headgearPart?.parent = bodyPart?.sprite
                        return headgearPart
                    }
                }

                // Garment
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateGarmentPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                // Shadow
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateShadowPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                for try await part in taskGroup.compactMap({ $0 }) {
                    parts.append(part)
                }

                return parts
            }

            return parts
        }

        func composeNonPlayerSprite() async throws -> [ComposedSprite.Part] {
            let configuration = configuration
            let resourceManager = resourceManager

            let parts = try await withThrowingTaskGroup(
                of: ComposedSprite.Part?.self,
                returning: [ComposedSprite.Part].self
            ) { taskGroup in
                var parts: [ComposedSprite.Part] = []

                // Body
                taskGroup.addTask {
                    let scriptContext = await resourceManager.scriptContext()
                    let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

                    guard let bodySpritePath = pathGenerator.generateNonPlayerSpritePath(job: configuration.job) else {
                        return nil
                    }

                    let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                    let bodyPart = ComposedSprite.Part(sprite: bodySprite, semantic: .main)
                    return bodyPart
                }

                // Shadow
                taskGroup.addTask {
                    try await ComposedSprite.Part.generateShadowPart(
                        configuration: configuration,
                        resourceManager: resourceManager
                    )
                }

                for try await part in taskGroup.compactMap({ $0 }) {
                    parts.append(part)
                }

                return parts
            }

            return parts
        }
    }
}

extension ComposedSprite.Part {
    static func generatePlayerBodyPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager,
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let clothesColor = configuration.clothesColor
        let outfit = configuration.outfit
        let madoType = configuration.madoType

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        var bodySprite: SpriteResource?
        var bodyPalette: PaletteResource?

        if outfit > 0 {
            if let spritePath = pathGenerator.generateAlternatePlayerBodySpritePath(job: job, gender: gender, costumeID: outfit, madoType: madoType) {
                bodySprite = try await resourceManager.sprite(at: spritePath)
            }

            if clothesColor > -1 {
                if let palettePath = pathGenerator.generateAlternatePlayerBodyPalettePath(job: job, clothesColor: clothesColor, gender: gender, costumeID: outfit, madoType: madoType) {
                    do {
                        bodyPalette = try await resourceManager.palette(at: palettePath)
                    } catch {
                        logger.warning("Body sprite palette error: \(error)")
                    }
                }
            }
        } else {
            if let spritePath = pathGenerator.generatePlayerBodySpritePath(job: job, gender: gender, madoType: madoType) {
                bodySprite = try await resourceManager.sprite(at: spritePath)
            }

            if clothesColor > -1 {
                if let palettePath = pathGenerator.generatePlayerBodyPalettePath(job: job, clothesColor: clothesColor, gender: gender, madoType: madoType) {
                    do {
                        bodyPalette = try await resourceManager.palette(at: palettePath)
                    } catch {
                        logger.warning("Body sprite palette error: \(error)")
                    }
                }
            }
        }

        guard let bodySprite else {
            return nil
        }

        bodySprite.palette = bodyPalette

        let bodyPart = ComposedSprite.Part(sprite: bodySprite, semantic: .playerBody)
        return bodyPart
    }

    static func generatePlayerHeadPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let hairStyle = configuration.hairStyle
        let hairColor = configuration.hairColor

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generatePlayerHeadSpritePath(job: job, hairStyle: hairStyle, gender: gender) else {
            return nil
        }

        var headPalette: PaletteResource?
        if hairColor > -1 {
            if let palettePath = pathGenerator.generatePlayerHeadPalettePath(job: job, hairStyle: hairStyle, hairColor: hairColor, gender: gender) {
                do {
                    headPalette = try await resourceManager.palette(at: palettePath)
                } catch {
                    logger.warning("Head palette error: \(error)")
                }
            }
        }

        let headSprite = try await resourceManager.sprite(at: spritePath)
        headSprite.palette = headPalette

        let headPart = ComposedSprite.Part(sprite: headSprite, semantic: .playerHead)
        return headPart
    }

    static func generateWeaponPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let weapon = configuration.weapon
        let madoType = configuration.madoType

        guard weapon > 0 && !job.isMadogear else {
            return nil
        }

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generateWeaponSpritePath(job: job, weapon: weapon, isSlash: false, gender: gender, madoType: madoType) else {
            return nil
        }

        let weaponSprite = try await resourceManager.sprite(at: spritePath)

        let weaponPart = ComposedSprite.Part(sprite: weaponSprite, semantic: .weapon, orderBySemantic: 0)
        return weaponPart
    }

    static func generateWeaponSlashPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let weapon = configuration.weapon
        let madoType = configuration.madoType

        guard weapon > 0 else {
            return nil
        }

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generateWeaponSpritePath(job: job, weapon: weapon, isSlash: true, gender: gender, madoType: madoType) else {
            return nil
        }

        let weaponSlashSprite = try await resourceManager.sprite(at: spritePath)

        let weaponSlashPart = ComposedSprite.Part(sprite: weaponSlashSprite, semantic: .weapon, orderBySemantic: 1)
        return weaponSlashPart
    }

    static func generateShieldPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let shield = configuration.shield

        guard shield > 0 else {
            return nil
        }

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generateShieldSpritePath(job: job, shield: shield, gender: gender) else {
            return nil
        }

        let shieldSprite = try await resourceManager.sprite(at: spritePath)

        let shieldPart = ComposedSprite.Part(sprite: shieldSprite, semantic: .shield)
        return shieldPart
    }

    static func generateHeadgearPart(
        configuration: ComposedSprite.Configuration,
        headgearIndex: Int,
        resourceManager: ResourceManager,
    ) async throws -> ComposedSprite.Part? {
        let gender = configuration.gender
        let headgear = configuration.headgears[headgearIndex]

        guard headgear > 0 else {
            return nil
        }

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generateHeadgearSpritePath(headgear: headgear, gender: gender) else {
            return nil
        }

        let headgearSprite = try await resourceManager.sprite(at: spritePath)

        // TODO: Handle headgear offset for Doram

        let headgearPart = ComposedSprite.Part(sprite: headgearSprite, semantic: .headgear, orderBySemantic: headgearIndex)
        return headgearPart
    }

    static func generateGarmentPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part? {
        let job = configuration.job
        let gender = configuration.gender
        let garment = configuration.garment

        guard garment > 0 && !job.isMadogear else {
            return nil
        }

        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        guard let spritePath = pathGenerator.generateGarmentSpritePath(job: job, garment: garment, gender: gender) else {
            return nil
        }

        let garmentSprite = try await resourceManager.sprite(at: spritePath)

        let garmentPart = ComposedSprite.Part(sprite: garmentSprite, semantic: .garment)
        return garmentPart
    }

    static func generateShadowPart(
        configuration: ComposedSprite.Configuration,
        resourceManager: ResourceManager
    ) async throws -> ComposedSprite.Part {
        let scriptContext = await resourceManager.scriptContext()
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)

        let spritePath = pathGenerator.generateShadowSpritePath()
        let shadowSprite = try await resourceManager.sprite(at: spritePath)

        if let shadowFactor = scriptContext.shadowFactor(forJobID: configuration.job.rawValue), shadowFactor >= 0 {
            shadowSprite.scaleFactor = shadowFactor
        }

        let shadowPart = ComposedSprite.Part(sprite: shadowSprite, semantic: .shadow)
        return shadowPart
    }
}
