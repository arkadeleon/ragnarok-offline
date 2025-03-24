//
//  SpriteResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import Foundation
import ROConstants
import ROFileFormats
import ROResources

enum SpritePart {
    case main
    case playerBody
    case playerHead
    case headgear
    case garment
    case weapon
    case shield
    case shadow
}

final public class SpriteResource: @unchecked Sendable {
    public let act: ACT
    public let spr: SPR

    var parent: SpriteResource?

    var part: SpritePart = .main
    var orderByPart = 0

    var palette: PaletteResource?

    var scaleFactor: CGFloat = 1

    private var indexedSpriteImages: [CGImage?]
    private var rgbaSpriteImages: [CGImage?]

    public init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr

        indexedSpriteImages = Array(repeating: nil, count: Int(spr.indexedSpriteCount))
        rgbaSpriteImages = Array(repeating: nil, count: Int(spr.rgbaSpriteCount))
    }

    func action(at actionIndex: Int) -> ACT.Action? {
        guard 0..<act.actions.count ~= actionIndex else {
            return nil
        }

        let action = act.actions[actionIndex]
        return action
    }

    func frame(at indexPath: IndexPath) -> ACT.Frame? {
        let actionIndex = indexPath[0]
        let frameIndex = indexPath[1]

        guard 0..<act.actions.count ~= actionIndex else {
            return nil
        }

        let action = act.actions[actionIndex]
        guard 0..<action.frames.count ~= frameIndex else {
            return nil
        }

        let frame = action.frames[frameIndex]
        return frame
    }

    func image(for layer: ACT.Layer) -> CGImage? {
        guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)) else {
            return nil
        }

        let spriteIndex = Int(layer.spriteIndex)
        let image = image(with: spriteType, at: spriteIndex)
        return image
    }

    private func image(with spriteType: SPR.SpriteType, at spriteIndex: Int) -> CGImage? {
        let indexedSpriteCount = Int(spr.indexedSpriteCount)
        let rgbaSpriteCount = Int(spr.rgbaSpriteCount)

        switch spriteType {
        case .indexed:
            guard 0..<indexedSpriteCount ~= spriteIndex else {
                return nil
            }

            if let image = indexedSpriteImages[spriteIndex] {
                return image
            }

            let index = spriteIndex
            let image = spr.image(forSpriteAt: index, palette: palette?.pal)
            indexedSpriteImages[spriteIndex] = image

            return image
        case .rgba:
            guard 0..<rgbaSpriteCount ~= spriteIndex else {
                return nil
            }

            if let image = rgbaSpriteImages[spriteIndex] {
                return image
            }

            let index = indexedSpriteCount + spriteIndex
            let image = spr.image(forSpriteAt: index, palette: palette?.pal)
            rgbaSpriteImages[spriteIndex] = image

            return image
        }
    }
}

extension ResourceManager {
    public func sprite(at path: ResourcePath) async throws -> SpriteResource {
        let actPath = path.appendingPathExtension("act")
        let actData = try await contentsOfResource(at: actPath)
        let act = try ACT(data: actData)

        let sprPath = path.appendingPathExtension("spr")
        let sprData = try await contentsOfResource(at: sprPath)
        let spr = try SPR(data: sprData)

        let sprite = SpriteResource(act: act, spr: spr)
        return sprite
    }
}

extension ResourcePath {
    static func playerBodySprite(jobID: UniformJobID, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID, madoType: madoType) else {
            return nil
        }

