//
//  ComposedSprite.Composer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/12.
//

import ROResources

extension ComposedSprite {
    class Composer {
        let configuration: ComposedSprite.Configuration
        let resourceManager: ResourceManager
        let scriptManager: ScriptManager

        private let pathGenerator: ResourcePathGenerator

        init(configuration: ComposedSprite.Configuration, resourceManager: ResourceManager, scriptManager: ScriptManager) {
            self.configuration = configuration
            self.resourceManager = resourceManager
            self.scriptManager = scriptManager

            self.pathGenerator = ResourcePathGenerator(scriptManager: scriptManager)
        }

        func composePlayerSprite() async -> [ComposedSprite.Part] {
            var parts: [ComposedSprite.Part] = []

            // Shadow
            if let shadowPart = await shadowPart() {
                parts.append(shadowPart)
            }

            // Body
            let bodyPart = await playerBodyPart()
            if let bodyPart {
                parts.append(bodyPart)
            }

            // Head
            if let headPart = await playerHeadPart(parent: bodyPart) {
                parts.append(headPart)
            }

            // Weapon
            if let weaponPart = await weaponPart() {
                parts.append(weaponPart)
            }

            // Weapon Slash
            if let weaponSlashPart = await weaponSlashPart() {
                parts.append(weaponSlashPart)
            }

            // Shield
            if let shieldPart = await shieldPart() {
                parts.append(shieldPart)
            }

            // Headgears
            for index in 0..<configuration.headgears.count {
                if let headgearPart = await headgearPart(at: index, parent: bodyPart) {
                    parts.append(headgearPart)
                }
            }

            // Garment
            if let garmentPart = await garmentPart() {
                parts.append(garmentPart)
            }

            return parts
        }

        func composeNonPlayerSprite() async -> [ComposedSprite.Part] {
            var parts: [ComposedSprite.Part] = []

            // Shadow
            if let shadowPart = await shadowPart() {
                parts.append(shadowPart)
            }

            // Body
            if let bodySpritePath = await pathGenerator.generateNonPlayerSpritePath(job: configuration.job) {
                do {
                    let bodySprite = try await resourceManager.sprite(at: bodySpritePath)
                    let bodyPart = ComposedSprite.Part(sprite: bodySprite, semantic: .main)
                    parts.append(bodyPart)
                } catch {
                    logger.warning("Body sprite error: \(error.localizedDescription)")
                }
            }

            return parts
        }

        private func shadowPart() async -> ComposedSprite.Part? {
            let shadowSprite: SpriteResource
            do {
                let spritePath = pathGenerator.generateShadowSpritePath()
                shadowSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Shadow sprite error: \(error.localizedDescription)")
                return nil
            }

            if let shadowFactor = await scriptManager.shadowFactor(forJobID: configuration.job.rawValue), shadowFactor >= 0 {
                shadowSprite.scaleFactor = shadowFactor
            }

            let shadowPart = ComposedSprite.Part(sprite: shadowSprite, semantic: .shadow)
            return shadowPart
        }

        private func playerBodyPart() async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let clothesColor = configuration.clothesColor
            let outfit = configuration.outfit
            let madoType = configuration.madoType

            var bodySprite: SpriteResource?
            var bodyPalette: PaletteResource?

