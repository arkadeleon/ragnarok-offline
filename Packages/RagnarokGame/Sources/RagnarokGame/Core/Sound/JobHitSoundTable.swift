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
    private static let table: [Int: [String]] = [
        JobID.novice.rawValue: ["player_clothes.wav"],
        JobID.swordman.rawValue: ["player_metal.wav"],
        JobID.mage.rawValue: ["player_clothes.wav"],
        JobID.archer.rawValue: ["player_wooden_male.wav"],
        JobID.acolyte.rawValue: ["player_clothes.wav"],
        JobID.merchant.rawValue: ["player_clothes.wav"],
        JobID.thief.rawValue: ["player_wooden_male.wav"],
        JobID.knight.rawValue: ["player_metal.wav"],
        JobID.priest.rawValue: ["player_clothes.wav"],
        JobID.wizard.rawValue: ["player_clothes.wav"],
        JobID.blacksmith.rawValue: ["player_clothes.wav"],
        JobID.hunter.rawValue: ["player_wooden_male.wav"],
        JobID.assassin.rawValue: ["player_wooden_male.wav"],
        JobID.knight2.rawValue: ["player_metal.wav"],
        JobID.crusader.rawValue: ["player_metal.wav"],
        JobID.monk.rawValue: ["player_metal.wav"],
        JobID.sage.rawValue: ["player_clothes.wav"],
        JobID.rogue.rawValue: ["player_wooden_male.wav"],
        JobID.alchemist.rawValue: ["player_clothes.wav"],
        JobID.bard.rawValue: ["player_wooden_male.wav"],
        JobID.dancer.rawValue: ["player_wooden_male.wav"],
        JobID.crusader2.rawValue: ["player_metal.wav"],
        JobID.wedding.rawValue: ["player_clothes.wav"],
        JobID.super_novice.rawValue: ["player_clothes.wav"],
        JobID.gunslinger.rawValue: ["player_wooden_male.wav"],
        JobID.ninja.rawValue: ["player_wooden_male.wav"],
        JobID.xmas.rawValue: ["player_clothes.wav"],
        JobID.summer.rawValue: ["player_clothes.wav"],
        JobID.novice_high.rawValue: ["player_clothes.wav"],
        JobID.swordman_high.rawValue: ["player_metal.wav"],
        JobID.mage_high.rawValue: ["player_clothes.wav"],
        JobID.archer_high.rawValue: ["player_wooden_male.wav"],
        JobID.acolyte_high.rawValue: ["player_clothes.wav"],
        JobID.merchant_high.rawValue: ["player_clothes.wav"],
        JobID.thief_high.rawValue: ["player_wooden_male.wav"],
        JobID.lord_knight.rawValue: ["player_metal.wav"],
        JobID.high_priest.rawValue: ["player_clothes.wav"],
        JobID.high_wizard.rawValue: ["player_clothes.wav"],
        JobID.whitesmith.rawValue: ["player_clothes.wav"],
        JobID.sniper.rawValue: ["player_wooden_male.wav"],
        JobID.assassin_cross.rawValue: ["player_wooden_male.wav"],
        JobID.lord_knight2.rawValue: ["player_metal.wav"],
        JobID.paladin.rawValue: ["player_metal.wav"],
        JobID.champion.rawValue: ["player_metal.wav"],
        JobID.professor.rawValue: ["player_clothes.wav"],
        JobID.stalker.rawValue: ["player_wooden_male.wav"],
        JobID.creator.rawValue: ["player_clothes.wav"],
        JobID.clown.rawValue: ["player_wooden_male.wav"],
        JobID.gypsy.rawValue: ["player_wooden_male.wav"],
        JobID.paladin2.rawValue: ["player_metal.wav"],
        JobID.baby.rawValue: ["player_clothes.wav"],
        JobID.baby_swordman.rawValue: ["player_metal.wav"],
        JobID.baby_mage.rawValue: ["player_clothes.wav"],
        JobID.baby_archer.rawValue: ["player_wooden_male.wav"],
        JobID.baby_acolyte.rawValue: ["player_clothes.wav"],
        JobID.baby_merchant.rawValue: ["player_clothes.wav"],
        JobID.baby_thief.rawValue: ["player_wooden_male.wav"],
        JobID.baby_knight.rawValue: ["player_metal.wav"],
        JobID.baby_priest.rawValue: ["player_clothes.wav"],
        JobID.baby_wizard.rawValue: ["player_clothes.wav"],
        JobID.baby_blacksmith.rawValue: ["player_clothes.wav"],
        JobID.baby_hunter.rawValue: ["player_wooden_male.wav"],
        JobID.baby_assassin.rawValue: ["player_wooden_male.wav"],
        JobID.baby_knight2.rawValue: ["player_metal.wav"],
        JobID.baby_crusader.rawValue: ["player_metal.wav"],
        JobID.baby_monk.rawValue: ["player_metal.wav"],
        JobID.baby_sage.rawValue: ["player_clothes.wav"],
        JobID.baby_rogue.rawValue: ["player_wooden_male.wav"],
        JobID.baby_alchemist.rawValue: ["player_clothes.wav"],
        JobID.baby_bard.rawValue: ["player_wooden_male.wav"],
        JobID.baby_dancer.rawValue: ["player_wooden_male.wav"],
        JobID.baby_crusader2.rawValue: ["player_metal.wav"],
        JobID.taekwon.rawValue: ["player_wooden_male.wav"],
        JobID.star_gladiator.rawValue: ["player_metal.wav"],
        JobID.star_gladiator2.rawValue: ["player_metal.wav"],
        JobID.soul_linker.rawValue: ["player_clothes.wav"],
        JobID.rune_knight.rawValue: ["player_metal.wav"],
        JobID.warlock.rawValue: ["player_clothes.wav"],
        JobID.ranger.rawValue: ["player_wooden_male.wav"],
        JobID.arch_bishop.rawValue: ["player_clothes.wav"],
        JobID.mechanic.rawValue: ["player_clothes.wav"],
        JobID.guillotine_cross.rawValue: ["player_wooden_male.wav"],
        JobID.rune_knight_t.rawValue: ["player_metal.wav"],
        JobID.warlock_t.rawValue: ["player_clothes.wav"],
        JobID.ranger_t.rawValue: ["player_wooden_male.wav"],
        JobID.arch_bishop_t.rawValue: ["player_clothes.wav"],
        JobID.mechanic_t.rawValue: ["player_clothes.wav"],
        JobID.guillotine_cross_t.rawValue: ["player_wooden_male.wav"],
        JobID.royal_guard.rawValue: ["player_metal.wav"],
        JobID.sorcerer.rawValue: ["player_clothes.wav"],
        JobID.minstrel.rawValue: ["player_wooden_male.wav"],
        JobID.wanderer.rawValue: ["player_wooden_male.wav"],
        JobID.sura.rawValue: ["player_metal.wav"],
        JobID.genetic.rawValue: ["player_clothes.wav"],
        JobID.shadow_chaser.rawValue: ["player_wooden_male.wav"],
        JobID.royal_guard_t.rawValue: ["player_metal.wav"],
        JobID.sorcerer_t.rawValue: ["player_clothes.wav"],
        JobID.minstrel_t.rawValue: ["player_wooden_male.wav"],
        JobID.wanderer_t.rawValue: ["player_wooden_male.wav"],
        JobID.sura_t.rawValue: ["player_metal.wav"],
        JobID.genetic_t.rawValue: ["player_clothes.wav"],
        JobID.shadow_chaser_t.rawValue: ["player_wooden_male.wav"],
        JobID.rune_knight2.rawValue: ["player_metal.wav"],
        JobID.rune_knight_t2.rawValue: ["player_metal.wav"],
        JobID.royal_guard2.rawValue: ["player_metal.wav"],
        JobID.royal_guard_t2.rawValue: ["player_metal.wav"],
        JobID.ranger2.rawValue: ["player_wooden_male.wav"],
        JobID.ranger_t2.rawValue: ["player_wooden_male.wav"],
        JobID.mechanic2.rawValue: ["player_clothes.wav"],
        JobID.mechanic_t2.rawValue: ["player_clothes.wav"],
        JobID.baby_rune_knight.rawValue: ["player_metal.wav"],
        JobID.baby_warlock.rawValue: ["player_clothes.wav"],
        JobID.baby_ranger.rawValue: ["player_wooden_male.wav"],
        JobID.baby_arch_bishop.rawValue: ["player_clothes.wav"],
        JobID.baby_mechanic.rawValue: ["player_clothes.wav"],
        JobID.baby_guillotine_cross.rawValue: ["player_wooden_male.wav"],
        JobID.baby_royal_guard.rawValue: ["player_metal.wav"],
        JobID.baby_sorcerer.rawValue: ["player_clothes.wav"],
        JobID.baby_minstrel.rawValue: ["player_wooden_male.wav"],
        JobID.baby_wanderer.rawValue: ["player_wooden_male.wav"],
        JobID.baby_sura.rawValue: ["player_metal.wav"],
        JobID.baby_genetic.rawValue: ["player_clothes.wav"],
        JobID.baby_shadow_chaser.rawValue: ["player_wooden_male.wav"],
        JobID.baby_rune_knight2.rawValue: ["player_metal.wav"],
        JobID.baby_royal_guard2.rawValue: ["player_metal.wav"],
        JobID.baby_ranger2.rawValue: ["player_wooden_male.wav"],
        JobID.baby_mechanic2.rawValue: ["player_clothes.wav"],
        4114: ["player_wooden_male.wav"], // FROG_NINJA
        4115: ["player_wooden_male.wav"], // PECO_GUNNER
        4116: ["player_metal.wav"],       // PECO_SWORD
        4117: ["player_clothes.wav"],     // FROG_LINKER
        4118: ["player_clothes.wav"],     // PIG_WHITESMITH
        4119: ["player_clothes.wav"],     // PIG_MERCHANT
        4120: ["player_clothes.wav"],     // PIG_GENETIC
        4121: ["player_clothes.wav"],     // PIG_CREATOR
        4122: ["player_wooden_male.wav"], // OSTRICH_ARCHER
        4123: ["player_metal.wav"],       // PORING_STAR
        4124: ["player_clothes.wav"],     // PORING_NOVICE
        4125: ["player_metal.wav"],       // SHEEP_MONK
        4126: ["player_clothes.wav"],     // SHEEP_ACO
        4127: ["player_metal.wav"],       // SHEEP_SURA
        4128: ["player_clothes.wav"],     // PORING_SNOVICE
        4129: ["player_clothes.wav"],     // SHEEP_ARCB
        4130: ["player_clothes.wav"],     // FOX_MAGICIAN
        4131: ["player_clothes.wav"],     // FOX_SAGE
        4132: ["player_clothes.wav"],     // FOX_SORCERER
        4133: ["player_clothes.wav"],     // FOX_WARLOCK
        4134: ["player_clothes.wav"],     // FOX_WIZ
        4135: ["player_clothes.wav"],     // FOX_PROF
        4136: ["player_clothes.wav"],     // FOX_HWIZ
        4137: ["player_clothes.wav"],     // PIG_ALCHE
        4138: ["player_clothes.wav"],     // PIG_BLACKSMITH
        4139: ["player_metal.wav"],       // SHEEP_CHAMP
        4140: ["player_wooden_male.wav"], // DOG_G_CROSS
        4141: ["player_wooden_male.wav"], // DOG_THIEF
        4142: ["player_wooden_male.wav"], // DOG_ROGUE
        4143: ["player_wooden_male.wav"], // DOG_CHASER
        4144: ["player_wooden_male.wav"], // DOG_STALKER
        4145: ["player_wooden_male.wav"], // DOG_ASSASSIN
        4146: ["player_wooden_male.wav"], // DOG_ASSA_X
        4147: ["player_wooden_male.wav"], // OSTRICH_DANCER
        4148: ["player_wooden_male.wav"], // OSTRICH_MINSTREL
        4149: ["player_wooden_male.wav"], // OSTRICH_BARD
        4150: ["player_wooden_male.wav"], // OSTRICH_SNIPER
        4151: ["player_wooden_male.wav"], // OSTRICH_WANDER
        4152: ["player_wooden_male.wav"], // OSTRICH_ZIPSI
        4153: ["player_wooden_male.wav"], // OSTRICH_CROWN
        4154: ["player_wooden_male.wav"], // OSTRICH_HUNTER
        4155: ["player_wooden_male.wav"], // PORING_TAEKWON
        4156: ["player_clothes.wav"],     // SHEEP_PRIEST
        4157: ["player_clothes.wav"],     // SHEEP_HPRIEST
        4158: ["player_clothes.wav"],     // PORING_NOVICE_B
        4159: ["player_metal.wav"],       // PECO_SWORD_B
        4160: ["player_clothes.wav"],     // FOX_MAGICIAN_B
        4161: ["player_wooden_male.wav"], // OSTRICH_ARCHER_B
        4162: ["player_clothes.wav"],     // SHEEP_ACO_B
        4163: ["player_clothes.wav"],     // PIG_MERCHANT_B
        4164: ["player_wooden_male.wav"], // OSTRICH_HUNTER_B
        4165: ["player_wooden_male.wav"], // DOG_ASSASSIN_B
        4166: ["player_metal.wav"],       // SHEEP_MONK_B
        4167: ["player_clothes.wav"],     // FOX_SAGE_B
        4168: ["player_wooden_male.wav"], // DOG_ROGUE_B
        4169: ["player_clothes.wav"],     // PIG_ALCHE_B
        4170: ["player_wooden_male.wav"], // OSTRICH_BARD_B
        4171: ["player_wooden_male.wav"], // OSTRICH_DANCER_B
        4172: ["player_clothes.wav"],     // PORING_SNOVICE_B
        4173: ["player_clothes.wav"],     // FOX_WARLOCK_B
        4174: ["player_clothes.wav"],     // SHEEP_ARCB_B
        4175: ["player_wooden_male.wav"], // DOG_G_CROSS_B
        4176: ["player_clothes.wav"],     // FOX_SORCERER_B
        4177: ["player_wooden_male.wav"], // OSTRICH_MINSTREL_B
        4178: ["player_wooden_male.wav"], // OSTRICH_WANDER_B
        4179: ["player_metal.wav"],       // SHEEP_SURA_B
        4180: ["player_clothes.wav"],     // PIG_GENETIC_B
        4181: ["player_wooden_male.wav"], // DOG_THIEF_B
        4182: ["player_wooden_male.wav"], // DOG_CHASER_B
        4183: ["player_clothes.wav"],     // PORING_NOVICE_H
        4184: ["player_metal.wav"],       // PECO_SWORD_H
        4185: ["player_clothes.wav"],     // FOX_MAGICIAN_H
        4186: ["player_wooden_male.wav"], // OSTRICH_ARCHER_H
        4187: ["player_clothes.wav"],     // SHEEP_ACO_H
        4188: ["player_clothes.wav"],     // PIG_MERCHANT_H
        4189: ["player_wooden_male.wav"], // DOG_THIEF_H
        JobID.super_novice_e.rawValue: ["player_clothes.wav"],
        4192: ["player_clothes.wav"],     // PORING_SNOVICE2
        4193: ["player_clothes.wav"],     // PORING_SNOVICE2_B
        4194: ["player_clothes.wav"],     // SHEEP_PRIEST_B
        4195: ["player_clothes.wav"],     // FOX_WIZ_B
        4196: ["player_clothes.wav"],     // PIG_BLACKSMITH_B
        4197: ["player_clothes.wav"],     // PIG_MECHANIC
        4198: ["player_wooden_male.wav"], // OSTRICH_RANGER
        4199: ["player_metal.wav"],       // LION_KNIGHT
        4200: ["player_metal.wav"],       // LION_KNIGHT_H
        4201: ["player_metal.wav"],       // LION_ROYAL_GUARD
        4202: ["player_metal.wav"],       // LION_RUNE_KNIGHT
        4203: ["player_metal.wav"],       // LION_CRUSADER
        4204: ["player_metal.wav"],       // LION_CRUSADER_H
        4205: ["player_clothes.wav"],     // PIG_MECHANIC_B
        4206: ["player_wooden_male.wav"], // OSTRICH_RANGER_B
        4207: ["player_metal.wav"],       // LION_KNIGHT_B
        4208: ["player_metal.wav"],       // LION_ROYAL_GUARD_B
        4209: ["player_metal.wav"],       // LION_RUNE_KNIGHT_B
        4210: ["player_metal.wav"],       // LION_CRUSADER_B
        JobID.kagerou.rawValue: ["player_wooden_male.wav"],
        JobID.oboro.rawValue: ["player_wooden_male.wav"],
        4213: ["player_wooden_male.wav"], // FROG_KAGEROU
        4214: ["player_wooden_male.wav"], // FROG_OBORO
        JobID.rebellion.rawValue: ["player_clothes.wav"],
        4216: ["player_clothes.wav"],     // PECO_REBELLION
        JobID.summoner.rawValue: ["player_clothes.wav"],
        JobID.baby_summoner.rawValue: ["player_clothes.wav"],
        4230: ["player_wooden_male.wav"], // FROG_NINJA_B
        4231: ["player_wooden_male.wav"], // PECO_GUNNER_B
        4232: ["player_wooden_male.wav"], // PORING_TAEKWON_B
        4233: ["player_metal.wav"],       // PORING_STAR_B
        4234: ["player_clothes.wav"],     // FROG_LINKER_B
        4235: ["player_wooden_male.wav"], // FROG_KAGEROU_B
        4236: ["player_wooden_male.wav"], // FROG_OBORO_B
        4237: ["player_clothes.wav"],     // PECO_REBELLION_B
        JobID.star_emperor.rawValue: ["player_metal.wav"],
        JobID.soul_reaper.rawValue: ["player_metal.wav"],
        JobID.baby_star_emperor.rawValue: ["player_metal.wav"],
        JobID.baby_soul_reaper.rawValue: ["player_metal.wav"],
        JobID.star_emperor2.rawValue: ["player_metal.wav"],
        JobID.baby_star_emperor2.rawValue: ["player_metal.wav"],
        4245: ["player_metal.wav"],       // SOUL_REAPER2
        4246: ["player_metal.wav"],       // SOUL_REAPER2_B
        JobID.dragon_knight.rawValue: ["player_metal.wav"],
        JobID.meister.rawValue: ["player_clothes.wav"],
        JobID.shadow_cross.rawValue: ["player_wooden_male.wav"],
        JobID.arch_mage.rawValue: ["player_clothes.wav"],
        JobID.cardinal.rawValue: ["player_clothes.wav"],
        JobID.windhawk.rawValue: ["player_wooden_male.wav"],
        JobID.imperial_guard.rawValue: ["player_metal.wav"],
        JobID.biolo.rawValue: ["player_clothes.wav"],
        JobID.abyss_chaser.rawValue: ["player_wooden_male.wav"],
        JobID.elemental_master.rawValue: ["player_clothes.wav"],
        JobID.inquisitor.rawValue: ["player_metal.wav"],
        JobID.troubadour.rawValue: ["player_wooden_male.wav"],
        JobID.trouvere.rawValue: ["player_wooden_male.wav"],
        JobID.windhawk2.rawValue: ["player_wooden_male.wav"],
        JobID.meister2.rawValue: ["player_clothes.wav"],
        JobID.dragon_knight2.rawValue: ["player_metal.wav"],
        JobID.imperial_guard2.rawValue: ["player_metal.wav"],
        JobID.rune_knight_2nd.rawValue: ["player_metal.wav"],
        JobID.mechanic_2nd.rawValue: ["player_clothes.wav"],
        JobID.guillotine_cross_2nd.rawValue: ["player_wooden_male.wav"],
        JobID.warlock_2nd.rawValue: ["player_clothes.wav"],
        JobID.archbishop_2nd.rawValue: ["player_clothes.wav"],
        JobID.ranger_2nd.rawValue: ["player_wooden_male.wav"],
        JobID.royal_guard_2nd.rawValue: ["player_metal.wav"],
        JobID.genetic_2nd.rawValue: ["player_clothes.wav"],
        JobID.shadow_chaser_2nd.rawValue: ["player_wooden_male.wav"],
        JobID.sorcerer_2nd.rawValue: ["player_clothes.wav"],
        JobID.sura_2nd.rawValue: ["player_metal.wav"],
        JobID.minstrel_2nd.rawValue: ["player_wooden_male.wav"],
        JobID.wanderer_2nd.rawValue: ["player_wooden_male.wav"],
        4345: ["player_metal.wav"],       // RUNE_KNIGHT2_2ND
        4346: ["player_wooden_male.wav"], // RANGER2_2ND
        4347: ["player_clothes.wav"],     // MECHANIC2_2ND
        4348: ["player_metal.wav"],       // ROYAL_GUARD2_2ND
    ]

    static func hitSoundFilenames(forJob job: Int) -> [String] {
        table[job] ?? ["player_clothes.wav"]
    }
}
