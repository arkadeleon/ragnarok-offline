//
//  JobModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import RagnarokConstants
import RagnarokDatabase
import RagnarokResources
import RagnarokSprite
import rAthenaCommon

@Observable
@dynamicMemberLookup
final class JobModel {
    struct BaseLevelStats: Identifiable {
        var level: Int
        var baseExp: Int
        var baseHp: Int
        var baseSp: Int

        var id: Int {
            level
        }
    }

    struct JobLevelStats: Identifiable {
        var level: Int
        var jobExp: Int
        var bonusStats: String

        var id: Int {
            level
        }
    }

    private let mode: DatabaseMode
    private let job: Job
    private let resourceManager: ResourceManager

    let localizedName: String?
    let skillTree: SkillTree?

    var animatedImagesByGender: [Gender : AnimatedImage] = [:]

    var displayName: String {
        localizedName ?? job.id.stringValue
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("Max Weight", table: "Database"), value: formatWeight(job.maxWeight)))
        attributes.append(.init(name: LocalizedStringResource("HP Factor", table: "Database"), value: job.hpFactor))
        attributes.append(.init(name: LocalizedStringResource("HP Increase", table: "Database"), value: job.hpIncrease))
        attributes.append(.init(name: LocalizedStringResource("SP Factor", table: "Database"), value: job.spFactor))
        attributes.append(.init(name: LocalizedStringResource("SP Increase", table: "Database"), value: job.spIncrease))
        attributes.append(.init(name: LocalizedStringResource("AP Factor", table: "Database"), value: job.apFactor))
        attributes.append(.init(name: LocalizedStringResource("AP Increase", table: "Database"), value: job.apIncrease))

        return attributes
    }

    var baseASPD: [DatabaseRecordAttribute] {
        WeaponType.allCases.compactMap { weaponType in
            if let aspd = job.baseASPD[weaponType] {
                DatabaseRecordAttribute(name: weaponType.localizedName, value: aspd)
            } else {
                nil
            }
        }
    }

    var baseLevels: [BaseLevelStats] {
        let maxBaseLevel = job.maxBaseLevel ?? RA_MAX_LEVEL
        let baseLevels = (1...maxBaseLevel).map { level in
            BaseLevelStats(
                level: level,
                baseExp: job.baseExp[level] ?? 0,
                baseHp: job.baseHp[level] ?? 0,
                baseSp: job.baseSp[level] ?? 0
            )
        }
        return baseLevels
    }

    var jobLevels: [JobLevelStats] {
        let maxJobLevel = job.maxJobLevel ?? RA_MAX_LEVEL
        let jobLevels = (1...maxJobLevel).map { level in
            let bonusStats = Parameter.allCases.compactMap { parameter in
                if let value = job.bonusStats[level]?[parameter], value > 0 {
                    return "\(parameter.stringValue)(+\(value.formatted()))"
                } else {
                    return nil
                }
            }.joined(separator: " ")

            return JobLevelStats(
                level: level,
                jobExp: job.jobExp[level] ?? 0,
                bonusStats: bonusStats
            )
        }
        return jobLevels
    }

    init(mode: DatabaseMode, job: Job, localizedName: String?, skillTree: SkillTree?, resourceManager: ResourceManager) {
        self.mode = mode
        self.job = job
        self.localizedName = localizedName
        self.skillTree = skillTree
        self.resourceManager = resourceManager
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Job, Value>) -> Value {
        job[keyPath: keyPath]
    }

    @MainActor
    func fetchAnimatedImage(for gender: Gender) async {
        if animatedImagesByGender[gender] != nil {
            return
        }

        let composedSprite: ComposedSprite
        do {
            let configuration = ComposedSprite.Configuration.configuration(jobID: job.id, gender: gender)
            composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
        } catch {
            logger.warning("Composed sprite error: \(error)")
            return
        }

        let renderer = SpriteAnimationRenderer()
        let animation = await renderer.render(composedSprite: composedSprite, actionType: .idle)
        animatedImagesByGender[gender] = AnimatedImage(animation: animation)
    }
}

extension JobModel: Equatable {
    static func == (lhs: JobModel, rhs: JobModel) -> Bool {
        lhs.job.id == rhs.job.id
    }
}

extension JobModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(job.id)
    }
}

extension JobModel: Identifiable {
    var id: JobID {
        job.id
    }
}

