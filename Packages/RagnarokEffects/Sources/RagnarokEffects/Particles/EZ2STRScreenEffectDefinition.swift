//
//  EZ2STRScreenEffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/23.
//

import RagnarokCore
import simd

/// Declarative definition for screen/world STR particle effects (`EZ2STRScreenEffect`).
public struct EZ2STRScreenEffectDefinition: Sendable {
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

    public struct PeriodicSound: Sendable, Equatable {
        public let startTick: Int
        public let intervalTicks: Int
        public let name: String

        public init(startTick: Int, intervalTicks: Int, name: String) {
            self.startTick = startTick
            self.intervalTicks = intervalTicks
            self.name = name
        }
    }

    public enum AimMode: Sendable, Equatable {
        case none
        case towardSource
        case fromSource
        case fromSourceInverted

        public func angle(from sourceWorldPosition: SIMD3<Float>, to targetWorldPosition: SIMD3<Float>) -> Float {
            let dx = sourceWorldPosition.x - targetWorldPosition.x
            let dz = sourceWorldPosition.z - targetWorldPosition.z
            let length = hypot(dx, dz)
            guard length > 1e-5 else {
                return 0
            }

            let cosValue: Float
            switch self {
            case .none:
                return 0
            case .towardSource:
                cosValue = max(-1, min(1, dx / length))
            case .fromSource, .fromSourceInverted:
                cosValue = max(-1, min(1, -dx / length))
            }

            var angle = acos(cosValue) * 180.0 / .pi
            switch self {
            case .none:
                break
            case .towardSource:
                if dz < 0 {
                    angle = 360.0 - angle
                }
            case .fromSource:
                if dz > 0 {
                    angle = 360.0 - angle
                }
            case .fromSourceInverted:
                if dz < 0 {
                    angle = 360.0 - angle
                }
            }
            return angle
        }
    }

    public let effectID: EffectID
    public let strPath: String
    public let randomPathRange: ClosedRange<Int>?
    public let renderMode: STREffectRenderMode
    public let isLooping: Bool
    public let isRetained: Bool
    public let isAttachedToHead: Bool
    public let isHeadEffect: Bool
    public let headOffsetX: Float
    public let headOffsetYDelta: Float
    public let ignoresRidingHeight: Bool
    public let defaultScale: Float
    public let levelScales: [Int : Float]
    public let defaultRepeatCount: Int
    public let defaultLifeTimeFrames: Int?
    public let overlayColorStep: UInt32
    public let followCamera: Bool
    public let aimMode: AimMode
    public let sounds: [TimedSound]
    public let periodicSound: PeriodicSound?
    public let cameraShakeTicks: [Int]

    public init(
        effectID: EffectID,
        strPath: String,
        randomPathRange: ClosedRange<Int>? = nil,
        renderMode: STREffectRenderMode = .billboard,
        isLooping: Bool = false,
        isRetained: Bool = false,
        isAttachedToHead: Bool = false,
        isHeadEffect: Bool = false,
        headOffsetX: Float = 0,
        headOffsetYDelta: Float = 0,
        ignoresRidingHeight: Bool = false,
        defaultScale: Float = 1,
        levelScales: [Int : Float] = [:],
        defaultRepeatCount: Int = 0,
        defaultLifeTimeFrames: Int? = nil,
        overlayColorStep: UInt32 = 0,
        followCamera: Bool = false,
        aimMode: AimMode = .none,
        sounds: [TimedSound] = [],
        periodicSound: PeriodicSound? = nil,
        cameraShakeTicks: [Int] = []
    ) {
        self.effectID = effectID
        self.strPath = strPath
        self.randomPathRange = randomPathRange
        self.renderMode = renderMode
        self.isLooping = isLooping
        self.isRetained = isRetained
        self.isAttachedToHead = isAttachedToHead
        self.isHeadEffect = isHeadEffect
        self.headOffsetX = headOffsetX
        self.headOffsetYDelta = headOffsetYDelta
        self.ignoresRidingHeight = ignoresRidingHeight
        self.defaultScale = defaultScale
        self.levelScales = levelScales
        self.defaultRepeatCount = defaultRepeatCount
        self.defaultLifeTimeFrames = defaultLifeTimeFrames
        self.overlayColorStep = overlayColorStep
        self.followCamera = followCamera
        self.aimMode = aimMode
        self.sounds = sounds
        self.periodicSound = periodicSound
        self.cameraShakeTicks = cameraShakeTicks
    }

    public func expandedSTRPath(randomValue: ((ClosedRange<Int>) -> Int)? = nil) -> String {
        guard let randomPathRange else {
            return strPath
        }
        let value = randomValue?(randomPathRange) ?? Int.random(in: randomPathRange)
        return strPath.replacingOccurrences(of: "%d", with: "\(value)")
    }

    public func candidateSTRPaths(usesMinimalEffects: Bool = false, randomValue: ((ClosedRange<Int>) -> Int)? = nil) -> [String] {
        let expandedPath = expandedSTRPath(randomValue: randomValue)
        let resolver = EffectResourcePathResolver(usesMinimalEffects: usesMinimalEffects)
        return resolver.candidateSTRPaths(forPath: expandedPath)
    }
}

