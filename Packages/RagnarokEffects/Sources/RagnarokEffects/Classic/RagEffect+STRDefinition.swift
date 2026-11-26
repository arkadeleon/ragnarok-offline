//
//  RagEffect+STRDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/21.
//

import RagnarokCore
import simd

extension RagEffect {
    /// Declarative definition for pure-STR `CRagEffect` entries ported from
    /// `RagEffectInitialization.cpp` and `RagEffect.cpp`.
    public struct STRDefinition: Sendable {
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
        public let sounds: [EffectTimedSound]
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
            sounds: [EffectTimedSound] = [],
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
}

extension RagEffect.STRDefinition {
    /// All 199 pure-STR `CRagEffect` definitions (sorted by `EffectID.rawValue`).
    public static let definitions: [RagEffect.STRDefinition] = [
        RagEffect.STRDefinition(
            effectID: .ef_stonecurse,
            strPath: "StoneCurse.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firewall,
            strPath: "Firewall%d.str",
            randomPathRange: 1...2
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lightbolt,
            strPath: "Lightning.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_thunderstorm,
            strPath: "ThunderStorm.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\magician_thunderstorm.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_angelus,
            strPath: "Angelus.str",
            minimalSTRPath: "jong_mini.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\EF_Angelus.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firehit,
            strPath: "FireHit%d.str",
            randomPathRange: 1...3,
            sounds: [EffectTimedSound(tick: 0, names: ["_enemy_hit_fire1.wav", "_enemy_hit_fire2.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_windhit,
            strPath: "WindHit%d.str",
            randomPathRange: 1...3
        ),
        RagEffect.STRDefinition(
            effectID: .ef_arrowshot,
            strPath: "ArrowShot.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_invenom,
            strPath: "Invenom.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\thief_invenom.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_cure,
            strPath: "Cure.str",
            minimalSTRPath: "cure_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\Acolyte_cure.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_provoke,
            strPath: "Provoke.str",
            sounds: [EffectTimedSound(tick: 5, names: ["effect\\swordman_provoke.wav"]), EffectTimedSound(tick: 30, names: ["effect\\swordman_provoke.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_mvp,
            strPath: "Mvp.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\st_mvp.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_skidtrap,
            strPath: "SkidTrap.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\hunter_skidtrap.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_brandishspear,
            strPath: "Brandish.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_gloria,
            strPath: "Gloria.str",
            minimalSTRPath: "gloria_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_gloria.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_magnificat,
            strPath: "Magnificat.str",
            minimalSTRPath: "magnificat_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_magnificat.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_resurrection,
            strPath: "Resurrection.str",
            minimalSTRPath: "resurrection_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_resurrection.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_recovery,
            strPath: "Recovery.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_recovery.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sanctuary,
            strPath: "Sanctuary.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_sanctuary.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_impositio,
            strPath: "Impositio.str",
            sounds: [EffectTimedSound(tick: 60, names: ["effect\\priest_impositio.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lexaeterna,
            strPath: "LexAeterna.str",
            minimalSTRPath: "lexaeterna_min.str",
            sounds: [EffectTimedSound(tick: 15, names: ["effect\\priest_lexaeterna.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lexdivina,
            strPath: "LexDivina.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_lexdivina.wav"]), EffectTimedSound(tick: 20, names: ["effect\\priest_lexdivina.wav"]), EffectTimedSound(tick: 35, names: ["effect\\priest_lexdivina.wav"]), EffectTimedSound(tick: 60, names: ["effect\\priest_lexdivina.wav"]), EffectTimedSound(tick: 70, names: ["effect\\priest_lexdivina.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_suffragium,
            strPath: "Suffragium.str",
            minimalSTRPath: "suffragium_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_suffragium.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lord,
            strPath: "Lord.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 0, names: ["effect\\hunter_blastmine.wav"]), EffectTimedSound(tick: 10, names: ["effect\\hunter_blastmine.wav"]), EffectTimedSound(tick: 20, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 50, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 80, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 100, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 130, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 140, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 180, names: ["effect\\wizard_meteo.wav"]), EffectTimedSound(tick: 200, names: ["effect\\wizard_meteo.wav"])],
            cameraShakeTicks: [50, 100, 150, 200, 250]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_benedictio,
            strPath: "Benedictio.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_benedictio.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_meteorstorm,
            strPath: "Meteor%d.str",
            randomPathRange: 1...3,
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\wizard_meteor.wav"])],
            cameraShakeTicks: [40]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_quagmire,
            strPath: "Quagmire.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\wizard_quagmire.wav"], chanceDenominator: 12)]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firepillar,
            strPath: "FirePillar.str",
            sounds: [EffectTimedSound(tick: 75, names: ["effect\\wizard_fire_pillar_a.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firepillarbomb,
            strPath: "FirePillarBomb.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\wizard_fire_pillar_b.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_repairweapon,
            strPath: "RepairWeapon.str",
            sounds: [EffectTimedSound(tick: 20, names: ["effect\\black_weapon_repair_a.wav"]), EffectTimedSound(tick: 55, names: ["effect\\black_weapon_repair_a.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_crashearth,
            strPath: "CrashEarth.str",
            sounds: [EffectTimedSound(tick: 30, names: ["effect\\wizard_fire_pillar_b.wav"])],
            cameraShakeTicks: [35]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_perfection,
            strPath: "WeaponPerfection.str",
            minimalSTRPath: "WeaponPerfection_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\black_weapon_perfection.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_maxpower,
            strPath: "MaximizePower.str",
            minimalSTRPath: "maximize_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\black_maximize_power_circle.wav"]), EffectTimedSound(tick: 40, names: ["effect\\black_maximize_power_sword.wav"]), EffectTimedSound(tick: 47, names: ["effect\\black_maximize_power_sword.wav"]), EffectTimedSound(tick: 65, names: ["effect\\black_maximize_power_sword_bic.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_blastminebomb,
            strPath: "BlastMine.str",
            sounds: [EffectTimedSound(tick: 20, names: ["effect\\hunter_blastmine.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_claymore,
            strPath: "Claymore.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\hunter_claymoretrap.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_freezing,
            strPath: "Freezing.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\hunter_freezingtrap.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_bubble,
            strPath: "Bubble%d.str",
            randomPathRange: 1...4
        ),
        RagEffect.STRDefinition(
            effectID: .ef_gaspush,
            strPath: "GasPush.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_springtrap,
            strPath: "Spring.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\hunter_springtrap.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_kyrie,
            strPath: "Kyrie.str",
            minimalSTRPath: "kyrie_min.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_kyrie_eleison_b.wav"]), EffectTimedSound(tick: 15, names: ["effect\\priest_kyrie_eleison_a.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_magnus,
            strPath: "Magnus.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\priest_magnus.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_venomdust,
            strPath: "VenomDust.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\assasin_poisonreact.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_poisonreact,
            strPath: "PoisonReact_1st.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_poisonreact2,
            strPath: "PoisonReact.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\assasin_poisonreact.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_splasher,
            strPath: "VenomSplasher.str",
            sounds: [EffectTimedSound(tick: 10, names: ["effect\\assasin_venomsplasher.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_autocounter,
            strPath: "AutoCounter.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\knight_autocounter.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_freeze,
            strPath: "Freeze.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_freezed,
            strPath: "Freezed.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_icecrash,
            strPath: "IceCrash.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_slowpoison,
            strPath: "slowp.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sandman,
            strPath: "SandMan.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pneuma,
            strPath: "Pneuma%d.str",
            randomPathRange: 1...3
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sonicblow2,
            strPath: "SonicBlow.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_brandish2,
            strPath: "Brandish2.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_shockwave,
            strPath: "ShockWave.str",
            restartsOnEnd: true,
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_shockwavehit,
            strPath: "ShockWaveHit.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_earthhit,
            strPath: "EarthHit.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pierceself,
            strPath: "Pierce.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_bowlingself,
            strPath: "Bowling.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_spearstabself,
            strPath: "SpearStab.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_spearbmrself,
            strPath: "SpearBoomerang.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_holyhit,
            strPath: "HolyHit.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_concentration,
            strPath: "Concentration.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\ac_concentration.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_refineok,
            strPath: "bs_RefineSuccess.str",
            sounds: [EffectTimedSound(tick: 15, names: ["effect\\bs_refinesuccess.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_refinefail,
            strPath: "bs_RefineFailed.str",
            sounds: [EffectTimedSound(tick: 5, names: ["effect\\bs_refinefailed.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_jobchange,
            strPath: "JobChange.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lvup,
            strPath: "LevelUP.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_joblvup,
            strPath: "JobLvUP.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_tamingsuccess,
            strPath: "TamingSuccess.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_tamingfailed,
            strPath: "TamingFailed.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_energycoat,
            strPath: "EnergyCoat.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_mentalbreak,
            strPath: "MentalBreak.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_magicalatthit,
            strPath: "magical.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_suicide,
            strPath: "suicide.str",
            usesTargetPosition: true
        ),
        RagEffect.STRDefinition(
            effectID: .ef_comboattack1,
            strPath: "yunta_1.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_comboattack2,
            strPath: "yunta_2.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_comboattack3,
            strPath: "yunta_3.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_comboattack4,
            strPath: "yunta_4.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_comboattack5,
            strPath: "yunta_5.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_guidedattack,
            strPath: "homing.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_poisonattack,
            strPath: "poison.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_silenceattack,
            strPath: "silence.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_stunattack,
            strPath: "stun.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_petrifyattack,
            strPath: "StoneCurse.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sleepattack,
            strPath: "sleep.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pong,
            strPath: "Pong%d.str",
            randomPathRange: 1...3
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion1,
            strPath: K2L("빨간포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion2,
            strPath: K2L("주홍포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion3,
            strPath: K2L("노란포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion4,
            strPath: K2L("하얀포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion5,
            strPath: K2L("파란포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion6,
            strPath: K2L("초록포션.str"),
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion7,
            strPath: "fruit.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_potion8,
            strPath: "fruit_.str",
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_deffender,
            strPath: "Deffender.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_keeping,
            strPath: "Keeping.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_spellbreaker,
            strPath: "spell.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\sage_spell breake.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_dispell,
            strPath: K2L("디스펠.str")
        ),
        RagEffect.STRDefinition(
            effectID: .ef_holycross,
            strPath: "holy_cross.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_shieldcharge,
            strPath: "shield_charge.str",
            yOffset: 0
        ),
        RagEffect.STRDefinition(
            effectID: .ef_devotion,
            strPath: "devotion.str",
            yOffset: -20
        ),
        RagEffect.STRDefinition(
            effectID: .ef_flamelauncher,
            strPath: "enc_fire.str",
            sounds: [EffectTimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_frostweapon,
            strPath: "enc_ice.str",
            sounds: [EffectTimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lightningloader,
            strPath: "enc_wind.str",
            sounds: [EffectTimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_seismicweapon,
            strPath: "enc_earth.str",
            sounds: [EffectTimedSound(tick: 10, names: ["_enemy_hit_wind1.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_stealcoin,
            strPath: "steal_coin.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_stripweapon,
            strPath: "strip_weapon.str",
            sounds: [EffectTimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_stripshield,
            strPath: "strip_shield.str",
            sounds: [EffectTimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_striparmor,
            strPath: "strip_armor.str",
            sounds: [EffectTimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_striphelm,
            strPath: "strip_helm.str",
            sounds: [EffectTimedSound(tick: 6, names: [K2L("effect\\복호격.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_chaincombo,
            strPath: K2L("연환.str"),
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\mon_연환.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pharmacy_ok,
            strPath: "p_success.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pharmacy_fail,
            strPath: "p_failed.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_loud,
            strPath: "loud.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lkconcentration,
            strPath: "TwoHand.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\knight_twohandquicken.wav"])],
            targetTint: .constant(SIMD4<Float>(1, 1, 160.0 / 255.0, 1))
        ),
        RagEffect.STRDefinition(
            effectID: .ef_angel,
            strPath: "angel.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_devil,
            strPath: "devil.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_meltdown,
            strPath: "melt.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\black_overthrust.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_cartboost,
            strPath: "cart.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_rejectsword,
            strPath: "sword.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\kyrie_guard.wav"])],
            targetTint: .rejectSwordFlicker(durationTicks: 30)
        ),
        RagEffect.STRDefinition(
            effectID: .ef_soulburn,
            strPath: K2L("소울번.str"),
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_soulchange,
            strPath: K2L("사람효과.str"),
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_assumptio2,
            strPath: "asum.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\아숨프티오.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_mochi,
            strPath: K2L("찹쌀떡.str"),
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lamadan,
            strPath: "ramadan.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_mapae,
            strPath: "mapae.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_itempokjuk,
            strPath: "itempokjuk.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hflimoon1,
            strPath: "moonlight_1.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\h_moonlight_1.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hflimoon2,
            strPath: "moonlight_2.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\h_moonlight_2.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hflimoon3,
            strPath: "moonlight_3.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\h_moonlight_3.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_ho_up,
            strPath: "h_levelup.str",
            sounds: [EffectTimedSound(tick: 0, names: ["levelup.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hamidefence,
            strPath: "defense.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food01,
            strPath: "food_str.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food02,
            strPath: "food_int.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food03,
            strPath: "food_vit.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food04,
            strPath: "food_agi.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food05,
            strPath: "food_dex.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_food06,
            strPath: "food_luk.str",
            sounds: [EffectTimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firehit2,
            strPath: "FireHit%d.str",
            randomPathRange: 1...3
        ),
        RagEffect.STRDefinition(
            effectID: .ef_cooking_ok,
            strPath: "cook_suc.str",
            sounds: [EffectTimedSound(tick: 45, names: ["_heal_effect.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_cooking_fail,
            strPath: "cook_fail.str",
            sounds: [EffectTimedSound(tick: 50, names: ["caramel_die.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_baku,
            strPath: "fire dragon.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\폭염룡.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hyousyouraku,
            strPath: "icy.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: [K2L("effect\\빙정락.wav")])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_trackcasting,
            strPath: K2L("트랙킹.str"),
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_bullseye,
            strPath: K2L("불스아이.str"),
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_dragonfear,
            strPath: "dfear.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["effect\\dragonfear.wav"])],
            cameraShakeTicks: [1]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_wideconfuse,
            strPath: "dfear.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_criticalwound,
            strPath: "cwound.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["effect\\wideb.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_flowerleaf,
            strPath: "flower_leaf.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_item315,
            strPath: "mobile_ef02.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_item316,
            strPath: "mobile_ef01.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_item317,
            strPath: "mobile_ef03.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_storm_min,
            strPath: "storm_min.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\wizard_stormgust.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_pok_jap,
            strPath: "pokjuk_jap.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_wewish,
            strPath: "Angelus.str",
            minimalSTRPath: "jong_mini.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_ado_str,
            strPath: "ado.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_crimson_str,
            strPath: "crimson_r.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["crimson_r.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_hell_str,
            strPath: "hell_in.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["hell_in.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_dhowl_str,
            strPath: "dragon_h.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_chainl_str,
            strPath: "chainlight.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["chainlight.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_aimed_str,
            strPath: "aimed.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["aimed.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_arrowstorm_str,
            strPath: "arrowstorm.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["arrowstorm.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_laulamus_str,
            strPath: "laulamus.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["lauagnus.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lauagnus_str,
            strPath: "lauagnus.str",
            endsWhenSTRCompletes: false,
            sounds: [EffectTimedSound(tick: 1, names: ["lauagnus.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_milshield_str,
            strPath: "mil_shield.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_crashaxe,
            strPath: "powerswing.str",
            sounds: [EffectTimedSound(tick: 30, names: ["effect\\wizard_fire_pillar_b.wav"])],
            cameraShakeTicks: [35]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_firewall2,
            strPath: "Firewall_per.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_shockwave2,
            strPath: "hunter_shockwave_blue.str",
            restartsOnEnd: true,
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_poison_mist,
            strPath: "poison_mist.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_eraser_cutter,
            strPath: "eraser_cutter.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_lava_slide,
            strPath: "lava_slide.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sonic_claw,
            strPath: "sonic_claw.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_tinder_breaker,
            strPath: "tinder.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_midnight_frenzy,
            strPath: "mid_frenzy.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_volcanic_ash,
            strPath: "vash00.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_2011rwc,
            strPath: "rwc2011.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_2011rwc2,
            strPath: "rwc2011_2.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_no100_firecracker,
            strPath: "100.str",
            endsWhenSTRCompletes: false
        ),
        RagEffect.STRDefinition(
            effectID: .ef_run_make_ok,
            strPath: "rune_success.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\p_success.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_run_make_failure,
            strPath: "rune_fail.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\p_failed.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_miresult_make_ok,
            strPath: "changematerial_su.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\p_success.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_miresult_make_fail,
            strPath: "changematerial_fa.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\p_failed.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_all_ray_of_protection,
            strPath: "Guardian.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_venomfog,
            strPath: "bubble%d_1.str",
            randomPathRange: 1...4
        ),
        RagEffect.STRDefinition(
            effectID: .ef_duststorm,
            strPath: "dust.str",
            loopLimit: 10
        ),
        RagEffect.STRDefinition(
            effectID: .ef_dance_blade_atk,
            strPath: "dancingblade.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_invincibleoff2,
            strPath: "INVINCIBLEOFF2.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_deathsummon,
            strPath: "devil.str"
        ),
        RagEffect.STRDefinition(
            effectID: .ef_gc_darkcrow,
            strPath: "gc_darkcrow.str",
            yOffset: 40,
            loopLimit: 9999
        ),
        RagEffect.STRDefinition(
            effectID: .ef_all_full_throttle,
            strPath: "all_full_throttle.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\all_full_throttle.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_sr_flashcombo,
            strPath: "sr_flashcombo.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\sr_flashcombo.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_rk_luxanima,
            strPath: "rk_luxanima.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\rk_luxanima.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_so_elemental_shield,
            strPath: "so_elemental_shield.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\so_elemental_shield.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_ab_offertorium,
            strPath: "AB_OFFERTORIUM.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\ab_offertorium.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_wl_telekinesis_intense,
            strPath: "WL_TELEKINESIS_INTENSE.str",
            yOffset: 0,
            loopLimit: 9999
        ),
        RagEffect.STRDefinition(
            effectID: .ef_gn_illusiondoping,
            strPath: "GN_ILLUSIONDOPING.str",
            sounds: [EffectTimedSound(tick: 0, names: ["effect\\gn_illusiondoping.wav"])]
        ),
        RagEffect.STRDefinition(
            effectID: .ef_nc_magma_eruption,
            strPath: "NC_MAGMA_ERUPTION.str",
            yOffset: -25,
            loopLimit: 9999
        ),
        RagEffect.STRDefinition(
            effectID: .ef_npc_chill,
            strPath: "chill.str",
            loopLimit: 9999
        ),
        RagEffect.STRDefinition(
            effectID: .ef_ab_offertorium_ring,
            strPath: "AB_OFFERTORIUM_ring.str",
            yOffset: -5,
            loopLimit: 9999
        ),
    ]

    public static let definitionsByEffectID: [EffectID : RagEffect.STRDefinition] = Dictionary(
        uniqueKeysWithValues: definitions.map { ($0.effectID, $0) }
    )

    public static func definition(for effectID: EffectID) -> RagEffect.STRDefinition? {
        definitionsByEffectID[effectID]
    }
}