extension JobID {
    static func availableJobIDs(for mode: DatabaseMode) -> [JobID] {
        switch mode {
        case .prerenewal:
            [
                // Novice and first jobs.
                .novice,
                .swordman, .mage, .archer, .acolyte, .merchant, .thief,

                // Second jobs.
                .knight, .priest, .wizard, .blacksmith, .hunter, .assassin,
                .crusader, .monk, .sage, .rogue, .alchemist, .bard, .dancer,

                // Transcendent jobs.
                .novice_high,
                .swordman_high, .mage_high, .archer_high, .acolyte_high, .merchant_high, .thief_high,
                .lord_knight, .high_priest, .high_wizard, .whitesmith, .sniper, .assassin_cross,
                .paladin, .champion, .professor, .stalker, .creator, .clown, .gypsy,

                // Expanded jobs.
                .super_novice, .gunslinger, .ninja,
                .taekwon, .star_gladiator, .soul_linker,
            ]
        case .renewal:
            [
                // Novice and first jobs.
                .novice,
                .swordman, .mage, .archer, .acolyte, .merchant, .thief,

                // Second jobs.
                .knight, .priest, .wizard, .blacksmith, .hunter, .assassin,
                .crusader, .monk, .sage, .rogue, .alchemist, .bard, .dancer,

                // Transcendent jobs.
                .novice_high,
                .swordman_high, .mage_high, .archer_high, .acolyte_high, .merchant_high, .thief_high,
                .lord_knight, .high_priest, .high_wizard, .whitesmith, .sniper, .assassin_cross,
                .paladin, .champion, .professor, .stalker, .creator, .clown, .gypsy,

                // Expanded jobs.
                .super_novice, .gunslinger, .ninja,
                .taekwon, .star_gladiator, .soul_linker,

                // Third jobs; use one representative per profession.
                .rune_knight, .warlock, .ranger, .arch_bishop, .mechanic, .guillotine_cross,
                .royal_guard, .sorcerer, .minstrel, .wanderer, .sura, .genetic, .shadow_chaser,

                // Fourth jobs.
                .dragon_knight, .meister, .shadow_cross, .arch_mage, .cardinal, .windhawk,
                .imperial_guard, .biolo, .abyss_chaser, .elemental_master, .inquisitor,
                .troubadour, .trouvere,

                // Expanded job progressions.
                .super_novice_e, .kagerou, .oboro, .rebellion, .summoner,
                .star_emperor, .soul_reaper,
                .sky_emperor, .soul_ascetic, .shinkiro, .shiranui, .night_watch,
                .hyper_novice, .spirit_handler,
            ]
        }
    }

    var availableGenders: [Gender] {
        switch self {
        case .dancer, .baby_dancer, .gypsy, .wanderer, .wanderer_t, .wanderer_2nd,
             .baby_wanderer, .trouvere, .oboro, .baby_oboro, .shiranui:
            [.female]
        case .bard, .baby_bard, .clown, .minstrel, .minstrel_t, .minstrel_2nd,
             .baby_minstrel, .troubadour, .kagerou, .baby_kagerou, .shinkiro:
            [.male]
        default:
            [.male, .female]
        }
    }
}

