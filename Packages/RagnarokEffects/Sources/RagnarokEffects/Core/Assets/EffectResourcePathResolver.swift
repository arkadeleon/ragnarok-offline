//
//  EffectResourcePathResolver.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

/// Resolves minimal-effect STR resource paths when `TT_MIN_EFFECT_ON_OFF` is enabled,
/// ported from explicit branches in `EZ2STREffect.cpp` / `Skills/*.cpp` and
/// `CEZ2STRParticle::ResolvePath()` in `Particle.cpp`.
public struct EffectResourcePathResolver: Sendable {
    /// Explicit STR path replacements gated on `TT_MIN_EFFECT_ON_OFF`
    /// (108 from `CEZ2STRScreenEffect::InitParticle` and 4 from `Skills/*.cpp`).
    public static let explicitMinimalSTRPaths: [String : String] = [
        // EZ2STREffect.cpp (108)
        "new_counter_slash\\new_counter_slash\\new_counter_slash.str": "mineffect\\new_counter_slash\\new_counter_slash\\new_counter_slash.str",
        "new_rayofgenesis\\new_rayofgenesis\\new_rayofgenesis.str": "mineffect\\new_rayofgenesis\\new_rayofgenesis\\new_rayofgenesis.str",
        "new_rayofgenesis\\new_rayofgenesis_cast\\new_rayofgenesis_cast.str": "mineffect\\new_rayofgenesis\\new_rayofgenesis_cast\\new_rayofgenesis_cast.str",
        "new_rayofgenesis\\new_rayofgenesis_hit\\new_rayofgenesis_hit.str": "mineffect\\new_rayofgenesis\\new_rayofgenesis_hit\\new_rayofgenesis_hit.str",
        "new_earthgrave\\new_earthgrave\\new_earthgrave.str": "mineffect\\new_earthgrave\\new_earthgrave\\new_earthgrave.str",
        "new_earthgrave\\new_earthgrave_bottom\\new_earthgrave_bottom.str": "mineffect\\new_earthgrave\\new_earthgrave_bottom\\new_earthgrave_bottom.str",
        "new_earthgrave\\new_earthgrave_hit\\new_earthgrave_hit.str": "mineffect\\new_earthgrave\\new_earthgrave_hit\\new_earthgrave_hit.str",
        "new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_1.str": "mineffect\\new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_1.str",
        "new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_2.str": "mineffect\\new_poisonsmoke\\new_poisonsmoke\\new_poisonsmoke_2.str",
        "new_fearbreeze\\new_fearbreeze.str": "mineffect\\new_fearbreeze\\new_fearbreeze.str",
        "new_hellInferno\\new_hellInferno\\new_hellInferno.str": "mineffect\\new_hellInferno\\new_hellInferno\\new_hellInferno.str",
        "new_hellInferno\\new_hellInferno_bottom\\new_hellInferno_bottom.str": "mineffect\\new_hellInferno\\new_hellInferno_bottom\\new_hellInferno_bottom.str",
        "new_hellInferno\\new_hellInferno_cast_bottom\\new_hellInferno_cast_bottom.str": "mineffect\\new_hellInferno\\new_hellInferno_cast_bottom\\new_hellInferno_cast_bottom.str",
        "new_hellInferno\\new_hellInferno_sub\\new_hellInferno_sub.str": "mineffect\\new_hellInferno\\new_hellInferno_sub\\new_hellInferno_sub.str",
        "new_hellInferno\\new_hellInferno_sub_bottom\\new_hellInferno_sub_bottom.str": "mineffect\\new_hellInferno\\new_hellInferno_sub_bottom\\new_hellInferno_sub_bottom.str",
        "new_clearence\\new_clearence\\new_clearence.str": "mineffect\\new_clearence\\new_clearence\\new_clearence.str",
        "new_clearence\\new_clearence_bottom\\new_clearence_bottom.str": "mineffect\\new_clearence\\new_clearence_bottom\\new_clearence_bottom.str",
        "new_clearence\\new_clearence_cast\\new_clearence_cast.str": "mineffect\\new_clearence\\new_clearence_cast\\new_clearence_cast.str",
        "new_crossimpact\\new_crossimpact\\new_crossimpact.str": "mineffect\\new_crossimpact\\new_crossimpact\\new_crossimpact.str",
        "new_crossimpact\\new_crossimpact_target\\new_crossimpact_target.str": "mineffect\\new_crossimpact\\new_crossimpact_target\\new_crossimpact_target.str",
        "new_reverberation\\new_reverberation_hit\\new_reverberation_hit.str": "mineffect\\new_reverberation\\new_reverberation_hit\\new_reverberation_hit.str",
        "new_fallenempire\\new_fallenempire\\new_fallenempire.str": "mineffect\\new_fallenempire\\new_fallenempire\\new_fallenempire.str",
        "new_fallenempire\\new_fallenempire_bottom\\new_fallenempire_bottom.str": "mineffect\\new_fallenempire\\new_fallenempire_bottom\\new_fallenempire_bottom.str",
        "new_fallenempire\\new_fallenempire_hit\\new_fallenempire_hit.str": "mineffect\\new_fallenempire\\new_fallenempire_hit\\new_fallenempire_hit.str",
        "new_gateofhell\\new_gateofhell_cast\\new_gateofhell_cast.str": "mineffect\\new_gateofhell\\new_gateofhell_cast\\new_gateofhell_cast.str",
        "new_gateofhell\\new_gateofhell_target\\new_gateofhell_target.str": "mineffect\\new_gateofhell\\new_gateofhell_target\\new_gateofhell_target.str",
        "new_howlingoflion\\new_howlingoflion\\new_howlingoflion.str": "mineffect\\new_howlingoflion\\new_howlingoflion\\new_howlingoflion.str",
        "new_howlingoflion\\new_howlingoflion_bottom\\new_howlingoflion_bottom.str": "mineffect\\new_howlingoflion\\new_howlingoflion_bottom\\new_howlingoflion_bottom.str",
        "new_howlingoflion\\new_howlingoflion_cast\\new_howlingoflion_cast.str": "mineffect\\new_howlingoflion\\new_howlingoflion_cast\\new_howlingoflion_cast.str",
        "new_howlingoflion\\new_howlingoflion_cast_bottom\\new_howlingoflion_cast_bottom.str": "mineffect\\new_howlingoflion\\new_howlingoflion_cast_bottom\\new_howlingoflion_cast_bottom.str",
        "new_howlingoflion\\new_howlingoflion_hit\\new_howlingoflion_hit.str": "mineffect\\new_howlingoflion\\new_howlingoflion_hit\\new_howlingoflion_hit.str",
        "new_metalicsound\\new_metalicsound\\new_metalicsound.str": "mineffect\\new_metalicsound\\new_metalicsound\\new_metalicsound.str",
        "new_metalicsound\\new_metalicsound_bottom\\new_metalicsound_bottom.str": "mineffect\\new_metalicsound\\new_metalicsound_bottom\\new_metalicsound_bottom.str",
        "new_metalicsound\\new_metalicsound_hit\\new_metalicsound_hit.str": "mineffect\\new_metalicsound\\new_metalicsound_hit\\new_metalicsound_hit.str",
        "new_reproduce\\new_reproduce\\new_reproduce.str": "mineffect\\new_reproduce\\new_reproduce\\new_reproduce.str",
        "new_reproduce\\new_reproduce_bottom\\new_reproduce_bottom.str": "mineffect\\new_reproduce\\new_reproduce_bottom\\new_reproduce_bottom.str",
        "new_soulexpansion\\new_soulexpansion_cast\\new_soulexpansion_cast.str": "mineffect\\new_soulexpansion\\new_soulexpansion_cast\\new_soulexpansion_cast.str",
        "new_soulexpansion\\new_soulexpansion_cast_bottom\\new_soulexpansion_cast_bottom.str": "mineffect\\new_soulexpansion\\new_soulexpansion_cast_bottom\\new_soulexpansion_cast_bottom.str",
        "new_soulexpansion\\new_soulexpansion_loop\\new_soulexpansion_loop.str": "mineffect\\new_soulexpansion\\new_soulexpansion_loop\\new_soulexpansion_loop.str",
        "new_soulexpansion\\new_soulexpansion_loop_bottom\\new_soulexpansion_loop_bottom.str": "mineffect\\new_soulexpansion\\new_soulexpansion_loop_bottom\\new_soulexpansion_loop_bottom.str",
        "new_soulexpansion\\new_soulexpansion_hit\\new_soulexpansion_hit.str": "mineffect\\new_soulexpansion\\new_soulexpansion_hit\\new_soulexpansion_hit.str",
        "new_soulexpansion\\new_soulexpansion_hit_bottom\\new_soulexpansion_hit_bottom.str": "mineffect\\new_soulexpansion\\new_soulexpansion_hit_bottom\\new_soulexpansion_hit_bottom.str",
        "new_wallofthorn\\new_wallofthorn_cast\\new_wallofthorn_cast.str": "mineffect\\new_wallofthorn\\new_wallofthorn_cast\\new_wallofthorn_cast.str",
        "new_ignitionbreak\\new_ignitionbreak\\new_ignitionbreak.str": "mineffect\\new_ignitionbreak\\new_ignitionbreak\\new_ignitionbreak.str",
        "new_ignitionbreak\\new_ignitionbreak_bottom\\new_ignitionbreak_bottom.str": "mineffect\\new_ignitionbreak\\new_ignitionbreak_bottom\\new_ignitionbreak_bottom.str",
        "new_judex\\new_judex_cast\\new_judex_cast.str": "mineffect\\new_judex\\new_judex_cast\\new_judex_cast.str",
        "new_judex\\new_judex_cast_bottom\\new_judex_cast_bottom.str": "mineffect\\new_judex\\new_judex_cast_bottom\\new_judex_cast_bottom.str",
        "new_judex\\new_judex_cast_loop\\new_judex_cast_loop.str": "mineffect\\new_judex\\new_judex_cast_loop\\new_judex_cast_loop.str",
        "new_judex\\new_judex_cast_loop_bottom\\new_judex_cast_loop_bottom.str": "mineffect\\new_judex\\new_judex_cast_loop_bottom\\new_judex_cast_loop_bottom.str",
        "new_judex\\new_judex_target\\new_judex_target.str": "mineffect\\new_judex\\new_judex_target\\new_judex_target.str",
        "new_judex\\new_judex_target_bottom\\new_judex_target_bottom.str": "mineffect\\new_judex\\new_judex_target_bottom\\new_judex_target_bottom.str",
        "new_judex\\new_judex_light\\new_judex_light.str": "mineffect\\new_judex\\new_judex_light\\new_judex_light.str",
        "new_judex\\new_judex_light_bottom\\new_judex_light_bottom.str": "mineffect\\new_judex\\new_judex_light_bottom\\new_judex_light_bottom.str",
        "new_chainlightning\\new_chainlightning_cast\\new_chainlightning_cast.str": "mineffect\\new_chainlightning\\new_chainlightning_cast\\new_chainlightning_cast.str",
        "new_chainlightning\\new_chainlightning_cast_bottom\\new_chainlightning_cast_bottom.str": "mineffect\\new_chainlightning\\new_chainlightning_cast_bottom\\new_chainlightning_cast_bottom.str",
        "new_chainlightning\\new_chainlightning_lockon\\new_chainlightning_lockon.str": "mineffect\\new_chainlightning\\new_chainlightning_lockon\\new_chainlightning_lockon.str",
        "new_chainlightning\\new_chainlightning_target\\new_chainlightning_target.str": "mineffect\\new_chainlightning\\new_chainlightning_target\\new_chainlightning_target.str",
        "new_mandragora\\new_mandragora\\new_mandragora.str": "mineffect\\new_mandragora\\new_mandragora\\new_mandragora.str",
        "new_mandragora\\new_mandragora_bottom\\new_mandragora_bottom.str": "mineffect\\new_mandragora\\new_mandragora_bottom\\new_mandragora_bottom.str",
        "new_mandragora\\new_mandragora_cast\\new_mandragora_cast.str": "mineffect\\new_mandragora\\new_mandragora_cast\\new_mandragora_cast.str",
        "new_soundofdestruction\\new_soundofdestruction_cast\\new_soundofdestruction_cast.str": "mineffect\\new_soundofdestruction\\new_soundofdestruction_cast\\new_soundofdestruction_cast.str",
        "new_soundofdestruction\\new_soundofdestruction_cast_bottom\\new_soundofdestruction_cast_bottom.str": "mineffect\\new_soundofdestruction\\new_soundofdestruction_cast_bottom\\new_soundofdestruction_cast_bottom.str",
        "new_soundofdestruction\\new_soundofdestruction_target\\new_soundofdestruction_target.str": "mineffect\\new_soundofdestruction\\new_soundofdestruction_target\\new_soundofdestruction_target.str",
        "new_aimedbolt\\new_aimedbolt_attack_01clock\\new_aimedbolt_attack_01clock.str": "mineffect\\new_aimedbolt\\new_aimedbolt_attack_01clock\\new_aimedbolt_attack_01clock.str",
        "new_aimedbolt\\new_aimedbolt_attack_05clock\\new_aimedbolt_attack_05clock.str": "mineffect\\new_aimedbolt\\new_aimedbolt_attack_05clock\\new_aimedbolt_attack_05clock.str",
        "new_aimedbolt\\new_aimedbolt_attack_07clock\\new_aimedbolt_attack_07clock.str": "mineffect\\new_aimedbolt\\new_aimedbolt_attack_07clock\\new_aimedbolt_attack_07clock.str",
        "new_aimedbolt\\new_aimedbolt_attack_11clock\\new_aimedbolt_attack_11clock.str": "mineffect\\new_aimedbolt\\new_aimedbolt_attack_11clock\\new_aimedbolt_attack_11clock.str",
        "new_aimedbolt\\new_aimedbolt_cast_bottom\\new_aimedbolt_cast_bottom.str": "mineffect\\new_aimedbolt\\new_aimedbolt_cast_bottom\\new_aimedbolt_cast_bottom.str",
        "new_aimedbolt\\new_aimedbolt_target_end\\new_aimedbolt_end.str": "mineffect\\new_aimedbolt\\new_aimedbolt_target_end\\new_aimedbolt_end.str",
        "new_aimedbolt\\new_aimedbolt_target_loop\\new_aimedbolt_target_loop.str": "mineffect\\new_aimedbolt\\new_aimedbolt_target_loop\\new_aimedbolt_target_loop.str",
        "new_unlimit\\new_unlimit\\new_unlimit.str": "mineffect\\new_unlimit\\new_unlimit\\new_unlimit.str",
        "new_unlimit\\new_unlimit_bottom\\new_unlimit_bottom.str": "mineffect\\new_unlimit\\new_unlimit_bottom\\new_unlimit_bottom.str",
        "new_epiclesis\\new_epiclesis_combine\\new_epiclesis_combine.str": "mineffect\\new_epiclesis\\new_epiclesis_combine.str",
        "new_axeboomerang\\new_axeboomerang_hit\\new_axeboomerang_hit.str": "mineffect\\new_axeboomerang\\new_axeboomerang_hit\\new_axeboomerang_hit.str",
        "new_spellfist\\new_spellfist_fire\\new_spellfist_fire.str": "mineffect\\new_spellfist\\new_spellfist_fire\\new_spellfist_fire.str",
        "new_spellfist\\new_spellfist_fire_bottom\\new_spellfist_fire_bottom.str": "mineffect\\new_spellfist\\new_spellfist_fire_bottom\\new_spellfist_fire_bottom.str",
        "new_spellfist\\new_spellfist_water\\new_spellfist_water.str": "mineffect\\new_spellfist\\new_spellfist_water\\new_spellfist_water.str",
        "new_spellfist\\new_spellfist_water_bottom\\new_spellfist_water_bottom.str": "mineffect\\new_spellfist\\new_spellfist_water_bottom\\new_spellfist_water_bottom.str",
        "new_spellfist\\new_spellfist_wind\\new_spellfist_wind.str": "mineffect\\new_spellfist\\new_spellfist_wind\\new_spellfist_wind.str",
        "new_cartboost\\new_cartboost\\new_cartboost.str": "mineffect\\new_cartboost\\new_cartboost\\new_cartboost.str",
        "new_cartboost\\new_cartboost_bottom\\new_cartboost_bottom.str": "mineffect\\new_cartboost\\new_cartboost_bottom\\new_cartboost_bottom.str",
        "new_overbrand\\new_overbrand_01_clock\\new_overbrand_01_clock.str": "mineffect\\new_overbrand\\new_overbrand_01_clock\\new_overbrand_01_clock.str",
        "new_overbrand\\new_overbrand_03_clock\\new_overbrand_03_clock.str": "mineffect\\new_overbrand\\new_overbrand_03_clock\\new_overbrand_03_clock.str",
        "new_overbrand\\new_overbrand_05_clock\\new_overbrand_05_clock.str": "mineffect\\new_overbrand\\new_overbrand_05_clock\\new_overbrand_05_clock.str",
        "new_overbrand\\new_overbrand_06_clock\\new_overbrand_06_clock.str": "mineffect\\new_overbrand\\new_overbrand_06_clock\\new_overbrand_06_clock.str",
        "new_overbrand\\new_overbrand_07_clock\\new_overbrand_07_clock.str": "mineffect\\new_overbrand\\new_overbrand_07_clock\\new_overbrand_07_clock.str",
        "new_overbrand\\new_overbrand_09_clock\\new_overbrand_09_clock.str": "mineffect\\new_overbrand\\new_overbrand_09_clock\\new_overbrand_09_clock.str",
        "new_overbrand\\new_overbrand_11_clock\\new_overbrand_11_clock.str": "mineffect\\new_overbrand\\new_overbrand_11_clock\\new_overbrand_11_clock.str",
        "new_overbrand\\new_overbrand_12_clock\\new_overbrand_12_clock.str": "mineffect\\new_overbrand\\new_overbrand_12_clock\\new_overbrand_12_clock.str",
        "new_overbrand\\new_overbrand_cast\\new_overbrand_cast.str": "mineffect\\new_overbrand\\new_overbrand_cast\\new_overbrand_cast.str",
        "new_overbrand\\new_overbrand_hit\\new_overbrand_hit.str": "mineffect\\new_overbrand\\new_overbrand_hit\\new_overbrand_hit.str",
        "new_windcutter\\new_windcutter\\new_windcutter.str": "mineffect\\new_windcutter\\new_windcutter\\new_windcutter.str",
        "new_windcutter\\new_windcutter_bottom_01clock\\new_windcutter_bottom_01clock.str": "mineffect\\new_windcutter\\new_windcutter_bottom_01clock\\new_windcutter_bottom_01clock.str",
        "new_windcutter\\new_windcutter_bottom_05clock\\new_windcutter_bottom_05clock.str": "mineffect\\new_windcutter\\new_windcutter_bottom_05clock\\new_windcutter_bottom_05clock.str",
        "new_windcutter\\new_windcutter_target\\new_windcutter_target.str": "mineffect\\new_windcutter\\new_windcutter_target\\new_windcutter_target.str",
        "new_powerswing\\new_powerwing_01_clock\\new_powerwing_01_clock.str": "mineffect\\new_powerswing\\new_powerswing_01_clock\\new_powerswing_01_clock.str",
        "new_powerswing\\new_powerwing_05_clock\\new_powerwing_05_clock.str": "mineffect\\new_powerswing\\new_powerswing_05_clock\\new_powerswing_05_clock.str",
        "new_powerswing\\new_powerwing_07_clock\\new_powerwing_07_clock.str": "mineffect\\new_powerswing\\new_powerswing_07_clock\\new_powerswing_07_clock.str",
        "new_powerswing\\new_powerwing_11_clock\\new_powerwing_11_clock.str": "mineffect\\new_powerswing\\new_powerswing_11_clock\\new_powerswing_11_clock.str",
        "new_powerswing\\new_powerswing_bottom\\new_powerswing_bottom.str": "mineffect\\new_powerswing\\new_powerswing_bottom\\new_powerswing_bottom.str",
        "new_vulcanarm\\new_vulcanarm\\new_vulcanarm.str": "mineffect\\new_vulcanarm\\new_vulcanarm\\new_vulcanarm.str",
        "new_vulcanarm\\new_vulcanarm_bottom\\new_vulcanarm_bottom.str": "mineffect\\new_vulcanarm\\new_vulcanarm_bottom\\new_vulcanarm_bottom.str",
        "new_vulcanarm\\new_vulcanarm_shothole\\new_vulcanarm_shothole.str": "mineffect\\new_vulcanarm\\new_vulcanarm_shothole\\new_vulcanarm_shothole.str",
        "new_earthdrive\\new_earthdrive\\new_earthdrive.str": "mineffect\\new_earthdrive\\new_earthdrive\\new_earthdrive.str",
        "new_earthdrive\\new_earthdrive_bottom\\new_earthdrive_bottom.str": "mineffect\\new_earthdrive\\new_earthdrive_bottom\\new_earthdrive_bottom.str",
        "new_earthdrive\\new_earthdrive_target\\new_earthdrive_target.str": "mineffect\\new_earthdrive\\new_earthdrive_target\\new_earthdrive_target.str",
        "new_autoshadowspell\\new_autoshadowspell\\new_autoshadowspell.str": "mineffect\\new_autoshadowspell\\new_autoshadowspell\\new_autoshadowspell.str",
        "new_autoshadowspell\\new_autoshadowspell_bottom\\new_autoshadowspell_bottom.str": "mineffect\\new_autoshadowspell\\new_autoshadowspell_bottom\\new_autoshadowspell_bottom.str",
        // Skills/*.cpp (4)
        "new_axeboomerang\\new_axeboomerang\\new_axeboomerang.str": "mineffect\\new_axeboomerang\\new_axeboomerang\\new_axeboomerang.str", // AxeBoomerang.cpp
        "new_cart_cannon\\new_cart_cannon\\new_cart_cannon.str": "mineffect\\new_cart_cannon\\new_cart_cannon\\new_cart_cannon.str", // CartCannon.cpp
        "new_triangleshot\\new_triangleshot_arrow\\new_triangleshot_arrow.str": "mineffect\\new_triangleshot\\new_triangleshot_arrow\\new_triangleshot_arrow.str", // TriangleShotArrow.cpp
        "new_severerainstorm\\new_severerainstorm\\new_severerainstorm.str": "mineffect\\new_severerainstorm\\new_severerainstorm\\new_severerainstorm.str", // MonsterSkillEffects.cpp
    ]

