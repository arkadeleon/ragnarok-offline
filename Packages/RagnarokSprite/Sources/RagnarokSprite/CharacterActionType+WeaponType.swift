//
//  CharacterActionType+WeaponType.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2026/2/4.
//

import RagnarokConstants

extension CharacterActionType {
    static func attackActionType(for baseJobID: JobID, gender: Gender, weaponType: WeaponType) -> CharacterActionType {
        let isFemale = gender == .female

        let attackActionType: CharacterActionType = switch baseJobID {
        case .novice:
            if isFemale {
                switch weaponType {
                case .w_dagger:
                    .attack3
                case .w_staff, .w_2hstaff, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                    .attack2
                default:
                    .attack1
                }
            } else {
                switch weaponType {
                case .w_dagger:
                    .attack2
                case .w_staff, .w_2hstaff, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                    .attack3
                default:
                    .attack1
                }
            }
        case .swordman:
            switch weaponType {
            case .w_1hspear, .w_2hspear:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .mage:
            switch weaponType {
            case .w_dagger:
                .attack3
            case .w_staff, .w_2hstaff:
                .attack2
            default:
                .attack1
            }
        case .archer:
            switch weaponType {
            case .w_dagger:
                .attack3
            case .w_bow:
                .attack2
            default:
                .attack1
            }
        case .acolyte:
            switch weaponType {
            case .w_staff, .w_2hstaff, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .merchant:
            switch weaponType {
            case .w_dagger:
                .attack3
            case .w_mace, .w_2hmace, .w_1haxe, .w_2haxe, .w_1hsword, .w_2hsword:
                .attack2
            default:
                .attack1
            }
        case .thief:
            switch weaponType {
            case .w_bow:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword:
                .attack2
            default:
                .attack1
            }
        case .knight:
            switch weaponType {
            case .w_1hspear, .w_2hspear:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .priest:
            switch weaponType {
            case .w_book:
                .attack3
            case .w_staff, .w_2hstaff, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .wizard:
            if isFemale {
                switch weaponType {
                case .w_staff, .w_2hstaff:
                    .attack3
                case .w_dagger:
                    .attack2
                default:
                    .attack1
                }
            } else {
                switch weaponType {
                case .w_dagger:
                    .attack3
                case .w_staff, .w_2hstaff:
                    .attack2
                default:
                    .attack1
                }
            }
        case .blacksmith:
            switch weaponType {
            case .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack3
            case .w_dagger:
                .attack2
            default:
                .attack1
            }
        case .hunter:
            switch weaponType {
            case .w_bow:
                .attack3
            case .w_dagger:
                .attack2
            default:
                .attack1
            }
        case .assassin:
            switch weaponType {
            case .w_katar:
                .attack3
            case .w_dagger, .w_1hsword, .w_1haxe:
                .attack2
            default:
                .attack1
            }
        case .knight2:
            switch weaponType {
            case .w_1hspear, .w_2hspear:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .crusader:
            switch weaponType {
            case .w_1hspear, .w_2hspear:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .monk:
            switch weaponType {
            case .w_knuckle:
                .attack3
            case .w_staff, .w_2hstaff, .w_mace, .w_2hmace:
                .attack2
            default:
                .attack1
            }
        case .sage:
            switch weaponType {
            case .w_staff, .w_2hstaff, .w_book:
                .attack3
            case .w_dagger:
                .attack2
            default:
                .attack1
            }
        case .rogue:
            switch weaponType {
            case .w_bow:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword:
                .attack2
            default:
                .attack1
            }
        case .alchemist:
            switch weaponType {
            case .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace:
                .attack3
            case .w_dagger:
                .attack2
            default:
                .attack1
            }
        case .bard:
            switch weaponType {
            case .w_bow:
                .attack3
            case .w_dagger, .w_musical:
                .attack2
            default:
                .attack1
            }
        case .dancer:
            switch weaponType {
            case .w_bow:
                .attack3
            case .w_whip:
                .attack2
            default:
                .attack1
            }
        case .crusader2:
            switch weaponType {
            case .w_1hspear, .w_2hspear:
                .attack3
            case .w_dagger, .w_1hsword, .w_2hsword, .w_1haxe, .w_2haxe, .w_mace:
                .attack2
            default:
                .attack1
            }
        case .super_novice:
            if isFemale {
                switch weaponType {
                case .w_dagger:
                    .attack3
                case .w_staff, .w_2hstaff, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace, .w_1hsword:
                    .attack2
                default:
                    .attack1
                }
            } else {
                switch weaponType {
                case .w_dagger:
                    .attack2
                case .w_staff, .w_2hstaff, .w_1haxe, .w_2haxe, .w_mace, .w_2hmace, .w_1hsword:
                    .attack3
                default:
                    .attack1
                }
            }
        case .gunslinger:
            switch weaponType {
            case .w_gatling, .w_rifle, .w_grenade:
                .attack3
            case .w_fist, .w_revolver, .w_shotgun:
                .attack2
            default:
                .attack1
            }
        case .ninja:
            switch weaponType {
            case .w_huuma:
                .attack3
            case .w_dagger:
                .attack2
            default:
                .attack1
            }
        case .soul_linker:
            if isFemale {
                switch weaponType {
                case .w_staff, .w_2hstaff:
                    .attack3
                case .w_dagger:
                    .attack2
                default:
                    .attack1
                }
            } else {
                switch weaponType {
                case .w_dagger:
                    .attack3
                case .w_staff, .w_2hstaff:
                    .attack2
                default:
                    .attack1
                }
            }
        default:
            .attack1
        }

        return attackActionType
    }

    public static func attackActionType(forJobID jobID: Int, gender: Gender, weapon: Int) -> CharacterActionType {
        guard let jobID = JobID(rawValue: jobID), let weaponType = WeaponType(rawValue: weapon) else {
            return .attack1
        }

        let baseJobID: JobID = switch jobID {
        case .novice, .novice_high, .baby:
            .novice
        case .swordman, .swordman_high, .baby_swordman:
            .swordman
        case .mage, .mage_high, .baby_mage:
            .mage
        case .archer, .archer_high, .baby_archer:
            .archer
        case .acolyte, .acolyte_high, .baby_acolyte:
            .acolyte
        case .merchant, .merchant_high, .baby_merchant:
            .merchant
        case .thief, .thief_high, .baby_thief:
            .thief
        case .knight, .lord_knight, .baby_knight, .rune_knight, .rune_knight_t, .baby_rune_knight, .dragon_knight, .rune_knight_2nd:
            .knight
        case .knight2, .lord_knight2, .baby_knight2, .rune_knight2, .rune_knight_t2, .baby_rune_knight2, .dragon_knight2:
            .knight2
        case .priest, .high_priest, .baby_priest, .arch_bishop, .arch_bishop_t, .baby_arch_bishop, .cardinal, .archbishop_2nd:
            .priest
        case .wizard, .high_wizard, .baby_wizard, .warlock, .warlock_t, .baby_warlock, .arch_mage, .warlock_2nd:
            .wizard
        case .blacksmith, .whitesmith, .baby_blacksmith, .mechanic, .mechanic_t, .baby_mechanic, .meister, .meister2, .mechanic2, .mechanic_t2, .baby_mechanic2, .mechanic_2nd:
            .blacksmith
        case .hunter, .sniper, .baby_hunter, .ranger, .ranger_t, .baby_ranger, .windhawk, .windhawk2, .ranger2, .ranger_t2, .baby_ranger2, .ranger_2nd:
            .hunter
        case .assassin, .assassin_cross, .baby_assassin, .guillotine_cross, .guillotine_cross_t, .baby_guillotine_cross, .shadow_cross, .guillotine_cross_2nd:
            .assassin
        case .crusader, .paladin, .baby_crusader, .royal_guard, .royal_guard_t, .baby_royal_guard, .imperial_guard, .royal_guard_2nd:
            .crusader
        case .crusader2, .paladin2, .baby_crusader2, .royal_guard2, .royal_guard_t2, .baby_royal_guard2, .imperial_guard2:
            .crusader2
        case .monk, .champion, .baby_monk, .sura, .sura_t, .baby_sura, .inquisitor, .sura_2nd:
            .monk
        case .sage, .professor, .baby_sage, .sorcerer, .sorcerer_t, .baby_sorcerer, .elemental_master, .sorcerer_2nd:
            .sage
        case .rogue, .stalker, .baby_rogue, .shadow_chaser, .shadow_chaser_t, .baby_shadow_chaser, .abyss_chaser, .shadow_chaser_2nd:
            .rogue
        case .alchemist, .creator, .baby_alchemist, .genetic, .genetic_t, .baby_genetic, .biolo, .genetic_2nd:
            .alchemist
        case .bard, .clown, .baby_bard, .minstrel, .minstrel_t, .baby_minstrel, .troubadour, .minstrel_2nd:
            .bard
        case .dancer, .gypsy, .baby_dancer, .wanderer, .wanderer_t, .baby_wanderer, .trouvere, .wanderer_2nd:
            .dancer
        case .super_novice, .super_novice_e, .super_baby, .super_baby_e, .hyper_novice:
            .super_novice
        case .ninja, .kagerou, .oboro, .shinkiro, .shiranui, .baby_ninja, .baby_kagerou, .baby_oboro:
            .ninja
        case .gunslinger, .rebellion, .night_watch, .baby_gunslinger, .baby_rebellion:
            .gunslinger
        case .soul_linker, .soul_reaper, .soul_ascetic, .baby_soul_linker, .baby_soul_reaper:
            .soul_linker
        default:
            .novice
        }

        return attackActionType(for: baseJobID, gender: gender, weaponType: weaponType)
    }
}