extension EZ2STRScreenEffectDefinition {
    /// All 1047 screen/world STR particle effect definitions (sorted by `EffectID.rawValue`).
    public static let definitions: [EZ2STRScreenEffectDefinition] = [
        EZ2STRScreenEffectDefinition(
            effectID: .ef_pneuma,
            strPath: "Pneuma%d.str",
            randomPathRange: 1...3,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion1,
            strPath: K2L("빨간포션.str"),
            sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion2,
            strPath: K2L("주홍포션.str"),
            sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion3,
            strPath: K2L("노란포션.str"),
            sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion4,
            strPath: K2L("하얀포션.str"),
            sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion5,
            strPath: K2L("파란포션.str"),
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion6,
            strPath: K2L("초록포션.str"),
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion7,
            strPath: "fruit.str",
            sounds: [TimedSound(tick: 0, names: ["_heal_effect.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_potion8,
            strPath: "fruit_.str",
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_zenkai_water,
            strPath: K2L("술식전개3.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_zenkai_land,
            strPath: K2L("술식전개4.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_zenkai_fire,
            strPath: K2L("술식전개2.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_zenkai_wind,
            strPath: K2L("술식전개5.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_jyumonjikiri,
            strPath: "jyumonjikiri.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_setsudan,
            strPath: "setsudan.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_red_cross,
            strPath: "red_cross.str",
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ko_izayoi,
            strPath: "ez_cure.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_kg_kyomu,
            strPath: K2L("허무의그림자.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_kaihou1,
            strPath: K2L("술식해방.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_akaitsuki,
            strPath: K2L("불길한붉은달빛.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_zangetsu,
            strPath: K2L("초승달2.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gensou,
            strPath: K2L("흐린달빛환상2.str")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hat_effect,
            strPath: "cloudh.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_moonstar,
            strPath: "moonstar.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_strangelights,
            strPath: "strangelights.str",
            isHeadEffect: true,
            headOffsetX: 5,
            headOffsetYDelta: 5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_super_star,
            strPath: "superstar.str",
            isHeadEffect: true,
            headOffsetX: 5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_c_maker,
            strPath: "RL_C_MAKER\\deffender.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hammer_of_god,
            strPath: "RL_HAMER_GOD\\hogg2.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\RL_HAMMER_OF_GOD.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mass_spiral,
            strPath: "RL_MESS_SPIRAL\\S5.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fire_rain,
            strPath: "RL_FIRE_RAIN\\fire_rain.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_banishing_buster,
            strPath: "RL_BANISHING_BUSTER\\vanishing1.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_slugshot,
            strPath: "RL_SLUGSHOT\\slug.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_d_tail,
            strPath: "RL_d_tail\\dtdt.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rl_explosion,
            strPath: "RL_EXPLOSION\\boom.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_c_maker_1,
            strPath: "RL_C_MAKER\\cm.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_qd_shot,
            strPath: "RL_QUICK_DRAW\\qd2.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_p_alter,
            strPath: "RL_P_ALTER\\platinum.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_s_storm,
            strPath: "RL_STORM\\S_STORM.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_music_hat,
            strPath: "EFST_DECORATION_OF_MUSIC\\note_1.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_flowersmoke,
            strPath: "efst_flowersmoke\\flowersmoke.str",
            isHeadEffect: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fstone,
            strPath: "efst_fstone\\fstone.str",
            isHeadEffect: true,
            headOffsetYDelta: -7
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_qscaraba,
            strPath: "efst_qscaraba\\qscaraba.str",
            isHeadEffect: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ljosalfar,
            strPath: "efst_ljosalfar\\ljosalfar.str",
            isHeadEffect: true,
            headOffsetX: 8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_happinessstar,
            strPath: "efst_happiness_star\\moonstar2.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_maple_falls,
            strPath: "efst_maple_falls\\maple_falls.str",
            isHeadEffect: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_marking_use_changemonster,
            strPath: "Arrows_Effect_finish\\pol.str",
            isLooping: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_magical_feather,
            strPath: "efst_magical_feather\\magical_feather.str",
            isHeadEffect: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mermaid_longing,
            strPath: "efst_mermaid_loging\\bubblebubble.str",
            isHeadEffect: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ach_complete,
            strPath: "ach_complete\\ppring3.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_time_accessory,
            strPath: "efst_time_accessory\\time_accessory.str",
            isHeadEffect: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_freshshrimp,
            strPath: "su_freshshrimp\\su_freshshrimp.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_sv_stemspear,
            strPath: "su_sv_stemspear\\su_sv_stemspear.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\su_stemspear.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_tunabelly,
            strPath: "su_tunabelly\\su_tunabelly.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_tunabelly.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_scratch,
            strPath: "su_scratch\\su_scratch.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_scratch.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_bite,
            strPath: "su_bite\\su_bite.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_scaroftarou,
            strPath: "su_scaroftarou\\su_scaroftarou.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_scaroftarou.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_arclousedash,
            strPath: "su_arclousedash\\su_arclousedash.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_pickypeck,
            strPath: "su_pickypeck\\su_pickypeck.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_pickypeck.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_bunchofshrimp,
            strPath: "su_bunchofshrimp\\su_bunchofshrimp.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_brunchofshrimp.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_bite_scar,
            strPath: "bite_scar\\bite_scar.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: 5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wide_critical_wound,
            strPath: "wide_critical_wound\\wide_critical_wound.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_grooming,
            strPath: "su_grooming\\su_grooming.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_grooming.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_chattering,
            strPath: "su_chattering\\su_chattering.str",
            isAttachedToHead: true,
            headOffsetYDelta: 8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_chattering.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_hiss,
            strPath: "su_hiss\\su_hiss.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\su_hiss.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_powerofflock,
            strPath: "su_powerofflock\\su_powerofflock.str",
            isAttachedToHead: true,
            headOffsetYDelta: 8,
            sounds: [TimedSound(tick: 0, names: ["effect\\su_powerofflock.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_su_svg_spirit,
            strPath: "su_svg_spirit\\su_svg_spirit.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\su_svg_spirit.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_firedance,
            strPath: "RL_fire_dance\\firedance.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_richs_coin_a,
            strPath: "RL_richs_coin_A\\reachs.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rl_anti_material_blast,
            strPath: "RL_anti_material\\anti.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_e_chain,
            strPath: "RL_e_chain\\eternal.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_heat_barrel,
            strPath: "RL_heat_barrel\\htb.str",
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_h_mine,
            strPath: "RL_h_mine\\mine.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_we_oneforever,
            strPath: "we_oneforever\\we_oneforever.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_we_cheerup,
            strPath: "we_cheerup\\we_cheerup.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_quagmire_visual,
            strPath: "Quagmire\\Quagmire.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\wizard_quagmire.wav"], chanceDenominator: 12)]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lord_of_vermillion_visual,
            strPath: "lord_of_vermillion\\lord_of_vermillion.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 0, names: ["effect\\hunter_blastmine.wav"]), TimedSound(tick: 10, names: ["effect\\hunter_blastmine.wav"]), TimedSound(tick: 20, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 50, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 80, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 100, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 130, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 140, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 180, names: ["effect\\wizard_meteo.wav"]), TimedSound(tick: 200, names: ["effect\\wizard_meteo.wav"])],
            cameraShakeTicks: [50, 100, 150, 200, 250]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_meteor_storm_visual,
            strPath: "MeteorStorm\\meteor%d.str",
            randomPathRange: 1...3,
            sounds: [TimedSound(tick: 0, names: ["effect\\wizard_meteor.wav"])],
            cameraShakeTicks: [40]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_solarburst,
            strPath: "solar_burst\\solar_burst.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sj_document,
            strPath: "sj_document\\sj_document.str",
            isAttachedToHead: true,
            headOffsetX: 0.5,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_falling_star,
            strPath: "falling_star\\falling_star.str",
            isAttachedToHead: true,
            headOffsetYDelta: -10
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_flash_kick,
            strPath: "flash_kick\\flash_kick.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_golem,
            strPath: "soul_golem\\soul_golem.str",
            isAttachedToHead: true,
            headOffsetYDelta: -16
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_newmoon_kick,
            strPath: "newmoon_kick\\newmoon_kick.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fullmoon_kick,
            strPath: "fullmoon_kick\\fullmoon_kick.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_curse,
            strPath: "soul_curse\\soul_curse.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_prominence_kick,
            strPath: "prominence_kick\\prominence_kick.str",
            isAttachedToHead: true,
            headOffsetYDelta: -10
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_revolve,
            strPath: "soul_revolve\\soul_revolve.str",
            isAttachedToHead: true,
            headOffsetYDelta: -10
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_00,
            strPath: "test_effect\\00\\00.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_01,
            strPath: "test_effect\\01\\01.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_02,
            strPath: "test_effect\\02\\02.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_03,
            strPath: "test_effect\\03\\03.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_04,
            strPath: "test_effect\\04\\04.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_05,
            strPath: "test_effect\\05\\05.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_06,
            strPath: "test_effect\\06\\06.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_07,
            strPath: "test_effect\\07\\07.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_08,
            strPath: "test_effect\\08\\08.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_test_effect_09,
            strPath: "test_effect\\09\\09.str",
            isLooping: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_meteorstorm,
            strPath: "new_meteostorm\\new_meteostorm\\new_meteostorm.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_meteorstorm_bottom,
            strPath: "new_meteostorm\\new_meteostorm_bottom\\new_meteostorm_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_adoramus,
            strPath: "new_adoramus\\new_adoramus\\new_adoramus.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_adoramus_bottom,
            strPath: "new_adoramus\\new_adoramus_bottom\\new_adoramus_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_cast,
            strPath: "tetravortex\\tetra_cast\\tetra_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_core,
            strPath: "tetravortex\\tetra_ball_00_core\\tetra_ball_00_core.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_fire_exp,
            strPath: "tetravortex\\tetra_01_fire_explosion\\tetra_01_fire_expn.str",
            isAttachedToHead: true,
            headOffsetX: -0.5,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_water_exp,
            strPath: "tetravortex\\tetra_04_water_explosion\\tetra_04_water_expn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_wind_exp,
            strPath: "tetravortex\\tetra_02_wind_explosion\\tetra_02_wind_expn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_earth_exp,
            strPath: "tetravortex\\tetra_03_earth_explosion\\tetra_03_earth_expn.str",
            isAttachedToHead: true,
            headOffsetX: -0.5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_fire_ground,
            strPath: "tetravortex\\tetra_01_fire_ground\\tetra_01_fire_grd.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_water_ground,
            strPath: "tetravortex\\tetra_04_water_ground\\tetra_04_water_grd.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_wind_ground,
            strPath: "tetravortex\\tetra_02_wind_ground\\tetra_02_wind_grd.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_earth_ground,
            strPath: "tetravortex\\tetra_03_earth_ground\\tetra_03_earth_grd.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crimsonrock,
            strPath: "new_crimsonrock\\new_crimsonrock\\new_crimsonrock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crimsonrock_bottom,
            strPath: "new_crimsonrock\\new_crimsonrock_bottom\\new_crimsonrock_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_core_ground,
            strPath: "tetravortex\\tetra_ball_00_core_ground\\tetra_ball_00_core_grd.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_fire_sub,
            strPath: "tetravortex\\tetra_01_fire_sub_explosion\\tetra_01_fire_sub_expn.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_water_sub,
            strPath: "tetravortex\\tetra_04_water_sub_explosion\\tetra_04_water_sub_expn.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_wind_sub,
            strPath: "tetravortex\\tetra_02_wind_sub_explosion\\tetra_02_wind_sub_expn.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_earth_sub,
            strPath: "tetravortex\\tetra_03_earth_sub_explosion\\tetra_03_earth_sub_expn.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_diamonddust,
            strPath: "new_diamonddust\\new_diamonddust\\new_diamonddust.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_diamonddust_bottom,
            strPath: "new_diamonddust\\new_diamonddust_bottom\\new_diamonddust_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_diamonddust_cast,
            strPath: "new_diamonddust\\new_diamonddust_cast\\new_diamonddust_cast.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_severerainstorm_cast,
            strPath: "new_severerainstorm\\new_severerainstorm_cast\\new_severerainstorm_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_secrament,
            strPath: "new_secrament\\new_secrament\\new_secrament.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_psychicwave,
            strPath: "new_psychicwave\\new_psychicwave\\new_psychicwave.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_psychicwave_bottom,
            strPath: "new_psychicwave\\new_psychicwave_bottom\\new_psychicwave_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_psychicwave_cast,
            strPath: "new_psychicwave\\new_psychicwave_cast\\new_psychicwave_cast.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_arrowstorm_00,
            strPath: "new_arrowstorm\\new_arrowstorm_00\\new_arrowstorm_00.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_arrowstorm_01,
            strPath: "new_arrowstorm\\new_arrowstorm_01\\new_arrowstorm_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_secrament_aura,
            strPath: "new_secrament\\new_secrament_aura\\new_secrament_aura.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_triangleshot,
            strPath: "new_triangleshot\\new_triangleshot\\new_triangleshot.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_triangleshot_bottom,
            strPath: "new_triangleshot\\new_triangleshot_bottom\\new_triangleshot_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crimsonrock_sub,
            strPath: "new_crimsonrock\\new_crimsonrock_sub_explosion\\new_crimsonrock_sub_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter,
            strPath: "new_rollingcutter\\new_rollingcutter\\new_rollingcutter.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_01,
            strPath: "new_rollingcutter\\new_rollingcutter_count_01\\new_rollingcutter_count_01.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_02,
            strPath: "new_rollingcutter\\new_rollingcutter_count_02\\new_rollingcutter_count_02.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_03,
            strPath: "new_rollingcutter\\new_rollingcutter_count_03\\new_rollingcutter_count_03.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_04,
            strPath: "new_rollingcutter\\new_rollingcutter_count_04\\new_rollingcutter_count_04.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_05,
            strPath: "new_rollingcutter\\new_rollingcutter_count_05\\new_rollingcutter_count_05.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_06,
            strPath: "new_rollingcutter\\new_rollingcutter_count_06\\new_rollingcutter_count_06.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_07,
            strPath: "new_rollingcutter\\new_rollingcutter_count_07\\new_rollingcutter_count_07.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_08,
            strPath: "new_rollingcutter\\new_rollingcutter_count_08\\new_rollingcutter_count_08.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_09,
            strPath: "new_rollingcutter\\new_rollingcutter_count_09\\new_rollingcutter_count_09.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rollingcutter_count_10,
            strPath: "new_rollingcutter\\new_rollingcutter_count_10\\new_rollingcutter_count_10.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rampageblaster,
            strPath: "new_rampageblaster\\new_rampageblaster\\new_rampageblaster.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rampageblaster_bottom,
            strPath: "new_rampageblaster\\new_rampageblaster_bottom\\new_rampageblaster_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_feintbomb,
            strPath: "new_peintbomb\\new_peintbomb\\new_peintbomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_feintbomb_bottom,
            strPath: "new_peintbomb\\new_peintbomb_bottom\\new_peintbomb_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher,
            strPath: "new_crossripperslasher\\new_crossripperslasher\\new_crossripperslasher.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_00,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_00\\new_crossripperslasher_clock_00.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_01,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_01\\new_crossripperslasher_clock_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_03,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_03\\new_crossripperslasher_clock_03.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_05,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_05\\new_crossripperslasher_clock_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_06,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_06\\new_crossripperslasher_clock_06.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_07,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_07\\new_crossripperslasher_clock_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_09,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_09\\new_crossripperslasher_clock_09.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossripperslasher_11,
            strPath: "new_crossripperslasher\\new_crossripperslasher_clock_11\\new_crossripperslasher_clock_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_tigercannon,
            strPath: "new_tigercannon\\new_tigercannon.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_01_up,
            strPath: "new_armscannon\\new_armscannon_01_clock_up\\new_armscannon_01_clock_up.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_01_down,
            strPath: "new_armscannon\\new_armscannon_01_clock_down\\new_armscannon_01_clock_down.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_05_up,
            strPath: "new_armscannon\\new_armscannon_05_clock_up\\new_armscannon_05_clock_up.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_05_down,
            strPath: "new_armscannon\\new_armscannon_05_clock_down\\new_armscannon_05_clock_down.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_07_up,
            strPath: "new_armscannon\\new_armscannon_07_clock_up\\new_armscannon_07_clock_up.str",
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_07_down,
            strPath: "new_armscannon\\new_armscannon_07_clock_down\\new_armscannon_07_clock_down.str",
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_11_up,
            strPath: "new_armscannon\\new_armscannon_11_clock_up\\new_armscannon_11_clock_up.str",
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_11_down,
            strPath: "new_armscannon\\new_armscannon_11_clock_down\\new_armscannon_11_clock_down.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_explosion,
            strPath: "new_armscannon\\new_armscannon_explosion\\new_armscannon_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_explosion_bottom,
            strPath: "new_armscannon\\new_armscannon_explosion_bottom\\new_armscannon_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_explosion,
            strPath: "new_cart_cannon\\new_cart_cannon_explosion\\new_cart_cannon_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_explosion_bottom,
            strPath: "new_cart_cannon\\new_cart_cannon_explosion_bottom\\new_cart_cannon_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_fire,
            strPath: "new_cart_cannon\\new_cart_cannon_fire\\new_cart_cannon_fire.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_fire_bottom,
            strPath: "new_cart_cannon\\new_cart_cannon_fire_bottom\\new_cart_cannon_fire_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_qscaraba_visual,
            strPath: "efst_qscaraba\\qscaraba.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axetornado,
            strPath: "new_axetornado\\new_axetornado\\new_axetornado.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axetornado_bottom,
            strPath: "new_axetornado\\new_axetornado_bottom\\new_axetornado_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 5, names: ["ice_titan_attack.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_tornado,
            strPath: "new_cart_tornado\\new_cart_tornado\\new_cart_tornado.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_tornado_bottom,
            strPath: "new_cart_tornado\\new_cart_tornado_bottom\\new_cart_tornado_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_help_angel,
            strPath: "help_angel\\help_angel\\help_angel.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_help_angel_bottom,
            strPath: "help_angel\\help_angel_bottom\\help_angel_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_target,
            strPath: "new_banishingpoint\\new_banishingpoint_target\\new_banishingpoint_target.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_target_bottom,
            strPath: "new_banishingpoint\\new_banishingpoint_target_bottom\\new_banishingpoint_target_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_cast,
            strPath: "new_banishingpoint\\new_banishingpoint_cast\\new_banishingpoint_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_cast_bottom,
            strPath: "new_banishingpoint\\new_banishingpoint_cast_bottom\\new_banishingpoint_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_01,
            strPath: "new_banishingpoint\\new_banishingpoint_01\\new_banishingpoint_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_05,
            strPath: "new_banishingpoint\\new_banishingpoint_05\\new_banishingpoint_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_07,
            strPath: "new_banishingpoint\\new_banishingpoint_07\\new_banishingpoint_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_banishingpoint_11,
            strPath: "new_banishingpoint\\new_banishingpoint_11\\new_banishingpoint_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_bomb,
            strPath: "new_dragonbreath\\new_dragonbreath_bomb\\new_dragonbreath_bomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_bomb_bottom,
            strPath: "new_dragonbreath\\new_dragonbreath_bomb_bottom\\new_dragonbreath_bomb_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_01,
            strPath: "new_dragonbreath\\new_dragonbreath_01_clock\\new_dragonbreath_01_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_05,
            strPath: "new_dragonbreath\\new_dragonbreath_05_clock\\new_dragonbreath_05_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_07,
            strPath: "new_dragonbreath\\new_dragonbreath_07_clock\\new_dragonbreath_07_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_11,
            strPath: "new_dragonbreath\\new_dragonbreath_11_clock\\new_dragonbreath_11_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_cast,
            strPath: "new_armscannon\\new_armscannon_cast\\new_armscannon_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_armscannon_cast_bottom,
            strPath: "new_armscannon\\new_armscannon_cast_bottom\\new_armscannon_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_bomb,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_bomb\\new_dragonbreath_water_bomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_bomb_bottom,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_bomb_bottom\\new_dragonbreath_water_bomb_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_01,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_01_clock\\new_dragonbreath_water_01_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_05,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_05_clock\\new_dragonbreath_water_05_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_07,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_07_clock\\new_dragonbreath_water_07_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dragonbreath_water_11,
            strPath: "new_dragonbreath_water\\new_dragonbreath_water_11_clock\\new_dragonbreath_water_11_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_counter_slash,
            strPath: "new_counter_slash\\new_counter_slash\\new_counter_slash.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_counter_slash_bottom,
            strPath: "new_counter_slash\\new_counter_slash_bottom\\new_counter_slash_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fatal_menace,
            strPath: "new_fatal_menace\\new_fatal_menace\\new_fatal_menace.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fatal_menace_bottom,
            strPath: "new_fatal_menace\\new_fatal_menace_bottom\\new_fatal_menace_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_Bash.wav"]), TimedSound(tick: 35, names: ["effect\\rog_intimidate.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fatal_menace_cast,
            strPath: "new_fatal_menace\\new_fatal_menace_cast\\new_fatal_menace_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fatal_menace_cast_bottom,
            strPath: "new_fatal_menace\\new_fatal_menace_cast_bottom\\new_fatal_menace_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_12,
            strPath: "new_cannon_spear\\new_cannon_spear_12_clock\\new_cannon_spear_12_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_01,
            strPath: "new_cannon_spear\\new_cannon_spear_01_clock\\new_cannon_spear_01_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_03,
            strPath: "new_cannon_spear\\new_cannon_spear_03_clock\\new_cannon_spear_03_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_05,
            strPath: "new_cannon_spear\\new_cannon_spear_05_clock\\new_cannon_spear_05_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_06,
            strPath: "new_cannon_spear\\new_cannon_spear_06_clock\\new_cannon_spear_06_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_07,
            strPath: "new_cannon_spear\\new_cannon_spear_07_clock\\new_cannon_spear_07_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_09,
            strPath: "new_cannon_spear\\new_cannon_spear_09_clock\\new_cannon_spear_09_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_11,
            strPath: "new_cannon_spear\\new_cannon_spear_11_clock\\new_cannon_spear_11_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cannon_spear_bottom,
            strPath: "new_cannon_spear\\new_cannon_spear_bottom\\new_cannon_spear_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 10, names: ["effect\\EF_hit2.wav"]), TimedSound(tick: 20, names: ["effect\\EF_hit4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_basicattack,
            strPath: "new_hit\\new_basicattack\\new_basicattack.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_criticalattack,
            strPath: "new_hit\\new_criticalattack\\new_criticalattack.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_hit2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rangedattack,
            strPath: K2L("빨간포션.str"),
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet,
            strPath: "new_comet\\new_comet\\new_comet.str",
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\g크레이지위드.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet_bottom,
            strPath: "new_comet\\new_comet_bottom\\new_comet_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet_cast_bottom,
            strPath: "new_comet\\new_comet_cast_bottom\\new_comet_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet_sub_exp,
            strPath: "new_comet\\new_comet_sub_explosion\\new_comet_sub_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet_sub_exp_bottom,
            strPath: "new_comet\\new_comet_sub_explosion_bottom\\new_comet_sub_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_comet_cast,
            strPath: "new_comet\\new_comet_cast\\new_comet_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_cast,
            strPath: "new_cart_cannon\\new_cart_cannon_cast\\new_cart_cannon_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cart_cannon_cast_bottom,
            strPath: "new_cart_cannon\\new_cart_cannon_cast_bottom\\new_cart_cannon_cast_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rayofgenesis,
            strPath: "new_rayofgenesis\\new_rayofgenesis\\new_rayofgenesis.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 5, names: [K2L("effect\\mon_맹룡과강.wav")]), TimedSound(tick: 5, names: [K2L("effect\\mon_맹룡과강.wav")]), TimedSound(tick: 5, names: [K2L("effect\\mon_맹룡과강.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rayofgenesis_cast,
            strPath: "new_rayofgenesis\\new_rayofgenesis_cast\\new_rayofgenesis_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rayofgenesis_cast_bottom,
            strPath: "new_rayofgenesis\\new_rayofgenesis_cast_bottom\\new_rayofgenesis_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rayofgenesis_hit,
            strPath: "new_rayofgenesis\\new_rayofgenesis_hit\\new_rayofgenesis_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_adoramus,
            strPath: "mineffect\\new_adoramus\\new_adoramus\\new_adoramus.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_adoramus_bottom,
            strPath: "mineffect\\new_adoramus\\new_adoramus_bottom\\new_adoramus_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_cast,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_cast\\new_tetravortex_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_core,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_ball_core\\new_tetravortex_ball_core.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_fire,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_fire\\new_tetravortex_fire.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_water,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_water\\new_tetravortex_water.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_wind,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_wind\\new_tetravortex_wind.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_earth,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_earth\\new_tetravortex_earth.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_fire_bottom,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_fire_bottom\\new_tetravortex_fire_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_water_bottom,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_water_bottom\\new_tetravortex_water_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_wind_bottom,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_wind_bottom\\new_tetravortex_wind_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_earth_bottom,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_earth_bottom\\new_tetravortex_earth_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tetra_core_bottom,
            strPath: "mineffect\\new_tetravortex\\new_tetravortex_ball_core_bottom\\new_tetravortex_ball_core_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crimsonrock,
            strPath: "mineffect\\new_crimsonrock\\new_crimsonrock\\new_crimsonrock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crimsonrock_bottom,
            strPath: "mineffect\\new_crimsonrock\\new_crimsonrock_bottom\\new_crimsonrock_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_jackfrost_00,
            strPath: "new_jackfrost\\new_jackfrost\\new_jackfrost_00.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_jackfrost_01,
            strPath: "new_jackfrost\\new_jackfrost\\new_jackfrost_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_jackfrost_02,
            strPath: "new_jackfrost\\new_jackfrost\\new_jackfrost_02.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_jackfrost_cast,
            strPath: "new_jackfrost\\new_jackfrost_cast\\new_jackfrost_cast.str",
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_jackfrost_rune,
            strPath: "new_jackfrost\\new_jackfrost_magicrune\\new_jackfrost_frost.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_diamonddust,
            strPath: "mineffect\\new_diamonddust\\new_diamonddust\\new_diamonddust.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_diamonddust_bottom,
            strPath: "mineffect\\new_diamonddust\\new_diamonddust_bottom\\new_diamonddust_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_diamonddust_cast,
            strPath: "mineffect\\new_diamonddust\\new_diamonddust_cast\\new_diamonddust_cast.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_secrament,
            strPath: "mineffect\\new_secrament\\new_secrament\\new_secrament.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_psychicwave,
            strPath: "mineffect\\new_psychicwave\\new_psychicwave\\new_psychicwave.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_psychicwave_bottom,
            strPath: "mineffect\\new_psychicwave\\new_psychicwave_bottom\\new_psychicwave_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_psychicwave_cast,
            strPath: "mineffect\\new_psychicwave\\new_psychicwave_cast\\new_psychicwave_cast.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_arrowstorm_00,
            strPath: "mineffect\\new_arrowstorm\\new_arrowstorm_00\\new_arrowstorm_00.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_arrowstorm_01,
            strPath: "mineffect\\new_arrowstorm\\new_arrowstorm_01\\new_arrowstorm_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_triangleshot,
            strPath: "mineffect\\new_triangleshot\\new_triangleshot\\new_triangleshot.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_triangleshot_bottom,
            strPath: "mineffect\\new_triangleshot\\new_triangleshot_bottom\\new_triangleshot_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rampageblaster,
            strPath: "mineffect\\new_rampageblaster\\new_rampageblaster\\new_rampageblaster_exp.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rampageblaster_bottom,
            strPath: "mineffect\\new_rampageblaster\\new_rampageblaster_bottom\\new_rampageblaster_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_feintbomb,
            strPath: "mineffect\\new_peintbomb\\new_peintbomb\\new_peintbomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_feintbomb_bottom,
            strPath: "mineffect\\new_peintbomb\\new_peintbomb_bottom\\new_peintbomb_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthgrave_visual,
            strPath: "new_earthgrave\\new_earthgrave\\new_earthgrave.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_cast,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter\\new_rollingcutter_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_01,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_01\\new_rollingcutter_count_01.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_02,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_02\\new_rollingcutter_count_02.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_03,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_03\\new_rollingcutter_count_03.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_04,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_04\\new_rollingcutter_count_04.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_05,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_05\\new_rollingcutter_count_05.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_06,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_06\\new_rollingcutter_count_06.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_07,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_07\\new_rollingcutter_count_07.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_08,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_08\\new_rollingcutter_count_08.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_09,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_09\\new_rollingcutter_count_09.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_rollingcutter_10,
            strPath: "mineffect\\new_rollingcutter\\new_rollingcutter_count_10\\new_rollingcutter_count_10.str",
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher\\new_crossripperslasher.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_12,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_12\\new_crossripperslasher_12.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_01,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_01\\new_crossripperslasher_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_03,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_03\\new_crossripperslasher_03.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_05,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_05\\new_crossripperslasher_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_06,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_06\\new_crossripperslasher_06.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_07,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_07\\new_crossripperslasher_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_09,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_09\\new_crossripperslasher_09.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_crossripperslasher_11,
            strPath: "mineffect\\new_crossripperslasher\\new_crossripperslasher_11\\new_crossripperslasher_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_01,
            strPath: "mineffect\\new_armscannon\\new_armscannon_01\\new_armscannon_01.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_05,
            strPath: "mineffect\\new_armscannon\\new_armscannon_05\\new_armscannon_05.str",
            isAttachedToHead: true,
            headOffsetX: 1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_07,
            strPath: "mineffect\\new_armscannon\\new_armscannon_07\\new_armscannon_07.str",
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_11,
            strPath: "mineffect\\new_armscannon\\new_armscannon_11\\new_armscannon_11.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetX: -1,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_explosion,
            strPath: "mineffect\\new_armscannon\\new_armscannon_explosion\\armscannon_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_explosion_bottom,
            strPath: "mineffect\\new_armscannon\\new_armscannon_explosion_bottom\\armscannon_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_cast,
            strPath: "mineffect\\new_armscannon\\new_armscannon_cast\\new_armscannon_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_armscannon_cast_bottom,
            strPath: "mineffect\\new_armscannon\\new_armscannon_cast_bottom\\new_armscannon_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_axetornado,
            strPath: "mineffect\\new_axetornado\\new_axetornado\\new_axetornado.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_axetornado_bottom,
            strPath: "mineffect\\new_axetornado\\new_axetornado_bottom\\new_axetornado_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 5, names: ["ice_titan_attack.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_cannon_explosion,
            strPath: "mineffect\\new_cart_cannon\\new_cart_cannon_explosion\\armscannon_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_cannon_explosion_bottom,
            strPath: "mineffect\\new_cart_cannon\\new_cart_cannon_explosion_bottom\\armscannon_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_cannon_fire_bottom,
            strPath: "mineffect\\new_cart_cannon\\new_cart_cannon_fire_bottom\\new_cartcannon_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_cannon_cast,
            strPath: "mineffect\\new_cart_cannon\\new_cart_cannon_cast\\new_cart_cannon_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_cannon_cast_bottom,
            strPath: "mineffect\\new_cart_cannon\\new_cart_cannon_cast_bottom\\new_cart_cannon_cast_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_tornado,
            strPath: "mineffect\\new_cart_tornado\\new_cart_tornado\\new_carttornado.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cart_tornado_bottom,
            strPath: "mineffect\\new_cart_tornado\\new_cart_tornado_bottom\\new_carttornado_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_target,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_target\\new_banishingpoint_target.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_target_bottom,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_target_bottom\\new_banishingpoint_target_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_cast,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_cast\\new_banishingpoint_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_cast_bottom,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_cast_bottom\\new_banishingpoint_cast_combine.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_01,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_01\\new_banishingpoint_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_05,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_05\\new_banishingpoint_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_07,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_07\\new_banishingpoint_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_banishingpoint_11,
            strPath: "mineffect\\new_banishingpoint\\new_banishingpoint_11\\new_banishingpoint_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_12,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_12\\new_cannonspear_12.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_01,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_01\\new_cannonspear_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_03,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_03\\new_cannonspear_03.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_05,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_05\\new_cannonspear_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_06,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_06\\new_cannonspear_06.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_07,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_07\\new_cannonspear_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_09,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_09\\new_cannonspear_09.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_11,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_11\\new_cannonspear_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_cannon_spear_bottom,
            strPath: "mineffect\\new_cannonspear\\new_cannonspear_bottom\\new_cannonspear_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 10, names: ["effect\\EF_hit2.wav"]), TimedSound(tick: 20, names: ["effect\\EF_hit4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_bomb,
            strPath: "mineffect\\new_dragonbreath\\new_dragonbreath_fire_bomb\\new_dragonbreath_fire_bomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_01,
            strPath: "mineffect\\new_dragonbreath\\new_dragonbreath_fire_01\\new_dragonbreath_fire_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_05,
            strPath: "mineffect\\new_dragonbreath\\new_dragonbreath_fire_05\\new_dragonbreath_fire_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_07,
            strPath: "mineffect\\new_dragonbreath\\new_dragonbreath_fire_07\\new_dragonbreath_fire_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_11,
            strPath: "mineffect\\new_dragonbreath\\new_dragonbreath_fire_11\\new_dragonbreath_fire_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_water_bomb,
            strPath: "mineffect\\new_dragonbreath_water\\new_dragonbreath_water_bomb\\new_dragonbreath_water_bomb.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_water_01,
            strPath: "mineffect\\new_dragonbreath_water\\new_dragonbreath_water_01\\new_dragonbreath_water_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_water_05,
            strPath: "mineffect\\new_dragonbreath_water\\new_dragonbreath_water_05\\new_dragonbreath_water_05.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_water_07,
            strPath: "mineffect\\new_dragonbreath_water\\new_dragonbreath_water_07\\new_dragonbreath_water_07.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_dragonbreath_water_11,
            strPath: "mineffect\\new_dragonbreath_water\\new_dragonbreath_water_11\\new_dragonbreath_water_11.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_tigercannon,
            strPath: "mineffect\\new_tigercannon\\new_tigercannon.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_severerainstorm_cast,
            strPath: "mineffect\\new_severerainstorm\\new_severerainstorm_cast\\new_severerainstorm_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet,
            strPath: "mineffect\\new_comet\\new_comet\\new_comet.str",
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\g크레이지위드.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet_bottom,
            strPath: "mineffect\\new_comet\\new_comet_bottom\\new_comet_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet_cast_bottom,
            strPath: "mineffect\\new_comet\\new_comet_cast_bottom\\new_comet_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet_sub_exp,
            strPath: "mineffect\\new_comet\\new_comet_sub_explosion\\new_comet_sub_explosion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet_sub_exp_bottom,
            strPath: "mineffect\\new_comet\\new_comet_sub_explosion_bottom\\new_comet_sub_explosion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_comet_cast,
            strPath: "mineffect\\new_comet\\new_comet_cast\\new_comet_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_jackfrost_00,
            strPath: "mineffect\\new_jackfrost\\new_jackfrost_ice\\new_jackfrost_00.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_jackfrost_01,
            strPath: "mineffect\\new_jackfrost\\new_jackfrost_ice\\new_jackfrost_01.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_jackfrost_02,
            strPath: "mineffect\\new_jackfrost\\new_jackfrost_ice\\new_jackfrost_02.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_jackfrost_cast,
            strPath: "mineffect\\new_jackfrost\\new_jackfrost_cast\\new_jackfrost_cast.str",
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mineffect_jackfrost_rune,
            strPath: "mineffect\\new_jackfrost\\new_jackfrost_magicrune\\new_jackfrost_frost.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_poisonsmoke_1,
            strPath: "new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_1.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_poisonsmoke_2,
            strPath: "new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_2.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_poisonsmoke_cast,
            strPath: "new_poisonsmoke\\new_poisonsmoke_cast\\new_poisonsmoke_cast.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fearbreeze,
            strPath: "new_fearbreeze\\new_fearbreeze.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_Bash.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_hellinferno,
            strPath: "new_hellInferno\\new_hellInferno\\new_hellInferno.str",
            sounds: [TimedSound(tick: 0, names: ["hell_in.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_hellinferno_bottom,
            strPath: "new_hellInferno\\new_hellInferno_bottom\\new_hellInferno_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_hellinferno_cast_bottom,
            strPath: "new_hellInferno\\new_hellInferno_cast_bottom\\new_hellInferno_cast_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_hellinferno_sub,
            strPath: "new_hellInferno\\new_hellInferno_sub\\new_hellInferno_sub.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_hellinferno_sub_bottom,
            strPath: "new_hellInferno\\new_hellInferno_sub_bottom\\new_hellInferno_sub_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_clearance,
            strPath: "new_clearence\\new_clearence\\new_clearence.str",
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\샤프슈팅.wav")]), TimedSound(tick: 0, names: [K2L("effect\\흡기.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_clearance_bottom,
            strPath: "new_clearence\\new_clearence_bottom\\new_clearence_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_clearance_cast,
            strPath: "new_clearence\\new_clearence_cast\\new_clearence_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_varetyrspear,
            strPath: "new_varetyrspear\\new_varetyrspear\\new_varetyrspear.str",
            sounds: [TimedSound(tick: 3, names: [K2L("effect\\프레셔.wav")]), TimedSound(tick: 22, names: [K2L("effect\\S바레티르스피어.wav")])],
            cameraShakeTicks: [22]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_varetyrspear_bottom,
            strPath: "new_varetyrspear\\new_varetyrspear_bottom\\new_varetyrspear_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_varetyrspear_cast,
            strPath: "new_varetyrspear\\new_varetyrspear_cast\\new_varetyrspear_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_varetyrspear_cast_bottom,
            strPath: "new_varetyrspear\\new_varetyrspear_cast_bottom\\new_varetyrspear_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossimpact,
            strPath: "new_crossimpact\\new_crossimpact\\new_crossimpact.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_StoneCurse.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_crossimpact_target,
            strPath: "new_crossimpact\\new_crossimpact_target\\new_crossimpact_target.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fallenempire,
            strPath: "new_fallenempire\\new_fallenempire\\new_fallenempire.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fallenempire_bottom,
            strPath: "new_fallenempire\\new_fallenempire_bottom\\new_fallenempire_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_fallenempire_hit,
            strPath: "new_fallenempire\\new_fallenempire_hit\\new_fallenempire_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_gateofhell_cast,
            strPath: "new_gateofhell\\new_gateofhell_cast\\new_gateofhell_cast.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_gateofhell_target,
            strPath: "new_gateofhell\\new_gateofhell_target\\new_gateofhell_target.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_howlingoflion,
            strPath: "new_howlingoflion\\new_howlingoflion\\new_howlingoflion.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_howlingoflion_bottom,
            strPath: "new_howlingoflion\\new_howlingoflion_bottom\\new_howlingoflion_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_howlingoflion_cast,
            strPath: "new_howlingoflion\\new_howlingoflion_cast\\new_howlingoflion_cast.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_howlingoflion_cast_bottom,
            strPath: "new_howlingoflion\\new_howlingoflion_cast_bottom\\new_howlingoflion_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_howlingoflion_hit,
            strPath: "new_howlingoflion\\new_howlingoflion_hit\\new_howlingoflion_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_metallicsound,
            strPath: "new_metalicsound\\new_metalicsound\\new_metalicsound.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_metallicsound_bottom,
            strPath: "new_metalicsound\\new_metalicsound_bottom\\new_metalicsound_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_metallicsound_hit,
            strPath: "new_metalicsound\\new_metalicsound_hit\\new_metalicsound_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reproduce,
            strPath: "new_reproduce\\new_reproduce\\new_reproduce.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reproduce_bottom,
            strPath: "new_reproduce\\new_reproduce_bottom\\new_reproduce_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_cast,
            strPath: "new_soulexpansion\\new_soulexpansion_cast\\new_soulexpansion_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_cast_bottom,
            strPath: "new_soulexpansion\\new_soulexpansion_cast_bottom\\new_soulexpansion_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_loop,
            strPath: "new_soulexpansion\\new_soulexpansion_loop\\new_soulexpansion_loop.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_loop_bottom,
            strPath: "new_soulexpansion\\new_soulexpansion_loop_bottom\\new_soulexpansion_loop_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_hit,
            strPath: "new_soulexpansion\\new_soulexpansion_hit\\new_soulexpansion_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soulexpansion_hit_bottom,
            strPath: "new_soulexpansion\\new_soulexpansion_hit_bottom\\new_soulexpansion_hit_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: [K2L("effect\\매직 크래쉬.wav")])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reverberation_hit,
            strPath: "new_reverberation\\new_reverberation_hit\\new_reverberation_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aromaoil,
            strPath: "new_aromaoil\\new_aromaoil\\new_aromaoil_combine.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aromaoil_bottom,
            strPath: "new_aromaoil\\new_aromaoil_bottom\\new_aromaoil_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_bathfoam,
            strPath: "new_bathfoam\\new_bathfoam\\new_bathfoam.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_bathfoam_bottom,
            strPath: "new_bathfoam\\new_bathfoam_bottom\\new_bathfoam_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_core_reuse,
            strPath: "tetravortex\\tetra_ball_00_core\\tetra_ball_00_core.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grade_enchant_intro,
            strPath: "grade_enchant\\new_intro\\new_intro.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grade_enchant_success,
            strPath: "grade_enchant\\new_success\\new_success.str",
            renderMode: .screen
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grade_enchant_failed,
            strPath: "grade_enchant\\new_failed\\new_failed.str",
            renderMode: .screen,
            cameraShakeTicks: [180]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_blue_wave_1,
            strPath: "blue_wave\\ef_mon_electric.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_blue_wave_2,
            strPath: "blue_wave\\ef_mon_electric2.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_blue_wave_3,
            strPath: "blue_wave\\ef_mon_electric3.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_red_wave_1,
            strPath: "red_wave\\ef_mon_explodngwave.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_red_wave_2,
            strPath: "red_wave\\ef_mon_explodngwave2.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_red_wave_3,
            strPath: "red_wave\\ef_mon_explodngwave3.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_wallofthorn_cast,
            strPath: "new_wallofthorn\\new_wallofthorn_cast\\new_wallofthorn_cast.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_wallofthorn_cast_bottom,
            strPath: "new_wallofthorn\\new_wallofthorn_cast_bottom\\new_wallofthorn_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthgrave_bottom,
            strPath: "new_earthgrave\\new_earthgrave_bottom\\new_earthgrave_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthgrave_hit,
            strPath: "new_earthgrave\\new_earthgrave_hit\\new_earthgrave_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_ignitionbreak,
            strPath: "new_ignitionbreak\\new_ignitionbreak\\new_ignitionbreak.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_ignitionbreak_bottom,
            strPath: "new_ignitionbreak\\new_ignitionbreak_bottom\\new_ignitionbreak_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_ignitionbreak_cast,
            strPath: "new_ignitionbreak\\new_ignitionbreak_cast\\new_ignitionbreak_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_cast,
            strPath: "new_judex\\new_judex_cast\\new_judex_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_cast_bottom,
            strPath: "new_judex\\new_judex_cast_bottom\\new_judex_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_cast_loop,
            strPath: "new_judex\\new_judex_cast_loop\\new_judex_cast_loop.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_cast_loop_bottom,
            strPath: "new_judex\\new_judex_cast_loop_bottom\\new_judex_cast_loop_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_target,
            strPath: "new_judex\\new_judex_target\\new_judex_target.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_target_bottom,
            strPath: "new_judex\\new_judex_target_bottom\\new_judex_target_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_light,
            strPath: "new_judex\\new_judex_light\\new_judex_light.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_light_bottom,
            strPath: "new_judex\\new_judex_light_bottom\\new_judex_light_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chainlightning_cast,
            strPath: "new_chainlightning\\new_chainlightning_cast\\new_chainlightning_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chainlightning_cast_bottom,
            strPath: "new_chainlightning\\new_chainlightning_cast_bottom\\new_chainlightning_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chainlightning_lockon,
            strPath: "new_chainlightning\\new_chainlightning_lockon\\new_chainlightning_lockon.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chainlightning_target,
            strPath: "new_chainlightning\\new_chainlightning_target\\new_chainlightning_target.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["chainlight.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_mandragora,
            strPath: "new_mandragora\\new_mandragora\\new_mandragora.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_mandragora_bottom,
            strPath: "new_mandragora\\new_mandragora_bottom\\new_mandragora_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_mandragora_cast,
            strPath: "new_mandragora\\new_mandragora_cast\\new_mandragora_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soundofdestruction_cast,
            strPath: "new_soundofdestruction\\new_soundofdestruction_cast\\new_soundofdestruction_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soundofdestruction_cast_bottom,
            strPath: "new_soundofdestruction\\new_soundofdestruction_cast_bottom\\new_soundofdestruction_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_soundofdestruction_target,
            strPath: "new_soundofdestruction\\new_soundofdestruction_target\\new_soundofdestruction_target.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\priest_lexaeterna.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_01,
            strPath: "new_aimedbolt\\new_aimedbolt_attack_01clock\\new_aimedbolt_attack_01clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_05,
            strPath: "new_aimedbolt\\new_aimedbolt_attack_05clock\\new_aimedbolt_attack_05clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_07,
            strPath: "new_aimedbolt\\new_aimedbolt_attack_07clock\\new_aimedbolt_attack_07clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_11,
            strPath: "new_aimedbolt\\new_aimedbolt_attack_11clock\\new_aimedbolt_attack_11clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_cast_bottom,
            strPath: "new_aimedbolt\\new_aimedbolt_cast_bottom\\new_aimedbolt_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_end,
            strPath: "new_aimedbolt\\new_aimedbolt_target_end\\new_aimedbolt_end.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_aimedbolt_target_loop,
            strPath: "new_aimedbolt\\new_aimedbolt_target_loop\\new_aimedbolt_target_loop.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_unlimit,
            strPath: "new_unlimit\\new_unlimit\\new_unlimit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_unlimit_bottom,
            strPath: "new_unlimit\\new_unlimit_bottom\\new_unlimit_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_epiclesis,
            strPath: "new_epiclesis\\new_epiclesis_combine\\new_epiclesis_combine.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3,
            sounds: [TimedSound(tick: 30, names: ["effect\\EF_GlassWall.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axeboomerang_cast,
            strPath: "new_axeboomerang\\new_axeboomerang_cast\\new_axeboomerang_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axeboomerang_cast_bottom,
            strPath: "new_axeboomerang\\new_axeboomerang_cast_bottom\\new_axeboomerang_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axeboomerang_hit,
            strPath: "new_axeboomerang\\new_axeboomerang_hit\\new_axeboomerang_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hackandslash,
            strPath: "hackandslash\\hackandslash\\hackandslash.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hackandslash_bottom,
            strPath: "hackandslash\\hackandslash_bottom\\hackandslash_bottom.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_HACKANDSLASHER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hackandslash_hit,
            strPath: "hackandslash\\hackandslash_hit\\hackandslash_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_spellfist_fire,
            strPath: "new_spellfist\\new_spellfist_fire\\new_spellfist_fire.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_spellfist_fire_bottom,
            strPath: "new_spellfist\\new_spellfist_fire_bottom\\new_spellfist_fire_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_spellfist_water,
            strPath: "new_spellfist\\new_spellfist_water\\new_spellfist_water.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_spellfist_water_bottom,
            strPath: "new_spellfist\\new_spellfist_water_bottom\\new_spellfist_water_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_spellfist_wind,
            strPath: "new_spellfist\\new_spellfist_wind\\new_spellfist_wind.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stormslash_1,
            strPath: "stormslash\\stormslash\\stormslash_1.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stormslash_2,
            strPath: "stormslash\\stormslash\\stormslash_2.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 15, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stormslash_3,
            strPath: "stormslash\\stormslash\\stormslash_3.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 15, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 30, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stormslash_4,
            strPath: "stormslash\\stormslash\\stormslash_4.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 15, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 30, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 45, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stormslash_5,
            strPath: "stormslash\\stormslash\\stormslash_5.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 15, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 30, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 45, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"]), TimedSound(tick: 60, names: ["effect\\DK_STORMSLASH1.wav", "effect\\DK_STORMSLASH2.wav", "effect\\DK_STORMSLASH3.wav", "effect\\DK_STORMSLASH4.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cartboost,
            strPath: "new_cartboost\\new_cartboost\\new_cartboost.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_cartboost_bottom,
            strPath: "new_cartboost\\new_cartboost_bottom\\new_cartboost_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_01,
            strPath: "new_overbrand\\new_overbrand_01_clock\\new_overbrand_01_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_03,
            strPath: "new_overbrand\\new_overbrand_03_clock\\new_overbrand_03_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_05,
            strPath: "new_overbrand\\new_overbrand_05_clock\\new_overbrand_05_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_06,
            strPath: "new_overbrand\\new_overbrand_06_clock\\new_overbrand_06_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_07,
            strPath: "new_overbrand\\new_overbrand_07_clock\\new_overbrand_07_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_09,
            strPath: "new_overbrand\\new_overbrand_09_clock\\new_overbrand_09_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_11,
            strPath: "new_overbrand\\new_overbrand_11_clock\\new_overbrand_11_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_12,
            strPath: "new_overbrand\\new_overbrand_12_clock\\new_overbrand_12_clock.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_cast,
            strPath: "new_overbrand\\new_overbrand_cast\\new_overbrand_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_cast_bottom,
            strPath: "new_overbrand\\new_overbrand_cast_bottom\\new_overbrand_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_overbrand_hit,
            strPath: "new_overbrand\\new_overbrand_hit\\new_overbrand_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_windcutter,
            strPath: "new_windcutter\\new_windcutter\\new_windcutter.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\wl_siennaexecrate.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_windcutter_bottom_01,
            strPath: "new_windcutter\\new_windcutter_bottom_01clock\\new_windcutter_bottom_01clock.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_windcutter_bottom_05,
            strPath: "new_windcutter\\new_windcutter_bottom_05clock\\new_windcutter_bottom_05clock.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_windcutter_target,
            strPath: "new_windcutter\\new_windcutter_target\\new_windcutter_target.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_servantweapon_hit,
            strPath: "new_servantweapon\\new_servantweapon_hit\\new_servantweapon_hit.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_servantweapon_hit_bottom,
            strPath: "new_servantweapon\\new_servantweapon_hit_bottom\\new_servantweapon_hit_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_servantweapon_shoot_bottom,
            strPath: "new_servantweapon\\new_servantweapon_shoot_bottom\\new_servantweapon_shoot_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_powerswing_01,
            strPath: "new_powerswing\\new_powerwing_01_clock\\new_powerwing_01_clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_powerswing_05,
            strPath: "new_powerswing\\new_powerwing_05_clock\\new_powerwing_05_clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_powerswing_07,
            strPath: "new_powerswing\\new_powerwing_07_clock\\new_powerwing_07_clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_powerswing_11,
            strPath: "new_powerswing\\new_powerwing_11_clock\\new_powerwing_11_clock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_powerswing_bottom,
            strPath: "new_powerswing\\new_powerswing_bottom\\new_powerswing_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 15, names: ["effect\\wizard_fire_pillar_b.wav"])],
            cameraShakeTicks: [20]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_vulcanarm,
            strPath: "new_vulcanarm\\new_vulcanarm\\new_vulcanarm.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_vulcanarm_bottom,
            strPath: "new_vulcanarm\\new_vulcanarm_bottom\\new_vulcanarm_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_vulcanarm_shothole,
            strPath: "new_vulcanarm\\new_vulcanarm_shothole\\new_vulcanarm_shothole.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthdrive,
            strPath: "new_earthdrive\\new_earthdrive\\new_earthdrive.str",
            sounds: [TimedSound(tick: 20, names: ["effect\\wizard_earthspike.wav"])],
            cameraShakeTicks: [20]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthdrive_bottom,
            strPath: "new_earthdrive\\new_earthdrive_bottom\\new_earthdrive_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_earthdrive_target,
            strPath: "new_earthdrive\\new_earthdrive_target\\new_earthdrive_target.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_sign,
            strPath: "servant_sign\\servant_sign\\servant_sign.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_sign_down,
            strPath: "servant_sign\\servant_sign_down\\servant_sign_down.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_sign_down_bottom,
            strPath: "servant_sign\\servant_sign_down_bottom\\servant_sign_down_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 40, names: ["effect\\DK_SERVANT_W_SIGN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_phantom_down,
            strPath: "servant_phantom\\servant_phantom_down\\servant_phantom_down.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_phantom_hit,
            strPath: "servant_phantom\\servant_phantom_hit\\servant_phantom_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_SERVANT_W_PHANTOM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_phantom_hit_bottom,
            strPath: "servant_phantom\\servant_phantom_hit_bottom\\servant_phantom_hit_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_phantom_sub,
            strPath: "servant_phantom\\servant_phantom_sub\\servant_phantom_sub.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_phantom_sub_bottom,
            strPath: "servant_phantom\\servant_phantom_sub_bottom\\servant_phantom_sub_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_demolition_collect,
            strPath: "servant_demolition\\servant_demolition_collect\\servant_demolition_collect.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_demolition_hit,
            strPath: "servant_demolition\\servant_demolition_hit\\servant_demolition_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_SERVANT_W_DEMOL.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_demolition_leftdown,
            strPath: "servant_demolition\\servant_demolition_leftdown\\servant_demolition_leftdown.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_demolition_rightdown,
            strPath: "servant_demolition\\servant_demolition_rightdown\\servant_demolition_rightdown.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura,
            strPath: "dragonnic_ora\\dragonnic_ora\\dragonnic_ora.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_DRAGONIC_AURA1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura_bottom,
            strPath: "dragonnic_ora\\dragonnic_ora_bottom\\dragonnic_ora_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura_hit,
            strPath: "dragonnic_ora\\dragonnic_ora_hit\\dragonnic_ora_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 1, names: ["effect\\DK_DRAGONIC_AURA2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura_hit_bottom,
            strPath: "dragonnic_ora\\dragonnic_ora_hit_bottom\\dragonnic_ora_hit_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura_buff,
            strPath: "dragonnic_ora\\dragonnic_ora_buff\\dragonnic_ora_buff.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dragonic_aura_buff_bottom,
            strPath: "dragonnic_ora\\dragonnic_ora_buff_bottom\\dragonnic_ora_buff_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_madness_crusher,
            strPath: "madness_crusher\\madness_crusher\\madness_crusher.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 1, names: ["effect\\DK_MADNESS_CRUSHER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_madness_crusher_bottom,
            strPath: "madness_crusher\\madness_crusher_bottom\\madness_crusher_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_autoshadowspell,
            strPath: "new_autoshadowspell\\new_autoshadowspell\\new_autoshadowspell.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_autoshadowspell_bottom,
            strPath: "new_autoshadowspell\\new_autoshadowspell_bottom\\new_autoshadowspell_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane,
            strPath: "destructive_hurricane\\destructive_hurricane\\destructive_hurricane.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_DESTRUCTIVE_HURRICANE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_bottom,
            strPath: "destructive_hurricane\\destructive_hurricane_bottom\\destructive_hurricane_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_cast,
            strPath: "destructive_hurricane\\destructive_hurricane_cast\\destructive_hurricane_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_cast_bottom,
            strPath: "destructive_hurricane\\destructive_hurricane_cast_bottom\\destructive_hurricane_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_climax,
            strPath: "destructive_hurricane\\destructive_hurricane_climax\\destructive_hurricane_climax.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_hit,
            strPath: "destructive_hurricane\\destructive_hurricane_hit\\destructive_hurricane_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deadly_projection_cast,
            strPath: "deadly_projection\\deadly_projection_cast\\deadly_projection_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deadly_projection_cast_bottom,
            strPath: "deadly_projection\\deadly_projection_cast_bottom\\deadly_projection_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deadly_projection_hit,
            strPath: "deadly_projection\\deadly_projection_hit\\deadly_projection_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_DEADLY_PROJECTION.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deadly_projection,
            strPath: "deadly_projection\\efst_deadly_defeasance\\efst_deadly_defeasance.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_vc_strike_cast,
            strPath: "soul_vc_strike\\soul_vc_strike_cast\\soul_vc_strike_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_vc_strike_cast_bottom,
            strPath: "soul_vc_strike\\soul_vc_strike_cast_bottom\\soul_vc_strike_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_soul_vc_strike_hit,
            strPath: "soul_vc_strike\\soul_vc_strike_hit\\soul_vc_strike_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rockdown,
            strPath: "rockdown\\rockdown\\rockdown.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_ROCK_DOWN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rockdown_bottom,
            strPath: "rockdown\\rockdown_bottom\\rockdown_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rockdown_cast,
            strPath: "rockdown\\rockdown_cast\\rockdown_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rockdown_cast_bottom,
            strPath: "rockdown\\rockdown_cast_bottom\\rockdown_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rockdown_hit,
            strPath: "rockdown\\rockdown_hit\\rockdown_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_vigor_cast,
            strPath: "vigor\\vigor_cast\\vigor_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_VIGOR.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_vigor_buff,
            strPath: "vigor\\vigor_buff\\vigor_buff.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rain_of_crystal,
            strPath: "rain_of_crystal\\rain_of_crystal_casting\\rain_of_crystal_casting.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rain_of_crystal_bottom,
            strPath: "rain_of_crystal\\rain_of_crystal_casting_bottom\\rain_of_crystal_casting_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crimson_arrow_cast,
            strPath: "crimsonarrow\\crimsonarrow_cast\\crimsonarrow_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crimson_arrow_cast_bottom,
            strPath: "crimsonarrow\\crimsonarrow_cast_bottom\\crimsonarrow_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crimson_arrow_hit,
            strPath: "crimsonarrow\\crimsonarrow_hit\\crimsonarrow_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_violent_quake_cast,
            strPath: "violentquake\\violentquake_cast\\violentquake_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_violent_quake_cast_bottom,
            strPath: "violentquake\\violentquake_cast_bottom\\violentquake_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_violent_quake_hit,
            strPath: "violentquake\\violentquake_hit\\violentquake_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chargingpierce_cast,
            strPath: "new_chargingpierce\\new_chargingpierce_cast\\new_chargingpierce_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chargingpierce_cast_bottom,
            strPath: "new_chargingpierce\\new_chargingpierce_cast_bottom\\new_chargingpierce_cast_bottom.str",
            renderMode: .ground
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_chargingpierce_hit,
            strPath: "new_chargingpierce\\new_chargingpierce_hit\\new_chargingpierce_hit.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\DK_CHARGINGPIERCE1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_astral_strike_cast,
            strPath: "astralstrike\\astralstrike_cast\\astralstrike_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_astral_strike_cast_bottom,
            strPath: "astralstrike\\astralstrike_cast_bottom\\astralstrike_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mystery_illusion,
            strPath: "mystery_illusion\\mystery_illusion\\mystery_illusion.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mystery_illusion_bottom,
            strPath: "mystery_illusion\\mystery_illusion_bottom\\mystery_illusion_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_MYSTERY_ILLUSION.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mystery_illusion_cast,
            strPath: "mystery_illusion\\mystery_illusion_cast\\mystery_illusion_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mystery_illusion_cast_bottom,
            strPath: "mystery_illusion\\mystery_illusion_cast_bottom\\mystery_illusion_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mystery_illusion_hit,
            strPath: "mystery_illusion\\mystery_illusion_hit\\mystery_illusion_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tornado_storm,
            strPath: "tornadostorm\\tornadostorm\\tornadostorm.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_TORNADO_STORM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tornado_storm_bottom,
            strPath: "tornadostorm\\tornadostorm_bottom\\tornadostorm_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tornado_storm_cast,
            strPath: "tornadostorm\\tornadostorm_cast\\tornadostorm_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tornado_storm_cast_bottom,
            strPath: "tornadostorm\\tornadostorm_cast_bottom\\tornadostorm_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tornado_storm_hit,
            strPath: "tornadostorm\\tornadostorm_hit\\tornadostorm_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash,
            strPath: "frozen_slash\\frozen_slash\\frozen_slash.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_FROZEN_SLASH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_cast,
            strPath: "frozen_slash\\frozen_slash_casting\\frozen_slash_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_cast_bottom,
            strPath: "frozen_slash\\frozen_slash_casting_bottom\\frozen_slash_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_hit,
            strPath: "frozen_slash\\frozen_slash_hit\\frozen_slash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_01,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_01.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_02,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_02.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_03,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_03.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_04,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_04.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_05,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_05.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_06,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_06.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_07,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_07.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frozen_slash_ice_08,
            strPath: "frozen_slash\\frozen_slash_ice\\frozen_slash_ice_08.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_violent_quake_bottom,
            strPath: "violentquake\\violentquake_bottom\\violentquake_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_all_bloom,
            strPath: "allbloom\\allbloom\\allbloom.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_all_bloom_bottom,
            strPath: "allbloom\\allbloom_bottom\\allbloom_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_all_bloom_cast,
            strPath: "allbloom\\allbloom_cast\\allbloom_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_all_bloom_cast_bottom,
            strPath: "allbloom\\allbloom_cast_bottom\\allbloom_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_all_bloom_hit,
            strPath: "allbloom\\allbloom_hit\\allbloom_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_climax_light,
            strPath: "climax\\climax_light\\climax_light.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_climax_cast,
            strPath: "climax\\climax_cast\\climax_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_climax_cast_loop,
            strPath: "climax\\climax_cast_loop\\climax_cast_loop.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_floral_flare_road_cast,
            strPath: "froral_flareroad\\froral_flareroad_cast\\froral_flareroad_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_floral_flare_road_cast_bottom,
            strPath: "froral_flareroad\\froral_flareroad_cast_bottom\\froral_flareroad_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_floral_flare_road_hit,
            strPath: "froral_flareroad\\froral_flareroad_hit\\froral_flareroad_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mediale_votum,
            strPath: "medialevotum\\medialevotum\\medialevotum.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_MEDIALE_VOTUM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mediale_votum_cast,
            strPath: "medialevotum\\medialevotum_cast\\medialevotum_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mediale_votum_loop,
            strPath: "medialevotum\\medialevotum_loop\\medialevotum_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_argutus_vita,
            strPath: "argutusvita\\argutusvita\\argutusvita.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_ARGUTUS_VITA.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_argutus_vita_cast,
            strPath: "argutusvita\\argutusvita_cast\\argutusvita_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_argutus_telum,
            strPath: "argutustelum\\argutustelum\\argutustelum.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_ARGUTUS_VITA.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_argutus_telum_cast,
            strPath: "argutustelum\\argutustelum_cast\\argutustelum_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_presens_acies,
            strPath: "presensacies\\presensacies\\presensacies.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_PRESENS_ACIES.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_presens_acies_cast,
            strPath: "presensacies\\presensacies_cast\\presensacies_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_machine,
            strPath: "new_d_machine\\new_d_machine\\new_d_machine.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            ignoresRidingHeight: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_machine_cast,
            strPath: "new_d_machine\\new_d_machine_cast\\new_d_machine_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_machine_cast_bottom,
            strPath: "new_d_machine\\new_d_machine_cast_bottom\\new_d_machine_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_machine_start,
            strPath: "new_d_machine\\new_d_machine_start_end\\new_d_machine_start.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\MT_D_MACHINE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_machine_end,
            strPath: "new_d_machine\\new_d_machine_start_end\\new_d_machine_end.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_arbitrium_cast,
            strPath: "arbitrium\\arbitrium_cast\\arbitrium_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_arbitrium_cast_bottom,
            strPath: "arbitrium\\arbitrium_cast_bottom\\arbitrium_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_arbitrium,
            strPath: "arbitrium\\arbitrium\\arbitrium.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_arbitrium_bottom,
            strPath: "arbitrium\\arbitrium_bottom\\arbitrium_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_ARBITRIUM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_arbitrium_hit,
            strPath: "arbitrium\\arbitrium_hit\\arbitrium_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dancing_knife_cast,
            strPath: "dancing_knife\\dancing_knife_cast\\dancing_knife_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_dancing_knife_cast_bottom,
            strPath: "dancing_knife\\dancing_knife_cast_bottom\\dancing_knife_cast_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_dagger_hit_1830,
            strPath: "abyss_dagger\\abyss_dagger_hit\\abyss_dagger_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio_cast,
            strPath: "new_reparatio\\new_reparatio_cast\\new_reparatio_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio_cast_bottom,
            strPath: "new_reparatio\\new_reparatio_cast_bottom\\new_reparatio_cast_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio,
            strPath: "new_reparatio\\new_reparatio\\new_reparatio.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio_bottom,
            strPath: "new_reparatio\\new_reparatio_bottom\\new_reparatio_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio_target,
            strPath: "new_reparatio\\new_reparatio_target\\new_reparatio_target.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_reparatio_target_bottom,
            strPath: "new_reparatio\\new_reparatio_target_bottom\\new_reparatio_target_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_eternal_slash_hit_1,
            strPath: "eternal_slash\\eternal_slash_hit\\eternal_slash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_a_machine_cast,
            strPath: "a_machine\\a_machine_cast\\a_machine_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_a_machine_hit,
            strPath: "a_machine\\a_machine_hit\\a_machine_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_effligo,
            strPath: "effligo\\effligo\\effligo.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_effligo_bottom,
            strPath: "effligo\\effligo_bottom\\effligo_bottom.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_EFFLIGO.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_effligo_hit,
            strPath: "effligo\\effligo_hit\\effligo_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_competentia,
            strPath: "competentia\\competentia\\competentia.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_competentia_bottom,
            strPath: "competentia\\competentia_bottom\\competentia_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_COMPETENTIA.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_competentia_loop,
            strPath: "competentia\\competentia_loop\\competentia_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_competentia_loop_bottom,
            strPath: "competentia\\competentia_loop_bottom\\competentia_loop_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact,
            strPath: "crystal_impact\\crystal_impact\\crystal_impact.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_CRYSTAL_IMPACT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_bottom,
            strPath: "crystal_impact\\crystal_impact_bottom\\crystal_impact_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_cast,
            strPath: "crystal_impact\\crystal_impact_cast\\crystal_impact_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_cast_bottom,
            strPath: "crystal_impact\\crystal_impact_cast_bottom\\crystal_impact_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_hit,
            strPath: "crystal_impact\\crystal_impact_hit\\crystal_impact_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_buff,
            strPath: "crystal_impact\\crystal_impact_buff\\crystal_impact_buff.str",
            isAttachedToHead: true,
            headOffsetYDelta: 4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_religio,
            strPath: "religio\\religio\\religio.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_RELIGIO.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_religio_cast,
            strPath: "religio\\religio_cast\\religio_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_enchanting_shadow,
            strPath: "enchanting_shadow\\enchanting_shadow\\new_enchanting_shadow.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_enchanting_shadow_bottom,
            strPath: "enchanting_shadow\\enchanting_shadow_bottom\\new_enchanting_shadow_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fatal_shadow_crow,
            strPath: "fatal_shadow_crow\\fatal_shadow_crow\\fatal_shadow_crow.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\SHC_FATAL_SHADOW_CROW.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fatal_shadow_crow_bottom,
            strPath: "fatal_shadow_crow\\fatal_shadow_crow_bottom\\fatal_shadow_crow_bottom.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_fatal_shadow_crow_hit,
            strPath: "fatal_shadow_crow\\fatal_shadow_crow_hit\\fatal_shadow_crow_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_shadow_exceed_cast,
            strPath: "shadow_exceed\\shadow_exceed_cast\\shadow_exceed_cast.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deep_blind_trap_cast,
            strPath: "deepblindtrap\\deepblindtrap_cast\\deepblindtrap_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deep_blind_trap,
            strPath: "deepblindtrap\\deepblindtrap\\deepblindtrap.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_TRAP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deep_blind_trap_hit,
            strPath: "deepblindtrap\\deepblindtrap_hit\\deepblindtrap_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_DEEP_BLIND_TRAP_HIT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_swift_trap_cast,
            strPath: "swifttrap\\swifttrap_cast\\swifttrap_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_swift_trap,
            strPath: "swifttrap\\swifttrap\\swifttrap.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_TRAP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_swift_trap_hit,
            strPath: "swifttrap\\swifttrap_hit\\swifttrap_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_SWIFT_TRAP_HIT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_solid_trap_cast,
            strPath: "solidtrap\\solidtrap_cast\\solidtrap_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_solid_trap_cast_bottom,
            strPath: "solidtrap\\solidtrap_cast_bottom\\solidtrap_cast_bottom.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_solid_trap,
            strPath: "solidtrap\\solidtrap\\solidtrap.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_TRAP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_solid_trap_hit,
            strPath: "solidtrap\\solidtrap_hit\\solidtrap_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_SOLID_TRAP_HIT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rush_quake,
            strPath: "new_rush_quake\\new_rush_quake\\new_rush_quake.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rush_quake_bottom,
            strPath: "new_rush_quake\\new_rush_quake_bottom\\new_rush_quake.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 15, names: ["effect\\wizard_fire_pillar_b.wav"])],
            cameraShakeTicks: [20]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_rush_quake_hit,
            strPath: "new_rush_quake\\new_rush_quake_hit\\new_rush_quake_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5,
            sounds: [TimedSound(tick: 0, names: ["effect\\MT_RUSH_QUAKE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_benedictum,
            strPath: "benedictum\\benedictum\\benedictum.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_BENEDICTUM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_benedictum_cast,
            strPath: "benedictum\\benedictum_cast\\benedictum_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_benedictum_cast_bottom,
            strPath: "benedictum\\benedictum_cast_bottom\\benedictum_cast_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stratum_tremor_cast,
            strPath: "strantumtremor\\strantumtremor_cast\\strantumtremor_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stratum_tremor_cast_bottom,
            strPath: "strantumtremor\\strantumtremor_cast_bottom\\strantumtremor_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stratum_tremor_hit,
            strPath: "strantumtremor\\strantumtremor_hit\\strantumtremor_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stratum_tremor,
            strPath: "strantumtremor\\strantumtremor\\strantumtremor.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            levelScales: [1: 0.7, 2: 1.25, 3: 1.25, 4: 1.25, 5: 1.25],
            sounds: [TimedSound(tick: 0, names: ["effect\\AG_STRANTUM_TREMOR1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_stratum_tremor_bottom,
            strPath: "strantumtremor\\strantumtremor_bottom\\strantumtremor_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8,
            levelScales: [1: 0.7, 2: 1.25, 3: 1.25, 4: 1.25, 5: 1.25]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_impact_crater,
            strPath: "impact_crater\\impact_crater\\impact_crater.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_impact_crater_bottom,
            strPath: "impact_crater\\impact_crater_bottom\\impact_crater_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_impact_crater_hit,
            strPath: "impact_crater\\impact_crater_hit\\impact_crater_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\SHC_IMPACT_CRATER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wind_sign,
            strPath: "windsign\\windsign\\windsign.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_WIND_SIGN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wind_sign_loop,
            strPath: "windsign\\windsign_loop\\windsign_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_mother_cast,
            strPath: "new_abr_mother\\new_abr_mother_cast\\new_abr_mother_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_mother_01,
            strPath: "new_abr_mother\\new_abr_mother_01\\new_abr_mother_01.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\MT_ABR_NET_REPAIR.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_mother_02,
            strPath: "new_abr_mother\\new_abr_mother_02\\new_abr_mother_02.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\MT_ABR_NET_SUPPORT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hawk_rush,
            strPath: "hawkrush\\hawkrush\\hawkrush.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_HAWKRUSH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_infinity,
            strPath: "new_abr_infinity\\new_abr_infinity\\new_abr_infinity.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_infinity_bottom,
            strPath: "new_abr_infinity\\new_abr_infinity_bottom\\new_abr_infinity_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_infinity_cast,
            strPath: "new_abr_infinity\\new_abr_infinity_cast\\new_abr_infinity_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abr_infinity_hit,
            strPath: "new_abr_infinity\\new_abr_infinity_hit\\new_abr_infinity_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_eternal_slash_hit_2,
            strPath: "eternal_slash\\eternal_slash_hit\\eternal_slash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            sounds: [TimedSound(tick: 0, names: ["effect\\SHC_ETERNAL_SLASH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_cannon,
            strPath: "new_d_cannon\\new_d_cannon\\new_d_cannon.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_cannon_cast,
            strPath: "new_d_cannon\\new_d_cannon_cast\\new_d_cannon_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_d_cannon_hit,
            strPath: "new_d_cannon\\new_d_cannon_hit\\new_d_cannon_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_flame_trap,
            strPath: "flametrap\\flametrap\\flametrap.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_TRAP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_flame_trap_cast,
            strPath: "flametrap\\flametrap_cast\\flametrap_cast.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_flame_trap_hit,
            strPath: "flametrap\\flametrap_hit\\flametrap_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_FLAMETRAP_HIT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dilectio_heal,
            strPath: "new_dilectioheal\\new_dilectioheal\\new_dilectioheal.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dilectio_heal_cast,
            strPath: "new_dilectioheal\\new_dilectioheal_cast\\new_dilectioheal_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dilectio_heal_cast_bottom,
            strPath: "new_dilectioheal\\new_dilectioheal_cast_bottom\\new_dilectioheal_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dilectio_heal_target,
            strPath: "new_dilectioheal\\new_dilectioheal_target\\new_dilectioheal_target.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_dilectio_heal_target_bottom,
            strPath: "new_dilectioheal\\new_dilectioheal_target_bottom\\new_dilectioheal_target_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: 1,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_DILECTIO_HEAL.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_pramen_bottom,
            strPath: "new_pramen\\new_pramen_bottom\\new_pramen_bottom.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\CD_FRAMEN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_pramen_cast,
            strPath: "new_pramen\\new_pramen_cast\\new_pramen_cast.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_pramen,
            strPath: "new_pramen\\new_pramen\\new_pramen.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_potent_venom,
            strPath: "new_potent_venom\\new_potent_venom.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\SHC_POTENT_VENOM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_battle_w,
            strPath: "new_battle_w\\new_battle_w\\new_battle_w.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_battle_w_cast,
            strPath: "new_battle_w\\new_battle_w_cast\\new_battle_w_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_battle_w_bottom,
            strPath: "new_battle_w\\new_battle_w_bottom\\new_battle_w_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_battle_w_hit,
            strPath: "new_battle_w\\new_battle_w_hit\\new_battle_w_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_hit,
            strPath: "new_axe_stomp\\new_axe_stomp_hit\\new_axe_stomp_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_bottom,
            strPath: "new_axe_stomp\\new_axe_stomp_bottom\\new_axe_stomp_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            cameraShakeTicks: [20]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp,
            strPath: "new_axe_stomp\\new_axe_stomp\\new_axe_stomp.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\MT_AXE_STOMP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_12,
            strPath: "new_axe_stomp\\new_axe_stomp_12c\\new_axe_stomp_12c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_01,
            strPath: "new_axe_stomp\\new_axe_stomp_01c\\new_axe_stomp_01c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_03,
            strPath: "new_axe_stomp\\new_axe_stomp_03c\\new_axe_stomp_03.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_05,
            strPath: "new_axe_stomp\\new_axe_stomp_05c\\new_axe_stomp_05c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_06,
            strPath: "new_axe_stomp\\new_axe_stomp_06c\\new_axe_stomp_06c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_08,
            strPath: "new_axe_stomp\\new_axe_stomp_08c\\new_axe_stomp_08c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_09,
            strPath: "new_axe_stomp\\new_axe_stomp_09c\\new_axe_stomp_09c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_axe_stomp_11,
            strPath: "new_axe_stomp\\new_axe_stomp_11c\\new_axe_stomp_11c.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crescivebolt_cast,
            strPath: "crescivebolt\\crescivebolt_cast\\crescivebolt_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crescivebolt_hit,
            strPath: "crescivebolt\\crescivebolt_hit\\crescivebolt_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_shadow_stab,
            strPath: "shadow_stab\\shadow_stab\\shadow_stab.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            aimMode: .towardSource
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_eternal_slash_hit,
            strPath: "eternal_slash\\eternal_slash_hit\\eternal_slash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\SHC_SHADOW_STAB.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_shadow_stab_hit2,
            strPath: "shadow_stab\\shadow_stab_hit2\\shadow_stab_hit2.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_pneumaticus_procella_cast,
            strPath: "pneumaticusprocella\\pneumaticusprocella_cast\\pneumaticusprocella_cast.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_calumitygale,
            strPath: "4wh_calumitygale\\calumitygale\\calumitygale.str",
            sounds: [TimedSound(tick: 0, names: ["effect\\WH_CALAMITYGALE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_calumitygale_cast,
            strPath: "4wh_calumitygale\\calumitygale_cast\\calumitygale_cast.str",
            renderMode: .ground,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_calumitygale_loop,
            strPath: "4wh_calumitygale\\calumitygale_loop\\calumitygale_loop.str",
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sincere_faith,
            strPath: "sincerefaith\\sincerefaith\\sincerefaith.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_FAITH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sincere_faith_bottom,
            strPath: "sincerefaith\\sincerefaith_bottom\\sincerefaith_bottom.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_dagger,
            strPath: "abyss_dagger\\abyss_dagger\\abyss_dagger.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ABC_ABYSS_DAGGER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_dagger_hit,
            strPath: "abyss_dagger\\abyss_dagger_hit\\abyss_dagger_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hawk_boomerang_cast,
            strPath: "hawkvumerang\\hawkvumerang_cast\\hawkvumerang_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hawk_boomerang_hit,
            strPath: "hawkvumerang\\hawkvumerang_hit\\hawkvumerang_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_hawk_boomerang_start,
            strPath: "hawkvumerang\\hawkvumerang_start\\hawkvumerang_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gale_storm_cast,
            strPath: "galestorm\\galestorm_cast\\galestorm_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gale_storm_hit,
            strPath: "galestorm\\galestorm_hit\\galestorm_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_faith_power,
            strPath: "4ig_firstfaithpower\\firstfaithpower\\firstfaithpower.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_faith_power_cast,
            strPath: "4ig_firstfaithpower\\firstfaithpower_cast\\firstfaithpower_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_faith_power_start,
            strPath: "4ig_firstfaithpower\\firstfaithpower_start\\firstfaithpower_start.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_FIRST_FAITH_POWER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judge,
            strPath: "4ig_judge\\judge\\judge.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judge_cast,
            strPath: "4ig_judge\\judge_cast\\judge_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judge_start,
            strPath: "4ig_judge\\judge_start\\judge_start.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_JUDGE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judge_aura,
            strPath: "4ig_judge\\judge_aura\\judge_aura.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_exor_flame,
            strPath: "4ig_thirdexorflame\\thirdexorflame\\thirdexorflame.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_exor_flame_cast,
            strPath: "4ig_thirdexorflame\\thirdexorflame_cast\\thirdexorflame_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_exor_flame_start,
            strPath: "4ig_thirdexorflame\\thirdexorflame_start\\thirdexorflame_start.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_THIRD_EXOR_FLAME.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_exor_flame_aura,
            strPath: "4ig_thirdexorflame\\thirdexorflame_aura\\thirdexorflame_aura.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_powerful_faith,
            strPath: "powerfulfaith\\powerfulfaith\\powerfulfaith.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_FAITH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_oleum_sanctum,
            strPath: "4ig_oleumsanctum\\oleumsanctum\\oleumsanctum.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 50, names: ["effect\\IQ_OLEUM_SANCTUM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_oleum_sanctum_bottom,
            strPath: "4ig_oleumsanctum\\oleumsanctum_bottom\\oleumsanctum_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_oleum_sanctum_hit,
            strPath: "4ig_oleumsanctum\\oleumsanctum_hit\\oleumsanctum_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_oleum_sanctum_loop,
            strPath: "4ig_oleumsanctum\\oleumsanctum_loop\\oleumsanctum_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_increasing_activity,
            strPath: "increasing_activity\\increasing_activity\\increasing_activity.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            defaultRepeatCount: 2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_INCREASING_ACTIVITY.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_increasing_activity_cast,
            strPath: "increasing_activity\\increasing_activity_cast\\increasing_activity_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_increasing_activity_cast_bottom,
            strPath: "increasing_activity\\increasing_activity_cast_bottom\\increasing_activity_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_explosion_blaster,
            strPath: "4ig_explosionblaster\\explosionblaster\\explosionblaster.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_EXPOSION_BLASTER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_explosion_blaster_bottom,
            strPath: "4ig_explosionblaster\\explosionblaster_bottom\\explosionblaster_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_explosion_blaster_hit,
            strPath: "4ig_explosionblaster\\explosionblaster_hit\\explosionblaster_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_firm_faith,
            strPath: "firmfaith\\firmfaith\\firmfaith.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_FAITH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mysticsymphony,
            strPath: "mysticsymphony\\mysticsymphony\\mysticsymphony.str",
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_MYSTIC_SYMPHONY.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mysticsymphony_cast,
            strPath: "mysticsymphony\\mysticsymphony_cast\\mysticsymphony_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_mysticsymphony_note,
            strPath: "mysticsymphony\\mysticsymphony_note\\mysticsymphony_note.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_activity_burn,
            strPath: "activity_burn\\activity_burn\\activity_burn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ACTIVITY_BURN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_activity_burn_cast,
            strPath: "activity_burn\\activity_burn_cast\\activity_burn_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_activity_burn_cast_bottom,
            strPath: "activity_burn\\activity_burn_cast_bottom\\activity_burn_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_kvasirsonata,
            strPath: "4tr_kvasirsonata\\kvasirsonata\\kvasirsonata.str",
            isAttachedToHead: true,
            headOffsetYDelta: 5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_kvasirsonata_cast,
            strPath: "4tr_kvasirsonata\\kvasirsonata_cast\\kvasirsonata_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_kvasirsonata_cast_bottom,
            strPath: "4tr_kvasirsonata\\kvasirsonata_cast_bottom\\kvasirsonata_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_KVASIR_SONATA.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_bottom,
            strPath: "serpens\\serpens_bottom\\serpens_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SUMMON_ELEMENTAL_SERPENS_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_cast,
            strPath: "serpens\\serpens_cast\\serpens_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_cast_bottom,
            strPath: "serpens\\serpens_cast_bottom\\serpens_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_hit,
            strPath: "serpens\\serpens_hit\\serpens_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_shield,
            strPath: "serpens\\serpens_shield\\serpens_shield.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_chain_reaction_shot_cast,
            strPath: "chain_reaction_shot\\chain_reaction_shot_cast\\chain_reaction_shot_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: 1,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_chain_reaction_shot_cast_bottom,
            strPath: "chain_reaction_shot\\chain_reaction_shot_cast_bottom\\chain_reaction_shot_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: 1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_eternal_slash_hit_3,
            strPath: "eternal_slash\\eternal_slash_hit\\eternal_slash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_chain_reaction_shot_hitsub,
            strPath: "chain_reaction_shot\\chain_reaction_shot_hitsub\\chain_reaction_shot_hitsub.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_chain_reaction_shot,
            strPath: "chain_reaction_shot\\chain_reaction_shot\\chain_reaction_shot.str",
            isAttachedToHead: true,
            headOffsetYDelta: -7,
            aimMode: .fromSource
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_ice,
            strPath: "diluvio\\diluvio_ice\\diluvio_ice.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SUMMON_ELEMENTAL_DILUVIO_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_ice_bottom,
            strPath: "diluvio\\diluvio_ice_bottom\\diluvio_ice_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_cast,
            strPath: "diluvio\\diluvio_cast\\diluvio_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_cast_bottom,
            strPath: "diluvio\\diluvio_cast_bottom\\diluvio_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_hit,
            strPath: "diluvio\\diluvio_hit\\diluvio_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_armor,
            strPath: "diluvio\\diluvio_armor\\diluvio_armor.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_spell_enchanting,
            strPath: "spell_enchanting\\spell_enchanting\\spell_enchanting.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SPELL_ENCHANTING.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diamond_storm_bottom,
            strPath: "diamond_storm\\diamond_storm_bottom\\diamond_storm_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultLifeTimeFrames: 60,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_DIAMOND_STORM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diamond_storm_cast,
            strPath: "diamond_storm\\diamond_storm_cast\\diamond_storm_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diamond_storm_cast_bottom,
            strPath: "diamond_storm\\diamond_storm_cast_bottom\\diamond_storm_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diamond_storm_hit,
            strPath: "diamond_storm\\diamond_storm_hit\\diamond_storm_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_venom_swamp_bottom,
            strPath: "venom_swamp\\venom_swamp_bottom\\venom_swamp_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_VENOM_SWAMP.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_venom_swamp_cast,
            strPath: "venom_swamp\\venom_swamp_cast\\venom_swamp_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_venom_swamp_cast_bottom,
            strPath: "venom_swamp\\venom_swamp_cast_bottom\\venom_swamp_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_venom_swamp_hit,
            strPath: "venom_swamp\\venom_swamp_hit\\venom_swamp_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor,
            strPath: "ardor\\ardor\\ardor.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SUMMON_ELEMENTAL_ARDOR_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_bottom,
            strPath: "ardor\\ardor_bottom\\ardor_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_cast,
            strPath: "ardor\\ardor_cast\\ardor_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_cast_bottom,
            strPath: "ardor\\ardor_cast_bottom\\ardor_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_hit,
            strPath: "ardor\\ardor_hit\\ardor_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_flamearmor,
            strPath: "ardor\\ardor_flamearmor\\ardor_flamearmor.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lightning_land,
            strPath: "lightning_land\\lightning_land\\lightning_land.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_LIGHTNING_LAND.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lightning_land_bottom,
            strPath: "lightning_land\\lightning_land_bottom\\lightning_land_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lightning_land_cast,
            strPath: "lightning_land\\lightning_land_cast\\lightning_land_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lightning_land_cast_bottom,
            strPath: "lightning_land\\lightning_land_cast_bottom\\lightning_land_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_lightning_land_hit,
            strPath: "lightning_land\\lightning_land_hit\\lightning_land_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roseblossom_cast,
            strPath: "roseblossom\\roseblossom_cast\\roseblossom_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roseblossom_cast_bottom,
            strPath: "roseblossom\\roseblossom_cast_bottom\\roseblossom_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roseblossom_hit,
            strPath: "roseblossom\\roseblossom_hit\\roseblossom_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roseblossom_rose,
            strPath: "roseblossom\\roseblossom_rose\\roseblossom_rose.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_ROSEBLOSSOM_ROSE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roseblossom_shot,
            strPath: "roseblossom\\roseblossom_shot\\roseblossom_shot.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6,
            aimMode: .fromSource,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_ROSEBLOSSOM_SHOT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_brand,
            strPath: "4ig_firstbrand\\firstbrand\\firstbrand.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_brand_aura,
            strPath: "4ig_firstbrand\\firstbrand_aura\\firstbrand_aura.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_brand_hit,
            strPath: "4ig_firstbrand\\firstbrand_hit\\firstbrand_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_first_brand_start,
            strPath: "4ig_firstbrand\\firstbrand_start\\firstbrand_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_FIRST_BRAND.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_conflagration,
            strPath: "conflagration\\conflagration\\conflagration.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_CONFLAGRATION.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_conflagration_bottom,
            strPath: "conflagration\\conflagration_bottom\\conflagration_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_conflagration_cast,
            strPath: "conflagration\\conflagration_cast\\conflagration_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_conflagration_cast_bottom,
            strPath: "conflagration\\conflagration_cast_bottom\\conflagration_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_conflagration_hit,
            strPath: "conflagration\\conflagration_hit\\conflagration_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sound_blend,
            strPath: "soundblend\\soundblend\\soundblend.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_SOUNDBLEND_SHOT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sound_blend_cast,
            strPath: "soundblend\\soundblend_cast\\soundblend_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sound_blend_cast_bottom,
            strPath: "soundblend\\soundblend_cast_bottom\\soundblend_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_sound_blend_red,
            strPath: "soundblend\\soundblend_red\\soundblend_red.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_SOUNDBLEND_HIT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_metallic_fury,
            strPath: "metalicfury\\metalicfury\\metalicfury.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_METALIC_FURY.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_jawaii_serenade,
            strPath: "jawaii_serenade\\jawaii_serenade\\jawaii_serenade.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_JAWAII_SERENADE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_jawaii_serenade_cast,
            strPath: "jawaii_serenade\\jawaii_serenade_cast\\jawaii_serenade_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_jawaii_serenade_cast_bottom,
            strPath: "jawaii_serenade\\jawaii_serenade_cast_bottom\\jawaii_serenade_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_pronmarch,
            strPath: "pronmarch\\pronmarch\\pronmarch.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_PRON_MARCH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_pronmarch_cast,
            strPath: "pronmarch\\pronmarch_cast\\pronmarch_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_pronmarch_cast_bottom,
            strPath: "pronmarch\\pronmarch_cast_bottom\\pronmarch_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rhythmshooting_cast,
            strPath: "rhythmshooting\\rhythmshooting_cast\\rhythmshooting_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rhythmshooting_cast_bottom,
            strPath: "rhythmshooting\\rhythmshooting_cast_bottom\\rhythmshooting_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rhythmshooting_hit,
            strPath: "rhythmshooting\\rhythmshooting_hit\\rhythmshooting_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_niflheim,
            strPath: "nipelheim\\nipelheim\\nipelheim.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_NIPELHEIM_REQUIEM.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_niflheim_cast,
            strPath: "nipelheim\\nipelheim_cast\\nipelheim_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_second_faith,
            strPath: "4ig_secondfalth\\secondfalth\\secondfalth.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -5,
            sounds: [TimedSound(tick: 20, names: ["effect\\IQ_SECOND_FAITH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_second_faith_aura,
            strPath: "4ig_secondfalth\\secondfalth_aura\\secondfalth_aura.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_second_faith_start,
            strPath: "4ig_secondfalth\\secondfalth_start\\secondfalth_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_second_flame,
            strPath: "4iq_secondflame\\secondflame\\secondflame.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_SECOND_FLAME.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_second_flame_bottom,
            strPath: "4iq_secondflame\\secondflame_bottom\\secondflame_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 15, names: ["effect\\wizard_fire_pillar_b.wav"])],
            cameraShakeTicks: [40]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_flame_bomb,
            strPath: "4iq_thirdflamebomb\\thirdflamebomb\\thirdflamebomb.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_flame_bomb_bottom,
            strPath: "4iq_thirdflamebomb\\thirdflamebomb_bottom\\thirdflamebomb_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_THIRD_FLAME_BOMB.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike,
            strPath: "abyss_strike\\abyss_strike\\abyss_strike.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\ABC_ABYSS_STRIKE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_bottom,
            strPath: "abyss_strike\\abyss_strike_bottom\\abyss_strike_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_cast,
            strPath: "abyss_strike\\abyss_strike_cast\\abyss_strike_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_cast_bottom,
            strPath: "abyss_strike\\abyss_strike_cast_bottom\\abyss_strike_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_ground,
            strPath: "abyss_strike\\abyss_strike_ground\\abyss_strike_ground.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_ground_bottom,
            strPath: "abyss_strike\\abyss_strike_ground_bottom\\abyss_strike_ground_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_hit,
            strPath: "abyss_strike\\abyss_strike_hit\\abyss_strike_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_massive_flame_blaster,
            strPath: "4iq_massivefblaster\\massivefblaster\\massivefblaster.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_MASSIVE_F_BLASTER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_massive_flame_blaster_hit,
            strPath: "4iq_massivefblaster\\massivefblaster_hit\\massivefblaster_hit.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_massive_flame_blaster_hit_bottom,
            strPath: "4iq_massivefblaster\\massivefblaster_hit_bottom\\massivefblaster_hit_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_consecration,
            strPath: "4iq_thirdconsecration\\thirdconsecration\\thirdconsecration.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_THIRD_CONSECRATION.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella,
            strPath: "procella\\procella\\procella.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SUMMON_ELEMENTAL_PROCELLA_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_bottom,
            strPath: "procella\\procella_bottom\\procella_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_cast,
            strPath: "procella\\procella_cast\\procella_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_cast_bottom,
            strPath: "procella\\procella_cast_bottom\\procella_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_hit,
            strPath: "procella\\procella_hit\\procella_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_storm,
            strPath: "procella\\procella_storm\\procella_storm.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus,
            strPath: "terremotus\\terremotus\\terremotus.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_SUMMON_ELEMENTAL_TERREMOTUS_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_cast,
            strPath: "terremotus\\terremotus_cast\\terremotus_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_cast_bottom,
            strPath: "terremotus\\terremotus_cast_bottom\\terremotus_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_hit,
            strPath: "terremotus\\terremotus_hit\\terremotus_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_protect,
            strPath: "terremotus\\terremotus_protect\\terremotus_protect.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_from_the_abyss,
            strPath: "from_the_abyss\\from_the_abyss_shadow\\from_the_abyss_shadow.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -5,
            sounds: [TimedSound(tick: 0, names: ["effect\\ABC_FROM_THE_ABYSS.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_strike_hit_2,
            strPath: "abyss_strike\\abyss_strike_hit\\abyss_strike_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_punish,
            strPath: "4iq_thirdpunish\\thirdpunish\\thirdpunish.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_punish_bottom,
            strPath: "4iq_thirdpunish\\thirdpunish_bottom\\thirdpunish_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\IQ_THIRD_PUNISH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_frenzy_shot_hit,
            strPath: "frenzy_shot\\frenzy_shot_hit\\frenzy_shot_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gef_nocturn,
            strPath: "gef_nocturn\\gef_nocturn\\gef_nocturn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_GEF_NOCTURN.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gef_nocturn_cast,
            strPath: "gef_nocturn\\gef_nocturn_cast\\gef_nocturn_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_gef_nocturn_cast_bottom,
            strPath: "gef_nocturn\\gef_nocturn_cast_bottom\\gef_nocturn_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roki_capriccio,
            strPath: "roki_capriccio\\roki_capriccio\\roki_capriccio.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_ROKI_CAPRICCIO.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roki_capriccio_cast,
            strPath: "roki_capriccio\\roki_capriccio_cast\\roki_capriccio_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_roki_capriccio_cast_bottom,
            strPath: "roki_capriccio\\roki_capriccio_cast_bottom\\roki_capriccio_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_musical_interlude,
            strPath: "musical_interlude\\musical_interlude\\musical_interlude.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_MUSICAL_INTERLUDE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_musical_interlude_cast,
            strPath: "musical_interlude\\musical_interlude_cast\\musical_interlude_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ain_rhapsody,
            strPath: "ain_rhapsody\\ain_rhapsody\\ain_rhapsody.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\TR_AIN_RHAPSODY.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ain_rhapsody_cast,
            strPath: "ain_rhapsody\\ain_rhapsody_cast\\ain_rhapsody_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_slayer,
            strPath: "4abc_abyss_slayer\\abyss_slayer\\abyss_slayer.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_slayer_cast,
            strPath: "4abc_abyss_slayer\\abyss_slayer_cast\\abyss_slayer_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_slayer_cast_bottom,
            strPath: "4abc_abyss_slayer\\abyss_slayer_cast_bottom\\abyss_slayer_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_square,
            strPath: "abyss_square\\abyss_square\\abyss_square.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -1,
            periodicSound: PeriodicSound(startTick: 30, intervalTicks: 64, name: "effect\\ABC_ABYSS_SQUARE.wav")
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_square_bottom,
            strPath: "abyss_square\\abyss_square_bottom\\abyss_square_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -1
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_dagger_hit_2,
            strPath: "abyss_dagger\\abyss_dagger_hit\\abyss_dagger_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -5
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_deft_stab,
            strPath: "deft_stab\\deft_stab\\deft_stab.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ABC_DEFT_STAB1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terra_drive,
            strPath: "terradrive\\terradrive\\terradrive.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_TERRA_DRIVE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terra_drive_bottom,
            strPath: "terradrive\\terradrive_bottom\\terradrive_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terra_drive_cast,
            strPath: "terradrive\\terradrive_cast\\terradrive_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terra_drive_cast_bottom,
            strPath: "terradrive\\terradrive_cast_bottom\\terradrive_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terra_drive_hit,
            strPath: "terradrive\\terradrive_hit\\terradrive_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_cast,
            strPath: "elemental_buster\\elemental_buster_cast\\elemental_buster_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_fire,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_fire\\elemental_buster_fire.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ELEMETAL_BUSTER_FIRE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_fire_bottom,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_fire_bottom\\elemental_buster_fire_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_fire_hit,
            strPath: "elemental_buster\\elemental_buster_hit\\elemental_buster_fire_hit\\elemental_buster_fire_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_land,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_land\\elemental_buster_land.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ELEMETAL_BUSTER_GROUND.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_land_bottom,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_land_bottom\\elemental_buster_land_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_land_hit,
            strPath: "elemental_buster\\elemental_buster_hit\\elemental_buster_land_hit\\elemental_buster_land_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_poison,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_poison\\elemental_buster_poison.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ELEMETAL_BUSTER_POISON.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_poison_bottom,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_poison_bottom\\elemental_buster_poison_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_poison_hit,
            strPath: "elemental_buster\\elemental_buster_hit\\elemental_buster_poison_hit\\elemental_buster_poison_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_water,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_water\\elemental_buster_water.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ELEMETAL_BUSTER_WATER.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_water_bottom,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_water_bottom\\elemental_buster_water_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_water_hit,
            strPath: "elemental_buster\\elemental_buster_hit\\elemental_buster_water_hit\\elemental_buster_water_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_wind,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_wind\\elemental_buster_wind.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EM_ELEMETAL_BUSTER_WIND.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_wind_bottom,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_wind_bottom\\elemental_buster_wind_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_wind_hit,
            strPath: "elemental_buster\\elemental_buster_hit\\elemental_buster_wind_hit\\elemental_buster_wind_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_unlucky_rush_cast,
            strPath: "unlucky_rush\\unlucky_rush_cast\\unlucky_rush_cast.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_abyss_dagger_hit_3,
            strPath: "abyss_dagger\\abyss_dagger_hit\\abyss_dagger_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_overslash,
            strPath: "overslash\\overslash\\overslash.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_OVERSLASH.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_overslash_bottom,
            strPath: "overslash\\overslash_bottom\\overslash_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_overslash_cast,
            strPath: "overslash\\overslash_cast\\overslash_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_overslash_hit,
            strPath: "overslash\\overslash_hit\\overslash_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_advanced_protection,
            strPath: "adv_protection\\adv_protection\\adv_protection.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_ADVANCE_PROTECTION.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_advanced_protection_bottom,
            strPath: "adv_protection\\adv_protection_bottom\\adv_protection_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_advanced_protection_cast,
            strPath: "adv_protection\\adv_protection_cast\\adv_protection_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_advanced_protection_cast_bottom,
            strPath: "adv_protection\\adv_protection_cast_bottom\\adv_protection_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_cross_rain_bottom,
            strPath: "crossrain\\cross_rain_bottom\\cross_rain_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_cross_rain_cast,
            strPath: "crossrain\\cross_rain_cast\\cross_rain_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_cross_rain_cast_bottom,
            strPath: "crossrain\\cross_rain_cast_bottom\\cross_rain_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guard_stance,
            strPath: "guard_stance\\guard_stance\\guard_stance.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_GUARD_STANCE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guard_stance_cast,
            strPath: "guard_stance\\guard_stance_cast\\guard_stance_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guard_stance_cast_bottom,
            strPath: "guard_stance\\guard_stance_cast_bottom\\guard_stance_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_attack_stance,
            strPath: "attack_stance\\attack_stance\\attack_stance.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_GUARD_STANCE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_attack_stance_cast,
            strPath: "attack_stance\\attack_stance_cast\\attack_stance_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_attack_stance_cast_bottom,
            strPath: "attack_stance\\attack_stance_cast_bottom\\attack_stance_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grand_judgement,
            strPath: "grand_judgement\\grand_judgement\\grand_judgement.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_GRAND_JUDGEMENT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grand_judgement_bottom,
            strPath: "grand_judgement\\grand_judgement_bottom\\grand_judgement_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grand_judgement_buff,
            strPath: "grand_judgement\\grand_judgement_buff\\grand_judgement_buff.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grand_judgement_cast,
            strPath: "grand_judgement\\grand_judgement_cast\\grand_judgement_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_grand_judgement_cast_bottom,
            strPath: "grand_judgement\\grand_judgement_cast_bottom\\grand_judgement_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_holy_shield_cast,
            strPath: "holy_shield\\holy_shield_cast\\holy_shield_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_holy_shield,
            strPath: "holy_shield\\holy_shield\\holy_shield.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_HOLY_SHIELD1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_holy_shield_loop,
            strPath: "holy_shield\\holy_shield_loop\\holy_shield_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 34, names: ["effect\\IG_HOLY_SHIELD2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_shield_shooting_cast,
            strPath: "shield_shooting\\shield_shooting_cast\\shield_shooting_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_shield_shooting_hit,
            strPath: "shield_shooting\\shield_shooting_hit\\shield_shooting_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_the_w_protection,
            strPath: "the_w_protection\\the_w_protection\\the_w_protection.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["apocalips_attack.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_the_w_protection_cast,
            strPath: "the_w_protection\\the_w_protection_cast\\the_w_protection_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guardianshield,
            strPath: "guardianshield\\guardianshield\\guardianshield.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guardianshield_bottom,
            strPath: "guardianshield\\guardianshield_bottom\\guardianshield_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_guardianshield_sub,
            strPath: "guardianshield\\guardianshield_sub\\guardianshield_sub.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_GUARDIAN_SHIELD.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judgement_cross,
            strPath: "judgement_cross\\judgement_cross\\judgement_cross.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judgement_cross_bottom,
            strPath: "judgement_cross\\judgement_cross_bottom\\judgement_cross_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judgement_cross_cast,
            strPath: "judgement_cross\\judgement_cross_cast\\judgement_cross_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_judgement_cross_cast_bottom,
            strPath: "judgement_cross\\judgement_cross_cast_bottom\\judgement_cross_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rebound_shield,
            strPath: "rebound_shield\\rebound_shield\\rebound_shield.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_REBOUND_SHIELD.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rebound_shield_bottom,
            strPath: "rebound_shield\\rebound_shield_bottom\\rebound_shield_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rebound_shield_cast,
            strPath: "rebound_shield\\rebound_shield_cast\\rebound_shield_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rebound_shield_cast_bottom,
            strPath: "rebound_shield\\rebound_shield_cast_bottom\\rebound_shield_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ultimatesacrifice,
            strPath: "ultimate_sacrifice\\ultimatesacrifice\\ultimatesacrifice.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\IG_ULTIMATE_SACRIFICE.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ultimatesacrifice_bottom,
            strPath: "ultimate_sacrifice\\ultimatesacrifice_bottom\\ultimatesacrifice_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ultimatesacrifice_shine,
            strPath: "ultimate_sacrifice\\ultimatesacrifice_shine\\ultimatesacrifice_shine.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_cast,
            strPath: "acidified_zone_fire\\acidified_zone_fire_cast\\acidified_zone_fire_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_cast_bottom,
            strPath: "acidified_zone_fire\\acidified_zone_fire_cast_bottom\\acidified_zone_fire_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_hit,
            strPath: "acidified_zone_fire\\acidified_zone_fire_hit\\acidified_zone_fire_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_start,
            strPath: "acidified_zone_fire\\acidified_zone_fire_a_start\\acidified_zone_fire_a_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_start_bottom,
            strPath: "acidified_zone_fire\\acidified_zone_fire_a_start_bottom\\acidified_zone_fire_a_start_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_loop,
            strPath: "acidified_zone_fire\\acidified_zone_fire_a_loop\\acidified_zone_fire_a_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_fire_loop_bottom,
            strPath: "acidified_zone_fire\\acidified_zone_fire_a_loop_bottom\\acidified_zone_fire_a_loop_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_cast,
            strPath: "acidified_zone_water\\acidified_zone_water_cast\\acidified_zone_water_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_cast_bottom,
            strPath: "acidified_zone_water\\acidified_zone_water_cast_bottom\\acidified_zone_water_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_hit,
            strPath: "acidified_zone_water\\acidified_zone_water_hit\\acidified_zone_water_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_start,
            strPath: "acidified_zone_water\\acidified_zone_water_a_start\\acidified_zone_water_a_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_start_bottom,
            strPath: "acidified_zone_water\\acidified_zone_water_a_start_bottom\\acidified_zone_water_a_start_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_loop,
            strPath: "acidified_zone_water\\acidified_zone_water_a_loop\\acidified_zone_water_a_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_water_loop_bottom,
            strPath: "acidified_zone_water\\acidified_zone_water_a_loop_bottom\\acidified_zone_water_a_loop_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_cast,
            strPath: "acidified_zone_wind\\acidified_zone_wind_cast\\acidified_zone_wind_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_cast_bottom,
            strPath: "acidified_zone_wind\\acidified_zone_wind_cast_bottom\\acidified_zone_wind_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_hit,
            strPath: "acidified_zone_wind\\acidified_zone_wind_hit\\acidified_zone_wind_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_start,
            strPath: "acidified_zone_wind\\acidified_zone_wind_a_start\\acidified_zone_wind_a_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_start_bottom,
            strPath: "acidified_zone_wind\\acidified_zone_wind_a_start_bottom\\acidified_zone_wind_a_start_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_loop,
            strPath: "acidified_zone_wind\\acidified_zone_wind_a_loop\\acidified_zone_wind_a_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_wind_loop_bottom,
            strPath: "acidified_zone_wind\\acidified_zone_wind_a_loop_bottom\\acidified_zone_wind_a_loop_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_cast,
            strPath: "acidified_zone_ground\\acidified_zone_ground_cast\\acidified_zone_ground_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_cast_bottom,
            strPath: "acidified_zone_ground\\acidified_zone_ground_cast_bottom\\acidified_zone_ground_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_hit,
            strPath: "acidified_zone_ground\\acidified_zone_ground_hit\\acidified_zone_ground_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_start,
            strPath: "acidified_zone_ground\\acidified_zone_ground_a_start\\acidified_zone_ground_a_start.str",
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_start_bottom,
            strPath: "acidified_zone_ground\\acidified_zone_ground_a_start_bottom\\acidified_zone_ground_a_start_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_loop,
            strPath: "acidified_zone_ground\\acidified_zone_ground_a_loop\\acidified_zone_ground_a_loop.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_acidified_zone_ground_loop_bottom,
            strPath: "acidified_zone_ground\\acidified_zone_ground_a_loop_bottom\\acidified_zone_ground_a_loop_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -3
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_helltree_cast,
            strPath: "helltree\\helltree_cast\\helltree_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_helltree_cast_bottom,
            strPath: "helltree\\helltree_cast_bottom\\helltree_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_helltree_dusty,
            strPath: "helltree\\hell_dusty\\hell_dusty.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_helltree_howling,
            strPath: "helltree\\hell_howling\\hell_howling.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_HELL_HOWLING.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_research_report,
            strPath: "research_report\\researchreport\\researchreport.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_RESEARCHREPORT.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_research_report_cast,
            strPath: "research_report\\researchreport_cast\\researchreport_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_beginspell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_research_report_cast_bottom,
            strPath: "research_report\\researchreport_cast_bottom\\researchreport_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_lassitude,
            strPath: "state_effect\\lassitude\\lassitude.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_swooning,
            strPath: "state_effect\\swooning\\swooning.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_holyflame,
            strPath: "state_effect\\holyflame\\holyflame.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_cast,
            strPath: "wooden_warrior\\wooden_warrior_cast\\wooden_warrior_cast.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_cast_bottom,
            strPath: "wooden_warrior\\wooden_warrior_cast_bottom\\wooden_warrior_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_attack,
            strPath: "wooden_warrior\\wooden_attack\\wooden_attack\\wooden_attack.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            aimMode: .fromSourceInverted,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_WOODEN_ATTACK.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_attack_hit,
            strPath: "wooden_warrior\\wooden_attack\\wooden_attack_hit\\wooden_attack_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_throwrock,
            strPath: "wooden_warrior\\throwrock\\throwrock\\throwrock.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            aimMode: .fromSourceInverted,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_THROWROCK.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_warrior_throwrock_hit,
            strPath: "wooden_warrior\\throwrock\\throwrock_hit\\throwrock_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_fairy_cast,
            strPath: "wooden_fairy\\wooden_cast\\wooden_cast.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_fairy_cast_bottom,
            strPath: "wooden_fairy\\wooden_cast_bottom\\wooden_cast_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_BeginSpell.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_wooden_fairy_dusty,
            strPath: "wooden_fairy\\fairy_dusty\\fairy_dusty.str",
            isAttachedToHead: true,
            sounds: [TimedSound(tick: 0, names: ["effect\\BO_FAIRY_DUSTY.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_deep_poisoning,
            strPath: "serpens\\serpens_deep_poisoning\\serpens_deep_poisoning.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\ef_detoxication.wav"])],
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_serpens_deep_poisoning_bottom,
            strPath: "serpens\\serpens_deep_poisoning_bottom\\serpens_deep_poisoning_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_cold_force,
            strPath: "diluvio\\diluvio_cold_force\\diluvio_cold_force.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_IceArrow1.wav"])],
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_diluvio_cold_force_bottom,
            strPath: "diluvio\\diluvio_cold_force _bottom\\diluvio_cold_force _bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_flametechnic,
            strPath: "ardor\\ardor_flametechnic\\ardor_flametechnic.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_FireArrow1.wav"])],
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ardor_flametechnic_bottom,
            strPath: "ardor\\ardor_flametechnic_bottom\\ardor_flametechnic_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_grace_breeze,
            strPath: "procella\\procella_grace_breeze\\procella_grace_breeze.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\EF_LightBolt3.wav"])],
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_procella_grace_breeze_bottom,
            strPath: "procella\\procella_grace_breeze_bottom\\procella_grace_breeze_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_earth_care,
            strPath: "terremotus\\terremotus_earth_care\\terremotus_earth_care.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2,
            sounds: [TimedSound(tick: 0, names: ["effect\\wizard_earthspike.wav"])],
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_terremotus_earth_care_bottom,
            strPath: "terremotus\\terremotus_earth_care_bottom\\terremotus_earth_care_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_lightningstrike,
            strPath: "state_effect\\lightningstrike\\lightningstrike.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_conflagration,
            strPath: "state_effect\\conflagration\\conflagration.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_frostbite,
            strPath: "state_effect\\frostbite\\frostbite\\frostbite.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_frostbite_finish,
            strPath: "state_effect\\frostbite\\frostbite_finish\\frostbite_finish.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_crystallization,
            strPath: "state_effect\\crystallization\\crystallization.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_state_deadlypoison,
            strPath: "state_effect\\deadlypoison\\deadlypoison.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_third_consecration_bottom,
            strPath: "4iq_thirdconsecration\\thirdconsecration_bottom\\thirdconsecration_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_servant_sign_bottom,
            strPath: "servant_sign\\servant_sign_bottom\\servant_sign_bottom.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_killing_aura,
            strPath: "NPC_KILLING_AURA\\npc_killing_aura_bottom\\killing_aura.str",
            renderMode: .ground,
            isLooping: true,
            isRetained: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_killing_aura_end,
            strPath: "NPC_KILLING_AURA\\npc_killing_aura_bottom\\killing_aura_end.str"
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_killing_aura_hit,
            strPath: "NPC_KILLING_AURA\\npc_killing_aura_hit\\killing_aura_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_cane_of_evil_eye,
            strPath: "NPC_CANE_OF_EVIL_EYE\\npc_cane_of_evil_eye_hit\\npc_cane_of_evil_eye_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_enchant_intro_yellow,
            strPath: "ui_enchant\\ui_intro_yellow\\ui_intro_yellow.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_enchant_success,
            strPath: "ui_enchant\\ui_enchant_success\\ui_enchant_success.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_enchant_fail,
            strPath: "ui_enchant\\ui_fail\\ui_enchant_fail.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000,
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_enchant_intro_blue,
            strPath: "ui_enchant\\ui_intro_blue\\ui_intro_blue.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_levelup_success,
            strPath: "ui_enchant\\ui_levelup_success\\ui_levelup_success.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_levelup_fail,
            strPath: "ui_enchant\\ui_fail\\ui_levelup_fail.str",
            renderMode: .screen,
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_enchant_intro_green,
            strPath: "ui_enchant\\ui_intro_green\\ui_intro_green.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_reset_success,
            strPath: "ui_enchant\\ui_reset_success\\ui_reset_success.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_ui_reset_fail,
            strPath: "ui_enchant\\ui_fail\\ui_reset_fail.str",
            renderMode: .screen,
            overlayColorStep: 0x02000000,
            cameraShakeTicks: [0]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_toxin_of_mandara_bomb,
            strPath: "toxin_of_mandara\\toxin_of_mandara_bomb\\toxin_of_mandara_bomb.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_toxin_of_mandara_bomb_bottom,
            strPath: "toxin_of_mandara\\toxin_of_mandara_bomb_bottom\\toxin_of_mandara_bomb_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_toxin_of_mandara_shock,
            strPath: "toxin_of_mandara\\toxin_of_mandara_shock\\toxin_of_mandara_shock.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_needle_stinger,
            strPath: "needle_stinger\\needle_stinger\\needle_stinger.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_needle_stinger_bottom,
            strPath: "needle_stinger\\needle_stinger_bottom\\needle_stinger_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_needle_stinger_hit,
            strPath: "needle_stinger\\needle_stinger_hit\\needle_stinger_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_absolute_zephyr,
            strPath: "absolute_zephyr\\absolute_zephyr\\absolute_zephyr.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_absolute_zephyr_bottom,
            strPath: "absolute_zephyr\\absolute_zephyr_bottom\\absolute_zephyr_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_absolute_zephyr_hit,
            strPath: "absolute_zephyr\\absolute_zephyr_hit\\absolute_zephyr_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_twister_cutter,
            strPath: "twister_cutter\\twister_cutter\\twister_cutter.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_twister_cutter_hit,
            strPath: "twister_cutter\\twister_cutter_hit\\twister_cutter_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_heilige_pferd,
            strPath: "heilige_pferd\\heilige_pferd\\heilige_pferd.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_heilige_pferd_bottom,
            strPath: "heilige_pferd\\heilige_pferd_bottom\\heilige_pferd_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_heilige_pferd_cast,
            strPath: "heilige_pferd\\heilige_pferd_cast\\heilige_pferd_cast.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_goldene_tone,
            strPath: "goldene_tone\\goldene_tone\\goldene_tone.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_glanzen_spies,
            strPath: "glanzen_spies\\glanzen_spies\\glanzen_spies.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_glanzen_spies_hit,
            strPath: "glanzen_spies\\glanzen_spies_hit\\glanzen_spies_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_blazing_and_furious,
            strPath: "blazing_and_furious\\blazing_and_furious\\blazing_and_furious.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_the_one_fighter_rises_bottom,
            strPath: "the_one_fighter_rises\\the_one_fighter_rises_bottom\\the_one_fighter_rises_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tempering,
            strPath: "tempering\\tempering\\tempering.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_blast_forge_hit,
            strPath: "blast_forge\\blast_forge_hit\\blast_forge_hit.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_water_sub_2,
            strPath: "tetravortex\\tetra_04_water_sub_explosion\\tetra_04_water_sub_expn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\drop_effect_1.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_tetra_vortex_earth_sub_2,
            strPath: "tetravortex\\tetra_03_earth_sub_explosion\\tetra_03_earth_sub_expn.str",
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            sounds: [TimedSound(tick: 0, names: ["effect\\drop_effect_2.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_20th_crystal_s,
            strPath: "npc_20th_crystal\\npc_20th_crystal_s.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_20th_crystal_m,
            strPath: "npc_20th_crystal\\npc_20th_crystal_m.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_20th_crystal_l,
            strPath: "npc_20th_crystal\\npc_20th_crystal_l.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_green_1,
            strPath: "npc_gate\\npc_gate_green\\npc_gate_green.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_purple_1,
            strPath: "npc_gate\\npc_gate_purple\\npc_gate_purple.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_red_1,
            strPath: "npc_gate\\npc_gate_red\\npc_gate_red.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_20th_firework,
            strPath: "20th_firework\\20th_firework.str",
            isAttachedToHead: true,
            headOffsetYDelta: 16,
            sounds: [TimedSound(tick: 0, names: ["effect\\pokjuk_jap.wav"])]
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_green_2,
            strPath: "npc_gate\\npc_gate_green\\npc_gate_green.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_purple_2,
            strPath: "npc_gate\\npc_gate_purple\\npc_gate_purple.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_red_2,
            strPath: "npc_gate\\npc_gate_red\\npc_gate_red.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.6
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_green_3,
            strPath: "npc_gate\\npc_gate_green\\npc_gate_green.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.35
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_purple_3,
            strPath: "npc_gate\\npc_gate_purple\\npc_gate_purple.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.35
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_red_3,
            strPath: "npc_gate\\npc_gate_red\\npc_gate_red.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -4,
            defaultScale: 0.35
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_npc_gate_skyblue,
            strPath: "npc_gate_skyblue\\npc_gate_skyblue\\npc_gate_skyblue.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true,
            headOffsetYDelta: -8
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rune_active_finish,
            strPath: "runesystem\\rune_active\\ui_finish.str",
            renderMode: .screen,
            isAttachedToHead: true,
            overlayColorStep: 0x10000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_runeset_active,
            strPath: "runesystem\\runeset_active\\ui_activate.str",
            renderMode: .screen,
            isAttachedToHead: true,
            overlayColorStep: 0x10000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_runeset_upgrade_success,
            strPath: "runesystem\\runeset_upgrade_success\\rune_upgrade_succecss.str",
            renderMode: .screen,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_runeset_upgrade_fail,
            strPath: "runesystem\\runeset_upgrade_fail\\rune_upgrade_fail.str",
            renderMode: .screen,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rune_broken,
            strPath: "runesystem\\decom_broken\\ui_broken.str",
            renderMode: .screen,
            isAttachedToHead: true,
            overlayColorStep: 0x10000000
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_battle_w_hit_2,
            strPath: "new_battle_w\\new_battle_w_hit\\new_battle_w_hit.str",
            isLooping: true,
            isRetained: true,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_pramen_reuse,
            strPath: "new_pramen\\new_pramen\\new_pramen.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_the_w_protection_reuse,
            strPath: "the_w_protection\\the_w_protection\\the_w_protection.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_elemental_buster_fire_reuse,
            strPath: "elemental_buster\\elemental_buster\\elemental_buster_fire\\elemental_buster_fire.str",
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_destructive_hurricane_bottom_reuse,
            strPath: "destructive_hurricane\\destructive_hurricane_bottom\\destructive_hurricane_bottom.str",
            renderMode: .ground,
            isAttachedToHead: true,
            headOffsetYDelta: -2
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_crystal_impact_bottom_reuse,
            strPath: "crystal_impact\\crystal_impact_bottom\\crystal_impact_bottom.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_new_judex_target_reuse,
            strPath: "new_judex\\new_judex_target\\new_judex_target.str",
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rune_slot_small,
            strPath: "runesystem\\rune_slot_small\\rune_slot_small.str",
            renderMode: .screen,
            isAttachedToHead: true
        ),
        EZ2STRScreenEffectDefinition(
            effectID: .ef_rune_slot_big,
            strPath: "runesystem\\rune_slot_big\\rune_slot_big.str",
            renderMode: .screen,
            isAttachedToHead: true
        ),
    ]

    public static let definitionsByEffectID: [EffectID : EZ2STRScreenEffectDefinition] = Dictionary(
        uniqueKeysWithValues: definitions.map { ($0.effectID, $0) }
    )

    public static func definition(for effectID: EffectID) -> EZ2STRScreenEffectDefinition? {
        definitionsByEffectID[effectID]
    }
}
