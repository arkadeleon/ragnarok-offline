//
//  JobHitSoundTable.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/15.
//

import RagnarokConstants

// Ported from roBrowserLegacy:
// https://github.com/MrAntares/roBrowserLegacy/blob/master/src/DB/Jobs/JobHitSoundTable.js
enum JobHitSoundTable {
    static func hitSoundFilenames(forJob job: Int) -> [String] {
        switch job {
        case JobID.novice.rawValue:
            ["player_clothes.wav"]
        case JobID.swordman.rawValue:
            ["player_metal.wav"]
        case JobID.mage.rawValue:
            ["player_clothes.wav"]
        case JobID.archer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.acolyte.rawValue:
            ["player_clothes.wav"]
        case JobID.merchant.rawValue:
            ["player_clothes.wav"]
        case JobID.thief.rawValue:
            ["player_wooden_male.wav"]
        case JobID.knight.rawValue:
            ["player_metal.wav"]
        case JobID.priest.rawValue:
            ["player_clothes.wav"]
        case JobID.wizard.rawValue:
            ["player_clothes.wav"]
        case JobID.blacksmith.rawValue:
            ["player_clothes.wav"]
        case JobID.hunter.rawValue:
            ["player_wooden_male.wav"]
        case JobID.assassin.rawValue:
            ["player_wooden_male.wav"]
        case JobID.knight2.rawValue:
            ["player_metal.wav"]
        case JobID.crusader.rawValue:
            ["player_metal.wav"]
        case JobID.monk.rawValue:
            ["player_metal.wav"]
        case JobID.sage.rawValue:
            ["player_clothes.wav"]
        case JobID.rogue.rawValue:
            ["player_wooden_male.wav"]
        case JobID.alchemist.rawValue:
            ["player_clothes.wav"]
        case JobID.bard.rawValue:
            ["player_wooden_male.wav"]
        case JobID.dancer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.crusader2.rawValue:
            ["player_metal.wav"]
        case JobID.wedding.rawValue:
            ["player_clothes.wav"]
        case JobID.super_novice.rawValue:
            ["player_clothes.wav"]
        case JobID.gunslinger.rawValue:
            ["player_wooden_male.wav"]
        case JobID.ninja.rawValue:
            ["player_wooden_male.wav"]
        case JobID.xmas.rawValue:
            ["player_clothes.wav"]
        case JobID.summer.rawValue:
            ["player_clothes.wav"]
        case JobID.novice_high.rawValue:
            ["player_clothes.wav"]
        case JobID.swordman_high.rawValue:
            ["player_metal.wav"]
        case JobID.mage_high.rawValue:
            ["player_clothes.wav"]
        case JobID.archer_high.rawValue:
            ["player_wooden_male.wav"]
        case JobID.acolyte_high.rawValue:
            ["player_clothes.wav"]
        case JobID.merchant_high.rawValue:
            ["player_clothes.wav"]
        case JobID.thief_high.rawValue:
            ["player_wooden_male.wav"]
        case JobID.lord_knight.rawValue:
            ["player_metal.wav"]
        case JobID.high_priest.rawValue:
            ["player_clothes.wav"]
        case JobID.high_wizard.rawValue:
            ["player_clothes.wav"]
        case JobID.whitesmith.rawValue:
            ["player_clothes.wav"]
        case JobID.sniper.rawValue:
            ["player_wooden_male.wav"]
        case JobID.assassin_cross.rawValue:
            ["player_wooden_male.wav"]
        case JobID.lord_knight2.rawValue:
            ["player_metal.wav"]
        case JobID.paladin.rawValue:
            ["player_metal.wav"]
        case JobID.champion.rawValue:
            ["player_metal.wav"]
        case JobID.professor.rawValue:
            ["player_clothes.wav"]
        case JobID.stalker.rawValue:
            ["player_wooden_male.wav"]
        case JobID.creator.rawValue:
            ["player_clothes.wav"]
        case JobID.clown.rawValue:
            ["player_wooden_male.wav"]
        case JobID.gypsy.rawValue:
            ["player_wooden_male.wav"]
        case JobID.paladin2.rawValue:
            ["player_metal.wav"]
        case JobID.baby.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_swordman.rawValue:
            ["player_metal.wav"]
        case JobID.baby_mage.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_archer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_acolyte.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_merchant.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_thief.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_knight.rawValue:
            ["player_metal.wav"]
        case JobID.baby_priest.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_wizard.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_blacksmith.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_hunter.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_assassin.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_knight2.rawValue:
            ["player_metal.wav"]
        case JobID.baby_crusader.rawValue:
            ["player_metal.wav"]
        case JobID.baby_monk.rawValue:
            ["player_metal.wav"]
        case JobID.baby_sage.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_rogue.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_alchemist.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_bard.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_dancer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_crusader2.rawValue:
            ["player_metal.wav"]
        case JobID.taekwon.rawValue:
            ["player_wooden_male.wav"]
        case JobID.star_gladiator.rawValue:
            ["player_metal.wav"]
        case JobID.star_gladiator2.rawValue:
            ["player_metal.wav"]
        case JobID.soul_linker.rawValue:
            ["player_clothes.wav"]
        case JobID.rune_knight.rawValue:
            ["player_metal.wav"]
        case JobID.warlock.rawValue:
            ["player_clothes.wav"]
        case JobID.ranger.rawValue:
            ["player_wooden_male.wav"]
        case JobID.arch_bishop.rawValue:
            ["player_clothes.wav"]
        case JobID.mechanic.rawValue:
            ["player_clothes.wav"]
        case JobID.guillotine_cross.rawValue:
            ["player_wooden_male.wav"]
        case JobID.rune_knight_t.rawValue:
            ["player_metal.wav"]
        case JobID.warlock_t.rawValue:
            ["player_clothes.wav"]
        case JobID.ranger_t.rawValue:
            ["player_wooden_male.wav"]
        case JobID.arch_bishop_t.rawValue:
            ["player_clothes.wav"]
        case JobID.mechanic_t.rawValue:
            ["player_clothes.wav"]
        case JobID.guillotine_cross_t.rawValue:
            ["player_wooden_male.wav"]
        case JobID.royal_guard.rawValue:
            ["player_metal.wav"]
        case JobID.sorcerer.rawValue:
            ["player_clothes.wav"]
        case JobID.minstrel.rawValue:
            ["player_wooden_male.wav"]
        case JobID.wanderer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.sura.rawValue:
            ["player_metal.wav"]
        case JobID.genetic.rawValue:
            ["player_clothes.wav"]
        case JobID.shadow_chaser.rawValue:
            ["player_wooden_male.wav"]
        case JobID.royal_guard_t.rawValue:
            ["player_metal.wav"]
        case JobID.sorcerer_t.rawValue:
            ["player_clothes.wav"]
        case JobID.minstrel_t.rawValue:
            ["player_wooden_male.wav"]
        case JobID.wanderer_t.rawValue:
            ["player_wooden_male.wav"]
        case JobID.sura_t.rawValue:
            ["player_metal.wav"]
        case JobID.genetic_t.rawValue:
            ["player_clothes.wav"]
        case JobID.shadow_chaser_t.rawValue:
            ["player_wooden_male.wav"]
        case JobID.rune_knight2.rawValue:
            ["player_metal.wav"]
        case JobID.rune_knight_t2.rawValue:
            ["player_metal.wav"]
        case JobID.royal_guard2.rawValue:
            ["player_metal.wav"]
        case JobID.royal_guard_t2.rawValue:
            ["player_metal.wav"]
        case JobID.ranger2.rawValue:
            ["player_wooden_male.wav"]
        case JobID.ranger_t2.rawValue:
            ["player_wooden_male.wav"]
        case JobID.mechanic2.rawValue:
            ["player_clothes.wav"]
        case JobID.mechanic_t2.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_rune_knight.rawValue:
            ["player_metal.wav"]
        case JobID.baby_warlock.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_ranger.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_arch_bishop.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_mechanic.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_guillotine_cross.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_royal_guard.rawValue:
            ["player_metal.wav"]
        case JobID.baby_sorcerer.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_minstrel.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_wanderer.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_sura.rawValue:
            ["player_metal.wav"]
        case JobID.baby_genetic.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_shadow_chaser.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_rune_knight2.rawValue:
            ["player_metal.wav"]
        case JobID.baby_royal_guard2.rawValue:
            ["player_metal.wav"]
        case JobID.baby_ranger2.rawValue:
            ["player_wooden_male.wav"]
        case JobID.baby_mechanic2.rawValue:
            ["player_clothes.wav"]
        case 4114: // FROG_NINJA
            ["player_wooden_male.wav"]
        case 4115: // PECO_GUNNER
            ["player_wooden_male.wav"]
        case 4116: // PECO_SWORD
            ["player_metal.wav"]
        case 4117: // FROG_LINKER
            ["player_clothes.wav"]
        case 4118: // PIG_WHITESMITH
            ["player_clothes.wav"]
        case 4119: // PIG_MERCHANT
            ["player_clothes.wav"]
        case 4120: // PIG_GENETIC
            ["player_clothes.wav"]
        case 4121: // PIG_CREATOR
            ["player_clothes.wav"]
        case 4122: // OSTRICH_ARCHER
            ["player_wooden_male.wav"]
        case 4123: // PORING_STAR
            ["player_metal.wav"]
        case 4124: // PORING_NOVICE
            ["player_clothes.wav"]
        case 4125: // SHEEP_MONK
            ["player_metal.wav"]
        case 4126: // SHEEP_ACO
            ["player_clothes.wav"]
        case 4127: // SHEEP_SURA
            ["player_metal.wav"]
        case 4128: // PORING_SNOVICE
            ["player_clothes.wav"]
        case 4129: // SHEEP_ARCB
            ["player_clothes.wav"]
        case 4130: // FOX_MAGICIAN
            ["player_clothes.wav"]
        case 4131: // FOX_SAGE
            ["player_clothes.wav"]
        case 4132: // FOX_SORCERER
            ["player_clothes.wav"]
        case 4133: // FOX_WARLOCK
            ["player_clothes.wav"]
        case 4134: // FOX_WIZ
            ["player_clothes.wav"]
        case 4135: // FOX_PROF
            ["player_clothes.wav"]
        case 4136: // FOX_HWIZ
            ["player_clothes.wav"]
        case 4137: // PIG_ALCHE
            ["player_clothes.wav"]
        case 4138: // PIG_BLACKSMITH
            ["player_clothes.wav"]
        case 4139: // SHEEP_CHAMP
            ["player_metal.wav"]
        case 4140: // DOG_G_CROSS
            ["player_wooden_male.wav"]
        case 4141: // DOG_THIEF
            ["player_wooden_male.wav"]
        case 4142: // DOG_ROGUE
            ["player_wooden_male.wav"]
        case 4143: // DOG_CHASER
            ["player_wooden_male.wav"]
        case 4144: // DOG_STALKER
            ["player_wooden_male.wav"]
        case 4145: // DOG_ASSASSIN
            ["player_wooden_male.wav"]
        case 4146: // DOG_ASSA_X
            ["player_wooden_male.wav"]
        case 4147: // OSTRICH_DANCER
            ["player_wooden_male.wav"]
        case 4148: // OSTRICH_MINSTREL
            ["player_wooden_male.wav"]
        case 4149: // OSTRICH_BARD
            ["player_wooden_male.wav"]
        case 4150: // OSTRICH_SNIPER
            ["player_wooden_male.wav"]
        case 4151: // OSTRICH_WANDER
            ["player_wooden_male.wav"]
        case 4152: // OSTRICH_ZIPSI
            ["player_wooden_male.wav"]
        case 4153: // OSTRICH_CROWN
            ["player_wooden_male.wav"]
        case 4154: // OSTRICH_HUNTER
            ["player_wooden_male.wav"]
        case 4155: // PORING_TAEKWON
            ["player_wooden_male.wav"]
        case 4156: // SHEEP_PRIEST
            ["player_clothes.wav"]
        case 4157: // SHEEP_HPRIEST
            ["player_clothes.wav"]
        case 4158: // PORING_NOVICE_B
            ["player_clothes.wav"]
        case 4159: // PECO_SWORD_B
            ["player_metal.wav"]
        case 4160: // FOX_MAGICIAN_B
            ["player_clothes.wav"]
        case 4161: // OSTRICH_ARCHER_B
            ["player_wooden_male.wav"]
        case 4162: // SHEEP_ACO_B
            ["player_clothes.wav"]
        case 4163: // PIG_MERCHANT_B
            ["player_clothes.wav"]
        case 4164: // OSTRICH_HUNTER_B
            ["player_wooden_male.wav"]
        case 4165: // DOG_ASSASSIN_B
            ["player_wooden_male.wav"]
        case 4166: // SHEEP_MONK_B
            ["player_metal.wav"]
        case 4167: // FOX_SAGE_B
            ["player_clothes.wav"]
        case 4168: // DOG_ROGUE_B
            ["player_wooden_male.wav"]
        case 4169: // PIG_ALCHE_B
            ["player_clothes.wav"]
        case 4170: // OSTRICH_BARD_B
            ["player_wooden_male.wav"]
        case 4171: // OSTRICH_DANCER_B
            ["player_wooden_male.wav"]
        case 4172: // PORING_SNOVICE_B
            ["player_clothes.wav"]
        case 4173: // FOX_WARLOCK_B
            ["player_clothes.wav"]
        case 4174: // SHEEP_ARCB_B
            ["player_clothes.wav"]
        case 4175: // DOG_G_CROSS_B
            ["player_wooden_male.wav"]
        case 4176: // FOX_SORCERER_B
            ["player_clothes.wav"]
        case 4177: // OSTRICH_MINSTREL_B
            ["player_wooden_male.wav"]
        case 4178: // OSTRICH_WANDER_B
            ["player_wooden_male.wav"]
        case 4179: // SHEEP_SURA_B
            ["player_metal.wav"]
        case 4180: // PIG_GENETIC_B
            ["player_clothes.wav"]
        case 4181: // DOG_THIEF_B
            ["player_wooden_male.wav"]
        case 4182: // DOG_CHASER_B
            ["player_wooden_male.wav"]
        case 4183: // PORING_NOVICE_H
            ["player_clothes.wav"]
        case 4184: // PECO_SWORD_H
            ["player_metal.wav"]
        case 4185: // FOX_MAGICIAN_H
            ["player_clothes.wav"]
        case 4186: // OSTRICH_ARCHER_H
            ["player_wooden_male.wav"]
        case 4187: // SHEEP_ACO_H
            ["player_clothes.wav"]
        case 4188: // PIG_MERCHANT_H
            ["player_clothes.wav"]
        case 4189: // DOG_THIEF_H
            ["player_wooden_male.wav"]
        case JobID.super_novice_e.rawValue:
            ["player_clothes.wav"]
        case 4192: // PORING_SNOVICE2
            ["player_clothes.wav"]
        case 4193: // PORING_SNOVICE2_B
            ["player_clothes.wav"]
        case 4194: // SHEEP_PRIEST_B
            ["player_clothes.wav"]
        case 4195: // FOX_WIZ_B
            ["player_clothes.wav"]
        case 4196: // PIG_BLACKSMITH_B
            ["player_clothes.wav"]
        case 4197: // PIG_MECHANIC
            ["player_clothes.wav"]
        case 4198: // OSTRICH_RANGER
            ["player_wooden_male.wav"]
        case 4199: // LION_KNIGHT
            ["player_metal.wav"]
        case 4200: // LION_KNIGHT_H
            ["player_metal.wav"]
        case 4201: // LION_ROYAL_GUARD
            ["player_metal.wav"]
        case 4202: // LION_RUNE_KNIGHT
            ["player_metal.wav"]
        case 4203: // LION_CRUSADER
            ["player_metal.wav"]
        case 4204: // LION_CRUSADER_H
            ["player_metal.wav"]
        case 4205: // PIG_MECHANIC_B
            ["player_clothes.wav"]
        case 4206: // OSTRICH_RANGER_B
            ["player_wooden_male.wav"]
        case 4207: // LION_KNIGHT_B
            ["player_metal.wav"]
        case 4208: // LION_ROYAL_GUARD_B
            ["player_metal.wav"]
        case 4209: // LION_RUNE_KNIGHT_B
            ["player_metal.wav"]
        case 4210: // LION_CRUSADER_B
            ["player_metal.wav"]
        case JobID.kagerou.rawValue:
            ["player_wooden_male.wav"]
        case JobID.oboro.rawValue:
            ["player_wooden_male.wav"]
        case 4213: // FROG_KAGEROU
            ["player_wooden_male.wav"]
        case 4214: // FROG_OBORO
            ["player_wooden_male.wav"]
        case JobID.rebellion.rawValue:
            ["player_clothes.wav"]
        case 4216: // PECO_REBELLION
            ["player_clothes.wav"]
        case JobID.summoner.rawValue:
            ["player_clothes.wav"]
        case JobID.baby_summoner.rawValue:
            ["player_clothes.wav"]
        case 4230: // FROG_NINJA_B
            ["player_wooden_male.wav"]
        case 4231: // PECO_GUNNER_B
            ["player_wooden_male.wav"]
        case 4232: // PORING_TAEKWON_B
            ["player_wooden_male.wav"]
        case 4233: // PORING_STAR_B
            ["player_metal.wav"]
        case 4234: // FROG_LINKER_B
            ["player_clothes.wav"]
        case 4235: // FROG_KAGEROU_B
            ["player_wooden_male.wav"]
        case 4236: // FROG_OBORO_B
            ["player_wooden_male.wav"]
        case 4237: // PECO_REBELLION_B
            ["player_clothes.wav"]
        case JobID.star_emperor.rawValue:
            ["player_metal.wav"]
        case JobID.soul_reaper.rawValue:
            ["player_metal.wav"]
        case JobID.baby_star_emperor.rawValue:
            ["player_metal.wav"]
        case JobID.baby_soul_reaper.rawValue:
            ["player_metal.wav"]
        case JobID.star_emperor2.rawValue:
            ["player_metal.wav"]
        case JobID.baby_star_emperor2.rawValue:
            ["player_metal.wav"]
        case 4245: // SOUL_REAPER2
            ["player_metal.wav"]
        case 4246: // SOUL_REAPER2_B
            ["player_metal.wav"]
        case JobID.dragon_knight.rawValue:
            ["player_metal.wav"]
        case JobID.meister.rawValue:
            ["player_clothes.wav"]
        case JobID.shadow_cross.rawValue:
            ["player_wooden_male.wav"]
        case JobID.arch_mage.rawValue:
            ["player_clothes.wav"]
        case JobID.cardinal.rawValue:
            ["player_clothes.wav"]
        case JobID.windhawk.rawValue:
            ["player_wooden_male.wav"]
        case JobID.imperial_guard.rawValue:
            ["player_metal.wav"]
        case JobID.biolo.rawValue:
            ["player_clothes.wav"]
        case JobID.abyss_chaser.rawValue:
            ["player_wooden_male.wav"]
        case JobID.elemental_master.rawValue:
            ["player_clothes.wav"]
        case JobID.inquisitor.rawValue:
            ["player_metal.wav"]
        case JobID.troubadour.rawValue:
            ["player_wooden_male.wav"]
        case JobID.trouvere.rawValue:
            ["player_wooden_male.wav"]
        case JobID.windhawk2.rawValue:
            ["player_wooden_male.wav"]
        case JobID.meister2.rawValue:
            ["player_clothes.wav"]
        case JobID.dragon_knight2.rawValue:
            ["player_metal.wav"]
        case JobID.imperial_guard2.rawValue:
            ["player_metal.wav"]
        case JobID.rune_knight_2nd.rawValue:
            ["player_metal.wav"]
        case JobID.mechanic_2nd.rawValue:
            ["player_clothes.wav"]
        case JobID.guillotine_cross_2nd.rawValue:
            ["player_wooden_male.wav"]
        case JobID.warlock_2nd.rawValue:
            ["player_clothes.wav"]
        case JobID.archbishop_2nd.rawValue:
            ["player_clothes.wav"]
        case JobID.ranger_2nd.rawValue:
            ["player_wooden_male.wav"]
        case JobID.royal_guard_2nd.rawValue:
            ["player_metal.wav"]
        case JobID.genetic_2nd.rawValue:
            ["player_clothes.wav"]
        case JobID.shadow_chaser_2nd.rawValue:
            ["player_wooden_male.wav"]
        case JobID.sorcerer_2nd.rawValue:
            ["player_clothes.wav"]
        case JobID.sura_2nd.rawValue:
            ["player_metal.wav"]
        case JobID.minstrel_2nd.rawValue:
            ["player_wooden_male.wav"]
        case JobID.wanderer_2nd.rawValue:
            ["player_wooden_male.wav"]
        case 4345: // RUNE_KNIGHT2_2ND
            ["player_metal.wav"]
        case 4346: // RANGER2_2ND
            ["player_wooden_male.wav"]
        case 4347: // MECHANIC2_2ND
            ["player_clothes.wav"]
        case 4348: // ROYAL_GUARD2_2ND
            ["player_metal.wav"]
        default:
            ["player_clothes.wav"]
        }
    }
}