/// Reference page: https://ro.ntome.com/skill
/// Basic job reference atlas: https://iro.ntome.com/class1.png
/// Expanded job reference atlas: https://iro.ntome.com/class2.webp
/// Jobs absent from the reference use a fixed representative appearance.
extension ComposedSprite.Configuration {
    static func configuration(jobID: JobID, gender: Gender) -> ComposedSprite.Configuration {
        var configuration = ComposedSprite.Configuration(jobID: jobID.rawValue)
        configuration.gender = gender

        // -1 uses the SPR's embedded palette.
        // Hair palettes: 1 yellow, 2 purple, 3 orange, 4 green, 5 blue, 6 white, 7 dark brown, 8 red.
        if gender == .female {
            let hair: (style: Int, color: Int) = switch jobID {
            case .swordman, .swordman_high:
                (4, -1)
            case .knight:
                (15, -1)
            case .lord_knight:
                (14, -1)
            case .rune_knight, .rune_knight_t:
                (3, 2)
            case .dragon_knight:
                (34, -1)
            case .crusader:
                (11, -1)
            case .paladin:
                (6, 0)
            case .royal_guard, .royal_guard_t:
                (25, 0)
            case .mage, .mage_high:
                (7, -1)
            case .wizard:
                (18, -1)
            case .high_wizard:
                (23, -1)
            case .arch_mage:
                (33, -1)
            case .sage:
                (19, -1)
            case .professor:
                (27, 3)
            case .sorcerer, .sorcerer_t:
                (20, 0)
            case .elemental_master:
                (38, -1)
            case .merchant, .merchant_high:
                (3, -1)
            case .blacksmith:
                (17, -1)
            case .whitesmith:
                (18, 6)
            case .mechanic, .mechanic_t:
                (26, -1)
            case .meister:
                (42, -1)
            case .alchemist:
                (9, -1)
            case .creator:
                (18, 0)
            case .genetic, .genetic_t:
                (9, 5)
            case .biolo:
                (40, -1)
            case .thief, .thief_high:
                (6, -1)
            case .assassin:
                (10, -1)
            case .guillotine_cross, .guillotine_cross_t:
                (18, 0)
            case .shadow_cross:
                (41, -1)
            case .rogue:
                (8, -1)
            case .stalker:
                (22, -1)
            case .shadow_chaser, .shadow_chaser_t:
                (6, 6)
            case .acolyte, .acolyte_high:
                (5, -1)
            case .priest:
                (12, -1)
            case .high_priest:
                (21, -1)
            case .arch_bishop, .arch_bishop_t:
                (27, 1)
            case .cardinal:
                (36, -1)
            case .monk:
                (13, -1)
            case .champion:
                (6, 2)
            case .sura, .sura_t:
                (16, 0)
            case .inquisitor:
                (37, -1)
            case .archer, .archer_high:
                (1, -1)
            case .hunter:
                (16, -1)
            case .sniper:
                (20, 1)
            case .ranger, .ranger_t:
                (24, 5)
            case .windhawk:
                (35, -1)
            case .dancer, .baby_dancer:
                (14, -1)
            case .gypsy:
                (7, 0)
            case .wanderer, .wanderer_t, .wanderer_2nd, .baby_wanderer:
                (26, 4)
            case .trouvere:
                (39, -1)
            case .oboro, .baby_oboro:
                (29, 0)
            case .imperial_guard, .warlock, .warlock_t, .assassin_cross, .abyss_chaser:
                // The reference head has not been matched to the available SPR/PAL resources yet.
                (1, -1)
            default:
                (1, -1)
            }
            configuration.hairStyle = hair.style
            configuration.hairColor = hair.color
        } else {
            let hair: (style: Int, color: Int) = switch jobID {
            case .novice, .novice_high, .super_novice, .super_novice_e, .hyper_novice:
                (1, 7)
            case .swordman, .swordman_high:
                (1, -1)
            case .knight:
                (8, -1)
            case .lord_knight:
                (23, 6)
            case .rune_knight, .rune_knight_t:
                (26, 3)
            case .dragon_knight:
                (34, -1)
            case .crusader:
                (9, -1)
            case .paladin:
                (14, 7)
            case .royal_guard, .royal_guard_t:
                (7, 2)
            case .imperial_guard:
                (30, -1)
            case .mage, .mage_high:
                (7, -1)
            case .wizard:
                (18, -1)
            case .high_wizard:
                (24, 1)
            case .warlock, .warlock_t:
                (7, 0)
            case .arch_mage:
                (33, -1)
            case .sage:
                (12, -1)
            case .professor:
                (11, 4)
            case .sorcerer, .sorcerer_t:
                (8, 4)
            case .elemental_master:
                (38, -1)
            case .merchant, .merchant_high:
                (3, -1)
            case .blacksmith:
                (17, -1)
            case .whitesmith:
                (22, 4)
            case .mechanic, .mechanic_t:
                (26, -1)
            case .meister:
                (42, -1)
            case .alchemist:
                (10, -1)
            case .creator:
                (27, -1)
            case .genetic, .genetic_t:
                (24, 7)
            case .biolo:
                (40, -1)
            case .thief, .thief_high:
                (6, -1)
            case .assassin:
                (15, -1)
            case .assassin_cross:
                (21, 5)
            case .guillotine_cross, .guillotine_cross_t:
                (10, 6)
            case .shadow_cross:
                (41, -1)
            case .rogue:
                (13, -1)
            case .stalker:
                (21, 7)
            case .shadow_chaser, .shadow_chaser_t:
                (24, 7)
            case .abyss_chaser:
                // Pending: no matching reference head was found in the available client resources.
                (24, 8)
            case .acolyte, .acolyte_high:
                (4, -1)
            case .priest:
                (11, -1)
            case .high_priest:
                (2, 6)
            case .arch_bishop, .arch_bishop_t:
                (27, 7)
            case .cardinal:
                (36, -1)
            case .monk:
                (19, -1)
            case .champion:
                (25, -1)
            case .sura, .sura_t:
                (27, 1)
            case .inquisitor:
                (37, -1)
            case .archer, .archer_high:
                (5, -1)
            case .hunter:
                (16, -1)
            case .sniper:
                (26, 4)
            case .ranger, .ranger_t:
                (13, 6)
            case .windhawk:
                (35, -1)
            case .bard:
                (14, -1)
            case .clown:
                (9, 1)
            case .minstrel, .minstrel_t:
                (23, 6)
            case .troubadour:
                (39, -1)
            case .dancer:
                (14, -1)
            case .gypsy:
                (7, 0)
            case .wanderer, .wanderer_t:
                (26, 4)
            case .trouvere:
                (39, -1)
            case .gunslinger, .rebellion, .night_watch:
                (2, 6)
            case .ninja, .kagerou, .shinkiro:
                (4, 7)
            case .oboro, .shiranui:
                (4, 7)
            case .taekwon, .star_gladiator, .star_emperor, .sky_emperor:
                (2, 7)
            case .soul_linker, .soul_reaper, .soul_ascetic:
                (4, 7)
            case .summoner, .spirit_handler:
                (1, -1)
            default:
                (1, -1)
            }
            configuration.hairStyle = hair.style
            configuration.hairColor = hair.color
        }

        return configuration
    }
}