    /// Whether minimal effects (`TT_MIN_EFFECT_ON_OFF`) are enabled.
    public var useMinimalEffects: Bool
    private let resourceExists: @Sendable (String) -> Bool

    public init(
        useMinimalEffects: Bool = false,
        resourceExists: @escaping @Sendable (String) -> Bool = { _ in false }
    ) {
        self.useMinimalEffects = useMinimalEffects
        self.resourceExists = resourceExists
    }

    /// Returns the same-directory `min_`-prefixed candidate STR path matching
    /// `CEZ2STRParticle::ResolvePath()` (`^(.+\\)(\w+\.str)$`), or `nil` if
    /// `path` lacks a directory backslash prefix or a word-character `.str` filename.
    public static func minimalCandidateSTRPath(forPath path: String) -> String? {
        guard let separatorIndex = path.lastIndex(of: "\\"),
              separatorIndex > path.startIndex else {
            return nil
        }

        let directoryPrefix = path[...separatorIndex]
        guard !directoryPrefix.contains(where: \.isNewline) else {
            return nil
        }

        let filenameStart = path.index(after: separatorIndex)
        let filename = path[filenameStart...]
        guard filename.hasSuffix(".str") else {
            return nil
        }

        let stem = filename.dropLast(4)
        guard !stem.isEmpty, stem.unicodeScalars.allSatisfy(\.isASCIIWord) else {
            return nil
        }

        return "\(directoryPrefix)min_\(filename)"
    }