        if jobID.isDoram {
            return .spritePath + ["도람족", "몸통", gender.name, "\(jobName)_\(gender.name)"]
        } else {
            return .spritePath + ["인간족", "몸통", gender.name, "\(jobName)_\(gender.name)"]
        }
    }

    static func playerBodyAltSprite(jobID: UniformJobID, gender: Gender, costumeID: Int, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID, madoType: madoType) else {
            return nil
        }

        if jobID.isDoram {
            return .spritePath + ["도람족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"]
        } else {
            return .spritePath + ["인간족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"]
        }
    }

    static func playerHeadSprite(jobID: UniformJobID, hairStyleID: Int, gender: Gender) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isDoram {
            return .spritePath + ["도람족", "머리통", gender.name, "\(hairStyleID)_\(gender.name)"]
        } else {
            return .spritePath + ["인간족", "머리통", gender.name, "\(hairStyleID)_\(gender.name)"]
        }
    }

    static func nonPlayerSprite(jobID: UniformJobID) async -> ResourcePath? {
        guard !jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID) else {
            return nil
        }

        if jobID.isNPC {
            return .spritePath + ["npc", jobName]
        } else if jobID.isMercenary {
            return .spritePath + ["인간족", "몸통", jobName]
        } else if jobID.isHomunculus {
            return .spritePath + ["homun", jobName]
        } else if jobID.isMonster {
            return .spritePath + ["몬스터", jobName]
        } else {
            return nil
        }
    }

    static func weaponSprite(jobID: UniformJobID, weaponID: Int, isSlash: Bool = false, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer || jobID.isMercenary else {
            return nil
        }

        if jobID.isPlayer {
            let isMadogear = jobID.isMadogear
            let isAlternativeMadogear = isMadogear && madoType == .suit
            let madogearJobName = isAlternativeMadogear ? alternativeMadogearJobName(jobID: jobID, madoType: madoType) : ""

            guard var jobName = jobNamesForWeapon[jobID.rawValue] else {
                return nil
            }

            if isAlternativeMadogear {
                jobName = (jobName.0, madogearJobName)
            }

            var weaponName = await ScriptManager.default.weaponName(forWeaponID: weaponID)

            if weaponName == nil && !isMadogear {
                if let realWeaponID = await ScriptManager.default.realWeaponID(forWeaponID: weaponID) {
                    weaponName = await ScriptManager.default.weaponName(forWeaponID: realWeaponID)
                    if weaponName == nil {
                        weaponName = "_\(weaponID)"
                    }
                }
            }

            guard let weaponName else {
                return nil
            }

            if jobID.isDoram {
                return .spritePath + ["도람족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"]
            } else {
                return .spritePath + ["인간족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"]
            }
        } else {
            let mercenaryPath: ResourcePath = .spritePath + ["인간족", "용병"]

            switch jobID.rawValue {
            case 6017...6026:
                return mercenaryPath + ["활용병_활"]
            case 6027...6036:
                return mercenaryPath + ["창용병_창"]
            default:
                return mercenaryPath + ["검용병_검"]
            }
        }
    }

    static func shieldSprite(jobID: UniformJobID, shieldID: Int, gender: Gender) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID) else {
            return nil
        }

        if let shieldName = shieldNames[shieldID] {
            return .spritePath + ["방패", jobName, "\(jobName)_\(gender.name)\(shieldName)"]
        } else {
            return .spritePath + ["방패", jobName, "\(jobName)_\(gender.name)_\(shieldID)_방패"]
        }
    }

    static func headgearSprite(headgearID: Int, gender: Gender) async -> ResourcePath? {
        guard let accessoryName = await ScriptManager.default.accessoryName(forAccessoryID: headgearID) else {
            return nil
        }

        return .spritePath + ["악세사리", gender.name, "\(gender.name)\(accessoryName)"]
    }

    static func garmentSprite(jobID: UniformJobID, garmentID: Int, gender: Gender, checkEnglish: Bool = false, useFallback: Bool = false) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID),
              let robeName = await ScriptManager.default.robeName(forRobeID: garmentID, checkEnglish: checkEnglish) else {
            return nil
        }

        if useFallback {
            return .spritePath + ["로브", robeName, robeName]
        } else {
            return .spritePath + ["로브", robeName, gender.name, "\(jobName)_\(gender.name)"]
        }
    }

    static func imf(jobID: UniformJobID, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, madoType: madoType)
            return ["\(jobName)_\(gender.name)"]
        }

        guard let jobName = jobNamesForIMF[jobID.rawValue] else {
            return nil
        }

        return ["data", "imf", "\(jobName)_\(gender.name)"]
    }

    static func bodyPalette(jobID: UniformJobID, clothesColorID: Int, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, madoType: madoType)
            return ["몸", "\(jobName)_\(gender.name)_\(clothesColorID)"]
        }

        guard let jobName = jobNamesForPalette[jobID.rawValue] else {
            return nil
        }

        if jobID.isDoram {
            return .palettePath + ["도람족", "body", "\(jobName)_\(gender.name)_\(clothesColorID)"]
        } else {
            return .palettePath + ["몸", "\(jobName)_\(gender.name)_\(clothesColorID)"]
        }
    }

    static func bodyAltPalette(jobID: UniformJobID, clothesColorID: Int, gender: Gender, costumeID: Int, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, madoType: madoType)
            return .palettePath + ["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColorID)_\(costumeID)"]
        }

        guard let jobName = jobNamesForPalette[jobID.rawValue] else {
            return nil
        }

        if jobID.isDoram {
            return .palettePath + ["도람족", "body", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColorID)_\(costumeID)"]
        } else {
            return .palettePath + ["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColorID)_\(costumeID)"]
        }
    }

    static func headPalette(jobID: UniformJobID, hairStyleID: Int, hairColorID: Int, gender: Gender) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isDoram {
            return .palettePath + ["도람족", "머리", "머리\(hairStyleID)_\(gender.name)_\(hairColorID)"]
        } else {
            return .palettePath + ["머리", "머리\(hairStyleID)_\(gender.name)_\(hairColorID)"]
        }
    }

    private static func jobSpriteName(jobID: UniformJobID, madoType: MadoType = .robot) async -> String? {
        if jobID.isPlayer {
            if jobID.isMadogear && madoType == .suit {
                return alternativeMadogearJobName(jobID: jobID, madoType: madoType)
            } else {
                return jobNamesForSprite[jobID.rawValue]
            }
        } else {
            return await ScriptManager.default.jobName(forJobID: jobID.rawValue)
        }
    }

    private static func alternativeMadogearJobName(jobID: UniformJobID, madoType: MadoType) -> String {
        if [4086, 4087, 4112].contains(jobID.rawValue) {
            return "마도아머"
        } else {
            return "meister_madogear2"
        }
    }
}

extension ResourcePath {
    public init?(itemSpritePathWithItemID itemID: Int) async {
        guard let resourceName = await ScriptManager.default.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        self = .spritePath + ["아이템", "\(resourceName)"]
    }

    public init(skillSpritePathWithSkillName skillName: String) {
        self = .spritePath + ["아이템", "\(skillName)"]
    }
}