            if outfit > 0 {
                if let spritePath = await pathGenerator.generateAlternatePlayerBodySpritePath(job: job, gender: gender, costumeID: outfit, madoType: madoType) {
                    do {
                        bodySprite = try await resourceManager.sprite(at: spritePath)
                    } catch {
                        logger.warning("Body sprite error: \(error.localizedDescription)")
                    }
                }

                if clothesColor > -1 {
                    if let palettePath = pathGenerator.generateAlternatePlayerBodyPalettePath(job: job, clothesColor: clothesColor, gender: gender, costumeID: outfit, madoType: madoType) {
                        do {
                            bodyPalette = try await resourceManager.palette(at: palettePath)
                        } catch {
                            logger.warning("Body sprite error: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                if let spritePath = await pathGenerator.generatePlayerBodySpritePath(job: job, gender: gender, madoType: madoType) {
                    do {
                        bodySprite = try await resourceManager.sprite(at: spritePath)
                    } catch {
                        logger.warning("Body sprite error: \(error.localizedDescription)")
                    }
                }

                if clothesColor > -1 {
                    if let palettePath = pathGenerator.generatePlayerBodyPalettePath(job: job, clothesColor: clothesColor, gender: gender, madoType: madoType) {
                        do {
                            bodyPalette = try await resourceManager.palette(at: palettePath)
                        } catch {
                            logger.warning("Body sprite error: \(error.localizedDescription)")
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

        private func playerHeadPart(parent: ComposedSprite.Part?) async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let hairStyle = configuration.hairStyle
            let hairColor = configuration.hairColor

            guard let spritePath = pathGenerator.generatePlayerHeadSpritePath(job: job, hairStyle: hairStyle, gender: gender) else {
                return nil
            }

            var headPalette: PaletteResource?
            if hairColor > -1 {
                if let palettePath = pathGenerator.generatePlayerHeadPalettePath(job: job, hairStyle: hairStyle, hairColor: hairColor, gender: gender) {
                    do {
                        headPalette = try await resourceManager.palette(at: palettePath)
                    } catch {
                        logger.warning("Head palette error: \(error.localizedDescription)")
                    }
                }
            }

            let headSprite: SpriteResource
            do {
                headSprite = try await resourceManager.sprite(at: spritePath)
                headSprite.palette = headPalette
            } catch {
                logger.warning("Head sprite error: \(error.localizedDescription)")
                return nil
            }

            var headPart = ComposedSprite.Part(sprite: headSprite, semantic: .playerHead)
            headPart.parent = parent?.sprite

            return headPart
        }

        private func weaponPart() async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let weapon = configuration.weapon
            let madoType = configuration.madoType

            guard weapon > 0 && !job.isMadogear else {
                return nil
            }

            guard let spritePath = await pathGenerator.generateWeaponSpritePath(job: job, weapon: weapon, isSlash: false, gender: gender, madoType: madoType) else {
                return nil
            }

            let weaponSprite: SpriteResource
            do {
                weaponSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Weapon sprite error: \(error.localizedDescription)")
                return nil
            }

            let weaponPart = ComposedSprite.Part(sprite: weaponSprite, semantic: .weapon, orderBySemantic: 0)
            return weaponPart
        }

        private func weaponSlashPart() async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let weapon = configuration.weapon
            let madoType = configuration.madoType

            guard weapon > 0 else {
                return nil
            }

            guard let spritePath = await pathGenerator.generateWeaponSpritePath(job: job, weapon: weapon, isSlash: true, gender: gender, madoType: madoType) else {
                return nil
            }

            let weaponSlashSprite: SpriteResource
            do {
                weaponSlashSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Weapon sprite error: \(error.localizedDescription)")
                return nil
            }

            let weaponSlashPart = ComposedSprite.Part(sprite: weaponSlashSprite, semantic: .weapon, orderBySemantic: 1)
            return weaponSlashPart
        }

        private func shieldPart() async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let shield = configuration.shield

            guard shield > 0 else {
                return nil
            }

            guard let spritePath = await pathGenerator.generateShieldSpritePath(job: job, shield: shield, gender: gender) else {
                return nil
            }

            let shieldSprite: SpriteResource
            do {
                shieldSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Shield sprite error: \(error.localizedDescription)")
                return nil
            }

            let shieldPart = ComposedSprite.Part(sprite: shieldSprite, semantic: .shield)
            return shieldPart
        }

        private func headgearPart(at index: Int, parent: ComposedSprite.Part?) async -> ComposedSprite.Part? {
            let gender = configuration.gender
            let headgear = configuration.headgears[index]

            guard headgear > 0 else {
                return nil
            }

            guard let spritePath = await pathGenerator.generateHeadgearSpritePath(headgear: headgear, gender: gender) else {
                return nil
            }

            let headgearSprite: SpriteResource
            do {
                headgearSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Headgear sprite error: \(error.localizedDescription)")
                return nil
            }

            // TODO: Handle headgear offset for Doram

            var headgearPart = ComposedSprite.Part(sprite: headgearSprite, semantic: .headgear, orderBySemantic: index)
            headgearPart.parent = parent?.sprite

            return headgearPart
        }

        private func garmentPart() async -> ComposedSprite.Part? {
            let job = configuration.job
            let gender = configuration.gender
            let garment = configuration.garment

            guard garment > 0 && !job.isMadogear else {
                return nil
            }

            guard let spritePath = await pathGenerator.generateGarmentSpritePath(job: job, garment: garment, gender: gender) else {
                return nil
            }

            let garmentSprite: SpriteResource
            do {
                garmentSprite = try await resourceManager.sprite(at: spritePath)
            } catch {
                logger.warning("Garment sprite error: \(error.localizedDescription)")
                return nil
            }

            let garmentPart = ComposedSprite.Part(sprite: garmentSprite, semantic: .garment)
            return garmentPart
        }
    }
}