    /// Resolves an explicit `TT_MIN_EFFECT_ON_OFF` STR path replacement.
    public func resolveExplicitSTRPath(_ path: String) -> String {
        guard useMinimalEffects else {
            return path
        }
        return Self.explicitMinimalSTRPaths[path] ?? path
    }

    /// Resolves a STR path via `CEZ2STRParticle::Load` + `CEZ2STRParticle::ResolvePath`.
    public func resolveMinimalSTRPath(_ path: String) -> String {
        guard useMinimalEffects,
              let candidate = Self.minimalCandidateSTRPath(forPath: path),
              resourceExists(candidate) else {
            return path
        }
        return candidate
    }

    /// Resolves a STR path checking explicit minimal-effect replacements first,
    /// then falling back to the `min_` candidate check via `resolveMinimalSTRPath(_:)`.
    public func resolveSTRPath(_ path: String) -> String {
        guard useMinimalEffects else {
            return path
        }
        if let explicitPath = Self.explicitMinimalSTRPaths[path] {
            return explicitPath
        }
        return resolveMinimalSTRPath(path)
    }
}

private extension Unicode.Scalar {
    var isASCIIWord: Bool {
        switch value {
        case 0x30...0x39, 0x41...0x5A, 0x5F, 0x61...0x7A:
            true
        default:
            false
        }
    }
}
