//
//  ResourcePathGenerator+Sprite.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

import ROConstants
import ROResources

extension ResourcePathGenerator {
    func generateShadowSpritePath() -> ResourcePath {
        ResourcePath.spriteDirectory.appending("shadow")
    }

    func generatePlayerBodySpritePath(job: UniformJob, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(for: job, madoType: madoType) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending(["도람족", "몸통", gender.name, "\(jobName)_\(gender.name)"])
        } else {
            return ResourcePath.spriteDirectory.appending(["인간족", "몸통", gender.name, "\(jobName)_\(gender.name)"])
        }
    }

    func generateAlternatePlayerBodySpritePath(job: UniformJob, gender: Gender, costumeID: Int, madoType: MadoType = .robot) async -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(for: job, madoType: madoType) else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending(["도람족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"])
        } else {
            return ResourcePath.spriteDirectory.appending(["인간족", "몸통", gender.name, "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(costumeID)"])
        }
    }

    func generatePlayerHeadSpritePath(job: UniformJob, hairStyle: Int, gender: Gender) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.spriteDirectory.appending(["도람족", "머리통", gender.name, "\(hairStyle)_\(gender.name)"])
        } else {
            return ResourcePath.spriteDirectory.appending(["인간족", "머리통", gender.name, "\(hairStyle)_\(gender.name)"])
        }
    }

    func generateNonPlayerSpritePath(job: UniformJob) async -> ResourcePath? {
        guard !job.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(for: job) else {
            return nil
        }

        if job.isNPC {
            return ResourcePath.spriteDirectory.appending(["npc", jobName])
        } else if job.isMercenary {
            return ResourcePath.spriteDirectory.appending(["인간족", "몸통", jobName])
        } else if job.isHomunculus {
            return ResourcePath.spriteDirectory.appending(["homun", jobName])
        } else if job.isMonster {
            return ResourcePath.spriteDirectory.appending(["몬스터", jobName])
        } else {
            return nil
        }
    }

    func generateWeaponSpritePath(job: UniformJob, weapon: Int, isSlash: Bool = false, gender: Gender, madoType: MadoType = .robot) async -> ResourcePath? {
        guard job.isPlayer || job.isMercenary else {
            return nil
        }

        if job.isPlayer {
            let isMadogear = job.isMadogear
            let isSuitMadogear = isMadogear && madoType == .suit
            let madogearJobName = isSuitMadogear ? suitMadogearJobName(for: job) : ""

            guard var jobName = jobNamesForWeapon[job.rawValue] else {
                return nil
            }

            if isSuitMadogear {
                jobName = (jobName.0, madogearJobName)
            }

            var weaponName = await scriptManager.weaponName(forWeaponID: weapon)

            if weaponName == nil && !isMadogear {
                if let realWeaponID = await scriptManager.realWeaponID(forWeaponID: weapon) {
                    weaponName = await scriptManager.weaponName(forWeaponID: realWeaponID)
                    if weaponName == nil {
                        weaponName = "_\(weapon)"
                    }
                }
            }

            guard let weaponName else {
                return nil
            }

            if job.isDoram {
                return ResourcePath.spriteDirectory.appending(["도람족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"])
            } else {
                return ResourcePath.spriteDirectory.appending(["인간족", jobName.0, "\(jobName.1)_\(gender.name)\(weaponName)\(isSlash ? "_검광" : "")"])
            }
        } else {
            let mercenaryPath = ResourcePath.spriteDirectory.appending(["인간족", "용병"])

            switch job.rawValue {
            case 6017...6026:
                return mercenaryPath.appending("활용병_활")
            case 6027...6036:
                return mercenaryPath.appending("창용병_창")
            default:
                return mercenaryPath.appending("검용병_검")
            }
        }
    }

    func generateShieldSpritePath(job: UniformJob, shield: Int, gender: Gender) async -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(for: job) else {
            return nil
        }

        if let shieldName = shieldNames[shield] {
            return ResourcePath.spriteDirectory.appending(["방패", jobName, "\(jobName)_\(gender.name)\(shieldName)"])
        } else {
            return ResourcePath.spriteDirectory.appending(["방패", jobName, "\(jobName)_\(gender.name)_\(shield)_방패"])
        }
    }

    func generateHeadgearSpritePath(headgear: Int, gender: Gender) async -> ResourcePath? {
        guard let accessoryName = await scriptManager.accessoryName(forAccessoryID: headgear) else {
            return nil
        }

        return ResourcePath.spriteDirectory.appending(["악세사리", gender.name, "\(gender.name)\(accessoryName)"])
    }

    func generateGarmentSpritePath(job: UniformJob, garment: Int, gender: Gender, checkEnglish: Bool = false, useFallback: Bool = false) async -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        guard let jobName = await jobSpriteName(for: job),
              let robeName = await scriptManager.robeName(forRobeID: garment, checkEnglish: checkEnglish) else {
            return nil
        }

        if useFallback {
            return ResourcePath.spriteDirectory.appending(["로브", robeName, robeName])
        } else {
            return ResourcePath.spriteDirectory.appending(["로브", robeName, gender.name, "\(jobName)_\(gender.name)"])
        }
    }

    func generatePlayerBodyPalettePath(job: UniformJob, clothesColor: Int, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ResourcePath.paletteDirectory.appending(["몸", "\(jobName)_\(gender.name)_\(clothesColor)"])
        }

        guard let jobName = jobNamesForPalette[job.rawValue] else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending(["도람족", "body", "\(jobName)_\(gender.name)_\(clothesColor)"])
        } else {
            return ResourcePath.paletteDirectory.appending(["몸", "\(jobName)_\(gender.name)_\(clothesColor)"])
        }
    }

    func generateAlternatePlayerBodyPalettePath(job: UniformJob, clothesColor: Int, gender: Gender, costumeID: Int, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ResourcePath.paletteDirectory.appending(["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        }

        guard let jobName = jobNamesForPalette[job.rawValue] else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending(["도람족", "body", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        } else {
            return ResourcePath.paletteDirectory.appending(["몸", "costume_\(costumeID)", "\(jobName)_\(gender.name)_\(clothesColor)_\(costumeID)"])
        }
    }

    func generatePlayerHeadPalettePath(job: UniformJob, hairStyle: Int, hairColor: Int, gender: Gender) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isDoram {
            return ResourcePath.paletteDirectory.appending(["도람족", "머리", "머리\(hairStyle)_\(gender.name)_\(hairColor)"])
        } else {
            return ResourcePath.paletteDirectory.appending(["머리", "머리\(hairStyle)_\(gender.name)_\(hairColor)"])
        }
    }

    func generateIMFPath(job: UniformJob, gender: Gender, madoType: MadoType = .robot) -> ResourcePath? {
        guard job.isPlayer else {
            return nil
        }

        if job.isMadogear && madoType == .suit {
            let jobName = suitMadogearJobName(for: job)
            return ["data", "imf", "\(jobName)_\(gender.name)"]
        }

        guard let jobName = jobNamesForIMF[job.rawValue] else {
            return nil
        }

        return ["data", "imf", "\(jobName)_\(gender.name)"]
    }

    private func jobSpriteName(for job: UniformJob, madoType: MadoType = .robot) async -> String? {
        if job.isPlayer {
            if job.isMadogear && madoType == .suit {
                return suitMadogearJobName(for: job)
            } else {
                return jobNamesForSprite[job.rawValue]
            }
        } else {
            return await scriptManager.jobName(forJobID: job.rawValue)
        }
    }

    private func suitMadogearJobName(for job: UniformJob) -> String {
        switch job.rawValue {
        case 4086, 4087, 4112:
            "마도아머"
        default:
            "meister_madogear2"
        }
    }
}
