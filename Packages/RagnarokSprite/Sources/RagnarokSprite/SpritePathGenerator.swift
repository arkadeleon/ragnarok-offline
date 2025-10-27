//
//  SpritePathGenerator.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/5/8.
//

import RagnarokConstants
import RagnarokResources
import TextEncoding

class SpritePathGenerator {
    let scriptContext: ScriptContext

    init(scriptContext: ScriptContext) {
        self.scriptContext = scriptContext
    }

    func generateShadowSpritePath() -> ResourcePath {
        ResourcePath.spriteDirectory.appending("shadow")
    }

    func generatePlayerBodySpritePath(job: CharacterJob, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = jobSpriteName(for: job, madoType: madoType) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending([K2L("도람족"), K2L("몸통"), gender.name, "\(jobName)_\(gender.name)"])
        } else {
            return ResourcePath.spriteDirectory.appending([K2L("인간족"), K2L("몸통"), gender.name, "\(jobName)_\(gender.name)"])
        }
    }

    func generateAlternatePlayerBodySpritePath(job: CharacterJob, gender: Gender, costumeID: Int, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = jobSpriteName(for: job, madoType: madoType) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending([K2L("도람족"), K2L("몸통"), gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"])
        } else {
            return ResourcePath.spriteDirectory.appending([K2L("인간족"), K2L("몸통"), gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"])
        }
    }

    func generatePlayerHeadSpritePath(job: CharacterJob, hairStyle: Int, gender: Gender) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending([K2L("도람족"), K2L("머리통"), gender.name, "\(hairStyle)_\(gender.name)"])
        } else {
            return ResourcePath.spriteDirectory.appending([K2L("인간족"), K2L("머리통"), gender.name, "\(hairStyle)_\(gender.name)"])
        }
    }

    func generateNonPlayerSpritePath(job: CharacterJob) -> ResourcePath? {
        guard !job.isPlayer else {
            return nil
        }

        guard let jobName = jobSpriteName(for: job) else {
            return nil
        }

        if job.isNPC {
            return ResourcePath.spriteDirectory.appending(["npc", jobName])
        } else if job.isMercenary {
            return ResourcePath.spriteDirectory.appending([K2L("인간족"), K2L("몸통"), jobName])
        } else if job.isHomunculus {
            return ResourcePath.spriteDirectory.appending(["homun", jobName])
        } else if job.isMonster {
            return ResourcePath.spriteDirectory.appending([K2L("몬스터"), jobName])
        } else {
            return nil
        }
    }

    func generateWeaponSpritePath(job: CharacterJob, weapon: Int, isSlash: Bool = false, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer || job.isMercenary else {
            return nil
        }

        if job.isPlayer {
            let isMadogear = job.isMadogear
            let isSuitMadogear = isMadogear && madoType == .suit
            let madogearJobName = isSuitMadogear ? suitMadogearJobName(for: job) : ""

            guard var jobName = jobNameForWeapon(job.rawValue) else {
                return nil
            }

            if isSuitMadogear {
                jobName = (jobName.0, madogearJobName)
            }

            var weaponName = scriptContext.weaponName(forWeaponID: weapon)

            if weaponName == nil && !isMadogear {
                if let realWeaponID = scriptContext.realWeaponID(forWeaponID: weapon) {
                    weaponName = scriptContext.weaponName(forWeaponID: realWeaponID)
                    if weaponName == nil {
                        weaponName = "_\(weapon)"
                    }
                }
            }

            guard let weaponName else {
                return nil
            }

            if job.isDoram {
                return ResourcePath.spriteDirectory.appending([K2L("도람족"), jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)" + (isSlash ? K2L("_검광") : "")])
            } else {
                return ResourcePath.spriteDirectory.appending([K2L("인간족"), jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)" + (isSlash ? K2L("_검광") : "")])
            }
        } else {
            let mercenaryPath = ResourcePath.spriteDirectory.appending([K2L("인간족"), K2L("용병")])

            switch job.rawValue {
            case 6017...6026:
                return mercenaryPath.appending(K2L("활용병_활"))
            case 6027...6036:
                return mercenaryPath.appending(K2L("창용병_창"))
            default:
                return mercenaryPath.appending(K2L("검용병_검"))
            }
        }
    }

    func generateShieldSpritePath(job: CharacterJob, shield: Int, gender: Gender) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = jobSpriteName(for: job) else {
            return nil
        }

        if let shieldName = shieldName(shield) {
            return ResourcePath.spriteDirectory.appending([K2L("방패"), jobName, "\(jobName)_\(gender.name)\(shieldName)"])
        } else {
            return ResourcePath.spriteDirectory.appending([K2L("방패"), jobName, "\(jobName)_\(gender.name)_\(shield)" + K2L("_방패")])
        }
    }

    func generateHeadgearSpritePath(headgear: Int, gender: Gender) -> ResourcePath? {
        guard let accessoryName = scriptContext.accessoryName(forAccessoryID: headgear) else {
            return nil
        }

        return ResourcePath.spriteDirectory.appending([K2L("악세사리"), gender.name, "\(gender.name)\(accessoryName)"])
    }

    func generateGarmentSpritePath(job: CharacterJob, garment: Int, gender: Gender, checkEnglish: Bool = false, useFallback: Bool = false) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = jobSpriteName(for: job),
              let robeName = scriptContext.robeName(forRobeID: garment, checkEnglish: checkEnglish) else {
            return nil
        }

        if useFallback {
            return ResourcePath.spriteDirectory.appending([K2L("로브"), robeName, robeName])
        } else {
            return ResourcePath.spriteDirectory.appending([K2L("로브"), robeName, gender.name, "\(jobName)_\(gender.name)"])
        }
    }

    func generatePlayerBodyPalettePath(job: CharacterJob, clothesColor: Int, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ResourcePath.paletteDirectory.appending([K2L("몸"), "\(jobName)_\(gender.name)_\(clothesColor)"])
        }

        guard let jobName = jobNameForPalette(job.rawValue) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending([K2L("도람족"), "body", "\(jobName)_\(gender.name)_\(clothesColor)"])
        } else {
            return ResourcePath.paletteDirectory.appending([K2L("몸"), "\(jobName)_\(gender.name)_\(clothesColor)"])
        }
    }

    func generateAlternatePlayerBodyPalettePath(job: CharacterJob, clothesColor: Int, gender: Gender, costumeID: Int, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ResourcePath.paletteDirectory.appending([K2L("몸"), "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        }

        guard let jobName = jobNameForPalette(job.rawValue) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending([K2L("도람족"), "body", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        } else {
            return ResourcePath.paletteDirectory.appending([K2L("몸"), "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        }
    }

    func generatePlayerHeadPalettePath(job: CharacterJob, hairStyle: Int, hairColor: Int, gender: Gender) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending([K2L("도람족"), K2L("머리"), K2L("머리") + "\(hairStyle)_\(gender.name)_\(hairColor)"])
        } else {
            return ResourcePath.paletteDirectory.appending([K2L("머리"), K2L("머리") + "\(hairStyle)_\(gender.name)_\(hairColor)"])
        }
    }

    func generateIMFPath(job: CharacterJob, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ["data", "imf", "\(jobName)_\(gender.name)"]
        }

        guard let jobName = jobNameForIMF(job.rawValue) else {
            return nil
        }

        return ["data", "imf", "\(jobName)_\(gender.name)"]
    }

    private func jobSpriteName(for job: CharacterJob, madoType: MadoType = .robot) -> String? {
        if job.isPlayer {
            if job.isMadogear && madoType == .suit {
                suitMadogearJobName(for: job)
            } else {
                jobNameForSprite(job.rawValue)
            }
        } else {
            scriptContext.jobName(forJobID: job.rawValue)
        }
    }

    private func suitMadogearJobName(for job: CharacterJob) -> String {
        switch job.rawValue {
        case 4086, 4087, 4112:
            K2L("마도아머")
        default:
            "meister_madogear2"
        }
    }
}

extension Gender {
    var name: String {
        switch self {
        case .female: K2L("여")
        case .male: K2L("남")
        case .both: ""
        }
    }
}
