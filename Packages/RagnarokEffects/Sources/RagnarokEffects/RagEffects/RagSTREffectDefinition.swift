//
//  RagSTREffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/21.
//

import RagnarokCore
import simd

/// Declarative definition for pure-STR `CRagEffect` entries ported from
/// `RagEffectInitialization.cpp` and `RagEffect.cpp`.
public struct RagSTREffectDefinition: Sendable {
    public struct TimedSound: Sendable, Equatable {
        public let tick: Int
        public let names: [String]
        public let chanceDenominator: Int

        public init(tick: Int, names: [String], chanceDenominator: Int = 1) {
            self.tick = tick
            self.names = names
            self.chanceDenominator = chanceDenominator
        }
    }

    public enum TargetTint: Sendable, Equatable {
        case constant(SIMD4<Float>)
        case rejectSwordFlicker(durationTicks: Int)
    }

    public let effectID: EffectID
    public let strPath: String
    public let minimalSTRPath: String?
    public let randomPathRange: ClosedRange<Int>?
    public let yOffset: Float
    public let loopLimit: Int
    public let restartsOnEnd: Bool
    public let endsWhenSTRCompletes: Bool
    public let usesTargetPosition: Bool
    public let sounds: [TimedSound]
    public let cameraShakeTicks: [Int]
    public let targetTint: TargetTint?

    public init(
        effectID: EffectID,
        strPath: String,
        minimalSTRPath: String? = nil,
        randomPathRange: ClosedRange<Int>? = nil,
        yOffset: Float = -80,
        loopLimit: Int = 0,
        restartsOnEnd: Bool = false,
        endsWhenSTRCompletes: Bool = true,
        usesTargetPosition: Bool = false,
        sounds: [TimedSound] = [],
        cameraShakeTicks: [Int] = [],
        targetTint: TargetTint? = nil
    ) {
        self.effectID = effectID
        self.strPath = strPath
        self.minimalSTRPath = minimalSTRPath
        self.randomPathRange = randomPathRange
        self.yOffset = yOffset
        self.loopLimit = loopLimit
        self.restartsOnEnd = restartsOnEnd
        self.endsWhenSTRCompletes = endsWhenSTRCompletes
        self.usesTargetPosition = usesTargetPosition
        self.sounds = sounds
        self.cameraShakeTicks = cameraShakeTicks
        self.targetTint = targetTint
    }

    public func resolveSTRPath(
        usesMinimalEffects: Bool = false,
        randomValue: ((ClosedRange<Int>) -> Int)? = nil
    ) -> String {
        if usesMinimalEffects, let minimalSTRPath {
            return minimalSTRPath
        }
        if let randomPathRange {
            let value = randomValue?(randomPathRange) ?? Int.random(in: randomPathRange)
            return strPath.replacingOccurrences(of: "%d", with: "\(value)")
        }
        return strPath
    }
}

