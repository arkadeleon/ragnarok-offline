//
//  EffectPrimitiveID.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

/// Primitive type identifier used by `EffectPrimitive`, covering named `pp_*` constants
/// as well as unnamed numeric primitive IDs dispatched by the classic effect engine.
public struct EffectPrimitiveID: RawRepresentable, Hashable, Comparable, Sendable, ExpressibleByIntegerLiteral {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: Int) {
        self.rawValue = value
    }

    public static func < (lhs: EffectPrimitiveID, rhs: EffectPrimitiveID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension EffectPrimitiveID {
    public static let pp_2dtexture = EffectPrimitiveID(rawValue: 0)
    public static let pp_2dtextureorbit = EffectPrimitiveID(rawValue: 1)
    public static let pp_2dquad = EffectPrimitiveID(rawValue: 2)
    public static let pp_2dflash = EffectPrimitiveID(rawValue: 3)
    public static let pp_2dcircle = EffectPrimitiveID(rawValue: 4)
    public static let pp_3dparticle = EffectPrimitiveID(rawValue: 5)
    public static let pp_3dparticlegravity = EffectPrimitiveID(rawValue: 6)
    public static let pp_3dparticleorbit = EffectPrimitiveID(rawValue: 7)
    public static let pp_3dparticlespline = EffectPrimitiveID(rawValue: 8)
    public static let pp_3dquadhorn = EffectPrimitiveID(rawValue: 9)
    public static let pp_3dspline = EffectPrimitiveID(rawValue: 10)
    public static let pp_3dspiral = EffectPrimitiveID(rawValue: 11)
    public static let pp_3dcircle = EffectPrimitiveID(rawValue: 12)
    public static let pp_3dcylinder = EffectPrimitiveID(rawValue: 13)
    public static let pp_3dsphere = EffectPrimitiveID(rawValue: 14)
    public static let pp_3dtexture = EffectPrimitiveID(rawValue: 15)
    public static let pp_3dcrosstexture = EffectPrimitiveID(rawValue: 16)
    public static let pp_3dcylinderhalf = EffectPrimitiveID(rawValue: 18)
    public static let pp_3dflash = EffectPrimitiveID(rawValue: 19)
    public static let pp_3dline = EffectPrimitiveID(rawValue: 20)
    public static let pp_3dparticle_nomaster = EffectPrimitiveID(rawValue: 21)
    public static let pp_3dtexture_nomaster = EffectPrimitiveID(rawValue: 22)
    public static let pp_3dcasting = EffectPrimitiveID(rawValue: 23)
    public static let pp_3dcasting_2 = EffectPrimitiveID(rawValue: 24)
    public static let pp_3dcasting_3 = EffectPrimitiveID(rawValue: 25)
    public static let pp_mapparticle = EffectPrimitiveID(rawValue: 27)
    public static let pp_gi_3 = EffectPrimitiveID(rawValue: 34)
    public static let pp_grandcross2 = EffectPrimitiveID(rawValue: 37)
    public static let pp_linelink = EffectPrimitiveID(rawValue: 38)
    public static let pp_sakura = EffectPrimitiveID(rawValue: 40)
    public static let pp_shieldboomerang = EffectPrimitiveID(rawValue: 42)
    public static let pp_intimidate = EffectPrimitiveID(rawValue: 43)
    public static let pp_teihit2 = EffectPrimitiveID(rawValue: 45)
    public static let pp_bottom = EffectPrimitiveID(rawValue: 47)
    public static let pp_bottom2 = EffectPrimitiveID(rawValue: 48)
    public static let pp_bottomout = EffectPrimitiveID(rawValue: 49)
    public static let pp_pokjuk = EffectPrimitiveID(rawValue: 52)
    public static let pp_throwitem = EffectPrimitiveID(rawValue: 53)
    public static let pp_chemicalprotection = EffectPrimitiveID(rawValue: 54)
    public static let pp_chemical2 = EffectPrimitiveID(rawValue: 55)
    public static let pp_chemical3 = EffectPrimitiveID(rawValue: 56)
    public static let pp_firstaid = EffectPrimitiveID(rawValue: 58)
    public static let pp_particle_up = EffectPrimitiveID(rawValue: 59)
    public static let pp_guard = EffectPrimitiveID(rawValue: 61)
    public static let pp_wind = EffectPrimitiveID(rawValue: 62)
    public static let pp_rect_up = EffectPrimitiveID(rawValue: 64)
    public static let pp_3dcasting_4 = EffectPrimitiveID(rawValue: 65)
    public static let pp_forest = EffectPrimitiveID(rawValue: 66)
    public static let pp_asuracasting = EffectPrimitiveID(rawValue: 68)
    public static let pp_hitline = EffectPrimitiveID(rawValue: 70)
    public static let pp_blind = EffectPrimitiveID(rawValue: 71)
    public static let pp_magnum2 = EffectPrimitiveID(rawValue: 73)
    public static let pp_slash1 = EffectPrimitiveID(rawValue: 75)
    public static let pp_saintwing = EffectPrimitiveID(rawValue: 76)
    public static let pp_spherewind = EffectPrimitiveID(rawValue: 77)
    public static let pp_colorpaper = EffectPrimitiveID(rawValue: 78)
    public static let pp_ghost = EffectPrimitiveID(rawValue: 84)
    public static let pp_superangel = EffectPrimitiveID(rawValue: 85)
    public static let pp_rect_up2 = EffectPrimitiveID(rawValue: 90)
    public static let pp_spherewind2 = EffectPrimitiveID(rawValue: 91)
    public static let pp_rainbow = EffectPrimitiveID(rawValue: 93)
    public static let pp_peong = EffectPrimitiveID(rawValue: 94)
    public static let pp_effecttexture2 = EffectPrimitiveID(rawValue: 95)
    public static let pp_peongup = EffectPrimitiveID(rawValue: 96)
    public static let pp_tanji2 = EffectPrimitiveID(rawValue: 97)
    public static let pp_doublegumgang = EffectPrimitiveID(rawValue: 99)
    public static let pp_hitline3 = EffectPrimitiveID(rawValue: 100)
    public static let pp_electric = EffectPrimitiveID(rawValue: 101)
    public static let pp_electric2 = EffectPrimitiveID(rawValue: 102)
    public static let pp_halfsphere = EffectPrimitiveID(rawValue: 104)
    public static let pp_attackenergy2 = EffectPrimitiveID(rawValue: 106)
    public static let pp_3dcasting_5 = EffectPrimitiveID(rawValue: 107)
    public static let pp_flowercast = EffectPrimitiveID(rawValue: 108)
    public static let pp_soullink = EffectPrimitiveID(rawValue: 109)
    public static let pp_heal_low = EffectPrimitiveID(rawValue: 110)
    public static let pp_soulparticle = EffectPrimitiveID(rawValue: 111)
    public static let pp_hermode = EffectPrimitiveID(rawValue: 114)
    public static let pp_shieldboomerang3 = EffectPrimitiveID(rawValue: 116)
    public static let pp_3dquadhorn2 = EffectPrimitiveID(rawValue: 117)
    public static let pp_aciddemon = EffectPrimitiveID(rawValue: 118)
    public static let pp_sma = EffectPrimitiveID(rawValue: 120)
    public static let pp_sma2 = EffectPrimitiveID(rawValue: 121)
    public static let pp_twilight = EffectPrimitiveID(rawValue: 123)
    public static let pp_kouenka = EffectPrimitiveID(rawValue: 124)
    public static let pp_stin4 = EffectPrimitiveID(rawValue: 125)
    public static let pp_bubble_drop = EffectPrimitiveID(rawValue: 127)
    public static let pp_effecttexture_ani = EffectPrimitiveID(rawValue: 128)
}
