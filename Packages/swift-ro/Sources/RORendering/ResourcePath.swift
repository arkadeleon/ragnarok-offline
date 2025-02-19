//
//  ResourcePath.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/12.
//

import Foundation
import ROGenerated
import ROResources

public struct ResourcePath: ExpressibleByArrayLiteral, Sendable {
    public static func + (lhs: ResourcePath, rhs: ResourcePath) -> ResourcePath {
        ResourcePath(components: lhs.components + rhs.components)
    }

    public let components: [String]

    public init(components: [String]) {
        self.components = components
    }

    public init(arrayLiteral elements: String...) {
        self.components = elements
    }

    public func appending(component: String) -> ResourcePath {
        ResourcePath(components: components + [component])
    }

    public func appendingPathExtension(_ pathExtension: String) -> ResourcePath {
        var components = components
        if var lastComponent = components.popLast() {
            lastComponent.append(".")
            lastComponent.append(pathExtension)
            components.append(lastComponent)
        }
        return ResourcePath(components: components)
    }
}

extension ResourcePath {
    static func playerBodySprite(jobID: UniversalJobID, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID, madoType: madoType) else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "몸통", gender.name, "\(jobName)_\(gender.name)"]
        } else {
            return ["인간족", "몸통", gender.name, "\(jobName)_\(gender.name)"]
        }
    }

    static func playerBodyAltSprite(jobID: UniversalJobID, gender: Gender, costumeID: Int, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID, madoType: madoType) else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"]
        } else {
            return ["인간족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"]
        }
    }

    static func playerHeadSprite(jobID: UniversalJobID, headID: Int, gender: Gender) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "머리통", gender.name, "\(headID)_\(gender.name)"]
        } else {
            return ["인간족", "머리통", gender.name, "\(headID)_\(gender.name)"]
        }
    }

    static func nonPlayerSprite(jobID: UniversalJobID) async -> ResourcePath? {
        guard !jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID) else {
            return nil
        }

        if jobID.isNPC {
            return ["npc", jobName]
        } else if jobID.isMercenary {
            return ["인간족", "몸통", jobName]
        } else if jobID.isHomunculus {
            return ["homun", jobName]
        } else if jobID.isMonster {
            return ["몬스터", jobName]
        } else {
            return nil
        }
    }

    static func weaponSprite(jobID: UniversalJobID, weaponID: Int, isSlash: Bool = false, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard jobID.isPlayer || jobID.isMercenary else {
            return nil
        }

        if jobID.isPlayer {
            let isMadogear = jobID.isMadogear
            let isAlternativeMadogear = isMadogear && madoType == .suit
            let madogearJobName = isAlternativeMadogear ? alternativeMadogearJobName(jobID: jobID, type: madoType) : ""

            guard var jobName = PlayerJobNameTable.current.weaponJobName(for: jobID.rawValue) else {
                return nil
            }

            if isAlternativeMadogear {
                jobName = (jobName.0, madogearJobName)
            }

            var weaponName = await WeaponNameTable.current.weaponName(forWeaponID: weaponID)

            if weaponName == nil && !isMadogear {
                if let realWeaponID = await WeaponNameTable.current.realWeaponID(forWeaponID: weaponID) {
                    weaponName = await WeaponNameTable.current.weaponName(forWeaponID: realWeaponID)
                    if weaponName == nil {
                        weaponName = "_\(weaponID)"
                    }
                }
            }

            guard let weaponName else {
                return nil
            }

            if jobID.isDoram {
                return ["도람족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"]
            } else {
                return ["인간족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"]
            }
        } else {
            let mercenaryPath: ResourcePath = ["인간족", "용병"]

            switch jobID.rawValue {
            case 6017...6026:
                return mercenaryPath.appending(component: "활용병_활")
            case 6027...6036:
                return mercenaryPath.appending(component: "창용병_창")
            default:
                return mercenaryPath.appending(component: "검용병_검")
            }
        }
    }

    static func shieldSprite(jobID: UniversalJobID, shieldID: Int, gender: Gender) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID) else {
            return nil
        }

        if let shieldName = ShieldNameTable.current.shieldName(for: shieldID) {
            return ["방패", jobName, "\(jobName)_\(gender.name)\(shieldName)"]
        } else {
            return ["방패", jobName, "\(jobName)_\(gender.name)_\(shieldID)_방패"]
        }
    }

    static func headgearSprite(headgearID: Int, gender: Gender) async -> ResourcePath? {
        guard let accessoryName = await AccessoryNameTable.current.accessoryName(forAccessoryID: headgearID) else {
            return nil
        }

        return ["악세사리", gender.name, "\(gender.name)\(accessoryName)"]
    }

    static func garmentSprite(jobID: UniversalJobID, garmentID: Int, gender: Gender, checkEnglish: Bool = false, useFallback: Bool = false) async -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(jobID: jobID),
              let robeName = await RobeNameTable.current.robeName(forRobeID: garmentID, checkEnglish: checkEnglish) else {
            return nil
        }

        if useFallback {
            return ["로브", robeName, robeName]
        } else {
            return ["로브", robeName, gender.name, "\(jobName)_\(gender.name)"]
        }
    }

    static func imf(jobID: UniversalJobID, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, type: madoType)
            return ["\(jobName)_\(gender.name)"]
        }

        guard let jobName = PlayerJobNameTable.current.imfJobName(for: jobID.rawValue) else {
            return nil
        }

        return ["\(jobName)_\(gender.name)"]
    }

    static func bodyPalette(jobID: UniversalJobID, paletteID: Int, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, type: madoType)
            return ["몸", "\(jobName)_\(gender.name)_\(paletteID)"]
        }

        guard let jobName = PlayerJobNameTable.current.palJobName(for: jobID.rawValue) else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "body", "\(jobName)_\(gender.name)_\(paletteID)"]
        } else {
            return ["몸", "\(jobName)_\(gender.name)_\(paletteID)"]
        }
    }

    static func bodyAltPalette(jobID: UniversalJobID, paletteID: Int, gender: Gender, costumeID: Int, madoType: MadoType = .robot) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isMadogear && madoType == .suit {
            let jobName = alternativeMadogearJobName(jobID: jobID, type: madoType)
            return ["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(paletteID)_\(costumeID)"]
        }

        guard let jobName = PlayerJobNameTable.current.palJobName(for: jobID.rawValue) else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "body", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(paletteID)_\(costumeID)"]
        } else {
            return ["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(paletteID)_\(costumeID)"]
        }
    }

    static func headPalette(jobID: UniversalJobID, headID: Int, paletteID: Int, gender: Gender) -> ResourcePath? {
        guard jobID.isPlayer else {
            return nil
        }

        if jobID.isDoram {
            return ["도람족", "머리", "머리\(headID)_\(gender.name)_\(paletteID)"]
        } else {
            return ["머리", "머리\(headID)_\(gender.name)_\(paletteID)"]
        }
    }

    private static func jobSpriteName(jobID: UniversalJobID, madoType: MadoType = .robot) async -> String? {
        if jobID.isPlayer {
            if jobID.isMadogear && madoType == .suit {
                return alternativeMadogearJobName(jobID: jobID, type: madoType)
            } else {
                return PlayerJobNameTable.current.jobName(for: jobID.rawValue)
            }
        } else {
            return await JobNameTable.current.jobName(forJobID: jobID.rawValue)
        }
    }

    private static func alternativeMadogearJobName(jobID: UniversalJobID, type: MadoType) -> String {
        if [4086, 4087, 4112].contains(jobID.rawValue) {
            return "마도아머"
        } else {
            return "meister_madogear2"
        }
    }
}

extension URL {
    func appending(path: ResourcePath, directoryHint: URL.DirectoryHint = .inferFromPath) -> URL {
        let path = path.components.joined(separator: "/")
        return appending(path: path, directoryHint: directoryHint)
    }
}