extension RagSTREffectDefinition {
    /// All 199 pure-STR `CRagEffect` definitions (sorted by `EffectID.rawValue`).
    public static let definitions: [RagSTREffectDefinition] = [
        RagSTREffectDefinition(effectID: .ef_stonecurse, strPath: "StoneCurse.str"),
        RagSTREffectDefinition(effectID: .ef_firewall, strPath: "Firewall%d.str", randomPathRange: 1...2),
        RagSTREffectDefinition(effectID: .ef_lightbolt, strPath: "Lightning.str"),
        RagSTREffectDefinition(effectID: .ef_thunderstorm, strPath: "ThunderStorm.str", sounds: [TimedSound(tick: 0, names: ["effect\\magician_thunderstorm.wav"])]),
        RagSTREffectDefinition(effectID: .ef_angelus, strPath: "Angelus.str", minimalSTRPath: "jong_mini.str", sounds: [TimedSound(tick: 0, names: ["effect\\EF_Angelus.wav"])]),
        RagSTREffectDefinition(effectID: .ef_firehit, strPath: "FireHit%d.str", randomPathRange: 1...3, sounds: [TimedSound(tick: 0, names: ["_enemy_hit_fire1.wav", "_enemy_hit_fire2.wav"])]),
        RagSTREffectDefinition(effectID: .ef_windhit, strPath: "WindHit%d.str", randomPathRange: 1...3),
        RagSTREffectDefinition(effectID: .ef_arrowshot, strPath: "ArrowShot.str"),
        RagSTREffectDefinition(effectID: .ef_invenom, strPath: "Invenom.str", sounds: [TimedSound(tick: 0, names: ["effect\\thief_invenom.wav"])]),
        RagSTREffectDefinition(effectID: .ef_cure, strPath: "Cure.str", minimalSTRPath: "cure_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\Acolyte_cure.wav"])]),
        RagSTREffectDefinition(effectID: .ef_provoke, strPath: "Provoke.str", sounds: [TimedSound(tick: 5, names: ["effect\\swordman_provoke.wav"]), TimedSound(tick: 30, names: ["effect\\swordman_provoke.wav"])]),
        RagSTREffectDefinition(effectID: .ef_mvp, strPath: "Mvp.str", sounds: [TimedSound(tick: 0, names: ["effect\\st_mvp.wav"])]),
        RagSTREffectDefinition(effectID: .ef_skidtrap, strPath: "SkidTrap.str", sounds: [TimedSound(tick: 0, names: ["effect\\hunter_skidtrap.wav"])]),
        RagSTREffectDefinition(effectID: .ef_brandishspear, strPath: "Brandish.str"),
        RagSTREffectDefinition(effectID: .ef_gloria, strPath: "Gloria.str", minimalSTRPath: "gloria_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_gloria.wav"])]),
        RagSTREffectDefinition(effectID: .ef_magnificat, strPath: "Magnificat.str", minimalSTRPath: "magnificat_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_magnificat.wav"])]),
        RagSTREffectDefinition(effectID: .ef_resurrection, strPath: "Resurrection.str", minimalSTRPath: "resurrection_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_resurrection.wav"])]),
        RagSTREffectDefinition(effectID: .ef_recovery, strPath: "Recovery.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_recovery.wav"])]),
        RagSTREffectDefinition(effectID: .ef_sanctuary, strPath: "Sanctuary.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_sanctuary.wav"])]),
        RagSTREffectDefinition(effectID: .ef_impositio, strPath: "Impositio.str", sounds: [TimedSound(tick: 60, names: ["effect\\priest_impositio.wav"])]),
        RagSTREffectDefinition(effectID: .ef_lexaeterna, strPath: "LexAeterna.str", minimalSTRPath: "lexaeterna_min.str", sounds: [TimedSound(tick: 15, names: ["effect\\priest_lexaeterna.wav"])]),
        RagSTREffectDefinition(effectID: .ef_lexdivina, strPath: "LexDivina.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_lexdivina.wav"]), TimedSound(tick: 20, names: ["effect\\priest_lexdivina.wav"]), TimedSound(tick: 35, names: ["effect\\priest_lexdivina.wav"]), TimedSound(tick: 60, names: ["effect\\priest_lexdivina.wav"]), TimedSound(tick: 70, names: ["effect\\priest_lexdivina.wav"])]),
        RagSTREffectDefinition(effectID: .ef_suffragium, strPath: "Suffragium.str", minimalSTRPath: "suffragium_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_suffragium.wav"])]),
        RagSTREffectDefinition(effectID: .ef_lord, strPath: "Lord.str", sounds: [TimedSound(tick: 0, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 0, names: ["effect\\hunter_blastmine.wav"]), TimedSound(tick: 10, names: ["effect\\hunter_blastmine.wav"]), TimedSound(tick: 20, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 50, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 80, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 100, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 130, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 140, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 180, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 200, names: ["effect\\wizard_meteo.wav"])], cameraShakeTicks: [50, 100, 150, 200, 250]),
        RagSTREffectDefinition(effectID: .ef_benedictio, strPath: "Benedictio.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_benedictio.wav"])]),
        RagSTREffectDefinition(effectID: .ef_meteorstorm, strPath: "Meteor%d.str", randomPathRange: 1...3, sounds: [TimedSound(tick: 0, names: ["effect\\wizard_meteor.wav"])], cameraShakeTicks: [40]),
        RagSTREffectDefinition(effectID: .ef_quagmire, strPath: "Quagmire.str", sounds: [TimedSound(tick: 0, names: ["effect\\wizard_quagmire.wav"], chanceDenominator: 12)]),
        RagSTREffectDefinition(effectID: .ef_firepillar, strPath: "FirePillar.str", sounds: [TimedSound(tick: 75, names: ["effect\\wizard_fire_pillar_a.wav"])]),
        RagSTREffectDefinition(effectID: .ef_firepillarbomb, strPath: "FirePillarBomb.str", sounds: [TimedSound(tick: 0, names: ["effect\\wizard_fire_pillar_b.wav"])]),
        RagSTREffectDefinition(effectID: .ef_repairweapon, strPath: "RepairWeapon.str", sounds: [TimedSound(tick: 20, names: ["effect\\black_weapon_repair_a.wav"]), TimedSound(tick: 55, names: ["effect\\black_weapon_repair_a.wav"])]),
        RagSTREffectDefinition(effectID: .ef_crashearth, strPath: "CrashEarth.str", sounds: [TimedSound(tick: 30, names: ["effect\\wizard_fire_pillar_b.wav"])], cameraShakeTicks: [35]),
        RagSTREffectDefinition(effectID: .ef_perfection, strPath: "WeaponPerfection.str", minimalSTRPath: "WeaponPerfection_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\black_weapon_perfection.wav"])]),
        RagSTREffectDefinition(effectID: .ef_maxpower, strPath: "MaximizePower.str", minimalSTRPath: "maximize_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\black_maximize_power_circle.wav"]), TimedSound(tick: 40, names: ["effect\\black_maximize_power_sword.wav"]), TimedSound(tick: 47, names: ["effect\\black_maximize_power_sword.wav"]), TimedSound(tick: 65, names: ["effect\\black_maximize_power_sword_bic.wav"])]),
        RagSTREffectDefinition(effectID: .ef_blastminebomb, strPath: "BlastMine.str", sounds: [TimedSound(tick: 20, names: ["effect\\hunter_blastmine.wav"])]),
        RagSTREffectDefinition(effectID: .ef_claymore, strPath: "Claymore.str", sounds: [TimedSound(tick: 0, names: ["effect\\hunter_claymoretrap.wav"])]),
        RagSTREffectDefinition(effectID: .ef_freezing, strPath: "Freezing.str", sounds: [TimedSound(tick: 0, names: ["effect\\hunter_freezingtrap.wav"])]),
        RagSTREffectDefinition(effectID: .ef_bubble, strPath: "Bubble%d.str", randomPathRange: 1...4),
        RagSTREffectDefinition(effectID: .ef_gaspush, strPath: "GasPush.str"),
        RagSTREffectDefinition(effectID: .ef_springtrap, strPath: "Spring.str", sounds: [TimedSound(tick: 0, names: ["effect\\hunter_springtrap.wav"])]),
        RagSTREffectDefinition(effectID: .ef_kyrie, strPath: "Kyrie.str", minimalSTRPath: "kyrie_min.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_kyrie_eleison_b.wav"]), TimedSound(tick: 15, names: ["effect\\priest_kyrie_eleison_a.wav"])]),
        RagSTREffectDefinition(effectID: .ef_magnus, strPath: "Magnus.str", sounds: [TimedSound(tick: 0, names: ["effect\\priest_magnus.wav"])]),
        RagSTREffectDefinition(effectID: .ef_venomdust, strPath: "VenomDust.str", sounds: [TimedSound(tick: 0, names: ["effect\\assasin_poisonreact.wav"])]),
        RagSTREffectDefinition(effectID: .ef_poisonreact, strPath: "PoisonReact_1st.str"),
        RagSTREffectDefinition(effectID: .ef_poisonreact2, strPath: "PoisonReact.str", sounds: [TimedSound(tick: 0, names: ["effect\\assasin_poisonreact.wav"])]),
        RagSTREffectDefinition(effectID: .ef_splasher, strPath: "VenomSplasher.str", sounds: [TimedSound(tick: 10, names: ["effect\\assasin_venomsplasher.wav"])]),
        RagSTREffectDefinition(effectID: .ef_autocounter, strPath: "AutoCounter.str", sounds: [TimedSound(tick: 0, names: ["effect\\knight_autocounter.wav"])]),
        RagSTREffectDefinition(effectID: .ef_freeze, strPath: "Freeze.str"),
        RagSTREffectDefinition(effectID: .ef_freezed, strPath: "Freezed.str"),
        RagSTREffectDefinition(effectID: .ef_icecrash, strPath: "IceCrash.str"),
        RagSTREffectDefinition(effectID: .ef_slowpoison, strPath: "slowp.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_sandman, strPath: "SandMan.str"),
        RagSTREffectDefinition(effectID: .ef_pneuma, strPath: "Pneuma%d.str", randomPathRange: 1...3),
        RagSTREffectDefinition(effectID: .ef_sonicblow2, strPath: "SonicBlow.str"),
        RagSTREffectDefinition(effectID: .ef_brandish2, strPath: "Brandish2.str"),
        RagSTREffectDefinition(effectID: .ef_shockwave, strPath: "ShockWave.str", restartsOnEnd: true, endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_shockwavehit, strPath: "ShockWaveHit.str"),
        RagSTREffectDefinition(effectID: .ef_earthhit, strPath: "EarthHit.str"),
        RagSTREffectDefinition(effectID: .ef_pierceself, strPath: "Pierce.str"),
        RagSTREffectDefinition(effectID: .ef_bowlingself, strPath: "Bowling.str"),
        RagSTREffectDefinition(effectID: .ef_spearstabself, strPath: "SpearStab.str"),
        RagSTREffectDefinition(effectID: .ef_spearbmrself, strPath: "SpearBoomerang.str"),
        RagSTREffectDefinition(effectID: .ef_holyhit, strPath: "HolyHit.str"),
        RagSTREffectDefinition(effectID: .ef_concentration, strPath: "Concentration.str", sounds: [TimedSound(tick: 0, names: ["effect\\ac_concentration.wav"])]),
        RagSTREffectDefinition(effectID: .ef_refineok, strPath: "bs_RefineSuccess.str", sounds: [TimedSound(tick: 15, names: ["effect\\bs_refinesuccess.wav"])]),
        RagSTREffectDefinition(effectID: .ef_refinefail, strPath: "bs_RefineFailed.str", sounds: [TimedSound(tick: 5, names: ["effect\\bs_refinefailed.wav"])]),
        RagSTREffectDefinition(effectID: .ef_jobchange, strPath: "JobChange.str"),
        RagSTREffectDefinition(effectID: .ef_lvup, strPath: "LevelUP.str"),
        RagSTREffectDefinition(effectID: .ef_joblvup, strPath: "JobLvUP.str"),
        RagSTREffectDefinition(effectID: .ef_tamingsuccess, strPath: "TamingSuccess.str"),
        RagSTREffectDefinition(effectID: .ef_tamingfailed, strPath: "TamingFailed.str"),
        RagSTREffectDefinition(effectID: .ef_energycoat, strPath: "EnergyCoat.str"),
        RagSTREffectDefinition(effectID: .ef_mentalbreak, strPath: "MentalBreak.str"),
        RagSTREffectDefinition(effectID: .ef_magicalatthit, strPath: "magical.str"),
        RagSTREffectDefinition(effectID: .ef_suicide, strPath: "suicide.str", usesTargetPosition: true),
        RagSTREffectDefinition(effectID: .ef_comboattack1, strPath: "yunta_1.str"),
        RagSTREffectDefinition(effectID: .ef_comboattack2, strPath: "yunta_2.str"),
        RagSTREffectDefinition(effectID: .ef_comboattack3, strPath: "yunta_3.str"),
        RagSTREffectDefinition(effectID: .ef_comboattack4, strPath: "yunta_4.str"),
        RagSTREffectDefinition(effectID: .ef_comboattack5, strPath: "yunta_5.str"),
        RagSTREffectDefinition(effectID: .ef_guidedattack, strPath: "homing.str"),
        RagSTREffectDefinition(effectID: .ef_poisonattack, strPath: "poison.str"),
        RagSTREffectDefinition(effectID: .ef_silenceattack, strPath: "silence.str"),
        RagSTREffectDefinition(effectID: .ef_stunattack, strPath: "stun.str"),
        RagSTREffectDefinition(effectID: .ef_petrifyattack, strPath: "StoneCurse.str"),
        RagSTREffectDefinition(effectID: .ef_sleepattack, strPath: "sleep.str"),
        RagSTREffectDefinition(effectID: .ef_pong, strPath: "Pong%d.str", randomPathRange: 1...3),
        RagSTREffectDefinition(effectID: .ef_potion1, strPath: K2L("빨간포션.str"), sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_potion2, strPath: K2L("주홍포션.str"), sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_potion3, strPath: K2L("노란포션.str"), sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_potion4, strPath: K2L("하얀포션.str"), sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_potion5, strPath: K2L("파란포션.str"), sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]),
        RagSTREffectDefinition(effectID: .ef_potion6, strPath: K2L("초록포션.str"), sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]),
        RagSTREffectDefinition(effectID: .ef_potion7, strPath: "fruit.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_potion8, strPath: "fruit_.str", sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]),
        RagSTREffectDefinition(effectID: .ef_deffender, strPath: "Deffender.str"),
        RagSTREffectDefinition(effectID: .ef_keeping, strPath: "Keeping.str"),
        RagSTREffectDefinition(effectID: .ef_spellbreaker, strPath: "spell.str", sounds: [TimedSound(tick: 0, names: ["effect\\sage_spell breake.wav"])]),
        RagSTREffectDefinition(effectID: .ef_dispell, strPath: K2L("디스펠.str")),
        RagSTREffectDefinition(effectID: .ef_holycross, strPath: "holy_cross.str"),
        RagSTREffectDefinition(effectID: .ef_shieldcharge, strPath: "shield_charge.str", yOffset: 0),
        RagSTREffectDefinition(effectID: .ef_devotion, strPath: "devotion.str", yOffset: -20),
        RagSTREffectDefinition(effectID: .ef_flamelauncher, strPath: "enc_fire.str", sounds: [TimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]),
        RagSTREffectDefinition(effectID: .ef_frostweapon, strPath: "enc_ice.str", sounds: [TimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]),
        RagSTREffectDefinition(effectID: .ef_lightningloader, strPath: "enc_wind.str", sounds: [TimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]),
        RagSTREffectDefinition(effectID: .ef_seismicweapon, strPath: "enc_earth.str", sounds: [TimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]),
        RagSTREffectDefinition(effectID: .ef_stealcoin, strPath: "steal_coin.str"),
        RagSTREffectDefinition(effectID: .ef_stripweapon, strPath: "strip_weapon.str", sounds: [TimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]),
        RagSTREffectDefinition(effectID: .ef_stripshield, strPath: "strip_shield.str", sounds: [TimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]),
        RagSTREffectDefinition(effectID: .ef_striparmor, strPath: "strip_armor.str", sounds: [TimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]),
        RagSTREffectDefinition(effectID: .ef_striphelm, strPath: "strip_helm.str", sounds: [TimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]),
        RagSTREffectDefinition(effectID: .ef_chaincombo, strPath: K2L("연환.str"), sounds: [TimedSound(tick: 0, names: [K2L("effect\\mon_연환.wav")])]),
        RagSTREffectDefinition(effectID: .ef_pharmacy_ok, strPath: "p_success.str"),
        RagSTREffectDefinition(effectID: .ef_pharmacy_fail, strPath: "p_failed.str"),
        RagSTREffectDefinition(effectID: .ef_loud, strPath: "loud.str"),
        RagSTREffectDefinition(effectID: .ef_lkconcentration, strPath: "TwoHand.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: ["effect\\knight_twohandquicken.wav"])], targetTint: .constant(SIMD4<Float>(1, 1, 160.0 / 255.0, 1))),
        RagSTREffectDefinition(effectID: .ef_angel, strPath: "angel.str"),
        RagSTREffectDefinition(effectID: .ef_devil, strPath: "devil.str"),
        RagSTREffectDefinition(effectID: .ef_meltdown, strPath: "melt.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: ["effect\\black_overthrust.wav"])]),
        RagSTREffectDefinition(effectID: .ef_cartboost, strPath: "cart.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_rejectsword, strPath: "sword.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: ["effect\\kyrie_guard.wav"])], targetTint: .rejectSwordFlicker(durationTicks: 30)),
        RagSTREffectDefinition(effectID: .ef_soulburn, strPath: K2L("소울번.str"), endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_soulchange, strPath: K2L("사람효과.str"), endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_assumptio2, strPath: "asum.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: [K2L("effect\\아숨프티오.wav")])]),
        RagSTREffectDefinition(effectID: .ef_mochi, strPath: K2L("찹쌀떡.str"), endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_lamadan, strPath: "ramadan.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_mapae, strPath: "mapae.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_itempokjuk, strPath: "itempokjuk.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_hflimoon1, strPath: "moonlight_1.str", sounds: [TimedSound(tick: 0, names: ["effect\\h_moonlight_1.wav"])]),
        RagSTREffectDefinition(effectID: .ef_hflimoon2, strPath: "moonlight_2.str", sounds: [TimedSound(tick: 0, names: ["effect\\h_moonlight_2.wav"])]),
        RagSTREffectDefinition(effectID: .ef_hflimoon3, strPath: "moonlight_3.str", sounds: [TimedSound(tick: 0, names: ["effect\\h_moonlight_3.wav"])]),
        RagSTREffectDefinition(effectID: .ef_ho_up, strPath: "h_levelup.str", sounds: [TimedSound(tick: 0, names: ["levelup.wav"])]),
        RagSTREffectDefinition(effectID: .ef_hamidefence, strPath: "defense.str"),
        RagSTREffectDefinition(effectID: .ef_food01, strPath: "food_str.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_food02, strPath: "food_int.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_food03, strPath: "food_vit.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_food04, strPath: "food_agi.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_food05, strPath: "food_dex.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_food06, strPath: "food_luk.str", sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_firehit2, strPath: "FireHit%d.str", randomPathRange: 1...3),
        RagSTREffectDefinition(effectID: .ef_cooking_ok, strPath: "cook_suc.str", sounds: [TimedSound(tick: 45, names: ["_heal_effect.wav"])]),
        RagSTREffectDefinition(effectID: .ef_cooking_fail, strPath: "cook_fail.str", sounds: [TimedSound(tick: 50, names: ["caramel_die.wav"])]),
        RagSTREffectDefinition(effectID: .ef_baku, strPath: "fire dragon.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: [K2L("effect\\폭염룡.wav")])]),
        RagSTREffectDefinition(effectID: .ef_hyousyouraku, strPath: "icy.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: [K2L("effect\\빙정락.wav")])]),
        RagSTREffectDefinition(effectID: .ef_trackcasting, strPath: K2L("트랙킹.str"), endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_bullseye, strPath: K2L("불스아이.str"), endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_dragonfear, strPath: "dfear.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["effect\\dragonfear.wav"])], cameraShakeTicks: [1]),
        RagSTREffectDefinition(effectID: .ef_wideconfuse, strPath: "dfear.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_criticalwound, strPath: "cwound.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["effect\\wideb.wav"])]),
        RagSTREffectDefinition(effectID: .ef_flowerleaf, strPath: "flower_leaf.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_item315, strPath: "mobile_ef02.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_item316, strPath: "mobile_ef01.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_item317, strPath: "mobile_ef03.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_storm_min, strPath: "storm_min.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 0, names: ["effect\\wizard_stormgust.wav"])]),
        RagSTREffectDefinition(effectID: .ef_pok_jap, strPath: "pokjuk_jap.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_wewish, strPath: "Angelus.str", minimalSTRPath: "jong_mini.str"),
        RagSTREffectDefinition(effectID: .ef_ado_str, strPath: "ado.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_crimson_str, strPath: "crimson_r.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["crimson_r.wav"])]),
        RagSTREffectDefinition(effectID: .ef_hell_str, strPath: "hell_in.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["hell_in.wav"])]),
        RagSTREffectDefinition(effectID: .ef_dhowl_str, strPath: "dragon_h.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_chainl_str, strPath: "chainlight.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["chainlight.wav"])]),
        RagSTREffectDefinition(effectID: .ef_aimed_str, strPath: "aimed.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["aimed.wav"])]),
        RagSTREffectDefinition(effectID: .ef_arrowstorm_str, strPath: "arrowstorm.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["arrowstorm.wav"])]),
        RagSTREffectDefinition(effectID: .ef_laulamus_str, strPath: "laulamus.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["lauagnus.wav"])]),
        RagSTREffectDefinition(effectID: .ef_lauagnus_str, strPath: "lauagnus.str", endsWhenSTRCompletes: false, sounds: [TimedSound(tick: 1, names: ["lauagnus.wav"])]),
        RagSTREffectDefinition(effectID: .ef_milshield_str, strPath: "mil_shield.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_crashaxe, strPath: "powerswing.str", sounds: [TimedSound(tick: 30, names: ["effect\\wizard_fire_pillar_b.wav"])], cameraShakeTicks: [35]),
        RagSTREffectDefinition(effectID: .ef_firewall2, strPath: "Firewall_per.str"),
        RagSTREffectDefinition(effectID: .ef_shockwave2, strPath: "hunter_shockwave_blue.str", restartsOnEnd: true, endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_poison_mist, strPath: "poison_mist.str"),
        RagSTREffectDefinition(effectID: .ef_eraser_cutter, strPath: "eraser_cutter.str"),
        RagSTREffectDefinition(effectID: .ef_lava_slide, strPath: "lava_slide.str"),
        RagSTREffectDefinition(effectID: .ef_sonic_claw, strPath: "sonic_claw.str"),
        RagSTREffectDefinition(effectID: .ef_tinder_breaker, strPath: "tinder.str"),
        RagSTREffectDefinition(effectID: .ef_midnight_frenzy, strPath: "mid_frenzy.str"),
        RagSTREffectDefinition(effectID: .ef_volcanic_ash, strPath: "vash00.str"),
        RagSTREffectDefinition(effectID: .ef_2011rwc, strPath: "rwc2011.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_2011rwc2, strPath: "rwc2011_2.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_no100_firecracker, strPath: "100.str", endsWhenSTRCompletes: false),
        RagSTREffectDefinition(effectID: .ef_run_make_ok, strPath: "rune_success.str", sounds: [TimedSound(tick: 0, names: ["effect\\p_success.wav"])]),
        RagSTREffectDefinition(effectID: .ef_run_make_failure, strPath: "rune_fail.str", sounds: [TimedSound(tick: 0, names: ["effect\\p_failed.wav"])]),
        RagSTREffectDefinition(effectID: .ef_miresult_make_ok, strPath: "changematerial_su.str", sounds: [TimedSound(tick: 0, names: ["effect\\p_success.wav"])]),
        RagSTREffectDefinition(effectID: .ef_miresult_make_fail, strPath: "changematerial_fa.str", sounds: [TimedSound(tick: 0, names: ["effect\\p_failed.wav"])]),
        RagSTREffectDefinition(effectID: .ef_all_ray_of_protection, strPath: "Guardian.str"),
        RagSTREffectDefinition(effectID: .ef_venomfog, strPath: "bubble%d_1.str", randomPathRange: 1...4),
        RagSTREffectDefinition(effectID: .ef_duststorm, strPath: "dust.str", loopLimit: 10),
        RagSTREffectDefinition(effectID: .ef_dance_blade_atk, strPath: "dancingblade.str"),
        RagSTREffectDefinition(effectID: .ef_invincibleoff2, strPath: "INVINCIBLEOFF2.str"),
        RagSTREffectDefinition(effectID: .ef_deathsummon, strPath: "devil.str"),
        RagSTREffectDefinition(effectID: .ef_gc_darkcrow, strPath: "gc_darkcrow.str", yOffset: 40, loopLimit: 9999),
        RagSTREffectDefinition(effectID: .ef_all_full_throttle, strPath: "all_full_throttle.str", sounds: [TimedSound(tick: 0, names: ["effect\\all_full_throttle.wav"])]),
        RagSTREffectDefinition(effectID: .ef_sr_flashcombo, strPath: "sr_flashcombo.str", sounds: [TimedSound(tick: 0, names: ["effect\\sr_flashcombo.wav"])]),
        RagSTREffectDefinition(effectID: .ef_rk_luxanima, strPath: "rk_luxanima.str", sounds: [TimedSound(tick: 0, names: ["effect\\rk_luxanima.wav"])]),
        RagSTREffectDefinition(effectID: .ef_so_elemental_shield, strPath: "so_elemental_shield.str", sounds: [TimedSound(tick: 0, names: ["effect\\so_elemental_shield.wav"])]),
        RagSTREffectDefinition(effectID: .ef_ab_offertorium, strPath: "AB_OFFERTORIUM.str", sounds: [TimedSound(tick: 0, names: ["effect\\ab_offertorium.wav"])]),
        RagSTREffectDefinition(effectID: .ef_wl_telekinesis_intense, strPath: "WL_TELEKINESIS_INTENSE.str", yOffset: 0, loopLimit: 9999),
        RagSTREffectDefinition(effectID: .ef_gn_illusiondoping, strPath: "GN_ILLUSIONDOPING.str", sounds: [TimedSound(tick: 0, names: ["effect\\gn_illusiondoping.wav"])]),
        RagSTREffectDefinition(effectID: .ef_nc_magma_eruption, strPath: "NC_MAGMA_ERUPTION.str", yOffset: -25, loopLimit: 9999),
        RagSTREffectDefinition(effectID: .ef_npc_chill, strPath: "chill.str", loopLimit: 9999),
        RagSTREffectDefinition(effectID: .ef_ab_offertorium_ring, strPath: "AB_OFFERTORIUM_ring.str", yOffset: -5, loopLimit: 9999),
    ]

    public static let definitionsByEffectID: [EffectID : RagSTREffectDefinition] = Dictionary(
        uniqueKeysWithValues: definitions.map { ($0.effectID, $0) }
    )

    public static func definition(for effectID: EffectID) -> RagSTREffectDefinition? {
        definitionsByEffectID[effectID]
    }
}
