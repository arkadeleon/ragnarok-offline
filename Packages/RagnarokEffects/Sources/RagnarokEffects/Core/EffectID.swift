//
//  EffectID.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

/// Effect identifier covering built-in IDs (`-1...2483`), hat effects (`2485...`),
/// and data-driven `EZ2STREffect.bson` entries (`10000...`).
public struct EffectID: RawRepresentable, Hashable, Comparable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static func < (lhs: EffectID, rhs: EffectID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension EffectID {
    public static let ef_none = EffectID(rawValue: -1)
    public static let ef_hit1 = EffectID(rawValue: 0)
    public static let ef_hit2 = EffectID(rawValue: 1)
    public static let ef_hit3 = EffectID(rawValue: 2)
    public static let ef_hit4 = EffectID(rawValue: 3)
    public static let ef_hit5 = EffectID(rawValue: 4)
    public static let ef_hit6 = EffectID(rawValue: 5)
    public static let ef_entry = EffectID(rawValue: 6)
    public static let ef_exit = EffectID(rawValue: 7)
    public static let ef_warp = EffectID(rawValue: 8)
    public static let ef_enhance = EffectID(rawValue: 9)
    public static let ef_coin = EffectID(rawValue: 10)
    public static let ef_endure = EffectID(rawValue: 11)
    public static let ef_beginspell = EffectID(rawValue: 12)
    public static let ef_glasswall = EffectID(rawValue: 13)
    public static let ef_healsp = EffectID(rawValue: 14)
    public static let ef_soulstrike = EffectID(rawValue: 15)
    public static let ef_bash = EffectID(rawValue: 16)
    public static let ef_magnumbreak = EffectID(rawValue: 17)
    public static let ef_steal = EffectID(rawValue: 18)
    public static let ef_hiding = EffectID(rawValue: 19)
    public static let ef_pattack = EffectID(rawValue: 20)
    public static let ef_detoxication = EffectID(rawValue: 21)
    public static let ef_sight = EffectID(rawValue: 22)
    public static let ef_stonecurse = EffectID(rawValue: 23)
    public static let ef_fireball = EffectID(rawValue: 24)
    public static let ef_firewall = EffectID(rawValue: 25)
    public static let ef_icearrow = EffectID(rawValue: 26)
    public static let ef_frostdiver = EffectID(rawValue: 27)
    public static let ef_frostdiver2 = EffectID(rawValue: 28)
    public static let ef_lightbolt = EffectID(rawValue: 29)
    public static let ef_thunderstorm = EffectID(rawValue: 30)
    public static let ef_firearrow = EffectID(rawValue: 31)
    public static let ef_napalmbeat = EffectID(rawValue: 32)
    public static let ef_ruwach = EffectID(rawValue: 33)
    public static let ef_teleportation = EffectID(rawValue: 34)
    public static let ef_readyportal = EffectID(rawValue: 35)
    public static let ef_portal = EffectID(rawValue: 36)
    public static let ef_incagility = EffectID(rawValue: 37)
    public static let ef_decagility = EffectID(rawValue: 38)
    public static let ef_aqua = EffectID(rawValue: 39)
    public static let ef_signum = EffectID(rawValue: 40)
    public static let ef_angelus = EffectID(rawValue: 41)
    public static let ef_blessing = EffectID(rawValue: 42)
    public static let ef_incagidex = EffectID(rawValue: 43)
    public static let ef_smoke = EffectID(rawValue: 44)
    public static let ef_firefly = EffectID(rawValue: 45)
    public static let ef_sandwind = EffectID(rawValue: 46)
    public static let ef_torch = EffectID(rawValue: 47)
    public static let ef_spraypond = EffectID(rawValue: 48)
    public static let ef_firehit = EffectID(rawValue: 49)
    public static let ef_firesplashhit = EffectID(rawValue: 50)
    public static let ef_coldhit = EffectID(rawValue: 51)
    public static let ef_windhit = EffectID(rawValue: 52)
    public static let ef_poisonhit = EffectID(rawValue: 53)
    public static let ef_beginspell2 = EffectID(rawValue: 54)
    public static let ef_beginspell3 = EffectID(rawValue: 55)
    public static let ef_beginspell4 = EffectID(rawValue: 56)
    public static let ef_beginspell5 = EffectID(rawValue: 57)
    public static let ef_beginspell6 = EffectID(rawValue: 58)
    public static let ef_beginspell7 = EffectID(rawValue: 59)
    public static let ef_lockon = EffectID(rawValue: 60)
    public static let ef_warpzone = EffectID(rawValue: 61)
    public static let ef_sightrasher = EffectID(rawValue: 62)
    public static let ef_barrier = EffectID(rawValue: 63)
    public static let ef_arrowshot = EffectID(rawValue: 64)
    public static let ef_invenom = EffectID(rawValue: 65)
    public static let ef_cure = EffectID(rawValue: 66)
    public static let ef_provoke = EffectID(rawValue: 67)
    public static let ef_mvp = EffectID(rawValue: 68)
    public static let ef_skidtrap = EffectID(rawValue: 69)
    public static let ef_brandishspear = EffectID(rawValue: 70)
    public static let ef_cone = EffectID(rawValue: 71)
    public static let ef_sphere = EffectID(rawValue: 72)
    public static let ef_bowlingbash = EffectID(rawValue: 73)
    public static let ef_icewall = EffectID(rawValue: 74)
    public static let ef_gloria = EffectID(rawValue: 75)
    public static let ef_magnificat = EffectID(rawValue: 76)
    public static let ef_resurrection = EffectID(rawValue: 77)
    public static let ef_recovery = EffectID(rawValue: 78)
    public static let ef_earthspike = EffectID(rawValue: 79)
    public static let ef_spearbmr = EffectID(rawValue: 80)
    public static let ef_pierce = EffectID(rawValue: 81)
    public static let ef_turnundead = EffectID(rawValue: 82)
    public static let ef_sanctuary = EffectID(rawValue: 83)
    public static let ef_impositio = EffectID(rawValue: 84)
    public static let ef_lexaeterna = EffectID(rawValue: 85)
    public static let ef_aspersio = EffectID(rawValue: 86)
    public static let ef_lexdivina = EffectID(rawValue: 87)
    public static let ef_suffragium = EffectID(rawValue: 88)
    public static let ef_stormgust = EffectID(rawValue: 89)
    public static let ef_lord = EffectID(rawValue: 90)
    public static let ef_benedictio = EffectID(rawValue: 91)
    public static let ef_meteorstorm = EffectID(rawValue: 92)
    public static let ef_yufitel = EffectID(rawValue: 93)
    public static let ef_yufitelhit = EffectID(rawValue: 94)
    public static let ef_quagmire = EffectID(rawValue: 95)
    public static let ef_firepillar = EffectID(rawValue: 96)
    public static let ef_firepillarbomb = EffectID(rawValue: 97)
    public static let ef_hasteup = EffectID(rawValue: 98)
    public static let ef_flasher = EffectID(rawValue: 99)
    public static let ef_removetrap = EffectID(rawValue: 100)
    public static let ef_repairweapon = EffectID(rawValue: 101)
    public static let ef_crashearth = EffectID(rawValue: 102)
    public static let ef_perfection = EffectID(rawValue: 103)
    public static let ef_maxpower = EffectID(rawValue: 104)
    public static let ef_blastmine = EffectID(rawValue: 105)
    public static let ef_blastminebomb = EffectID(rawValue: 106)
    public static let ef_claymore = EffectID(rawValue: 107)
    public static let ef_freezing = EffectID(rawValue: 108)
    public static let ef_bubble = EffectID(rawValue: 109)
    public static let ef_gaspush = EffectID(rawValue: 110)
    public static let ef_springtrap = EffectID(rawValue: 111)
    public static let ef_kyrie = EffectID(rawValue: 112)
    public static let ef_magnus = EffectID(rawValue: 113)
    public static let ef_bottom = EffectID(rawValue: 114)
    public static let ef_blitzbeat = EffectID(rawValue: 115)
    public static let ef_waterball = EffectID(rawValue: 116)
    public static let ef_waterball2 = EffectID(rawValue: 117)
    public static let ef_fireivy = EffectID(rawValue: 118)
    public static let ef_detecting = EffectID(rawValue: 119)
    public static let ef_cloaking = EffectID(rawValue: 120)
    public static let ef_sonicblow = EffectID(rawValue: 121)
    public static let ef_sonicblowhit = EffectID(rawValue: 122)
    public static let ef_grimtooth = EffectID(rawValue: 123)
    public static let ef_venomdust = EffectID(rawValue: 124)
    public static let ef_enchantpoison = EffectID(rawValue: 125)
    public static let ef_poisonreact = EffectID(rawValue: 126)
    public static let ef_poisonreact2 = EffectID(rawValue: 127)
    public static let ef_overthrust = EffectID(rawValue: 128)
    public static let ef_splasher = EffectID(rawValue: 129)
    public static let ef_twohandquicken = EffectID(rawValue: 130)
    public static let ef_autocounter = EffectID(rawValue: 131)
    public static let ef_grimtoothatk = EffectID(rawValue: 132)
    public static let ef_freeze = EffectID(rawValue: 133)
    public static let ef_freezed = EffectID(rawValue: 134)
    public static let ef_icecrash = EffectID(rawValue: 135)
    public static let ef_slowpoison = EffectID(rawValue: 136)
    public static let ef_bottom2 = EffectID(rawValue: 137)
    public static let ef_firepillaron = EffectID(rawValue: 138)
    public static let ef_sandman = EffectID(rawValue: 139)
    public static let ef_revive = EffectID(rawValue: 140)
    public static let ef_pneuma = EffectID(rawValue: 141)
    public static let ef_heavensdrive = EffectID(rawValue: 142)
    public static let ef_sonicblow2 = EffectID(rawValue: 143)
    public static let ef_brandish2 = EffectID(rawValue: 144)
    public static let ef_shockwave = EffectID(rawValue: 145)
    public static let ef_shockwavehit = EffectID(rawValue: 146)
    public static let ef_earthhit = EffectID(rawValue: 147)
    public static let ef_pierceself = EffectID(rawValue: 148)
    public static let ef_bowlingself = EffectID(rawValue: 149)
    public static let ef_spearstabself = EffectID(rawValue: 150)
    public static let ef_spearbmrself = EffectID(rawValue: 151)
    public static let ef_holyhit = EffectID(rawValue: 152)
    public static let ef_concentration = EffectID(rawValue: 153)
    public static let ef_refineok = EffectID(rawValue: 154)
    public static let ef_refinefail = EffectID(rawValue: 155)
    public static let ef_jobchange = EffectID(rawValue: 156)
    public static let ef_lvup = EffectID(rawValue: 157)
    public static let ef_joblvup = EffectID(rawValue: 158)
    public static let ef_toprank = EffectID(rawValue: 159)
    public static let ef_party = EffectID(rawValue: 160)
    public static let ef_rain = EffectID(rawValue: 161)
    public static let ef_snow = EffectID(rawValue: 162)
    public static let ef_sakura = EffectID(rawValue: 163)
    public static let ef_status_state = EffectID(rawValue: 164)
    public static let ef_banjjakii = EffectID(rawValue: 165)
    public static let ef_makeblur = EffectID(rawValue: 166)
    public static let ef_tamingsuccess = EffectID(rawValue: 167)
    public static let ef_tamingfailed = EffectID(rawValue: 168)
    public static let ef_energycoat = EffectID(rawValue: 169)
    public static let ef_cartrevolution = EffectID(rawValue: 170)
    public static let ef_venomdust2 = EffectID(rawValue: 171)
    public static let ef_changedark = EffectID(rawValue: 172)
    public static let ef_changefire = EffectID(rawValue: 173)
    public static let ef_changecold = EffectID(rawValue: 174)
    public static let ef_changewind = EffectID(rawValue: 175)
    public static let ef_changeflame = EffectID(rawValue: 176)
    public static let ef_changeearth = EffectID(rawValue: 177)
    public static let ef_chaingeholy = EffectID(rawValue: 178)
    public static let ef_changepoison = EffectID(rawValue: 179)
    public static let ef_hitdark = EffectID(rawValue: 180)
    public static let ef_mentalbreak = EffectID(rawValue: 181)
    public static let ef_magicalatthit = EffectID(rawValue: 182)
    public static let ef_sui_explosion = EffectID(rawValue: 183)
    public static let ef_darkattack = EffectID(rawValue: 184)
    public static let ef_suicide = EffectID(rawValue: 185)
    public static let ef_comboattack1 = EffectID(rawValue: 186)
    public static let ef_comboattack2 = EffectID(rawValue: 187)
    public static let ef_comboattack3 = EffectID(rawValue: 188)
    public static let ef_comboattack4 = EffectID(rawValue: 189)
    public static let ef_comboattack5 = EffectID(rawValue: 190)
    public static let ef_guidedattack = EffectID(rawValue: 191)
    public static let ef_poisonattack = EffectID(rawValue: 192)
    public static let ef_silenceattack = EffectID(rawValue: 193)
    public static let ef_stunattack = EffectID(rawValue: 194)
    public static let ef_petrifyattack = EffectID(rawValue: 195)
    public static let ef_curseattack = EffectID(rawValue: 196)
    public static let ef_sleepattack = EffectID(rawValue: 197)
    public static let ef_telekhit = EffectID(rawValue: 198)
    public static let ef_pong = EffectID(rawValue: 199)
    public static let ef_level99 = EffectID(rawValue: 200)
    public static let ef_level99_2 = EffectID(rawValue: 201)
    public static let ef_level99_3 = EffectID(rawValue: 202)
    public static let ef_gumgang = EffectID(rawValue: 203)
    public static let ef_potion1 = EffectID(rawValue: 204)
    public static let ef_potion2 = EffectID(rawValue: 205)
    public static let ef_potion3 = EffectID(rawValue: 206)
    public static let ef_potion4 = EffectID(rawValue: 207)
    public static let ef_potion5 = EffectID(rawValue: 208)
    public static let ef_potion6 = EffectID(rawValue: 209)
    public static let ef_potion7 = EffectID(rawValue: 210)
    public static let ef_potion8 = EffectID(rawValue: 211)
    public static let ef_darkbreath = EffectID(rawValue: 212)
    public static let ef_deffender = EffectID(rawValue: 213)
    public static let ef_keeping = EffectID(rawValue: 214)
    public static let ef_summonslave = EffectID(rawValue: 215)
    public static let ef_blooddrain = EffectID(rawValue: 216)
    public static let ef_energydrain = EffectID(rawValue: 217)
    public static let ef_potion_con = EffectID(rawValue: 218)
    public static let ef_potion_ = EffectID(rawValue: 219)
    public static let ef_potion_berserk = EffectID(rawValue: 220)
    public static let ef_potionpillar = EffectID(rawValue: 221)
    public static let ef_defender = EffectID(rawValue: 222)
    public static let ef_ganbantein = EffectID(rawValue: 223)
    public static let ef_wind = EffectID(rawValue: 224)
    public static let ef_volcano = EffectID(rawValue: 225)
    public static let ef_grandcross = EffectID(rawValue: 226)
    public static let ef_intimidate = EffectID(rawValue: 227)
    public static let ef_chookgi = EffectID(rawValue: 228)
    public static let ef_cloud = EffectID(rawValue: 229)
    public static let ef_cloud2 = EffectID(rawValue: 230)
    public static let ef_mappillar = EffectID(rawValue: 231)
    public static let ef_linelink = EffectID(rawValue: 232)
    public static let ef_cloud3 = EffectID(rawValue: 233)
    public static let ef_spellbreaker = EffectID(rawValue: 234)
    public static let ef_dispell = EffectID(rawValue: 235)
    public static let ef_deluge = EffectID(rawValue: 236)
    public static let ef_violentgale = EffectID(rawValue: 237)
    public static let ef_landprotector = EffectID(rawValue: 238)
    public static let ef_bottom_vo = EffectID(rawValue: 239)
    public static let ef_bottom_de = EffectID(rawValue: 240)
    public static let ef_bottom_vi = EffectID(rawValue: 241)
    public static let ef_bottom_la = EffectID(rawValue: 242)
    public static let ef_fastmove = EffectID(rawValue: 243)
    public static let ef_magicrod = EffectID(rawValue: 244)
    public static let ef_holycross = EffectID(rawValue: 245)
    public static let ef_shieldcharge = EffectID(rawValue: 246)
    public static let ef_mappillar2 = EffectID(rawValue: 247)
    public static let ef_providence = EffectID(rawValue: 248)
    public static let ef_shieldboomerang = EffectID(rawValue: 249)
    public static let ef_spearquicken = EffectID(rawValue: 250)
    public static let ef_devotion = EffectID(rawValue: 251)
    public static let ef_reflectshield = EffectID(rawValue: 252)
    public static let ef_absorbspirits = EffectID(rawValue: 253)
    public static let ef_steelbody = EffectID(rawValue: 254)
    public static let ef_flamelauncher = EffectID(rawValue: 255)
    public static let ef_frostweapon = EffectID(rawValue: 256)
    public static let ef_lightningloader = EffectID(rawValue: 257)
    public static let ef_seismicweapon = EffectID(rawValue: 258)
    public static let ef_mappillar3 = EffectID(rawValue: 259)
    public static let ef_mappillar4 = EffectID(rawValue: 260)
    public static let ef_gumgang2 = EffectID(rawValue: 261)
    public static let ef_teihit1 = EffectID(rawValue: 262)
    public static let ef_gumgang3 = EffectID(rawValue: 263)
    public static let ef_teihit2 = EffectID(rawValue: 264)
    public static let ef_tanji = EffectID(rawValue: 265)
    public static let ef_teihit1x = EffectID(rawValue: 266)
    public static let ef_chimto = EffectID(rawValue: 267)
    public static let ef_stealcoin = EffectID(rawValue: 268)
    public static let ef_stripweapon = EffectID(rawValue: 269)
    public static let ef_stripshield = EffectID(rawValue: 270)
    public static let ef_striparmor = EffectID(rawValue: 271)
    public static let ef_striphelm = EffectID(rawValue: 272)
    public static let ef_chaincombo = EffectID(rawValue: 273)
    public static let ef_rg_coin = EffectID(rawValue: 274)
    public static let ef_backstap = EffectID(rawValue: 275)
    public static let ef_teihit3 = EffectID(rawValue: 276)
    public static let ef_bottom_dissonance = EffectID(rawValue: 277)
    public static let ef_bottom_lullaby = EffectID(rawValue: 278)
    public static let ef_bottom_richmankim = EffectID(rawValue: 279)
    public static let ef_bottom_eternalchaos = EffectID(rawValue: 280)
    public static let ef_bottom_drumbattlefield = EffectID(rawValue: 281)
    public static let ef_bottom_ringnibelungen = EffectID(rawValue: 282)
    public static let ef_bottom_rokisweil = EffectID(rawValue: 283)
    public static let ef_bottom_intoabyss = EffectID(rawValue: 284)
    public static let ef_bottom_siegfried = EffectID(rawValue: 285)
    public static let ef_bottom_whistle = EffectID(rawValue: 286)
    public static let ef_bottom_assassincross = EffectID(rawValue: 287)
    public static let ef_bottom_poembragi = EffectID(rawValue: 288)
    public static let ef_bottom_appleidun = EffectID(rawValue: 289)
    public static let ef_bottom_uglydance = EffectID(rawValue: 290)
    public static let ef_bottom_humming = EffectID(rawValue: 291)
    public static let ef_bottom_dontforgetme = EffectID(rawValue: 292)
    public static let ef_bottom_fortunekiss = EffectID(rawValue: 293)
    public static let ef_bottom_serviceforyou = EffectID(rawValue: 294)
    public static let ef_talk_frostjoke = EffectID(rawValue: 295)
    public static let ef_talk_scream = EffectID(rawValue: 296)
    public static let ef_pokjuk = EffectID(rawValue: 297)
    public static let ef_throwitem = EffectID(rawValue: 298)
    public static let ef_throwitem2 = EffectID(rawValue: 299)
    public static let ef_chemicalprotection = EffectID(rawValue: 300)
    public static let ef_pokjuk_sound = EffectID(rawValue: 301)
    public static let ef_demonstration = EffectID(rawValue: 302)
    public static let ef_chemical2 = EffectID(rawValue: 303)
    public static let ef_teleportation2 = EffectID(rawValue: 304)
    public static let ef_pharmacy_ok = EffectID(rawValue: 305)
    public static let ef_pharmacy_fail = EffectID(rawValue: 306)
    public static let ef_forestlight = EffectID(rawValue: 307)
    public static let ef_throwitem3 = EffectID(rawValue: 308)
    public static let ef_firstaid = EffectID(rawValue: 309)
    public static let ef_sprinklesand = EffectID(rawValue: 310)
    public static let ef_loud = EffectID(rawValue: 311)
    public static let ef_heal = EffectID(rawValue: 312)
    public static let ef_heal2 = EffectID(rawValue: 313)
    public static let ef_exit2 = EffectID(rawValue: 314)
    public static let ef_glasswall2 = EffectID(rawValue: 315)
    public static let ef_readyportal2 = EffectID(rawValue: 316)
    public static let ef_portal2 = EffectID(rawValue: 317)
    public static let ef_bottom_mag = EffectID(rawValue: 318)
    public static let ef_bottom_sanc = EffectID(rawValue: 319)
    public static let ef_heal3 = EffectID(rawValue: 320)
    public static let ef_warpzone2 = EffectID(rawValue: 321)
    public static let ef_forestlight2 = EffectID(rawValue: 322)
    public static let ef_forestlight3 = EffectID(rawValue: 323)
    public static let ef_forestlight4 = EffectID(rawValue: 324)
    public static let ef_heal4 = EffectID(rawValue: 325)
    public static let ef_foot = EffectID(rawValue: 326)
    public static let ef_foot2 = EffectID(rawValue: 327)
    public static let ef_beginasura = EffectID(rawValue: 328)
    public static let ef_tripleattack = EffectID(rawValue: 329)
    public static let ef_hitline = EffectID(rawValue: 330)
    public static let ef_hptime = EffectID(rawValue: 331)
    public static let ef_sptime = EffectID(rawValue: 332)
    public static let ef_maple = EffectID(rawValue: 333)
    public static let ef_blind = EffectID(rawValue: 334)
    public static let ef_poison = EffectID(rawValue: 335)
    public static let ef_guard = EffectID(rawValue: 336)
    public static let ef_joblvup50 = EffectID(rawValue: 337)
    public static let ef_angel2 = EffectID(rawValue: 338)
    public static let ef_magnum2 = EffectID(rawValue: 339)
    public static let ef_callzone = EffectID(rawValue: 340)
    public static let ef_portal3 = EffectID(rawValue: 341)
    public static let ef_couplecasting = EffectID(rawValue: 342)
    public static let ef_heartcasting = EffectID(rawValue: 343)
    public static let ef_entry2 = EffectID(rawValue: 344)
    public static let ef_saintwing = EffectID(rawValue: 345)
    public static let ef_spherewind = EffectID(rawValue: 346)
    public static let ef_colorpaper = EffectID(rawValue: 347)
    public static let ef_lightsphere = EffectID(rawValue: 348)
    public static let ef_waterfall = EffectID(rawValue: 349)
    public static let ef_waterfall_90 = EffectID(rawValue: 350)
    public static let ef_waterfall_small = EffectID(rawValue: 351)
    public static let ef_waterfall_small_90 = EffectID(rawValue: 352)
    public static let ef_waterfall_t2 = EffectID(rawValue: 353)
    public static let ef_waterfall_t2_90 = EffectID(rawValue: 354)
    public static let ef_waterfall_small_t2 = EffectID(rawValue: 355)
    public static let ef_waterfall_small_t2_90 = EffectID(rawValue: 356)
    public static let ef_mini_tetris = EffectID(rawValue: 357)
    public static let ef_ghost = EffectID(rawValue: 358)
    public static let ef_bat = EffectID(rawValue: 359)
    public static let ef_bat2 = EffectID(rawValue: 360)
    public static let ef_soulbreaker = EffectID(rawValue: 361)
    public static let ef_level99_4 = EffectID(rawValue: 362)
    public static let ef_vallentine = EffectID(rawValue: 363)
    public static let ef_vallentine2 = EffectID(rawValue: 364)
    public static let ef_pressure = EffectID(rawValue: 365)
    public static let ef_bash3d = EffectID(rawValue: 366)
    public static let ef_aurablade = EffectID(rawValue: 367)
    public static let ef_redbody = EffectID(rawValue: 368)
    public static let ef_lkconcentration = EffectID(rawValue: 369)
    public static let ef_bottom_gospel = EffectID(rawValue: 370)
    public static let ef_angel = EffectID(rawValue: 371)
    public static let ef_devil = EffectID(rawValue: 372)
    public static let ef_dragonsmoke = EffectID(rawValue: 373)
    public static let ef_bottom_basilica = EffectID(rawValue: 374)
    public static let ef_assumptio = EffectID(rawValue: 375)
    public static let ef_hitline2 = EffectID(rawValue: 376)
    public static let ef_bash3d2 = EffectID(rawValue: 377)
    public static let ef_energydrain2 = EffectID(rawValue: 378)
    public static let ef_transbluebody = EffectID(rawValue: 379)
    public static let ef_magiccrasher = EffectID(rawValue: 380)
    public static let ef_lightsphere2 = EffectID(rawValue: 381)
    public static let ef_lightblade = EffectID(rawValue: 382)
    public static let ef_energydrain3 = EffectID(rawValue: 383)
    public static let ef_linelink2 = EffectID(rawValue: 384)
    public static let ef_linklight = EffectID(rawValue: 385)
    public static let ef_truesight = EffectID(rawValue: 386)
    public static let ef_falconassault = EffectID(rawValue: 387)
    public static let ef_tripleattack2 = EffectID(rawValue: 388)
    public static let ef_portal4 = EffectID(rawValue: 389)
    public static let ef_meltdown = EffectID(rawValue: 390)
    public static let ef_cartboost = EffectID(rawValue: 391)
    public static let ef_rejectsword = EffectID(rawValue: 392)
    public static let ef_tripleattack3 = EffectID(rawValue: 393)
    public static let ef_spherewind2 = EffectID(rawValue: 394)
    public static let ef_linelink3 = EffectID(rawValue: 395)
    public static let ef_pinkbody = EffectID(rawValue: 396)
    public static let ef_level99_5 = EffectID(rawValue: 397)
    public static let ef_level99_6 = EffectID(rawValue: 398)
    public static let ef_bash3d3 = EffectID(rawValue: 399)
    public static let ef_bash3d4 = EffectID(rawValue: 400)
    public static let ef_napalmvalcan = EffectID(rawValue: 401)
    public static let ef_portal5 = EffectID(rawValue: 402)
    public static let ef_magiccrasher2 = EffectID(rawValue: 403)
    public static let ef_bottom_spider = EffectID(rawValue: 404)
    public static let ef_bottom_fogwall = EffectID(rawValue: 405)
    public static let ef_soulburn = EffectID(rawValue: 406)
    public static let ef_soulchange = EffectID(rawValue: 407)
    public static let ef_baby = EffectID(rawValue: 408)
    public static let ef_soulbreaker2 = EffectID(rawValue: 409)
    public static let ef_rainbow = EffectID(rawValue: 410)
    public static let ef_peong = EffectID(rawValue: 411)
    public static let ef_tanji2 = EffectID(rawValue: 412)
    public static let ef_pressedbody = EffectID(rawValue: 413)
    public static let ef_spinedbody = EffectID(rawValue: 414)
    public static let ef_kickedbody = EffectID(rawValue: 415)
    public static let ef_airtexture = EffectID(rawValue: 416)
    public static let ef_hitbody = EffectID(rawValue: 417)
    public static let ef_doublegumgang = EffectID(rawValue: 418)
    public static let ef_reflectbody = EffectID(rawValue: 419)
    public static let ef_babybody = EffectID(rawValue: 420)
    public static let ef_babybody2 = EffectID(rawValue: 421)
    public static let ef_giantbody = EffectID(rawValue: 422)
    public static let ef_giantbody2 = EffectID(rawValue: 423)
    public static let ef_asurabody = EffectID(rawValue: 424)
    public static let ef_4waybody = EffectID(rawValue: 425)
    public static let ef_quakebody = EffectID(rawValue: 426)
    public static let ef_asurabody_monster = EffectID(rawValue: 427)
    public static let ef_hitline3 = EffectID(rawValue: 428)
    public static let ef_hitline4 = EffectID(rawValue: 429)
    public static let ef_hitline5 = EffectID(rawValue: 430)
    public static let ef_hitline6 = EffectID(rawValue: 431)
    public static let ef_electric = EffectID(rawValue: 432)
    public static let ef_electric2 = EffectID(rawValue: 433)
    public static let ef_hitline7 = EffectID(rawValue: 434)
    public static let ef_stormkick = EffectID(rawValue: 435)
    public static let ef_halfsphere = EffectID(rawValue: 436)
    public static let ef_attackenergy = EffectID(rawValue: 437)
    public static let ef_attackenergy2 = EffectID(rawValue: 438)
    public static let ef_chemical3 = EffectID(rawValue: 439)
    public static let ef_assumptio2 = EffectID(rawValue: 440)
    public static let ef_bluecasting = EffectID(rawValue: 441)
    public static let ef_run = EffectID(rawValue: 442)
    public static let ef_stoprun = EffectID(rawValue: 443)
    public static let ef_stopeffect = EffectID(rawValue: 444)
    public static let ef_jumpbody = EffectID(rawValue: 445)
    public static let ef_landbody = EffectID(rawValue: 446)
    public static let ef_foot3 = EffectID(rawValue: 447)
    public static let ef_foot4 = EffectID(rawValue: 448)
    public static let ef_tae_ready = EffectID(rawValue: 449)
    public static let ef_grandcross2 = EffectID(rawValue: 450)
    public static let ef_soulstrike2 = EffectID(rawValue: 451)
    public static let ef_yufitel2 = EffectID(rawValue: 452)
    public static let ef_npc_stop = EffectID(rawValue: 453)
    public static let ef_darkcasting = EffectID(rawValue: 454)
    public static let ef_gumgangnpc = EffectID(rawValue: 455)
    public static let ef_agiup = EffectID(rawValue: 456)
    public static let ef_jumpkick = EffectID(rawValue: 457)
    public static let ef_quakebody2 = EffectID(rawValue: 458)
    public static let ef_stormkick1 = EffectID(rawValue: 459)
    public static let ef_stormkick2 = EffectID(rawValue: 460)
    public static let ef_stormkick3 = EffectID(rawValue: 461)
    public static let ef_stormkick4 = EffectID(rawValue: 462)
    public static let ef_stormkick5 = EffectID(rawValue: 463)
    public static let ef_stormkick6 = EffectID(rawValue: 464)
    public static let ef_stormkick7 = EffectID(rawValue: 465)
    public static let ef_spinedbody2 = EffectID(rawValue: 466)
    public static let ef_beginasura1 = EffectID(rawValue: 467)
    public static let ef_beginasura2 = EffectID(rawValue: 468)
    public static let ef_beginasura3 = EffectID(rawValue: 469)
    public static let ef_beginasura4 = EffectID(rawValue: 470)
    public static let ef_beginasura5 = EffectID(rawValue: 471)
    public static let ef_beginasura6 = EffectID(rawValue: 472)
    public static let ef_beginasura7 = EffectID(rawValue: 473)
    public static let ef_aurablade2 = EffectID(rawValue: 474)
    public static let ef_devil1 = EffectID(rawValue: 475)
    public static let ef_devil2 = EffectID(rawValue: 476)
    public static let ef_devil3 = EffectID(rawValue: 477)
    public static let ef_devil4 = EffectID(rawValue: 478)
    public static let ef_devil5 = EffectID(rawValue: 479)
    public static let ef_devil6 = EffectID(rawValue: 480)
    public static let ef_devil7 = EffectID(rawValue: 481)
    public static let ef_devil8 = EffectID(rawValue: 482)
    public static let ef_devil9 = EffectID(rawValue: 483)
    public static let ef_devil10 = EffectID(rawValue: 484)
    public static let ef_doublegumgang2 = EffectID(rawValue: 485)
    public static let ef_doublegumgang3 = EffectID(rawValue: 486)
    public static let ef_blackdevil = EffectID(rawValue: 487)
    public static let ef_flowercast = EffectID(rawValue: 488)
    public static let ef_flowercast2 = EffectID(rawValue: 489)
    public static let ef_flowercast3 = EffectID(rawValue: 490)
    public static let ef_mochi = EffectID(rawValue: 491)
    public static let ef_lamadan = EffectID(rawValue: 492)
    public static let ef_edp = EffectID(rawValue: 493)
    public static let ef_shieldboomerang2 = EffectID(rawValue: 494)
    public static let ef_rg_coin2 = EffectID(rawValue: 495)
    public static let ef_guard2 = EffectID(rawValue: 496)
    public static let ef_slim = EffectID(rawValue: 497)
    public static let ef_slim2 = EffectID(rawValue: 498)
    public static let ef_slim3 = EffectID(rawValue: 499)
    public static let ef_chemicalbody = EffectID(rawValue: 500)
    public static let ef_castspin = EffectID(rawValue: 501)
    public static let ef_piercebody = EffectID(rawValue: 502)
    public static let ef_soullink = EffectID(rawValue: 503)
    public static let ef_chookgi2 = EffectID(rawValue: 504)
    public static let ef_memorize = EffectID(rawValue: 505)
    public static let ef_soullight = EffectID(rawValue: 506)
    public static let ef_mapae = EffectID(rawValue: 507)
    public static let ef_itempokjuk = EffectID(rawValue: 508)
    public static let ef_05val = EffectID(rawValue: 509)
    public static let ef_beginasura11 = EffectID(rawValue: 510)
    public static let ef_night = EffectID(rawValue: 511)
    public static let ef_chemical2dash = EffectID(rawValue: 512)
    public static let ef_groundsample = EffectID(rawValue: 513)
    public static let ef_gi_explosion = EffectID(rawValue: 514)
    public static let ef_cloud4 = EffectID(rawValue: 515)
    public static let ef_cloud5 = EffectID(rawValue: 516)
    public static let ef_bottom_hermode = EffectID(rawValue: 517)
    public static let ef_cartter = EffectID(rawValue: 518)
    public static let ef_itemfast = EffectID(rawValue: 519)
    public static let ef_shieldboomerang3 = EffectID(rawValue: 520)
    public static let ef_doublecastbody = EffectID(rawValue: 521)
    public static let ef_gravitation = EffectID(rawValue: 522)
    public static let ef_tarotcard1 = EffectID(rawValue: 523)
    public static let ef_tarotcard2 = EffectID(rawValue: 524)
    public static let ef_tarotcard3 = EffectID(rawValue: 525)
    public static let ef_tarotcard4 = EffectID(rawValue: 526)
    public static let ef_tarotcard5 = EffectID(rawValue: 527)
    public static let ef_tarotcard6 = EffectID(rawValue: 528)
    public static let ef_tarotcard7 = EffectID(rawValue: 529)
    public static let ef_tarotcard8 = EffectID(rawValue: 530)
    public static let ef_tarotcard9 = EffectID(rawValue: 531)
    public static let ef_tarotcard10 = EffectID(rawValue: 532)
    public static let ef_tarotcard11 = EffectID(rawValue: 533)
    public static let ef_tarotcard12 = EffectID(rawValue: 534)
    public static let ef_tarotcard13 = EffectID(rawValue: 535)
    public static let ef_tarotcard14 = EffectID(rawValue: 536)
    public static let ef_aciddemon = EffectID(rawValue: 537)
    public static let ef_greenbody = EffectID(rawValue: 538)
    public static let ef_throwitem4 = EffectID(rawValue: 539)
    public static let ef_babybody_back = EffectID(rawValue: 540)
    public static let ef_throwitem5 = EffectID(rawValue: 541)
    public static let ef_bluebody = EffectID(rawValue: 542)
    public static let ef_hated = EffectID(rawValue: 543)
    public static let ef_redlightbody = EffectID(rawValue: 544)
    public static let ef_ro2year = EffectID(rawValue: 545)
    public static let ef_sma_ready = EffectID(rawValue: 546)
    public static let ef_stin = EffectID(rawValue: 547)
    public static let ef_red_hit = EffectID(rawValue: 548)
    public static let ef_blue_hit = EffectID(rawValue: 549)
    public static let ef_quakebody3 = EffectID(rawValue: 550)
    public static let ef_sma = EffectID(rawValue: 551)
    public static let ef_sma2 = EffectID(rawValue: 552)
    public static let ef_stin2 = EffectID(rawValue: 553)
    public static let ef_hittexture = EffectID(rawValue: 554)
    public static let ef_stin3 = EffectID(rawValue: 555)
    public static let ef_sma3 = EffectID(rawValue: 556)
    public static let ef_bluefall = EffectID(rawValue: 557)
    public static let ef_bluefall_90 = EffectID(rawValue: 558)
    public static let ef_fastbluefall = EffectID(rawValue: 559)
    public static let ef_fastbluefall_90 = EffectID(rawValue: 560)
    public static let ef_big_portal = EffectID(rawValue: 561)
    public static let ef_big_portal2 = EffectID(rawValue: 562)
    public static let ef_screen_quake = EffectID(rawValue: 563)
    public static let ef_homuncasting = EffectID(rawValue: 564)
    public static let ef_hflimoon1 = EffectID(rawValue: 565)
    public static let ef_hflimoon2 = EffectID(rawValue: 566)
    public static let ef_hflimoon3 = EffectID(rawValue: 567)
    public static let ef_ho_up = EffectID(rawValue: 568)
    public static let ef_hamidefence = EffectID(rawValue: 569)
    public static let ef_hamicastle = EffectID(rawValue: 570)
    public static let ef_hamiblood = EffectID(rawValue: 571)
    public static let ef_hated2 = EffectID(rawValue: 572)
    public static let ef_twilight1 = EffectID(rawValue: 573)
    public static let ef_twilight2 = EffectID(rawValue: 574)
    public static let ef_twilight3 = EffectID(rawValue: 575)
    public static let ef_item_thunder = EffectID(rawValue: 576)
    public static let ef_item_cloud = EffectID(rawValue: 577)
    public static let ef_item_curse = EffectID(rawValue: 578)
    public static let ef_item_zzz = EffectID(rawValue: 579)
    public static let ef_item_rain = EffectID(rawValue: 580)
    public static let ef_item_light = EffectID(rawValue: 581)
    public static let ef_angel3 = EffectID(rawValue: 582)
    public static let ef_m01 = EffectID(rawValue: 583)
    public static let ef_m02 = EffectID(rawValue: 584)
    public static let ef_m03 = EffectID(rawValue: 585)
    public static let ef_m04 = EffectID(rawValue: 586)
    public static let ef_m05 = EffectID(rawValue: 587)
    public static let ef_m06 = EffectID(rawValue: 588)
    public static let ef_m07 = EffectID(rawValue: 589)
    public static let ef_kaizel = EffectID(rawValue: 590)
    public static let ef_kaahi = EffectID(rawValue: 591)
    public static let ef_cloud6 = EffectID(rawValue: 592)
    public static let ef_food01 = EffectID(rawValue: 593)
    public static let ef_food02 = EffectID(rawValue: 594)
    public static let ef_food03 = EffectID(rawValue: 595)
    public static let ef_food04 = EffectID(rawValue: 596)
    public static let ef_food05 = EffectID(rawValue: 597)
    public static let ef_food06 = EffectID(rawValue: 598)
    public static let ef_shrink = EffectID(rawValue: 599)
    public static let ef_throwitem6 = EffectID(rawValue: 600)
    public static let ef_sight2 = EffectID(rawValue: 601)
    public static let ef_quakebody4 = EffectID(rawValue: 602)
    public static let ef_firehit2 = EffectID(rawValue: 603)
    public static let ef_npc_stop2 = EffectID(rawValue: 604)
    public static let ef_npc_stop2_del = EffectID(rawValue: 605)
    public static let ef_fvoice = EffectID(rawValue: 606)
    public static let ef_wink = EffectID(rawValue: 607)
    public static let ef_cooking_ok = EffectID(rawValue: 608)
    public static let ef_cooking_fail = EffectID(rawValue: 609)
    public static let ef_temp_ok = EffectID(rawValue: 610)
    public static let ef_temp_fail = EffectID(rawValue: 611)
    public static let ef_hapgyeok = EffectID(rawValue: 612)
    public static let ef_throwitem7 = EffectID(rawValue: 613)
    public static let ef_throwitem8 = EffectID(rawValue: 614)
    public static let ef_throwitem9 = EffectID(rawValue: 615)
    public static let ef_throwitem10 = EffectID(rawValue: 616)
    public static let ef_bunsinjyutsu = EffectID(rawValue: 617)
    public static let ef_kouenka = EffectID(rawValue: 618)
    public static let ef_hyousensou = EffectID(rawValue: 619)
    public static let ef_bottom_suiton = EffectID(rawValue: 620)
    public static let ef_stin4 = EffectID(rawValue: 621)
    public static let ef_thunderstorm2 = EffectID(rawValue: 622)
    public static let ef_chemical4 = EffectID(rawValue: 623)
    public static let ef_stin5 = EffectID(rawValue: 624)
    public static let ef_madness_blue = EffectID(rawValue: 625)
    public static let ef_madness_red = EffectID(rawValue: 626)
    public static let ef_rg_coin3 = EffectID(rawValue: 627)
    public static let ef_bash3d5 = EffectID(rawValue: 628)
    public static let ef_chookgi3 = EffectID(rawValue: 629)
    public static let ef_kirikage = EffectID(rawValue: 630)
    public static let ef_tatami = EffectID(rawValue: 631)
    public static let ef_kasumikiri = EffectID(rawValue: 632)
    public static let ef_issen = EffectID(rawValue: 633)
    public static let ef_kaen = EffectID(rawValue: 634)
    public static let ef_baku = EffectID(rawValue: 635)
    public static let ef_hyousyouraku = EffectID(rawValue: 636)
    public static let ef_desperado = EffectID(rawValue: 637)
    public static let ef_lightning_s = EffectID(rawValue: 638)
    public static let ef_blind_s = EffectID(rawValue: 639)
    public static let ef_poison_s = EffectID(rawValue: 640)
    public static let ef_freezing_s = EffectID(rawValue: 641)
    public static let ef_flare_s = EffectID(rawValue: 642)
    public static let ef_rapidshower = EffectID(rawValue: 643)
    public static let ef_magicalbullet = EffectID(rawValue: 644)
    public static let ef_spreadattack = EffectID(rawValue: 645)
    public static let ef_trackcasting = EffectID(rawValue: 646)
    public static let ef_tracking = EffectID(rawValue: 647)
    public static let ef_tripleaction = EffectID(rawValue: 648)
    public static let ef_bullseye = EffectID(rawValue: 649)
    public static let ef_map_magiczone = EffectID(rawValue: 650)
    public static let ef_map_magiczone2 = EffectID(rawValue: 651)
    public static let ef_damage1 = EffectID(rawValue: 652)
    public static let ef_damage1_2 = EffectID(rawValue: 653)
    public static let ef_damage1_3 = EffectID(rawValue: 654)
    public static let ef_undeadbody = EffectID(rawValue: 655)
    public static let ef_undeadbody_del = EffectID(rawValue: 656)
    public static let ef_green_number = EffectID(rawValue: 657)
    public static let ef_blue_number = EffectID(rawValue: 658)
    public static let ef_red_number = EffectID(rawValue: 659)
    public static let ef_purple_number = EffectID(rawValue: 660)
    public static let ef_black_number = EffectID(rawValue: 661)
    public static let ef_white_number = EffectID(rawValue: 662)
    public static let ef_yellow_number = EffectID(rawValue: 663)
    public static let ef_pink_number = EffectID(rawValue: 664)
    public static let ef_bubble_drop = EffectID(rawValue: 665)
    public static let ef_npc_earthquake = EffectID(rawValue: 666)
    public static let ef_da_space = EffectID(rawValue: 667)
    public static let ef_dragonfear = EffectID(rawValue: 668)
    public static let ef_bleeding = EffectID(rawValue: 669)
    public static let ef_wideconfuse = EffectID(rawValue: 670)
    public static let ef_bottom_runner = EffectID(rawValue: 671)
    public static let ef_bottom_transfer = EffectID(rawValue: 672)
    public static let ef_crystal_blue = EffectID(rawValue: 673)
    public static let ef_bottom_evilland = EffectID(rawValue: 674)
    public static let ef_guard3 = EffectID(rawValue: 675)
    public static let ef_npc_slowcast = EffectID(rawValue: 676)
    public static let ef_criticalwound = EffectID(rawValue: 677)
    public static let ef_green99_3 = EffectID(rawValue: 678)
    public static let ef_green99_5 = EffectID(rawValue: 679)
    public static let ef_green99_6 = EffectID(rawValue: 680)
    public static let ef_mapsphere = EffectID(rawValue: 681)
    public static let ef_pok_love = EffectID(rawValue: 682)
    public static let ef_pok_white = EffectID(rawValue: 683)
    public static let ef_pok_valen = EffectID(rawValue: 684)
    public static let ef_pok_birth = EffectID(rawValue: 685)
    public static let ef_pok_christmas = EffectID(rawValue: 686)
    public static let ef_map_magiczone3 = EffectID(rawValue: 687)
    public static let ef_map_magiczone4 = EffectID(rawValue: 688)
    public static let ef_dust = EffectID(rawValue: 689)
    public static let ef_torch_red = EffectID(rawValue: 690)
    public static let ef_torch_green = EffectID(rawValue: 691)
    public static let ef_map_ghost = EffectID(rawValue: 692)
    public static let ef_glow1 = EffectID(rawValue: 693)
    public static let ef_glow2 = EffectID(rawValue: 694)
    public static let ef_glow4 = EffectID(rawValue: 695)
    public static let ef_torch_purple = EffectID(rawValue: 696)
    public static let ef_cloud7 = EffectID(rawValue: 697)
    public static let ef_cloud8 = EffectID(rawValue: 698)
    public static let ef_flowerleaf = EffectID(rawValue: 699)
    public static let ef_mapsphere2 = EffectID(rawValue: 700)
    public static let ef_glow11 = EffectID(rawValue: 701)
    public static let ef_glow12 = EffectID(rawValue: 702)
    public static let ef_circlelight = EffectID(rawValue: 703)
    public static let ef_item315 = EffectID(rawValue: 704)
    public static let ef_item316 = EffectID(rawValue: 705)
    public static let ef_item317 = EffectID(rawValue: 706)
    public static let ef_item318 = EffectID(rawValue: 707)
    public static let ef_storm_min = EffectID(rawValue: 708)
    public static let ef_pok_jap = EffectID(rawValue: 709)
    public static let ef_map_greenlight = EffectID(rawValue: 710)
    public static let ef_map_magicwall = EffectID(rawValue: 711)
    public static let ef_map_greenlight2 = EffectID(rawValue: 712)
    public static let ef_yellowfly1 = EffectID(rawValue: 713)
    public static let ef_yellowfly2 = EffectID(rawValue: 714)
    public static let ef_bottom_blue = EffectID(rawValue: 715)
    public static let ef_bottom_blue2 = EffectID(rawValue: 716)
    public static let ef_wewish = EffectID(rawValue: 717)
    public static let ef_firepillaron2 = EffectID(rawValue: 718)
    public static let ef_forestlight5 = EffectID(rawValue: 719)
    public static let ef_soulbreaker3 = EffectID(rawValue: 720)
    public static let ef_ado_str = EffectID(rawValue: 721)
    public static let ef_ign_str = EffectID(rawValue: 722)
    public static let ef_chimto2 = EffectID(rawValue: 723)
    public static let ef_windcutter = EffectID(rawValue: 724)
    public static let ef_detect2 = EffectID(rawValue: 725)
    public static let ef_frostmysty = EffectID(rawValue: 726)
    public static let ef_crimson_str = EffectID(rawValue: 727)
    public static let ef_hell_str = EffectID(rawValue: 728)
    public static let ef_spr_mash = EffectID(rawValue: 729)
    public static let ef_spr_soule = EffectID(rawValue: 730)
    public static let ef_dhowl_str = EffectID(rawValue: 731)
    public static let ef_earthwall = EffectID(rawValue: 732)
    public static let ef_soulbreaker4 = EffectID(rawValue: 733)
    public static let ef_chainl_str = EffectID(rawValue: 734)
    public static let ef_chookgi_fire = EffectID(rawValue: 735)
    public static let ef_chookgi_wind = EffectID(rawValue: 736)
    public static let ef_chookgi_water = EffectID(rawValue: 737)
    public static let ef_chookgi_ground = EffectID(rawValue: 738)
    public static let ef_magenta_trap = EffectID(rawValue: 739)
    public static let ef_cobalt_trap = EffectID(rawValue: 740)
    public static let ef_maize_trap = EffectID(rawValue: 741)
    public static let ef_verdure_trap = EffectID(rawValue: 742)
    public static let ef_normal_trap = EffectID(rawValue: 743)
    public static let ef_cloaking2 = EffectID(rawValue: 744)
    public static let ef_aimed_str = EffectID(rawValue: 745)
    public static let ef_arrowstorm_str = EffectID(rawValue: 746)
    public static let ef_laulamus_str = EffectID(rawValue: 747)
    public static let ef_lauagnus_str = EffectID(rawValue: 748)
    public static let ef_milshield_str = EffectID(rawValue: 749)
    public static let ef_concentration2 = EffectID(rawValue: 750)
    public static let ef_fireball2 = EffectID(rawValue: 751)
    public static let ef_bunsinjyutsu2 = EffectID(rawValue: 752)
    public static let ef_cleartime = EffectID(rawValue: 753)
    public static let ef_glasswall3 = EffectID(rawValue: 754)
    public static let ef_oratio = EffectID(rawValue: 755)
    public static let ef_potion_berserk2 = EffectID(rawValue: 756)
    public static let ef_circlepower = EffectID(rawValue: 757)
    public static let ef_rolling1 = EffectID(rawValue: 758)
    public static let ef_rolling2 = EffectID(rawValue: 759)
    public static let ef_rolling3 = EffectID(rawValue: 760)
    public static let ef_rolling4 = EffectID(rawValue: 761)
    public static let ef_rolling5 = EffectID(rawValue: 762)
    public static let ef_rolling6 = EffectID(rawValue: 763)
    public static let ef_rolling7 = EffectID(rawValue: 764)
    public static let ef_rolling8 = EffectID(rawValue: 765)
    public static let ef_rolling9 = EffectID(rawValue: 766)
    public static let ef_rolling10 = EffectID(rawValue: 767)
    public static let ef_purplebody = EffectID(rawValue: 768)
    public static let ef_stin6 = EffectID(rawValue: 769)
    public static let ef_rg_coin4 = EffectID(rawValue: 770)
    public static let ef_poisonwav = EffectID(rawValue: 771)
    public static let ef_poisonsmoke = EffectID(rawValue: 772)
    public static let ef_gumgang4 = EffectID(rawValue: 773)
    public static let ef_shieldboomerang4 = EffectID(rawValue: 774)
    public static let ef_castspin2 = EffectID(rawValue: 775)
    public static let ef_vulcanwav = EffectID(rawValue: 776)
    public static let ef_agiup2 = EffectID(rawValue: 777)
    public static let ef_detect3 = EffectID(rawValue: 778)
    public static let ef_agiup3 = EffectID(rawValue: 779)
    public static let ef_detect4 = EffectID(rawValue: 780)
    public static let ef_electric3 = EffectID(rawValue: 781)
    public static let ef_guard4 = EffectID(rawValue: 782)
    public static let ef_bottom_barrier = EffectID(rawValue: 783)
    public static let ef_bottom_stealth = EffectID(rawValue: 784)
    public static let ef_repairtime = EffectID(rawValue: 785)
    public static let ef_nc_anal = EffectID(rawValue: 786)
    public static let ef_firethrow = EffectID(rawValue: 787)
    public static let ef_venomimpress = EffectID(rawValue: 788)
    public static let ef_frostmisty = EffectID(rawValue: 789)
    public static let ef_burning = EffectID(rawValue: 790)
    public static let ef_coldthrow = EffectID(rawValue: 791)
    public static let ef_makehallu = EffectID(rawValue: 792)
    public static let ef_hallutime = EffectID(rawValue: 793)
    public static let ef_infraredscan = EffectID(rawValue: 794)
    public static let ef_crashaxe = EffectID(rawValue: 795)
    public static let ef_gthunder = EffectID(rawValue: 796)
    public static let ef_stonering = EffectID(rawValue: 797)
    public static let ef_intimidate2 = EffectID(rawValue: 798)
    public static let ef_stasis = EffectID(rawValue: 799)
    public static let ef_redline = EffectID(rawValue: 800)
    public static let ef_frostdiver3 = EffectID(rawValue: 801)
    public static let ef_bottom_basilica2 = EffectID(rawValue: 802)
    public static let ef_recognized = EffectID(rawValue: 803)
    public static let ef_tetra = EffectID(rawValue: 804)
    public static let ef_tetracasting = EffectID(rawValue: 805)
    public static let ef_fireball3 = EffectID(rawValue: 806)
    public static let ef_intimidate3 = EffectID(rawValue: 807)
    public static let ef_recognized2 = EffectID(rawValue: 808)
    public static let ef_cloaking3 = EffectID(rawValue: 809)
    public static let ef_intimidate4 = EffectID(rawValue: 810)
    public static let ef_stretch = EffectID(rawValue: 811)
    public static let ef_blackbody = EffectID(rawValue: 812)
    public static let ef_enervation = EffectID(rawValue: 813)
    public static let ef_enervation2 = EffectID(rawValue: 814)
    public static let ef_enervation3 = EffectID(rawValue: 815)
    public static let ef_enervation4 = EffectID(rawValue: 816)
    public static let ef_enervation5 = EffectID(rawValue: 817)
    public static let ef_enervation6 = EffectID(rawValue: 818)
    public static let ef_linelink4 = EffectID(rawValue: 819)
    public static let ef_rg_coin5 = EffectID(rawValue: 820)
    public static let ef_waterfall_ani = EffectID(rawValue: 821)
    public static let ef_bottom_manhole = EffectID(rawValue: 822)
    public static let ef_manhole = EffectID(rawValue: 823)
    public static let ef_makefeint = EffectID(rawValue: 824)
    public static let ef_forestlight6 = EffectID(rawValue: 825)
    public static let ef_darkcasting2 = EffectID(rawValue: 826)
    public static let ef_bottom_ani = EffectID(rawValue: 827)
    public static let ef_bottom_maelstrom = EffectID(rawValue: 828)
    public static let ef_bottom_bloodylust = EffectID(rawValue: 829)
    public static let ef_beginspell_n1 = EffectID(rawValue: 830)
    public static let ef_beginspell_n2 = EffectID(rawValue: 831)
    public static let ef_heal_n = EffectID(rawValue: 832)
    public static let ef_chookgi_n = EffectID(rawValue: 833)
    public static let ef_joblvup50_2 = EffectID(rawValue: 834)
    public static let ef_chemical2dash2 = EffectID(rawValue: 835)
    public static let ef_chemical2dash3 = EffectID(rawValue: 836)
    public static let ef_rollingcast = EffectID(rawValue: 837)
    public static let ef_water_below = EffectID(rawValue: 838)
    public static let ef_water_fade = EffectID(rawValue: 839)
    public static let ef_beginspell_n3 = EffectID(rawValue: 840)
    public static let ef_beginspell_n4 = EffectID(rawValue: 841)
    public static let ef_beginspell_n5 = EffectID(rawValue: 842)
    public static let ef_beginspell_n6 = EffectID(rawValue: 843)
    public static let ef_beginspell_n7 = EffectID(rawValue: 844)
    public static let ef_beginspell_n8 = EffectID(rawValue: 845)
    public static let ef_water_smoke = EffectID(rawValue: 846)
    public static let ef_dance1 = EffectID(rawValue: 847)
    public static let ef_dance2 = EffectID(rawValue: 848)
    public static let ef_linkparticle = EffectID(rawValue: 849)
    public static let ef_soullight2 = EffectID(rawValue: 850)
    public static let ef_spr_particle = EffectID(rawValue: 851)
    public static let ef_spr_particle2 = EffectID(rawValue: 852)
    public static let ef_spr_plant = EffectID(rawValue: 853)
    public static let ef_chemical_v = EffectID(rawValue: 854)
    public static let ef_shootparticle = EffectID(rawValue: 855)
    public static let ef_bot_reverb = EffectID(rawValue: 856)
    public static let ef_rain_particle = EffectID(rawValue: 857)
    public static let ef_chemical_v2 = EffectID(rawValue: 858)
    public static let ef_secra = EffectID(rawValue: 859)
    public static let ef_bot_reverb2 = EffectID(rawValue: 860)
    public static let ef_circlepower2 = EffectID(rawValue: 861)
    public static let ef_secra2 = EffectID(rawValue: 862)
    public static let ef_chemical_v3 = EffectID(rawValue: 863)
    public static let ef_enervation7 = EffectID(rawValue: 864)
    public static let ef_circlepower3 = EffectID(rawValue: 865)
    public static let ef_spr_plant2 = EffectID(rawValue: 866)
    public static let ef_circlepower4 = EffectID(rawValue: 867)
    public static let ef_spr_plant3 = EffectID(rawValue: 868)
    public static let ef_rg_coin6 = EffectID(rawValue: 869)
    public static let ef_spr_plant4 = EffectID(rawValue: 870)
    public static let ef_circlepower5 = EffectID(rawValue: 871)
    public static let ef_spr_plant5 = EffectID(rawValue: 872)
    public static let ef_circlepower6 = EffectID(rawValue: 873)
    public static let ef_spr_plant6 = EffectID(rawValue: 874)
    public static let ef_circlepower7 = EffectID(rawValue: 875)
    public static let ef_spr_plant7 = EffectID(rawValue: 876)
    public static let ef_circlepower8 = EffectID(rawValue: 877)
    public static let ef_spr_plant8 = EffectID(rawValue: 878)
    public static let ef_heartasura = EffectID(rawValue: 879)
    public static let ef_beginspell_150 = EffectID(rawValue: 880)
    public static let ef_level99_150 = EffectID(rawValue: 881)
    public static let ef_primecharge = EffectID(rawValue: 882)
    public static let ef_glasswall4 = EffectID(rawValue: 883)
    public static let ef_gradius_laser = EffectID(rawValue: 884)
    public static let ef_bash3d6 = EffectID(rawValue: 885)
    public static let ef_gumgang5 = EffectID(rawValue: 886)
    public static let ef_hitline8 = EffectID(rawValue: 887)
    public static let ef_electric4 = EffectID(rawValue: 888)
    public static let ef_teihit1t = EffectID(rawValue: 889)
    public static let ef_spinmove = EffectID(rawValue: 890)
    public static let ef_fireball4 = EffectID(rawValue: 891)
    public static let ef_tripleattack4 = EffectID(rawValue: 892)
    public static let ef_chemical3s = EffectID(rawValue: 893)
    public static let ef_groundshake = EffectID(rawValue: 894)
    public static let ef_dq9_charge = EffectID(rawValue: 895)
    public static let ef_dq9_charge2 = EffectID(rawValue: 896)
    public static let ef_dq9_charge3 = EffectID(rawValue: 897)
    public static let ef_dq9_charge4 = EffectID(rawValue: 898)
    public static let ef_blueline = EffectID(rawValue: 899)
    public static let ef_selfscroll = EffectID(rawValue: 900)
    public static let ef_spr_lightprint = EffectID(rawValue: 901)
    public static let ef_png_test = EffectID(rawValue: 902)
    public static let ef_beginspell_yb = EffectID(rawValue: 903)
    public static let ef_chemical2dash4 = EffectID(rawValue: 904)
    public static let ef_groundshake2 = EffectID(rawValue: 905)
    public static let ef_pressure2 = EffectID(rawValue: 906)
    public static let ef_rg_coin7 = EffectID(rawValue: 907)
    public static let ef_primecharge2 = EffectID(rawValue: 908)
    public static let ef_primecharge3 = EffectID(rawValue: 909)
    public static let ef_primecharge4 = EffectID(rawValue: 910)
    public static let ef_greencasting = EffectID(rawValue: 911)
    public static let ef_wallofthorn = EffectID(rawValue: 912)
    public static let ef_fireball5 = EffectID(rawValue: 913)
    public static let ef_throwitem11 = EffectID(rawValue: 914)
    public static let ef_spr_plant9 = EffectID(rawValue: 915)
    public static let ef_demonicfire = EffectID(rawValue: 916)
    public static let ef_demonicfire2 = EffectID(rawValue: 917)
    public static let ef_demonicfire3 = EffectID(rawValue: 918)
    public static let ef_hellsplant = EffectID(rawValue: 919)
    public static let ef_firewall2 = EffectID(rawValue: 920)
    public static let ef_vacuum = EffectID(rawValue: 921)
    public static let ef_spr_plant10 = EffectID(rawValue: 922)
    public static let ef_spr_lightprint2 = EffectID(rawValue: 923)
    public static let ef_poisonsmoke2 = EffectID(rawValue: 924)
    public static let ef_makehallu2 = EffectID(rawValue: 925)
    public static let ef_shockwave2 = EffectID(rawValue: 926)
    public static let ef_spr_plant11 = EffectID(rawValue: 927)
    public static let ef_coldthrow2 = EffectID(rawValue: 928)
    public static let ef_demonicfire4 = EffectID(rawValue: 929)
    public static let ef_pressure3 = EffectID(rawValue: 930)
    public static let ef_linkparticle2 = EffectID(rawValue: 931)
    public static let ef_soullight3 = EffectID(rawValue: 932)
    public static let ef_chareffect = EffectID(rawValue: 933)
    public static let ef_gumgang6 = EffectID(rawValue: 934)
    public static let ef_fireball6 = EffectID(rawValue: 935)
    public static let ef_gumgang7 = EffectID(rawValue: 936)
    public static let ef_gumgang8 = EffectID(rawValue: 937)
    public static let ef_gumgang9 = EffectID(rawValue: 938)
    public static let ef_bottom_de2 = EffectID(rawValue: 939)
    public static let ef_coldstatus = EffectID(rawValue: 940)
    public static let ef_spr_lightprint3 = EffectID(rawValue: 941)
    public static let ef_waterball3 = EffectID(rawValue: 942)
    public static let ef_heal_n2 = EffectID(rawValue: 943)
    public static let ef_rain_particle2 = EffectID(rawValue: 944)
    public static let ef_cloud9 = EffectID(rawValue: 945)
    public static let ef_yellowfly3 = EffectID(rawValue: 946)
    public static let ef_el_gust = EffectID(rawValue: 947)
    public static let ef_el_blast = EffectID(rawValue: 948)
    public static let ef_el_aquaplay = EffectID(rawValue: 949)
    public static let ef_el_upheaval = EffectID(rawValue: 950)
    public static let ef_el_wild_storm = EffectID(rawValue: 951)
    public static let ef_el_chilly_air = EffectID(rawValue: 952)
    public static let ef_el_cursed_soil = EffectID(rawValue: 953)
    public static let ef_el_cooler = EffectID(rawValue: 954)
    public static let ef_el_tropic = EffectID(rawValue: 955)
    public static let ef_el_pyrotechnic = EffectID(rawValue: 956)
    public static let ef_el_petrology = EffectID(rawValue: 957)
    public static let ef_el_heater = EffectID(rawValue: 958)
    public static let ef_poison_mist = EffectID(rawValue: 959)
    public static let ef_eraser_cutter = EffectID(rawValue: 960)
    public static let ef_silent_breeze = EffectID(rawValue: 961)
    public static let ef_magma_flow = EffectID(rawValue: 962)
    public static let ef_graybody = EffectID(rawValue: 963)
    public static let ef_lava_slide = EffectID(rawValue: 964)
    public static let ef_sonic_claw = EffectID(rawValue: 965)
    public static let ef_tinder_breaker = EffectID(rawValue: 966)
    public static let ef_midnight_frenzy = EffectID(rawValue: 967)
    public static let ef_macro = EffectID(rawValue: 968)
    public static let ef_chemical_allrange = EffectID(rawValue: 969)
    public static let ef_tetra_fire = EffectID(rawValue: 970)
    public static let ef_tetra_water = EffectID(rawValue: 971)
    public static let ef_tetra_wind = EffectID(rawValue: 972)
    public static let ef_tetra_ground = EffectID(rawValue: 973)
    public static let ef_emitter = EffectID(rawValue: 974)
    public static let ef_volcanic_ash = EffectID(rawValue: 975)
    public static let ef_level99_orb1 = EffectID(rawValue: 976)
    public static let ef_level99_orb2 = EffectID(rawValue: 977)
    public static let ef_level150 = EffectID(rawValue: 978)
    public static let ef_level150_sub = EffectID(rawValue: 979)
    public static let ef_throwitem4_1 = EffectID(rawValue: 980)
    public static let ef_throw_happokunai = EffectID(rawValue: 981)
    public static let ef_throw_multiple_coin = EffectID(rawValue: 982)
    public static let ef_throw_bakuretsu = EffectID(rawValue: 983)
    public static let ef_rotate_huumaranka = EffectID(rawValue: 984)
    public static let ef_rotate_bg = EffectID(rawValue: 985)
    public static let ef_rotate_line_gray = EffectID(rawValue: 986)
    public static let ef_2011rwc = EffectID(rawValue: 987)
    public static let ef_2011rwc2 = EffectID(rawValue: 988)
    public static let ef_kaihou = EffectID(rawValue: 989)
    public static let ef_ground_explosion = EffectID(rawValue: 990)
    public static let ef_kg_kagehumi = EffectID(rawValue: 991)
    public static let ef_ko_zenkai_water = EffectID(rawValue: 992)
    public static let ef_ko_zenkai_land = EffectID(rawValue: 993)
    public static let ef_ko_zenkai_fire = EffectID(rawValue: 994)
    public static let ef_ko_zenkai_wind = EffectID(rawValue: 995)
    public static let ef_ko_jyumonjikiri = EffectID(rawValue: 996)
    public static let ef_ko_setsudan = EffectID(rawValue: 997)
    public static let ef_red_cross = EffectID(rawValue: 998)
    public static let ef_ko_izayoi = EffectID(rawValue: 999)
    public static let ef_rotate_line_blue = EffectID(rawValue: 1000)
    public static let ef_kg_kyomu = EffectID(rawValue: 1001)
    public static let ef_ko_huumaranka = EffectID(rawValue: 1002)
    public static let ef_bluelightbody = EffectID(rawValue: 1003)
    public static let ef_kagemusya = EffectID(rawValue: 1004)
    public static let ef_ob_gensou = EffectID(rawValue: 1005)
    public static let ef_no100_firecracker = EffectID(rawValue: 1006)
    public static let ef_ko_makibishi = EffectID(rawValue: 1007)
    public static let ef_kaihou1 = EffectID(rawValue: 1008)
    public static let ef_akaitsuki = EffectID(rawValue: 1009)
    public static let ef_zangetsu = EffectID(rawValue: 1010)
    public static let ef_gensou = EffectID(rawValue: 1011)
    public static let ef_hat_effect = EffectID(rawValue: 1012)
    public static let ef_cherryblossom = EffectID(rawValue: 1013)
    public static let ef_event_cloud = EffectID(rawValue: 1014)
    public static let ef_run_make_ok = EffectID(rawValue: 1015)
    public static let ef_run_make_failure = EffectID(rawValue: 1016)
    public static let ef_miresult_make_ok = EffectID(rawValue: 1017)
    public static let ef_miresult_make_fail = EffectID(rawValue: 1018)
    public static let ef_all_ray_of_protection = EffectID(rawValue: 1019)
    public static let ef_venomfog = EffectID(rawValue: 1020)
    public static let ef_duststorm = EffectID(rawValue: 1021)
    public static let ef_level160 = EffectID(rawValue: 1022)
    public static let ef_level160_sub = EffectID(rawValue: 1023)
    public static let ef_mapchain = EffectID(rawValue: 1024)
    public static let ef_magic_floor = EffectID(rawValue: 1025)
    public static let ef_icemine = EffectID(rawValue: 1026)
    public static let ef_flamecorss = EffectID(rawValue: 1027)
    public static let ef_icemine_1 = EffectID(rawValue: 1028)
    public static let ef_dance_blade_atk = EffectID(rawValue: 1029)
    public static let ef_darkpiercing = EffectID(rawValue: 1030)
    public static let ef_invincibleoff2 = EffectID(rawValue: 1031)
    public static let ef_maxpain = EffectID(rawValue: 1032)
    public static let ef_deathsummon = EffectID(rawValue: 1033)
    public static let ef_moonstar = EffectID(rawValue: 1034)
    public static let ef_strangelights = EffectID(rawValue: 1035)
    public static let ef_super_star = EffectID(rawValue: 1036)
    public static let ef_yellobody = EffectID(rawValue: 1037)
    public static let ef_colorpaper2 = EffectID(rawValue: 1038)
    public static let ef_evils_paw = EffectID(rawValue: 1039)
    public static let ef_gc_darkcrow = EffectID(rawValue: 1040)
    public static let ef_rk_dragonbreath_water = EffectID(rawValue: 1041)
    public static let ef_all_full_throttle = EffectID(rawValue: 1042)
    public static let ef_sr_flashcombo = EffectID(rawValue: 1043)
    public static let ef_rk_luxanima = EffectID(rawValue: 1044)
    public static let ef_cloud10 = EffectID(rawValue: 1045)
    public static let ef_so_elemental_shield = EffectID(rawValue: 1046)
    public static let ef_ab_offertorium = EffectID(rawValue: 1047)
    public static let ef_wl_telekinesis_intense = EffectID(rawValue: 1048)
    public static let ef_gn_illusiondoping = EffectID(rawValue: 1049)
    public static let ef_nc_magma_eruption = EffectID(rawValue: 1050)
    public static let ef_lg_kings_grace = EffectID(rawValue: 1051)
    public static let ef_blooddrain2 = EffectID(rawValue: 1052)
    public static let ef_npc_wideweb = EffectID(rawValue: 1053)
    public static let ef_npc_burnt = EffectID(rawValue: 1054)
    public static let ef_npc_chill = EffectID(rawValue: 1055)
    public static let ef_ra_unlimit = EffectID(rawValue: 1056)
    public static let ef_ab_offertorium_ring = EffectID(rawValue: 1057)
    public static let ef_sc_escape = EffectID(rawValue: 1058)
    public static let ef_wm_frigg_song = EffectID(rawValue: 1059)
    public static let ef_flicker = EffectID(rawValue: 1060)
    public static let ef_c_maker = EffectID(rawValue: 1061)
    public static let ef_hammer_of_god = EffectID(rawValue: 1062)
    public static let ef_mass_spiral = EffectID(rawValue: 1063)
    public static let ef_fire_rain = EffectID(rawValue: 1064)
    public static let ef_whitebody = EffectID(rawValue: 1065)
    public static let ef_banishing_buster = EffectID(rawValue: 1066)
    public static let ef_slugshot = EffectID(rawValue: 1067)
    public static let ef_d_tail = EffectID(rawValue: 1068)
    public static let ef_bind_trap1 = EffectID(rawValue: 1069)
    public static let ef_bind_trap2 = EffectID(rawValue: 1070)
    public static let ef_bind_trap3 = EffectID(rawValue: 1071)
    public static let ef_jumpbody1 = EffectID(rawValue: 1072)
    public static let ef_animated_emitter = EffectID(rawValue: 1073)
    public static let ef_rl_explosion = EffectID(rawValue: 1074)
    public static let ef_c_maker_1 = EffectID(rawValue: 1075)
    public static let ef_qd_shot = EffectID(rawValue: 1076)
    public static let ef_p_alter = EffectID(rawValue: 1077)
    public static let ef_s_storm = EffectID(rawValue: 1078)
    public static let ef_music_hat = EffectID(rawValue: 1079)
    public static let ef_cloud_kill = EffectID(rawValue: 1080)
    public static let ef_escape = EffectID(rawValue: 1081)
    public static let ef_xeno_slasher = EffectID(rawValue: 1082)
    public static let ef_flowersmoke = EffectID(rawValue: 1083)
    public static let ef_fstone = EffectID(rawValue: 1084)
    public static let ef_qscaraba = EffectID(rawValue: 1085)
    public static let ef_ljosalfar = EffectID(rawValue: 1086)
    public static let ef_happinessstar = EffectID(rawValue: 1087)
    public static let ef_power_of_gaia = EffectID(rawValue: 1088)
    public static let ef_maple_falls = EffectID(rawValue: 1089)
    public static let ef_marking_use_changemonster = EffectID(rawValue: 1090)
    public static let ef_magical_feather = EffectID(rawValue: 1091)
    public static let ef_mermaid_longing = EffectID(rawValue: 1092)
    public static let ef_gift_of_snow = EffectID(rawValue: 1093)
    public static let ef_ach_complete = EffectID(rawValue: 1094)
    public static let ef_time_accessory = EffectID(rawValue: 1095)
    public static let ef_spritemable = EffectID(rawValue: 1096)
    public static let ef_tunaparty = EffectID(rawValue: 1097)
    public static let ef_freshshrimp = EffectID(rawValue: 1098)
    public static let ef_unk_1099 = EffectID(rawValue: 1099)
    public static let ef_unk_1100 = EffectID(rawValue: 1100)
    public static let ef_su_sv_stemspear = EffectID(rawValue: 1101)
    public static let ef_su_tunabelly = EffectID(rawValue: 1102)
    public static let ef_su_scratch = EffectID(rawValue: 1103)
    public static let ef_su_cn_powdering = EffectID(rawValue: 1104)
    public static let ef_su_bite = EffectID(rawValue: 1105)
    public static let ef_unk_1106 = EffectID(rawValue: 1106)
    public static let ef_su_scaroftarou = EffectID(rawValue: 1107)
    public static let ef_su_arclousedash = EffectID(rawValue: 1108)
    public static let ef_su_pickypeck = EffectID(rawValue: 1109)
    public static let ef_su_sv_roottwist = EffectID(rawValue: 1110)
    public static let ef_unk_1111 = EffectID(rawValue: 1111)
    public static let ef_unk_1112 = EffectID(rawValue: 1112)
    public static let ef_unk_1113 = EffectID(rawValue: 1113)
    public static let ef_warning_plane = EffectID(rawValue: 1114)
    public static let ef_su_cn_meteor = EffectID(rawValue: 1115)
    public static let ef_su_bunchofshrimp = EffectID(rawValue: 1116)
    public static let ef_unk_1117 = EffectID(rawValue: 1117)
    public static let ef_unk_1118 = EffectID(rawValue: 1118)
    public static let ef_bite_scar = EffectID(rawValue: 1119)
    public static let ef_su_lunatic_carrot_beat = EffectID(rawValue: 1120)
    public static let ef_wide_critical_wound = EffectID(rawValue: 1121)
    public static let ef_su_soul_attack = EffectID(rawValue: 1122)
    public static let ef_su_grooming = EffectID(rawValue: 1123)
    public static let ef_su_chattering = EffectID(rawValue: 1124)
    public static let ef_su_lope = EffectID(rawValue: 1125)
    public static let ef_su_hiss = EffectID(rawValue: 1126)
    public static let ef_su_powerofflock = EffectID(rawValue: 1127)
    public static let ef_unk_1128 = EffectID(rawValue: 1128)
    public static let ef_su_svg_spirit = EffectID(rawValue: 1129)
    public static let ef_bakuretsu_hadou = EffectID(rawValue: 1130)
    public static let ef_su_spirit_of_life = EffectID(rawValue: 1131)
    public static let ef_su_stoop = EffectID(rawValue: 1132)
    public static let ef_firedance = EffectID(rawValue: 1133)
    public static let ef_richs_coin_a = EffectID(rawValue: 1134)
    public static let ef_rl_b_trap = EffectID(rawValue: 1135)
    public static let ef_rl_anti_material_blast = EffectID(rawValue: 1136)
    public static let ef_e_chain = EffectID(rawValue: 1137)
    public static let ef_heat_barrel = EffectID(rawValue: 1138)
    public static let ef_h_mine = EffectID(rawValue: 1139)
    public static let ef_fallen_angel = EffectID(rawValue: 1140)
    public static let ef_we_oneforever = EffectID(rawValue: 1141)
    public static let ef_we_cheerup = EffectID(rawValue: 1142)
    public static let ef_unk_1143 = EffectID(rawValue: 1143)
    public static let ef_unk_1144 = EffectID(rawValue: 1144)
    public static let ef_rl_hammer_of_god = EffectID(rawValue: 1145)
    public static let ef_unk_1146 = EffectID(rawValue: 1146)
    public static let ef_popcorn = EffectID(rawValue: 1147)
    public static let ef_rl_r_trip = EffectID(rawValue: 1148)
    public static let ef_immune_property = EffectID(rawValue: 1149)
    public static let ef_move_coordinate = EffectID(rawValue: 1150)
    public static let ef_immune_property_nothing = EffectID(rawValue: 1151)
    public static let ef_immune_property_water = EffectID(rawValue: 1152)
    public static let ef_immune_property_ground = EffectID(rawValue: 1153)
    public static let ef_immune_property_fire = EffectID(rawValue: 1154)
    public static let ef_immune_property_wind = EffectID(rawValue: 1155)
    public static let ef_immune_property_poison = EffectID(rawValue: 1156)
    public static let ef_immune_property_saint = EffectID(rawValue: 1157)
    public static let ef_immune_property_darkness = EffectID(rawValue: 1158)
    public static let ef_immune_property_telekinesis = EffectID(rawValue: 1159)
    public static let ef_immune_property_undead = EffectID(rawValue: 1160)
    public static let ef_quagmire_visual = EffectID(rawValue: 1161)
    public static let ef_lord_of_vermillion_visual = EffectID(rawValue: 1162)
    public static let ef_meteor_storm_visual = EffectID(rawValue: 1163)
    public static let ef_unk_1164 = EffectID(rawValue: 1164)
    public static let ef_unk_1165 = EffectID(rawValue: 1165)
    public static let ef_unk_1166 = EffectID(rawValue: 1166)
    public static let ef_unk_1167 = EffectID(rawValue: 1167)
    public static let ef_unk_1168 = EffectID(rawValue: 1168)
    public static let ef_unk_1169 = EffectID(rawValue: 1169)
    public static let ef_unk_1170 = EffectID(rawValue: 1170)
    public static let ef_unk_1171 = EffectID(rawValue: 1171)
    public static let ef_unk_1172 = EffectID(rawValue: 1172)
    public static let ef_unk_1173 = EffectID(rawValue: 1173)
    public static let ef_unk_1174 = EffectID(rawValue: 1174)
    public static let ef_unk_1175 = EffectID(rawValue: 1175)
    public static let ef_unk_1176 = EffectID(rawValue: 1176)
    public static let ef_unk_1177 = EffectID(rawValue: 1177)
    public static let ef_unk_1178 = EffectID(rawValue: 1178)
    public static let ef_unk_1179 = EffectID(rawValue: 1179)
    public static let ef_unk_1180 = EffectID(rawValue: 1180)
    public static let ef_unk_1181 = EffectID(rawValue: 1181)
    public static let ef_unk_1182 = EffectID(rawValue: 1182)
    public static let ef_unk_1183 = EffectID(rawValue: 1183)
    public static let ef_unk_1184 = EffectID(rawValue: 1184)
    public static let ef_warpzone3 = EffectID(rawValue: 1185)
    public static let ef_dropitem_pink = EffectID(rawValue: 1186)
    public static let ef_unk_1187 = EffectID(rawValue: 1187)
    public static let ef_unk_1188 = EffectID(rawValue: 1188)
    public static let ef_dropitem_yellow = EffectID(rawValue: 1189)
    public static let ef_dropitem_purple = EffectID(rawValue: 1190)
    public static let ef_unk_1191 = EffectID(rawValue: 1191)
    public static let ef_random_opt_yellow = EffectID(rawValue: 1192)
    public static let ef_unk_1193 = EffectID(rawValue: 1193)
    public static let ef_unk_1194 = EffectID(rawValue: 1194)
    public static let ef_autoshadowspell_active = EffectID(rawValue: 1195)
    public static let ef_new_cloud_kill = EffectID(rawValue: 1196)
    public static let ef_lightsphere_sun = EffectID(rawValue: 1197)
    public static let ef_lightsphere_moon = EffectID(rawValue: 1198)
    public static let ef_lightsphere_star = EffectID(rawValue: 1199)
    public static let ef_thunder_plazma_blast = EffectID(rawValue: 1200)
    public static let ef_unk_1201 = EffectID(rawValue: 1201)
    public static let ef_novaexplosing = EffectID(rawValue: 1202)
    public static let ef_star_emperor = EffectID(rawValue: 1203)
    public static let ef_sma_black = EffectID(rawValue: 1204)
    public static let ef_sma_black2 = EffectID(rawValue: 1205)
    public static let ef_stin_black = EffectID(rawValue: 1206)
    public static let ef_peong_black = EffectID(rawValue: 1207)
    public static let ef_energydrain_black = EffectID(rawValue: 1208)
    public static let ef_blink_body = EffectID(rawValue: 1209)
    public static let ef_linelink5 = EffectID(rawValue: 1210)
    public static let ef_subject_aura_1211 = EffectID(rawValue: 1211)
    public static let ef_subject_aura_1212 = EffectID(rawValue: 1212)
    public static let ef_subject_aura_1213 = EffectID(rawValue: 1213)
    public static let ef_sun_stance = EffectID(rawValue: 1214)
    public static let ef_lunar_stance = EffectID(rawValue: 1215)
    public static let ef_star_stance = EffectID(rawValue: 1216)
    public static let ef_universe_stance = EffectID(rawValue: 1217)
    public static let ef_solarburst = EffectID(rawValue: 1218)
    public static let ef_sj_document = EffectID(rawValue: 1219)
    public static let ef_falling_star = EffectID(rawValue: 1220)
    public static let ef_flash_kick = EffectID(rawValue: 1221)
    public static let ef_soul_unity = EffectID(rawValue: 1222)
    public static let ef_stormkick8 = EffectID(rawValue: 1223)
    public static let ef_solar_explosion = EffectID(rawValue: 1224)
    public static let ef_soul_collect = EffectID(rawValue: 1225)
    public static let ef_level185 = EffectID(rawValue: 1226)
    public static let ef_level185_sub = EffectID(rawValue: 1227)
    public static let ef_soul_golem = EffectID(rawValue: 1228)
    public static let ef_newmoon_kick = EffectID(rawValue: 1229)
    public static let ef_fullmoon_kick = EffectID(rawValue: 1230)
    public static let ef_book_of_dimension = EffectID(rawValue: 1231)
    public static let ef_book_of_creatingstar = EffectID(rawValue: 1232)
    public static let ef_curse_explosion = EffectID(rawValue: 1233)
    public static let ef_soul_reaper = EffectID(rawValue: 1234)
    public static let ef_soul_shadow = EffectID(rawValue: 1235)
    public static let ef_soul_fairy = EffectID(rawValue: 1236)
    public static let ef_soul_falcon = EffectID(rawValue: 1237)
    public static let ef_soul_curse = EffectID(rawValue: 1238)
    public static let ef_prominence_kick = EffectID(rawValue: 1239)
    public static let ef_soul_reaper_collect = EffectID(rawValue: 1240)
    public static let ef_unk_1241 = EffectID(rawValue: 1241)
    public static let ef_soul_explosion = EffectID(rawValue: 1242)
    public static let ef_soul_revolve = EffectID(rawValue: 1243)
    public static let ef_test_effect_00 = EffectID(rawValue: 1244)
    public static let ef_test_effect_01 = EffectID(rawValue: 1245)
    public static let ef_test_effect_02 = EffectID(rawValue: 1246)
    public static let ef_test_effect_03 = EffectID(rawValue: 1247)
    public static let ef_test_effect_04 = EffectID(rawValue: 1248)
    public static let ef_test_effect_05 = EffectID(rawValue: 1249)
    public static let ef_test_effect_06 = EffectID(rawValue: 1250)
    public static let ef_test_effect_07 = EffectID(rawValue: 1251)
    public static let ef_test_effect_08 = EffectID(rawValue: 1252)
    public static let ef_test_effect_09 = EffectID(rawValue: 1253)
    public static let ef_new_meteorstorm = EffectID(rawValue: 1254)
    public static let ef_new_meteorstorm_bottom = EffectID(rawValue: 1255)
    public static let ef_unk_1256 = EffectID(rawValue: 1256)
    public static let ef_unk_1257 = EffectID(rawValue: 1257)
    public static let ef_new_adoramus = EffectID(rawValue: 1258)
    public static let ef_new_adoramus_bottom = EffectID(rawValue: 1259)
    public static let ef_tetra_vortex_cast = EffectID(rawValue: 1260)
    public static let ef_tetra_vortex_core = EffectID(rawValue: 1261)
    public static let ef_tetra_vortex_ball_1 = EffectID(rawValue: 1262)
    public static let ef_tetra_vortex_ball_2 = EffectID(rawValue: 1263)
    public static let ef_tetra_vortex_ball_3 = EffectID(rawValue: 1264)
    public static let ef_tetra_vortex_ball_4 = EffectID(rawValue: 1265)
    public static let ef_tetra_vortex_fire_exp = EffectID(rawValue: 1266)
    public static let ef_tetra_vortex_water_exp = EffectID(rawValue: 1267)
    public static let ef_tetra_vortex_wind_exp = EffectID(rawValue: 1268)
    public static let ef_tetra_vortex_earth_exp = EffectID(rawValue: 1269)
    public static let ef_tetra_vortex_fire_ground = EffectID(rawValue: 1270)
    public static let ef_tetra_vortex_water_ground = EffectID(rawValue: 1271)
    public static let ef_tetra_vortex_wind_ground = EffectID(rawValue: 1272)
    public static let ef_tetra_vortex_earth_ground = EffectID(rawValue: 1273)
    public static let ef_new_crimsonrock = EffectID(rawValue: 1274)
    public static let ef_new_crimsonrock_bottom = EffectID(rawValue: 1275)
    public static let ef_new_severerainstorm = EffectID(rawValue: 1276)
    public static let ef_tetra_vortex_core_ground = EffectID(rawValue: 1277)
    public static let ef_tetra_vortex_fire_sub = EffectID(rawValue: 1278)
    public static let ef_tetra_vortex_water_sub = EffectID(rawValue: 1279)
    public static let ef_tetra_vortex_wind_sub = EffectID(rawValue: 1280)
    public static let ef_tetra_vortex_earth_sub = EffectID(rawValue: 1281)
    public static let ef_new_diamonddust = EffectID(rawValue: 1282)
    public static let ef_new_diamonddust_bottom = EffectID(rawValue: 1283)
    public static let ef_new_diamonddust_cast = EffectID(rawValue: 1284)
    public static let ef_new_severerainstorm_cast = EffectID(rawValue: 1285)
    public static let ef_new_severerainstorm_hit = EffectID(rawValue: 1286)
    public static let ef_new_secrament = EffectID(rawValue: 1287)
    public static let ef_new_psychicwave = EffectID(rawValue: 1288)
    public static let ef_new_psychicwave_bottom = EffectID(rawValue: 1289)
    public static let ef_new_psychicwave_cast = EffectID(rawValue: 1290)
    public static let ef_unk_1291 = EffectID(rawValue: 1291)
    public static let ef_unk_1292 = EffectID(rawValue: 1292)
    public static let ef_new_arrowstorm_00 = EffectID(rawValue: 1293)
    public static let ef_new_arrowstorm_01 = EffectID(rawValue: 1294)
    public static let ef_new_secrament_aura = EffectID(rawValue: 1295)
    public static let ef_new_triangleshot = EffectID(rawValue: 1296)
    public static let ef_new_triangleshot_bottom = EffectID(rawValue: 1297)
    public static let ef_new_crimsonrock_sub = EffectID(rawValue: 1298)
    public static let ef_new_rollingcutter = EffectID(rawValue: 1299)
    public static let ef_new_rollingcutter_count_01 = EffectID(rawValue: 1300)
    public static let ef_new_rollingcutter_count_02 = EffectID(rawValue: 1301)
    public static let ef_new_rollingcutter_count_03 = EffectID(rawValue: 1302)
    public static let ef_new_rollingcutter_count_04 = EffectID(rawValue: 1303)
    public static let ef_new_rollingcutter_count_05 = EffectID(rawValue: 1304)
    public static let ef_new_rollingcutter_count_06 = EffectID(rawValue: 1305)
    public static let ef_new_rollingcutter_count_07 = EffectID(rawValue: 1306)
    public static let ef_new_rollingcutter_count_08 = EffectID(rawValue: 1307)
    public static let ef_new_rollingcutter_count_09 = EffectID(rawValue: 1308)
    public static let ef_new_rollingcutter_count_10 = EffectID(rawValue: 1309)
    public static let ef_new_rampageblaster = EffectID(rawValue: 1310)
    public static let ef_new_rampageblaster_bottom = EffectID(rawValue: 1311)
    public static let ef_new_feintbomb = EffectID(rawValue: 1312)
    public static let ef_new_feintbomb_bottom = EffectID(rawValue: 1313)
    public static let ef_new_crossripperslasher = EffectID(rawValue: 1314)
    public static let ef_new_crossripperslasher_00 = EffectID(rawValue: 1315)
    public static let ef_new_crossripperslasher_01 = EffectID(rawValue: 1316)
    public static let ef_new_crossripperslasher_03 = EffectID(rawValue: 1317)
    public static let ef_new_crossripperslasher_05 = EffectID(rawValue: 1318)
    public static let ef_new_crossripperslasher_06 = EffectID(rawValue: 1319)
    public static let ef_new_crossripperslasher_07 = EffectID(rawValue: 1320)
    public static let ef_new_crossripperslasher_09 = EffectID(rawValue: 1321)
    public static let ef_new_crossripperslasher_11 = EffectID(rawValue: 1322)
    public static let ef_new_tigercannon = EffectID(rawValue: 1323)
    public static let ef_new_triangleshot_arrow = EffectID(rawValue: 1324)
    public static let ef_unk_1325 = EffectID(rawValue: 1325)
    public static let ef_unk_1326 = EffectID(rawValue: 1326)
    public static let ef_unk_1327 = EffectID(rawValue: 1327)
    public static let ef_unk_1328 = EffectID(rawValue: 1328)
    public static let ef_unk_1329 = EffectID(rawValue: 1329)
    public static let ef_unk_1330 = EffectID(rawValue: 1330)
    public static let ef_unk_1331 = EffectID(rawValue: 1331)
    public static let ef_unk_1332 = EffectID(rawValue: 1332)
    public static let ef_unk_1333 = EffectID(rawValue: 1333)
    public static let ef_unk_1334 = EffectID(rawValue: 1334)
    public static let ef_unk_1335 = EffectID(rawValue: 1335)
    public static let ef_unk_1336 = EffectID(rawValue: 1336)
    public static let ef_unk_1337 = EffectID(rawValue: 1337)
    public static let ef_unk_1338 = EffectID(rawValue: 1338)
    public static let ef_unk_1339 = EffectID(rawValue: 1339)
    public static let ef_unk_1340 = EffectID(rawValue: 1340)
    public static let ef_unk_1341 = EffectID(rawValue: 1341)
    public static let ef_unk_1342 = EffectID(rawValue: 1342)
    public static let ef_unk_1343 = EffectID(rawValue: 1343)
    public static let ef_unk_1344 = EffectID(rawValue: 1344)
    public static let ef_unk_1345 = EffectID(rawValue: 1345)
    public static let ef_unk_1346 = EffectID(rawValue: 1346)
    public static let ef_new_armscannon_01_up = EffectID(rawValue: 1347)
    public static let ef_new_armscannon_01_down = EffectID(rawValue: 1348)
    public static let ef_new_armscannon_05_up = EffectID(rawValue: 1349)
    public static let ef_new_armscannon_05_down = EffectID(rawValue: 1350)
    public static let ef_new_armscannon_07_up = EffectID(rawValue: 1351)
    public static let ef_new_armscannon_07_down = EffectID(rawValue: 1352)
    public static let ef_new_armscannon_11_up = EffectID(rawValue: 1353)
    public static let ef_new_armscannon_11_down = EffectID(rawValue: 1354)
    public static let ef_new_armscannon_explosion = EffectID(rawValue: 1355)
    public static let ef_new_armscannon_explosion_bottom = EffectID(rawValue: 1356)
    public static let ef_new_cart_cannon = EffectID(rawValue: 1357)
    public static let ef_new_cart_cannon_explosion = EffectID(rawValue: 1358)
    public static let ef_new_cart_cannon_explosion_bottom = EffectID(rawValue: 1359)
    public static let ef_new_cart_cannon_fire = EffectID(rawValue: 1360)
    public static let ef_new_cart_cannon_fire_bottom = EffectID(rawValue: 1361)
    public static let ef_qscaraba_visual = EffectID(rawValue: 1362)
    public static let ef_new_axetornado = EffectID(rawValue: 1363)
    public static let ef_new_axetornado_bottom = EffectID(rawValue: 1364)
    public static let ef_new_cart_tornado = EffectID(rawValue: 1365)
    public static let ef_new_cart_tornado_bottom = EffectID(rawValue: 1366)
    public static let ef_help_angel = EffectID(rawValue: 1367)
    public static let ef_help_angel_bottom = EffectID(rawValue: 1368)
    public static let ef_new_banishingpoint_target = EffectID(rawValue: 1369)
    public static let ef_new_banishingpoint_target_bottom = EffectID(rawValue: 1370)
    public static let ef_new_banishingpoint_cast = EffectID(rawValue: 1371)
    public static let ef_new_banishingpoint_cast_bottom = EffectID(rawValue: 1372)
    public static let ef_new_banishingpoint_01 = EffectID(rawValue: 1373)
    public static let ef_new_banishingpoint_05 = EffectID(rawValue: 1374)
    public static let ef_new_banishingpoint_07 = EffectID(rawValue: 1375)
    public static let ef_new_banishingpoint_11 = EffectID(rawValue: 1376)
    public static let ef_valkyrie_wing = EffectID(rawValue: 1377)
    public static let ef_new_dragonbreath_bomb = EffectID(rawValue: 1378)
    public static let ef_new_dragonbreath_bomb_bottom = EffectID(rawValue: 1379)
    public static let ef_new_dragonbreath_01 = EffectID(rawValue: 1380)
    public static let ef_new_dragonbreath_05 = EffectID(rawValue: 1381)
    public static let ef_new_dragonbreath_07 = EffectID(rawValue: 1382)
    public static let ef_new_dragonbreath_11 = EffectID(rawValue: 1383)
    public static let ef_new_armscannon_cast = EffectID(rawValue: 1384)
    public static let ef_new_armscannon_cast_bottom = EffectID(rawValue: 1385)
    public static let ef_new_dragonbreath_water_bomb = EffectID(rawValue: 1386)
    public static let ef_new_dragonbreath_water_bomb_bottom = EffectID(rawValue: 1387)
    public static let ef_new_dragonbreath_water_01 = EffectID(rawValue: 1388)
    public static let ef_new_dragonbreath_water_05 = EffectID(rawValue: 1389)
    public static let ef_new_dragonbreath_water_07 = EffectID(rawValue: 1390)
    public static let ef_new_dragonbreath_water_11 = EffectID(rawValue: 1391)
    public static let ef_new_counter_slash = EffectID(rawValue: 1392)
    public static let ef_new_counter_slash_bottom = EffectID(rawValue: 1393)
    public static let ef_new_fatal_menace = EffectID(rawValue: 1394)
    public static let ef_new_fatal_menace_bottom = EffectID(rawValue: 1395)
    public static let ef_new_fatal_menace_cast = EffectID(rawValue: 1396)
    public static let ef_new_fatal_menace_cast_bottom = EffectID(rawValue: 1397)
    public static let ef_unk_1398 = EffectID(rawValue: 1398)
    public static let ef_new_heavens_drive = EffectID(rawValue: 1399)
    public static let ef_new_cannon_spear_12 = EffectID(rawValue: 1400)
    public static let ef_new_cannon_spear_01 = EffectID(rawValue: 1401)
    public static let ef_new_cannon_spear_03 = EffectID(rawValue: 1402)
    public static let ef_new_cannon_spear_05 = EffectID(rawValue: 1403)
    public static let ef_new_cannon_spear_06 = EffectID(rawValue: 1404)
    public static let ef_new_cannon_spear_07 = EffectID(rawValue: 1405)
    public static let ef_new_cannon_spear_09 = EffectID(rawValue: 1406)
    public static let ef_new_cannon_spear_11 = EffectID(rawValue: 1407)
    public static let ef_new_cannon_spear_bottom = EffectID(rawValue: 1408)
    public static let ef_new_tripleattack = EffectID(rawValue: 1409)
    public static let ef_new_basicattack = EffectID(rawValue: 1410)
    public static let ef_new_criticalattack = EffectID(rawValue: 1411)
    public static let ef_new_rangedattack = EffectID(rawValue: 1412)
    public static let ef_new_comet = EffectID(rawValue: 1413)
    public static let ef_new_comet_bottom = EffectID(rawValue: 1414)
    public static let ef_new_comet_cast_bottom = EffectID(rawValue: 1415)
    public static let ef_new_comet_sub_exp = EffectID(rawValue: 1416)
    public static let ef_new_comet_sub_exp_bottom = EffectID(rawValue: 1417)
    public static let ef_new_moon_slash = EffectID(rawValue: 1418)
    public static let ef_c_amdarais_effect = EffectID(rawValue: 1419)
    public static let ef_new_grandcross = EffectID(rawValue: 1420)
    public static let ef_new_comet_cast = EffectID(rawValue: 1421)
    public static let ef_new_cart_cannon_cast = EffectID(rawValue: 1422)
    public static let ef_new_cart_cannon_cast_bottom = EffectID(rawValue: 1423)
    public static let ef_new_rayofgenesis = EffectID(rawValue: 1424)
    public static let ef_new_rayofgenesis_cast = EffectID(rawValue: 1425)
    public static let ef_new_rayofgenesis_cast_bottom = EffectID(rawValue: 1426)
    public static let ef_new_rayofgenesis_hit = EffectID(rawValue: 1427)
    public static let ef_mineffect_adoramus = EffectID(rawValue: 1428)
    public static let ef_mineffect_adoramus_bottom = EffectID(rawValue: 1429)
    public static let ef_mineffect_tetra_cast = EffectID(rawValue: 1430)
    public static let ef_mineffect_tetra_core = EffectID(rawValue: 1431)
    public static let ef_mineffect_tetra_fire = EffectID(rawValue: 1432)
    public static let ef_mineffect_tetra_water = EffectID(rawValue: 1433)
    public static let ef_mineffect_tetra_wind = EffectID(rawValue: 1434)
    public static let ef_mineffect_tetra_earth = EffectID(rawValue: 1435)
    public static let ef_mineffect_tetra_fire_bottom = EffectID(rawValue: 1436)
    public static let ef_mineffect_tetra_water_bottom = EffectID(rawValue: 1437)
    public static let ef_mineffect_tetra_wind_bottom = EffectID(rawValue: 1438)
    public static let ef_mineffect_tetra_earth_bottom = EffectID(rawValue: 1439)
    public static let ef_mineffect_tetra_core_bottom = EffectID(rawValue: 1440)
    public static let ef_mineffect_crimsonrock = EffectID(rawValue: 1441)
    public static let ef_mineffect_crimsonrock_bottom = EffectID(rawValue: 1442)
    public static let ef_new_jackfrost_00 = EffectID(rawValue: 1443)
    public static let ef_new_jackfrost_01 = EffectID(rawValue: 1444)
    public static let ef_new_jackfrost_02 = EffectID(rawValue: 1445)
    public static let ef_new_jackfrost_cast = EffectID(rawValue: 1446)
    public static let ef_new_jackfrost_rune = EffectID(rawValue: 1447)
    public static let ef_new_jackfrost_art = EffectID(rawValue: 1448)
    public static let ef_new_frostmisty = EffectID(rawValue: 1449)
    public static let ef_mineffect_diamonddust = EffectID(rawValue: 1450)
    public static let ef_mineffect_diamonddust_bottom = EffectID(rawValue: 1451)
    public static let ef_mineffect_diamonddust_cast = EffectID(rawValue: 1452)
    public static let ef_mineffect_secrament = EffectID(rawValue: 1453)
    public static let ef_mineffect_psychicwave = EffectID(rawValue: 1454)
    public static let ef_mineffect_psychicwave_bottom = EffectID(rawValue: 1455)
    public static let ef_mineffect_psychicwave_cast = EffectID(rawValue: 1456)
    public static let ef_mineffect_arrowstorm_00 = EffectID(rawValue: 1457)
    public static let ef_mineffect_arrowstorm_01 = EffectID(rawValue: 1458)
    public static let ef_mineffect_triangleshot = EffectID(rawValue: 1459)
    public static let ef_mineffect_triangleshot_bottom = EffectID(rawValue: 1460)
    public static let ef_mineffect_rampageblaster = EffectID(rawValue: 1461)
    public static let ef_mineffect_rampageblaster_bottom = EffectID(rawValue: 1462)
    public static let ef_mineffect_feintbomb = EffectID(rawValue: 1463)
    public static let ef_mineffect_feintbomb_bottom = EffectID(rawValue: 1464)
    public static let ef_new_earthgrave_visual = EffectID(rawValue: 1465)
    public static let ef_mineffect_rollingcutter_cast = EffectID(rawValue: 1466)
    public static let ef_mineffect_rollingcutter_01 = EffectID(rawValue: 1467)
    public static let ef_mineffect_rollingcutter_02 = EffectID(rawValue: 1468)
    public static let ef_mineffect_rollingcutter_03 = EffectID(rawValue: 1469)
    public static let ef_mineffect_rollingcutter_04 = EffectID(rawValue: 1470)
    public static let ef_mineffect_rollingcutter_05 = EffectID(rawValue: 1471)
    public static let ef_mineffect_rollingcutter_06 = EffectID(rawValue: 1472)
    public static let ef_mineffect_rollingcutter_07 = EffectID(rawValue: 1473)
    public static let ef_mineffect_rollingcutter_08 = EffectID(rawValue: 1474)
    public static let ef_mineffect_rollingcutter_09 = EffectID(rawValue: 1475)
    public static let ef_mineffect_rollingcutter_10 = EffectID(rawValue: 1476)
    public static let ef_mineffect_crossripperslasher = EffectID(rawValue: 1477)
    public static let ef_mineffect_crossripperslasher_12 = EffectID(rawValue: 1478)
    public static let ef_mineffect_crossripperslasher_01 = EffectID(rawValue: 1479)
    public static let ef_mineffect_crossripperslasher_03 = EffectID(rawValue: 1480)
    public static let ef_mineffect_crossripperslasher_05 = EffectID(rawValue: 1481)
    public static let ef_mineffect_crossripperslasher_06 = EffectID(rawValue: 1482)
    public static let ef_mineffect_crossripperslasher_07 = EffectID(rawValue: 1483)
    public static let ef_mineffect_crossripperslasher_09 = EffectID(rawValue: 1484)
    public static let ef_mineffect_crossripperslasher_11 = EffectID(rawValue: 1485)
    public static let ef_mineffect_armscannon_01 = EffectID(rawValue: 1486)
    public static let ef_mineffect_armscannon_05 = EffectID(rawValue: 1487)
    public static let ef_mineffect_armscannon_07 = EffectID(rawValue: 1488)
    public static let ef_mineffect_armscannon_11 = EffectID(rawValue: 1489)
    public static let ef_mineffect_armscannon_explosion = EffectID(rawValue: 1490)
    public static let ef_mineffect_armscannon_explosion_bottom = EffectID(rawValue: 1491)
    public static let ef_mineffect_armscannon_cast = EffectID(rawValue: 1492)
    public static let ef_mineffect_armscannon_cast_bottom = EffectID(rawValue: 1493)
    public static let ef_mineffect_axetornado = EffectID(rawValue: 1494)
    public static let ef_mineffect_axetornado_bottom = EffectID(rawValue: 1495)
    public static let ef_mineffect_cart_cannon_explosion = EffectID(rawValue: 1496)
    public static let ef_mineffect_cart_cannon_explosion_bottom = EffectID(rawValue: 1497)
    public static let ef_mineffect_cart_cannon_fire_bottom = EffectID(rawValue: 1498)
    public static let ef_mineffect_cart_cannon_cast = EffectID(rawValue: 1499)
    public static let ef_mineffect_cart_cannon_cast_bottom = EffectID(rawValue: 1500)
    public static let ef_mineffect_cart_tornado = EffectID(rawValue: 1501)
    public static let ef_mineffect_cart_tornado_bottom = EffectID(rawValue: 1502)
    public static let ef_mineffect_banishingpoint_target = EffectID(rawValue: 1503)
    public static let ef_mineffect_banishingpoint_target_bottom = EffectID(rawValue: 1504)
    public static let ef_mineffect_banishingpoint_cast = EffectID(rawValue: 1505)
    public static let ef_mineffect_banishingpoint_cast_bottom = EffectID(rawValue: 1506)
    public static let ef_mineffect_banishingpoint_01 = EffectID(rawValue: 1507)
    public static let ef_mineffect_banishingpoint_05 = EffectID(rawValue: 1508)
    public static let ef_mineffect_banishingpoint_07 = EffectID(rawValue: 1509)
    public static let ef_mineffect_banishingpoint_11 = EffectID(rawValue: 1510)
    public static let ef_mineffect_cannon_spear_12 = EffectID(rawValue: 1511)
    public static let ef_mineffect_cannon_spear_01 = EffectID(rawValue: 1512)
    public static let ef_mineffect_cannon_spear_03 = EffectID(rawValue: 1513)
    public static let ef_mineffect_cannon_spear_05 = EffectID(rawValue: 1514)
    public static let ef_mineffect_cannon_spear_06 = EffectID(rawValue: 1515)
    public static let ef_mineffect_cannon_spear_07 = EffectID(rawValue: 1516)
    public static let ef_mineffect_cannon_spear_09 = EffectID(rawValue: 1517)
    public static let ef_mineffect_cannon_spear_11 = EffectID(rawValue: 1518)
    public static let ef_mineffect_cannon_spear_bottom = EffectID(rawValue: 1519)
    public static let ef_mineffect_dragonbreath_bomb = EffectID(rawValue: 1520)
    public static let ef_mineffect_dragonbreath_01 = EffectID(rawValue: 1521)
    public static let ef_mineffect_dragonbreath_05 = EffectID(rawValue: 1522)
    public static let ef_mineffect_dragonbreath_07 = EffectID(rawValue: 1523)
    public static let ef_mineffect_dragonbreath_11 = EffectID(rawValue: 1524)
    public static let ef_whiteimprison_state = EffectID(rawValue: 1525)
    public static let ef_mineffect_dragonbreath_water_bomb = EffectID(rawValue: 1526)
    public static let ef_mineffect_dragonbreath_water_01 = EffectID(rawValue: 1527)
    public static let ef_mineffect_dragonbreath_water_05 = EffectID(rawValue: 1528)
    public static let ef_mineffect_dragonbreath_water_07 = EffectID(rawValue: 1529)
    public static let ef_mineffect_dragonbreath_water_11 = EffectID(rawValue: 1530)
    public static let ef_pok_thunder = EffectID(rawValue: 1531)
    public static let ef_mineffect_tigercannon = EffectID(rawValue: 1532)
    public static let ef_mineffect_severerainstorm_cast = EffectID(rawValue: 1533)
    public static let ef_mineffect_comet = EffectID(rawValue: 1534)
    public static let ef_mineffect_comet_bottom = EffectID(rawValue: 1535)
    public static let ef_mineffect_comet_cast_bottom = EffectID(rawValue: 1536)
    public static let ef_mineffect_comet_sub_exp = EffectID(rawValue: 1537)
    public static let ef_mineffect_comet_sub_exp_bottom = EffectID(rawValue: 1538)
    public static let ef_mineffect_comet_cast = EffectID(rawValue: 1539)
    public static let ef_mineffect_jackfrost_00 = EffectID(rawValue: 1540)
    public static let ef_mineffect_jackfrost_01 = EffectID(rawValue: 1541)
    public static let ef_mineffect_jackfrost_02 = EffectID(rawValue: 1542)
    public static let ef_mineffect_jackfrost_cast = EffectID(rawValue: 1543)
    public static let ef_mineffect_jackfrost_rune = EffectID(rawValue: 1544)
    public static let ef_new_magnum_break = EffectID(rawValue: 1545)
    public static let ef_new_poisonsmoke_1 = EffectID(rawValue: 1546)
    public static let ef_new_poisonsmoke_2 = EffectID(rawValue: 1547)
    public static let ef_new_poisonsmoke_cast = EffectID(rawValue: 1548)
    public static let ef_new_fearbreeze = EffectID(rawValue: 1549)
    public static let ef_new_hellinferno = EffectID(rawValue: 1550)
    public static let ef_new_hellinferno_bottom = EffectID(rawValue: 1551)
    public static let ef_new_hellinferno_cast_bottom = EffectID(rawValue: 1552)
    public static let ef_new_hellinferno_sub = EffectID(rawValue: 1553)
    public static let ef_new_hellinferno_sub_bottom = EffectID(rawValue: 1554)
    public static let ef_evilland = EffectID(rawValue: 1555)
    public static let ef_new_heal_blue = EffectID(rawValue: 1556)
    public static let ef_new_clearance = EffectID(rawValue: 1557)
    public static let ef_new_clearance_bottom = EffectID(rawValue: 1558)
    public static let ef_new_clearance_cast = EffectID(rawValue: 1559)
    public static let ef_new_heal_white = EffectID(rawValue: 1560)
    public static let ef_new_varetyrspear = EffectID(rawValue: 1561)
    public static let ef_new_varetyrspear_bottom = EffectID(rawValue: 1562)
    public static let ef_new_varetyrspear_cast = EffectID(rawValue: 1563)
    public static let ef_new_varetyrspear_cast_bottom = EffectID(rawValue: 1564)
    public static let ef_new_heal_yellow = EffectID(rawValue: 1565)
    public static let ef_new_crossimpact = EffectID(rawValue: 1566)
    public static let ef_new_crossimpact_target = EffectID(rawValue: 1567)
    public static let ef_new_crossimpact_hit = EffectID(rawValue: 1568)
    public static let ef_new_reverberation = EffectID(rawValue: 1569)
    public static let ef_new_fallenempire = EffectID(rawValue: 1570)
    public static let ef_new_fallenempire_bottom = EffectID(rawValue: 1571)
    public static let ef_new_fallenempire_hit = EffectID(rawValue: 1572)
    public static let ef_new_gateofhell_cast = EffectID(rawValue: 1573)
    public static let ef_new_gateofhell_target = EffectID(rawValue: 1574)
    public static let ef_new_gateofhell = EffectID(rawValue: 1575)
    public static let ef_new_howlingoflion = EffectID(rawValue: 1576)
    public static let ef_new_howlingoflion_bottom = EffectID(rawValue: 1577)
    public static let ef_new_howlingoflion_cast = EffectID(rawValue: 1578)
    public static let ef_new_howlingoflion_cast_bottom = EffectID(rawValue: 1579)
    public static let ef_new_howlingoflion_hit = EffectID(rawValue: 1580)
    public static let ef_new_metallicsound = EffectID(rawValue: 1581)
    public static let ef_new_metallicsound_bottom = EffectID(rawValue: 1582)
    public static let ef_new_metallicsound_hit = EffectID(rawValue: 1583)
    public static let ef_new_metallicsound_line = EffectID(rawValue: 1584)
    public static let ef_new_reproduce = EffectID(rawValue: 1585)
    public static let ef_new_reproduce_bottom = EffectID(rawValue: 1586)
    public static let ef_new_soulexpansion_cast = EffectID(rawValue: 1587)
    public static let ef_new_soulexpansion_cast_bottom = EffectID(rawValue: 1588)
    public static let ef_new_soulexpansion_loop = EffectID(rawValue: 1589)
    public static let ef_new_soulexpansion_loop_bottom = EffectID(rawValue: 1590)
    public static let ef_new_soulexpansion_hit = EffectID(rawValue: 1591)
    public static let ef_new_soulexpansion_hit_bottom = EffectID(rawValue: 1592)
    public static let ef_new_reverberation_hit = EffectID(rawValue: 1593)
    public static let ef_new_reverberation_note = EffectID(rawValue: 1594)
    public static let ef_new_aromaoil = EffectID(rawValue: 1595)
    public static let ef_new_aromaoil_bottom = EffectID(rawValue: 1596)
    public static let ef_new_bathfoam = EffectID(rawValue: 1597)
    public static let ef_new_bathfoam_bottom = EffectID(rawValue: 1598)
    public static let ef_tetra_vortex_core_reuse = EffectID(rawValue: 1599)
    public static let ef_guard5 = EffectID(rawValue: 1600)
    public static let ef_magic_circle_1 = EffectID(rawValue: 1601)
    public static let ef_bio5_plant_green = EffectID(rawValue: 1602)
    public static let ef_bio5_plant_blue = EffectID(rawValue: 1603)
    public static let ef_bio5_plant_yellow = EffectID(rawValue: 1604)
    public static let ef_bio5_plant_white = EffectID(rawValue: 1605)
    public static let ef_bio5_plant_red = EffectID(rawValue: 1606)
    public static let ef_grade_enchant_intro = EffectID(rawValue: 1607)
    public static let ef_grade_enchant_success = EffectID(rawValue: 1608)
    public static let ef_grade_enchant_failed = EffectID(rawValue: 1609)
    public static let ef_pok_magic = EffectID(rawValue: 1610)
    public static let ef_blue_wave_1 = EffectID(rawValue: 1611)
    public static let ef_blue_wave_2 = EffectID(rawValue: 1612)
    public static let ef_blue_wave_3 = EffectID(rawValue: 1613)
    public static let ef_red_wave_1 = EffectID(rawValue: 1614)
    public static let ef_red_wave_2 = EffectID(rawValue: 1615)
    public static let ef_red_wave_3 = EffectID(rawValue: 1616)
    public static let ef_blackbubble_small = EffectID(rawValue: 1617)
    public static let ef_blackbubble_midium = EffectID(rawValue: 1618)
    public static let ef_blackbubble_large = EffectID(rawValue: 1619)
    public static let ef_new_wallofthorn_cast = EffectID(rawValue: 1620)
    public static let ef_new_wallofthorn_cast_bottom = EffectID(rawValue: 1621)
    public static let ef_new_earthgrave_bottom = EffectID(rawValue: 1622)
    public static let ef_new_earthgrave_hit = EffectID(rawValue: 1623)
    public static let ef_new_ignitionbreak = EffectID(rawValue: 1624)
    public static let ef_new_ignitionbreak_bottom = EffectID(rawValue: 1625)
    public static let ef_new_ignitionbreak_cast = EffectID(rawValue: 1626)
    public static let ef_new_judex_cast = EffectID(rawValue: 1627)
    public static let ef_new_judex_cast_bottom = EffectID(rawValue: 1628)
    public static let ef_new_judex_cast_loop = EffectID(rawValue: 1629)
    public static let ef_new_judex_cast_loop_bottom = EffectID(rawValue: 1630)
    public static let ef_new_judex_target = EffectID(rawValue: 1631)
    public static let ef_new_judex_target_bottom = EffectID(rawValue: 1632)
    public static let ef_new_judex_light = EffectID(rawValue: 1633)
    public static let ef_new_judex_light_bottom = EffectID(rawValue: 1634)
    public static let ef_new_chainlightning_cast = EffectID(rawValue: 1635)
    public static let ef_new_chainlightning_cast_bottom = EffectID(rawValue: 1636)
    public static let ef_new_chainlightning_lockon = EffectID(rawValue: 1637)
    public static let ef_new_chainlightning_target = EffectID(rawValue: 1638)
    public static let ef_new_mandragora = EffectID(rawValue: 1639)
    public static let ef_new_mandragora_bottom = EffectID(rawValue: 1640)
    public static let ef_new_mandragora_cast = EffectID(rawValue: 1641)
    public static let ef_new_soundofdestruction_cast = EffectID(rawValue: 1642)
    public static let ef_new_soundofdestruction_cast_bottom = EffectID(rawValue: 1643)
    public static let ef_new_soundofdestruction_target = EffectID(rawValue: 1644)
    public static let ef_new_aimedbolt_01 = EffectID(rawValue: 1645)
    public static let ef_new_aimedbolt_05 = EffectID(rawValue: 1646)
    public static let ef_new_aimedbolt_07 = EffectID(rawValue: 1647)
    public static let ef_new_aimedbolt_11 = EffectID(rawValue: 1648)
    public static let ef_new_aimedbolt_cast_bottom = EffectID(rawValue: 1649)
    public static let ef_new_aimedbolt_end = EffectID(rawValue: 1650)
    public static let ef_new_aimedbolt_target_loop = EffectID(rawValue: 1651)
    public static let ef_new_unlimit = EffectID(rawValue: 1652)
    public static let ef_new_unlimit_bottom = EffectID(rawValue: 1653)
    public static let ef_new_epiclesis = EffectID(rawValue: 1654)
    public static let ef_new_epiclesis_aura = EffectID(rawValue: 1655)
    public static let ef_new_epiclesis_cast = EffectID(rawValue: 1656)
    public static let ef_new_axeboomerang = EffectID(rawValue: 1657)
    public static let ef_new_axeboomerang_cast = EffectID(rawValue: 1658)
    public static let ef_new_axeboomerang_cast_bottom = EffectID(rawValue: 1659)
    public static let ef_new_axeboomerang_hit = EffectID(rawValue: 1660)
    public static let ef_hackandslash = EffectID(rawValue: 1661)
    public static let ef_hackandslash_bottom = EffectID(rawValue: 1662)
    public static let ef_hackandslash_hit = EffectID(rawValue: 1663)
    public static let ef_new_sanctuary = EffectID(rawValue: 1664)
    public static let ef_new_spellfist_fire = EffectID(rawValue: 1665)
    public static let ef_new_spellfist_fire_bottom = EffectID(rawValue: 1666)
    public static let ef_new_spellfist_water = EffectID(rawValue: 1667)
    public static let ef_new_spellfist_water_bottom = EffectID(rawValue: 1668)
    public static let ef_new_spellfist_wind = EffectID(rawValue: 1669)
    public static let ef_stormslash_1 = EffectID(rawValue: 1670)
    public static let ef_stormslash_2 = EffectID(rawValue: 1671)
    public static let ef_stormslash_3 = EffectID(rawValue: 1672)
    public static let ef_stormslash_4 = EffectID(rawValue: 1673)
    public static let ef_stormslash_5 = EffectID(rawValue: 1674)
    public static let ef_new_cartboost = EffectID(rawValue: 1675)
    public static let ef_new_cartboost_bottom = EffectID(rawValue: 1676)
    public static let ef_new_safetywall = EffectID(rawValue: 1677)
    public static let ef_new_sonicwave = EffectID(rawValue: 1678)
    public static let ef_new_overbrand_01 = EffectID(rawValue: 1679)
    public static let ef_new_overbrand_03 = EffectID(rawValue: 1680)
    public static let ef_new_overbrand_05 = EffectID(rawValue: 1681)
    public static let ef_new_overbrand_06 = EffectID(rawValue: 1682)
    public static let ef_new_overbrand_07 = EffectID(rawValue: 1683)
    public static let ef_new_overbrand_09 = EffectID(rawValue: 1684)
    public static let ef_new_overbrand_11 = EffectID(rawValue: 1685)
    public static let ef_new_overbrand_12 = EffectID(rawValue: 1686)
    public static let ef_new_overbrand_cast = EffectID(rawValue: 1687)
    public static let ef_new_overbrand_cast_bottom = EffectID(rawValue: 1688)
    public static let ef_new_overbrand_hit = EffectID(rawValue: 1689)
    public static let ef_new_windcutter = EffectID(rawValue: 1690)
    public static let ef_new_windcutter_bottom_01 = EffectID(rawValue: 1691)
    public static let ef_new_windcutter_bottom_05 = EffectID(rawValue: 1692)
    public static let ef_new_windcutter_target = EffectID(rawValue: 1693)
    public static let ef_servantweapon = EffectID(rawValue: 1694)
    public static let ef_new_servantweapon_hit = EffectID(rawValue: 1695)
    public static let ef_new_servantweapon_hit_bottom = EffectID(rawValue: 1696)
    public static let ef_new_servantweapon_shoot_bottom = EffectID(rawValue: 1697)
    public static let ef_new_powerswing_01 = EffectID(rawValue: 1698)
    public static let ef_new_powerswing_05 = EffectID(rawValue: 1699)
    public static let ef_new_powerswing_07 = EffectID(rawValue: 1700)
    public static let ef_new_powerswing_11 = EffectID(rawValue: 1701)
    public static let ef_new_powerswing_bottom = EffectID(rawValue: 1702)
    public static let ef_new_vulcanarm = EffectID(rawValue: 1703)
    public static let ef_new_vulcanarm_bottom = EffectID(rawValue: 1704)
    public static let ef_new_vulcanarm_shothole = EffectID(rawValue: 1705)
    public static let ef_new_earthdrive = EffectID(rawValue: 1706)
    public static let ef_new_earthdrive_bottom = EffectID(rawValue: 1707)
    public static let ef_new_earthdrive_target = EffectID(rawValue: 1708)
    public static let ef_new_earthdrive_cast = EffectID(rawValue: 1709)
    public static let ef_servant_sign = EffectID(rawValue: 1710)
    public static let ef_servant_sign_down = EffectID(rawValue: 1711)
    public static let ef_servant_sign_down_bottom = EffectID(rawValue: 1712)
    public static let ef_servant_phantom_down = EffectID(rawValue: 1713)
    public static let ef_servant_phantom_hit = EffectID(rawValue: 1714)
    public static let ef_servant_phantom_hit_bottom = EffectID(rawValue: 1715)
    public static let ef_servant_phantom_sub = EffectID(rawValue: 1716)
    public static let ef_servant_phantom_sub_bottom = EffectID(rawValue: 1717)
    public static let ef_servant_demolition_collect = EffectID(rawValue: 1718)
    public static let ef_servant_demolition_hit = EffectID(rawValue: 1719)
    public static let ef_servant_demolition_leftdown = EffectID(rawValue: 1720)
    public static let ef_servant_demolition_rightdown = EffectID(rawValue: 1721)
    public static let ef_dragonic_aura = EffectID(rawValue: 1722)
    public static let ef_dragonic_aura_bottom = EffectID(rawValue: 1723)
    public static let ef_dragonic_aura_hit = EffectID(rawValue: 1724)
    public static let ef_dragonic_aura_hit_bottom = EffectID(rawValue: 1725)
    public static let ef_dragonic_aura_buff = EffectID(rawValue: 1726)
    public static let ef_dragonic_aura_buff_bottom = EffectID(rawValue: 1727)
    public static let ef_madness_crusher = EffectID(rawValue: 1728)
    public static let ef_madness_crusher_bottom = EffectID(rawValue: 1729)
    public static let ef_new_autoshadowspell = EffectID(rawValue: 1730)
    public static let ef_new_autoshadowspell_bottom = EffectID(rawValue: 1731)
    public static let ef_destructive_hurricane = EffectID(rawValue: 1732)
    public static let ef_destructive_hurricane_bottom = EffectID(rawValue: 1733)
    public static let ef_destructive_hurricane_cast = EffectID(rawValue: 1734)
    public static let ef_destructive_hurricane_cast_bottom = EffectID(rawValue: 1735)
    public static let ef_destructive_hurricane_climax = EffectID(rawValue: 1736)
    public static let ef_destructive_hurricane_hit = EffectID(rawValue: 1737)
    public static let ef_deadly_projection_cast = EffectID(rawValue: 1738)
    public static let ef_deadly_projection_cast_bottom = EffectID(rawValue: 1739)
    public static let ef_deadly_projection_hit = EffectID(rawValue: 1740)
    public static let ef_deadly_projection = EffectID(rawValue: 1741)
    public static let ef_soul_vc_strike_cast = EffectID(rawValue: 1742)
    public static let ef_soul_vc_strike_cast_bottom = EffectID(rawValue: 1743)
    public static let ef_soul_vc_strike_hit = EffectID(rawValue: 1744)
    public static let ef_rockdown = EffectID(rawValue: 1745)
    public static let ef_rockdown_bottom = EffectID(rawValue: 1746)
    public static let ef_rockdown_cast = EffectID(rawValue: 1747)
    public static let ef_rockdown_cast_bottom = EffectID(rawValue: 1748)
    public static let ef_rockdown_hit = EffectID(rawValue: 1749)
    public static let ef_vigor_cast = EffectID(rawValue: 1750)
    public static let ef_vigor_buff = EffectID(rawValue: 1751)
    public static let ef_unk_1752 = EffectID(rawValue: 1752)
    public static let ef_rain_of_crystal = EffectID(rawValue: 1753)
    public static let ef_rain_of_crystal_bottom = EffectID(rawValue: 1754)
    public static let ef_storm_cannon = EffectID(rawValue: 1755)
    public static let ef_crimsonarrow = EffectID(rawValue: 1756)
    public static let ef_crimson_arrow_cast = EffectID(rawValue: 1757)
    public static let ef_crimson_arrow_cast_bottom = EffectID(rawValue: 1758)
    public static let ef_crimson_arrow_hit = EffectID(rawValue: 1759)
    public static let ef_violentquake = EffectID(rawValue: 1760)
    public static let ef_violent_quake_cast = EffectID(rawValue: 1761)
    public static let ef_violent_quake_cast_bottom = EffectID(rawValue: 1762)
    public static let ef_violent_quake_hit = EffectID(rawValue: 1763)
    public static let ef_new_chargingpierce = EffectID(rawValue: 1764)
    public static let ef_new_chargingpierce_cast = EffectID(rawValue: 1765)
    public static let ef_new_chargingpierce_cast_bottom = EffectID(rawValue: 1766)
    public static let ef_new_chargingpierce_hit = EffectID(rawValue: 1767)
    public static let ef_astral_strike = EffectID(rawValue: 1768)
    public static let ef_astral_strike_cast = EffectID(rawValue: 1769)
    public static let ef_astral_strike_cast_bottom = EffectID(rawValue: 1770)
    public static let ef_mystery_illusion = EffectID(rawValue: 1771)
    public static let ef_mystery_illusion_bottom = EffectID(rawValue: 1772)
    public static let ef_mystery_illusion_cast = EffectID(rawValue: 1773)
    public static let ef_mystery_illusion_cast_bottom = EffectID(rawValue: 1774)
    public static let ef_mystery_illusion_hit = EffectID(rawValue: 1775)
    public static let ef_tornado_storm = EffectID(rawValue: 1776)
    public static let ef_tornado_storm_bottom = EffectID(rawValue: 1777)
    public static let ef_tornado_storm_cast = EffectID(rawValue: 1778)
    public static let ef_tornado_storm_cast_bottom = EffectID(rawValue: 1779)
    public static let ef_tornado_storm_hit = EffectID(rawValue: 1780)
    public static let ef_frozen_slash = EffectID(rawValue: 1781)
    public static let ef_frozen_slash_cast = EffectID(rawValue: 1782)
    public static let ef_frozen_slash_cast_bottom = EffectID(rawValue: 1783)
    public static let ef_frozen_slash_hit = EffectID(rawValue: 1784)
    public static let ef_frozen_slash_ice_01 = EffectID(rawValue: 1785)
    public static let ef_frozen_slash_ice_02 = EffectID(rawValue: 1786)
    public static let ef_frozen_slash_ice_03 = EffectID(rawValue: 1787)
    public static let ef_frozen_slash_ice_04 = EffectID(rawValue: 1788)
    public static let ef_frozen_slash_ice_05 = EffectID(rawValue: 1789)
    public static let ef_frozen_slash_ice_06 = EffectID(rawValue: 1790)
    public static let ef_frozen_slash_ice_07 = EffectID(rawValue: 1791)
    public static let ef_frozen_slash_ice_08 = EffectID(rawValue: 1792)
    public static let ef_violent_quake_bottom = EffectID(rawValue: 1793)
    public static let ef_all_bloom = EffectID(rawValue: 1794)
    public static let ef_all_bloom_bottom = EffectID(rawValue: 1795)
    public static let ef_all_bloom_cast = EffectID(rawValue: 1796)
    public static let ef_all_bloom_cast_bottom = EffectID(rawValue: 1797)
    public static let ef_unk_1798 = EffectID(rawValue: 1798)
    public static let ef_all_bloom_hit = EffectID(rawValue: 1799)
    public static let ef_climax = EffectID(rawValue: 1800)
    public static let ef_climax_light = EffectID(rawValue: 1801)
    public static let ef_climax_cast = EffectID(rawValue: 1802)
    public static let ef_climax_cast_loop = EffectID(rawValue: 1803)
    public static let ef_floral_flare_road = EffectID(rawValue: 1804)
    public static let ef_floral_flare_road_cast = EffectID(rawValue: 1805)
    public static let ef_floral_flare_road_cast_bottom = EffectID(rawValue: 1806)
    public static let ef_floral_flare_road_hit = EffectID(rawValue: 1807)
    public static let ef_mediale_votum = EffectID(rawValue: 1808)
    public static let ef_mediale_votum_cast = EffectID(rawValue: 1809)
    public static let ef_mediale_votum_loop = EffectID(rawValue: 1810)
    public static let ef_argutus_vita = EffectID(rawValue: 1811)
    public static let ef_argutus_vita_cast = EffectID(rawValue: 1812)
    public static let ef_argutus_telum = EffectID(rawValue: 1813)
    public static let ef_argutus_telum_cast = EffectID(rawValue: 1814)
    public static let ef_presens_acies = EffectID(rawValue: 1815)
    public static let ef_presens_acies_cast = EffectID(rawValue: 1816)
    public static let ef_new_d_machine = EffectID(rawValue: 1817)
    public static let ef_new_d_machine_cast = EffectID(rawValue: 1818)
    public static let ef_new_d_machine_cast_bottom = EffectID(rawValue: 1819)
    public static let ef_new_d_machine_start = EffectID(rawValue: 1820)
    public static let ef_new_d_machine_end = EffectID(rawValue: 1821)
    public static let ef_arbitrium_cast = EffectID(rawValue: 1822)
    public static let ef_arbitrium_cast_bottom = EffectID(rawValue: 1823)
    public static let ef_arbitrium = EffectID(rawValue: 1824)
    public static let ef_arbitrium_bottom = EffectID(rawValue: 1825)
    public static let ef_arbitrium_hit = EffectID(rawValue: 1826)
    public static let ef_dancing_knife_cast = EffectID(rawValue: 1827)
    public static let ef_dancing_knife_cast_bottom = EffectID(rawValue: 1828)
    public static let ef_dancing_knife = EffectID(rawValue: 1829)
    public static let ef_abyss_dagger_hit_1830 = EffectID(rawValue: 1830)
    public static let ef_new_reparatio_cast = EffectID(rawValue: 1831)
    public static let ef_new_reparatio_cast_bottom = EffectID(rawValue: 1832)
    public static let ef_new_reparatio = EffectID(rawValue: 1833)
    public static let ef_new_reparatio_bottom = EffectID(rawValue: 1834)
    public static let ef_new_reparatio_target = EffectID(rawValue: 1835)
    public static let ef_new_reparatio_target_bottom = EffectID(rawValue: 1836)
    public static let ef_savage_impact = EffectID(rawValue: 1837)
    public static let ef_eternal_slash_hit_1 = EffectID(rawValue: 1838)
    public static let ef_a_machine = EffectID(rawValue: 1839)
    public static let ef_a_machine_cast = EffectID(rawValue: 1840)
    public static let ef_unk_1841 = EffectID(rawValue: 1841)
    public static let ef_a_machine_hit = EffectID(rawValue: 1842)
    public static let ef_unk_1843 = EffectID(rawValue: 1843)
    public static let ef_unk_1844 = EffectID(rawValue: 1844)
    public static let ef_unk_1845 = EffectID(rawValue: 1845)
    public static let ef_effligo = EffectID(rawValue: 1846)
    public static let ef_effligo_bottom = EffectID(rawValue: 1847)
    public static let ef_effligo_hit = EffectID(rawValue: 1848)
    public static let ef_competentia = EffectID(rawValue: 1849)
    public static let ef_competentia_bottom = EffectID(rawValue: 1850)
    public static let ef_unk_1851 = EffectID(rawValue: 1851)
    public static let ef_competentia_loop = EffectID(rawValue: 1852)
    public static let ef_competentia_loop_bottom = EffectID(rawValue: 1853)
    public static let ef_crystal_impact = EffectID(rawValue: 1854)
    public static let ef_crystal_impact_bottom = EffectID(rawValue: 1855)
    public static let ef_crystal_impact_cast = EffectID(rawValue: 1856)
    public static let ef_crystal_impact_cast_bottom = EffectID(rawValue: 1857)
    public static let ef_crystal_impact_hit = EffectID(rawValue: 1858)
    public static let ef_crystal_impact_buff = EffectID(rawValue: 1859)
    public static let ef_religio = EffectID(rawValue: 1860)
    public static let ef_religio_cast = EffectID(rawValue: 1861)
    public static let ef_new_enchanting_shadow = EffectID(rawValue: 1862)
    public static let ef_new_enchanting_shadow_bottom = EffectID(rawValue: 1863)
    public static let ef_fatal_shadow_crow = EffectID(rawValue: 1864)
    public static let ef_fatal_shadow_crow_bottom = EffectID(rawValue: 1865)
    public static let ef_fatal_shadow_crow_hit = EffectID(rawValue: 1866)
    public static let ef_shadow_exceed = EffectID(rawValue: 1867)
    public static let ef_shadow_exceed_cast = EffectID(rawValue: 1868)
    public static let ef_dropitem_blue = EffectID(rawValue: 1869)
    public static let ef_dropitem_green = EffectID(rawValue: 1870)
    public static let ef_dropitem_red = EffectID(rawValue: 1871)
    public static let ef_new_pneuma = EffectID(rawValue: 1872)
    public static let ef_deep_blind_trap_cast = EffectID(rawValue: 1873)
    public static let ef_deep_blind_trap = EffectID(rawValue: 1874)
    public static let ef_deep_blind_trap_hit = EffectID(rawValue: 1875)
    public static let ef_new_sw_cast = EffectID(rawValue: 1876)
    public static let ef_swift_trap_cast = EffectID(rawValue: 1877)
    public static let ef_swift_trap = EffectID(rawValue: 1878)
    public static let ef_swift_trap_hit = EffectID(rawValue: 1879)
    public static let ef_solid_trap_cast = EffectID(rawValue: 1880)
    public static let ef_solid_trap_cast_bottom = EffectID(rawValue: 1881)
    public static let ef_solid_trap = EffectID(rawValue: 1882)
    public static let ef_solid_trap_hit = EffectID(rawValue: 1883)
    public static let ef_new_rush_quake = EffectID(rawValue: 1884)
    public static let ef_new_rush_quake_bottom = EffectID(rawValue: 1885)
    public static let ef_new_rush_quake_hit = EffectID(rawValue: 1886)
    public static let ef_benedictum = EffectID(rawValue: 1887)
    public static let ef_benedictum_cast = EffectID(rawValue: 1888)
    public static let ef_benedictum_cast_bottom = EffectID(rawValue: 1889)
    public static let ef_stratum_tremor_cast = EffectID(rawValue: 1890)
    public static let ef_stratum_tremor_cast_bottom = EffectID(rawValue: 1891)
    public static let ef_stratum_tremor_hit = EffectID(rawValue: 1892)
    public static let ef_stratum_tremor = EffectID(rawValue: 1893)
    public static let ef_stratum_tremor_bottom = EffectID(rawValue: 1894)
    public static let ef_impact_crater = EffectID(rawValue: 1895)
    public static let ef_impact_crater_bottom = EffectID(rawValue: 1896)
    public static let ef_unk_1897 = EffectID(rawValue: 1897)
    public static let ef_impact_crater_hit = EffectID(rawValue: 1898)
    public static let ef_wind_sign = EffectID(rawValue: 1899)
    public static let ef_wind_sign_loop = EffectID(rawValue: 1900)
    public static let ef_abr_mother_cast = EffectID(rawValue: 1901)
    public static let ef_abr_mother = EffectID(rawValue: 1902)
    public static let ef_abr_mother_01 = EffectID(rawValue: 1903)
    public static let ef_abr_mother_02 = EffectID(rawValue: 1904)
    public static let ef_hawk_rush = EffectID(rawValue: 1905)
    public static let ef_abr_infinity = EffectID(rawValue: 1906)
    public static let ef_abr_infinity_bottom = EffectID(rawValue: 1907)
    public static let ef_abr_infinity_cast = EffectID(rawValue: 1908)
    public static let ef_abr_infinity_hit = EffectID(rawValue: 1909)
    public static let ef_abr_infinity_ring = EffectID(rawValue: 1910)
    public static let ef_petitio = EffectID(rawValue: 1911)
    public static let ef_eternal_slash = EffectID(rawValue: 1912)
    public static let ef_eternal_slash_count = EffectID(rawValue: 1913)
    public static let ef_eternal_slash_hit_2 = EffectID(rawValue: 1914)
    public static let ef_new_d_cannon = EffectID(rawValue: 1915)
    public static let ef_new_d_cannon_cast = EffectID(rawValue: 1916)
    public static let ef_new_d_cannon_hit = EffectID(rawValue: 1917)
    public static let ef_new_d_cannon_entity = EffectID(rawValue: 1918)
    public static let ef_flame_trap = EffectID(rawValue: 1919)
    public static let ef_unk_1920 = EffectID(rawValue: 1920)
    public static let ef_flame_trap_cast = EffectID(rawValue: 1921)
    public static let ef_flame_trap_hit = EffectID(rawValue: 1922)
    public static let ef_flame_trap_ring = EffectID(rawValue: 1923)
    public static let ef_new_dilectio_heal = EffectID(rawValue: 1924)
    public static let ef_new_dilectio_heal_cast = EffectID(rawValue: 1925)
    public static let ef_new_dilectio_heal_cast_bottom = EffectID(rawValue: 1926)
    public static let ef_new_dilectio_heal_target = EffectID(rawValue: 1927)
    public static let ef_new_dilectio_heal_target_bottom = EffectID(rawValue: 1928)
    public static let ef_new_pramen_bottom = EffectID(rawValue: 1929)
    public static let ef_new_pramen_cast = EffectID(rawValue: 1930)
    public static let ef_new_pramen = EffectID(rawValue: 1931)
    public static let ef_new_pramen_ring = EffectID(rawValue: 1932)
    public static let ef_new_potent_venom = EffectID(rawValue: 1933)
    public static let ef_new_battle_w = EffectID(rawValue: 1934)
    public static let ef_new_battle_w_cast = EffectID(rawValue: 1935)
    public static let ef_new_battle_w_bottom = EffectID(rawValue: 1936)
    public static let ef_new_battle_w_hit = EffectID(rawValue: 1937)
    public static let ef_new_battle_w_entity = EffectID(rawValue: 1938)
    public static let ef_new_axe_stomp_hit = EffectID(rawValue: 1939)
    public static let ef_new_axe_stomp_bottom = EffectID(rawValue: 1940)
    public static let ef_new_axe_stomp = EffectID(rawValue: 1941)
    public static let ef_new_axe_stomp_12 = EffectID(rawValue: 1942)
    public static let ef_new_axe_stomp_01 = EffectID(rawValue: 1943)
    public static let ef_new_axe_stomp_03 = EffectID(rawValue: 1944)
    public static let ef_new_axe_stomp_05 = EffectID(rawValue: 1945)
    public static let ef_new_axe_stomp_06 = EffectID(rawValue: 1946)
    public static let ef_new_axe_stomp_08 = EffectID(rawValue: 1947)
    public static let ef_new_axe_stomp_09 = EffectID(rawValue: 1948)
    public static let ef_new_axe_stomp_11 = EffectID(rawValue: 1949)
    public static let ef_crescivebolt_cast = EffectID(rawValue: 1950)
    public static let ef_crescivebolt = EffectID(rawValue: 1951)
    public static let ef_crescivebolt_hit = EffectID(rawValue: 1952)
    public static let ef_shadow_stab = EffectID(rawValue: 1953)
    public static let ef_eternal_slash_hit = EffectID(rawValue: 1954)
    public static let ef_shadow_stab_hit2 = EffectID(rawValue: 1955)
    public static let ef_unk_1956 = EffectID(rawValue: 1956)
    public static let ef_pneumaticus_procella = EffectID(rawValue: 1957)
    public static let ef_pneumaticus_procella_cast = EffectID(rawValue: 1958)
    public static let ef_pneumaticus_procella_ring = EffectID(rawValue: 1959)
    public static let ef_calumitygale = EffectID(rawValue: 1960)
    public static let ef_calumitygale_cast = EffectID(rawValue: 1961)
    public static let ef_calumitygale_loop = EffectID(rawValue: 1962)
    public static let ef_sincere_faith_ring = EffectID(rawValue: 1963)
    public static let ef_sincere_faith = EffectID(rawValue: 1964)
    public static let ef_sincere_faith_bottom = EffectID(rawValue: 1965)
    public static let ef_abyss_dagger = EffectID(rawValue: 1966)
    public static let ef_abyss_dagger_hit = EffectID(rawValue: 1967)
    public static let ef_hawk_boomerang = EffectID(rawValue: 1968)
    public static let ef_hawk_boomerang_cast = EffectID(rawValue: 1969)
    public static let ef_hawk_boomerang_hit = EffectID(rawValue: 1970)
    public static let ef_hawk_boomerang_start = EffectID(rawValue: 1971)
    public static let ef_gale_storm_cast = EffectID(rawValue: 1972)
    public static let ef_gale_storm = EffectID(rawValue: 1973)
    public static let ef_gale_storm_hit = EffectID(rawValue: 1974)
    public static let ef_first_faith_power = EffectID(rawValue: 1975)
    public static let ef_first_faith_power_cast = EffectID(rawValue: 1976)
    public static let ef_first_faith_power_start = EffectID(rawValue: 1977)
    public static let ef_judge = EffectID(rawValue: 1978)
    public static let ef_judge_cast = EffectID(rawValue: 1979)
    public static let ef_judge_start = EffectID(rawValue: 1980)
    public static let ef_judge_aura = EffectID(rawValue: 1981)
    public static let ef_third_exor_flame = EffectID(rawValue: 1982)
    public static let ef_third_exor_flame_cast = EffectID(rawValue: 1983)
    public static let ef_third_exor_flame_start = EffectID(rawValue: 1984)
    public static let ef_third_exor_flame_aura = EffectID(rawValue: 1985)
    public static let ef_powerful_faith_ring = EffectID(rawValue: 1986)
    public static let ef_powerful_faith = EffectID(rawValue: 1987)
    public static let ef_oleum_sanctum = EffectID(rawValue: 1988)
    public static let ef_oleum_sanctum_bottom = EffectID(rawValue: 1989)
    public static let ef_oleum_sanctum_hit = EffectID(rawValue: 1990)
    public static let ef_oleum_sanctum_loop = EffectID(rawValue: 1991)
    public static let ef_increasing_activity = EffectID(rawValue: 1992)
    public static let ef_increasing_activity_cast = EffectID(rawValue: 1993)
    public static let ef_increasing_activity_cast_bottom = EffectID(rawValue: 1994)
    public static let ef_explosion_blaster = EffectID(rawValue: 1995)
    public static let ef_explosion_blaster_bottom = EffectID(rawValue: 1996)
    public static let ef_explosion_blaster_hit = EffectID(rawValue: 1997)
    public static let ef_firm_faith_ring = EffectID(rawValue: 1998)
    public static let ef_firm_faith = EffectID(rawValue: 1999)
    public static let ef_mysticsymphony = EffectID(rawValue: 2000)
    public static let ef_mysticsymphony_cast = EffectID(rawValue: 2001)
    public static let ef_mysticsymphony_note = EffectID(rawValue: 2002)
    public static let ef_activity_burn = EffectID(rawValue: 2003)
    public static let ef_activity_burn_cast = EffectID(rawValue: 2004)
    public static let ef_activity_burn_cast_bottom = EffectID(rawValue: 2005)
    public static let ef_kvasirsonata = EffectID(rawValue: 2006)
    public static let ef_kvasirsonata_cast = EffectID(rawValue: 2007)
    public static let ef_kvasirsonata_cast_bottom = EffectID(rawValue: 2008)
    public static let ef_serpens_bottom = EffectID(rawValue: 2009)
    public static let ef_serpens_cast = EffectID(rawValue: 2010)
    public static let ef_serpens_cast_bottom = EffectID(rawValue: 2011)
    public static let ef_serpens_hit = EffectID(rawValue: 2012)
    public static let ef_serpens_shield = EffectID(rawValue: 2013)
    public static let ef_chain_reaction_shot_cast = EffectID(rawValue: 2014)
    public static let ef_chain_reaction_shot_cast_bottom = EffectID(rawValue: 2015)
    public static let ef_eternal_slash_hit_3 = EffectID(rawValue: 2016)
    public static let ef_chain_reaction_shot_hitsub = EffectID(rawValue: 2017)
    public static let ef_chain_reaction_shot = EffectID(rawValue: 2018)
    public static let ef_diluvio_ice = EffectID(rawValue: 2019)
    public static let ef_diluvio_ice_bottom = EffectID(rawValue: 2020)
    public static let ef_diluvio_cast = EffectID(rawValue: 2021)
    public static let ef_diluvio_cast_bottom = EffectID(rawValue: 2022)
    public static let ef_diluvio_hit = EffectID(rawValue: 2023)
    public static let ef_diluvio_armor = EffectID(rawValue: 2024)
    public static let ef_spell_enchanting = EffectID(rawValue: 2025)
    public static let ef_diamond_storm = EffectID(rawValue: 2026)
    public static let ef_diamond_storm_bottom = EffectID(rawValue: 2027)
    public static let ef_diamond_storm_cast = EffectID(rawValue: 2028)
    public static let ef_diamond_storm_cast_bottom = EffectID(rawValue: 2029)
    public static let ef_diamond_storm_hit = EffectID(rawValue: 2030)
    public static let ef_venom_swamp_bottom = EffectID(rawValue: 2031)
    public static let ef_venom_swamp_cast = EffectID(rawValue: 2032)
    public static let ef_venom_swamp_cast_bottom = EffectID(rawValue: 2033)
    public static let ef_venom_swamp_hit = EffectID(rawValue: 2034)
    public static let ef_ardor = EffectID(rawValue: 2035)
    public static let ef_ardor_bottom = EffectID(rawValue: 2036)
    public static let ef_ardor_cast = EffectID(rawValue: 2037)
    public static let ef_ardor_cast_bottom = EffectID(rawValue: 2038)
    public static let ef_ardor_hit = EffectID(rawValue: 2039)
    public static let ef_ardor_flamearmor = EffectID(rawValue: 2040)
    public static let ef_lightning_land = EffectID(rawValue: 2041)
    public static let ef_lightning_land_bottom = EffectID(rawValue: 2042)
    public static let ef_lightning_land_cast = EffectID(rawValue: 2043)
    public static let ef_lightning_land_cast_bottom = EffectID(rawValue: 2044)
    public static let ef_lightning_land_hit = EffectID(rawValue: 2045)
    public static let ef_roseblossom_cast = EffectID(rawValue: 2046)
    public static let ef_roseblossom_cast_bottom = EffectID(rawValue: 2047)
    public static let ef_roseblossom_hit = EffectID(rawValue: 2048)
    public static let ef_roseblossom_rose = EffectID(rawValue: 2049)
    public static let ef_roseblossom_shot = EffectID(rawValue: 2050)
    public static let ef_first_brand = EffectID(rawValue: 2051)
    public static let ef_first_brand_aura = EffectID(rawValue: 2052)
    public static let ef_first_brand_hit = EffectID(rawValue: 2053)
    public static let ef_first_brand_start = EffectID(rawValue: 2054)
    public static let ef_conflagration = EffectID(rawValue: 2055)
    public static let ef_conflagration_bottom = EffectID(rawValue: 2056)
    public static let ef_conflagration_cast = EffectID(rawValue: 2057)
    public static let ef_conflagration_cast_bottom = EffectID(rawValue: 2058)
    public static let ef_conflagration_hit = EffectID(rawValue: 2059)
    public static let ef_sound_blend = EffectID(rawValue: 2060)
    public static let ef_sound_blend_cast = EffectID(rawValue: 2061)
    public static let ef_sound_blend_cast_bottom = EffectID(rawValue: 2062)
    public static let ef_sound_blend_red = EffectID(rawValue: 2063)
    public static let ef_metallic_fury = EffectID(rawValue: 2064)
    public static let ef_jawaii_serenade = EffectID(rawValue: 2065)
    public static let ef_jawaii_serenade_cast = EffectID(rawValue: 2066)
    public static let ef_jawaii_serenade_cast_bottom = EffectID(rawValue: 2067)
    public static let ef_pronmarch = EffectID(rawValue: 2068)
    public static let ef_pronmarch_cast = EffectID(rawValue: 2069)
    public static let ef_pronmarch_cast_bottom = EffectID(rawValue: 2070)
    public static let ef_rhythmshooting_cast = EffectID(rawValue: 2071)
    public static let ef_rhythmshooting_cast_bottom = EffectID(rawValue: 2072)
    public static let ef_rhythmshooting_hit = EffectID(rawValue: 2073)
    public static let ef_rhythmshooting_shot = EffectID(rawValue: 2074)
    public static let ef_niflheim = EffectID(rawValue: 2075)
    public static let ef_niflheim_cast = EffectID(rawValue: 2076)
    public static let ef_unk_2077 = EffectID(rawValue: 2077)
    public static let ef_second_faith = EffectID(rawValue: 2078)
    public static let ef_second_faith_aura = EffectID(rawValue: 2079)
    public static let ef_second_faith_hit = EffectID(rawValue: 2080)
    public static let ef_second_faith_start = EffectID(rawValue: 2081)
    public static let ef_second_judgement = EffectID(rawValue: 2082)
    public static let ef_second_flame = EffectID(rawValue: 2083)
    public static let ef_second_flame_bottom = EffectID(rawValue: 2084)
    public static let ef_third_flame_bomb = EffectID(rawValue: 2085)
    public static let ef_third_flame_bomb_bottom = EffectID(rawValue: 2086)
    public static let ef_abyss_strike = EffectID(rawValue: 2087)
    public static let ef_abyss_strike_bottom = EffectID(rawValue: 2088)
    public static let ef_abyss_strike_cast = EffectID(rawValue: 2089)
    public static let ef_abyss_strike_cast_bottom = EffectID(rawValue: 2090)
    public static let ef_abyss_strike_ground = EffectID(rawValue: 2091)
    public static let ef_abyss_strike_ground_bottom = EffectID(rawValue: 2092)
    public static let ef_abyss_strike_hit = EffectID(rawValue: 2093)
    public static let ef_massive_flame_blaster = EffectID(rawValue: 2094)
    public static let ef_massive_flame_blaster_hit = EffectID(rawValue: 2095)
    public static let ef_massive_flame_blaster_hit_bottom = EffectID(rawValue: 2096)
    public static let ef_third_consecration = EffectID(rawValue: 2097)
    public static let ef_procella = EffectID(rawValue: 2098)
    public static let ef_procella_bottom = EffectID(rawValue: 2099)
    public static let ef_procella_cast = EffectID(rawValue: 2100)
    public static let ef_procella_cast_bottom = EffectID(rawValue: 2101)
    public static let ef_procella_hit = EffectID(rawValue: 2102)
    public static let ef_procella_storm = EffectID(rawValue: 2103)
    public static let ef_terremotus = EffectID(rawValue: 2104)
    public static let ef_terremotus_cast = EffectID(rawValue: 2105)
    public static let ef_terremotus_cast_bottom = EffectID(rawValue: 2106)
    public static let ef_terremotus_hit = EffectID(rawValue: 2107)
    public static let ef_terremotus_protect = EffectID(rawValue: 2108)
    public static let ef_unk_2109 = EffectID(rawValue: 2109)
    public static let ef_from_the_abyss = EffectID(rawValue: 2110)
    public static let ef_abyss_strike_hit_2 = EffectID(rawValue: 2111)
    public static let ef_third_punish = EffectID(rawValue: 2112)
    public static let ef_third_punish_bottom = EffectID(rawValue: 2113)
    public static let ef_frenzy_shot = EffectID(rawValue: 2114)
    public static let ef_frenzy_shot_hit = EffectID(rawValue: 2115)
    public static let ef_gef_nocturn = EffectID(rawValue: 2116)
    public static let ef_gef_nocturn_cast = EffectID(rawValue: 2117)
    public static let ef_gef_nocturn_cast_bottom = EffectID(rawValue: 2118)
    public static let ef_roki_capriccio = EffectID(rawValue: 2119)
    public static let ef_roki_capriccio_cast = EffectID(rawValue: 2120)
    public static let ef_roki_capriccio_cast_bottom = EffectID(rawValue: 2121)
    public static let ef_musical_interlude = EffectID(rawValue: 2122)
    public static let ef_musical_interlude_cast = EffectID(rawValue: 2123)
    public static let ef_ain_rhapsody = EffectID(rawValue: 2124)
    public static let ef_ain_rhapsody_cast = EffectID(rawValue: 2125)
    public static let ef_abyss_slayer = EffectID(rawValue: 2126)
    public static let ef_abyss_slayer_cast = EffectID(rawValue: 2127)
    public static let ef_abyss_slayer_cast_bottom = EffectID(rawValue: 2128)
    public static let ef_abyss_square = EffectID(rawValue: 2129)
    public static let ef_abyss_square_bottom = EffectID(rawValue: 2130)
    public static let ef_abyss_dagger_hit_2 = EffectID(rawValue: 2131)
    public static let ef_deft_stab = EffectID(rawValue: 2132)
    public static let ef_terra_drive = EffectID(rawValue: 2133)
    public static let ef_terra_drive_bottom = EffectID(rawValue: 2134)
    public static let ef_terra_drive_cast = EffectID(rawValue: 2135)
    public static let ef_terra_drive_cast_bottom = EffectID(rawValue: 2136)
    public static let ef_terra_drive_hit = EffectID(rawValue: 2137)
    public static let ef_elemental_buster_cast = EffectID(rawValue: 2138)
    public static let ef_elemental_buster_fire = EffectID(rawValue: 2139)
    public static let ef_elemental_buster_fire_bottom = EffectID(rawValue: 2140)
    public static let ef_elemental_buster_fire_hit = EffectID(rawValue: 2141)
    public static let ef_elemental_buster_land = EffectID(rawValue: 2142)
    public static let ef_elemental_buster_land_bottom = EffectID(rawValue: 2143)
    public static let ef_elemental_buster_land_hit = EffectID(rawValue: 2144)
    public static let ef_elemental_buster_poison = EffectID(rawValue: 2145)
    public static let ef_elemental_buster_poison_bottom = EffectID(rawValue: 2146)
    public static let ef_elemental_buster_poison_hit = EffectID(rawValue: 2147)
    public static let ef_elemental_buster_water = EffectID(rawValue: 2148)
    public static let ef_elemental_buster_water_bottom = EffectID(rawValue: 2149)
    public static let ef_elemental_buster_water_hit = EffectID(rawValue: 2150)
    public static let ef_elemental_buster_wind = EffectID(rawValue: 2151)
    public static let ef_elemental_buster_wind_bottom = EffectID(rawValue: 2152)
    public static let ef_elemental_buster_wind_hit = EffectID(rawValue: 2153)
    public static let ef_unlucky_rush = EffectID(rawValue: 2154)
    public static let ef_unlucky_rush_cast = EffectID(rawValue: 2155)
    public static let ef_abyss_dagger_hit_3 = EffectID(rawValue: 2156)
    public static let ef_overslash = EffectID(rawValue: 2157)
    public static let ef_overslash_bottom = EffectID(rawValue: 2158)
    public static let ef_overslash_cast = EffectID(rawValue: 2159)
    public static let ef_overslash_hit = EffectID(rawValue: 2160)
    public static let ef_advanced_protection = EffectID(rawValue: 2161)
    public static let ef_advanced_protection_bottom = EffectID(rawValue: 2162)
    public static let ef_advanced_protection_cast = EffectID(rawValue: 2163)
    public static let ef_advanced_protection_cast_bottom = EffectID(rawValue: 2164)
    public static let ef_cross_rain = EffectID(rawValue: 2165)
    public static let ef_cross_rain_bottom = EffectID(rawValue: 2166)
    public static let ef_cross_rain_cast = EffectID(rawValue: 2167)
    public static let ef_cross_rain_cast_bottom = EffectID(rawValue: 2168)
    public static let ef_guard_stance = EffectID(rawValue: 2169)
    public static let ef_guard_stance_cast = EffectID(rawValue: 2170)
    public static let ef_guard_stance_cast_bottom = EffectID(rawValue: 2171)
    public static let ef_attack_stance = EffectID(rawValue: 2172)
    public static let ef_attack_stance_cast = EffectID(rawValue: 2173)
    public static let ef_attack_stance_cast_bottom = EffectID(rawValue: 2174)
    public static let ef_grand_judgement = EffectID(rawValue: 2175)
    public static let ef_grand_judgement_bottom = EffectID(rawValue: 2176)
    public static let ef_grand_judgement_buff = EffectID(rawValue: 2177)
    public static let ef_grand_judgement_cast = EffectID(rawValue: 2178)
    public static let ef_grand_judgement_cast_bottom = EffectID(rawValue: 2179)
    public static let ef_holy_shield_cast = EffectID(rawValue: 2180)
    public static let ef_holy_shield = EffectID(rawValue: 2181)
    public static let ef_holy_shield_loop = EffectID(rawValue: 2182)
    public static let ef_shield_shooting = EffectID(rawValue: 2183)
    public static let ef_shield_shooting_cast = EffectID(rawValue: 2184)
    public static let ef_shield_shooting_hit = EffectID(rawValue: 2185)
    public static let ef_the_w_protection = EffectID(rawValue: 2186)
    public static let ef_the_w_protection_cast = EffectID(rawValue: 2187)
    public static let ef_guardianshield = EffectID(rawValue: 2188)
    public static let ef_guardianshield_bottom = EffectID(rawValue: 2189)
    public static let ef_guardianshield_sub = EffectID(rawValue: 2190)
    public static let ef_judgement_cross = EffectID(rawValue: 2191)
    public static let ef_judgement_cross_bottom = EffectID(rawValue: 2192)
    public static let ef_judgement_cross_cast = EffectID(rawValue: 2193)
    public static let ef_judgement_cross_cast_bottom = EffectID(rawValue: 2194)
    public static let ef_judgement_cross_shot = EffectID(rawValue: 2195)
    public static let ef_rebound_shield = EffectID(rawValue: 2196)
    public static let ef_rebound_shield_bottom = EffectID(rawValue: 2197)
    public static let ef_rebound_shield_cast = EffectID(rawValue: 2198)
    public static let ef_rebound_shield_cast_bottom = EffectID(rawValue: 2199)
    public static let ef_ultimatesacrifice = EffectID(rawValue: 2200)
    public static let ef_ultimatesacrifice_bottom = EffectID(rawValue: 2201)
    public static let ef_ultimatesacrifice_shine = EffectID(rawValue: 2202)
    public static let ef_unk_2203 = EffectID(rawValue: 2203)
    public static let ef_acidified_zone_fire_cast = EffectID(rawValue: 2204)
    public static let ef_acidified_zone_fire_cast_bottom = EffectID(rawValue: 2205)
    public static let ef_acidified_zone_fire = EffectID(rawValue: 2206)
    public static let ef_acidified_zone_fire_hit = EffectID(rawValue: 2207)
    public static let ef_acidified_zone_fire_start = EffectID(rawValue: 2208)
    public static let ef_acidified_zone_fire_start_bottom = EffectID(rawValue: 2209)
    public static let ef_acidified_zone_fire_loop = EffectID(rawValue: 2210)
    public static let ef_acidified_zone_fire_loop_bottom = EffectID(rawValue: 2211)
    public static let ef_acidified_zone_water_cast = EffectID(rawValue: 2212)
    public static let ef_acidified_zone_water_cast_bottom = EffectID(rawValue: 2213)
    public static let ef_acidified_zone_water = EffectID(rawValue: 2214)
    public static let ef_acidified_zone_water_hit = EffectID(rawValue: 2215)
    public static let ef_acidified_zone_water_start = EffectID(rawValue: 2216)
    public static let ef_acidified_zone_water_start_bottom = EffectID(rawValue: 2217)
    public static let ef_acidified_zone_water_loop = EffectID(rawValue: 2218)
    public static let ef_acidified_zone_water_loop_bottom = EffectID(rawValue: 2219)
    public static let ef_acidified_zone_wind_cast = EffectID(rawValue: 2220)
    public static let ef_acidified_zone_wind_cast_bottom = EffectID(rawValue: 2221)
    public static let ef_acidified_zone_wind = EffectID(rawValue: 2222)
    public static let ef_acidified_zone_wind_hit = EffectID(rawValue: 2223)
    public static let ef_acidified_zone_wind_start = EffectID(rawValue: 2224)
    public static let ef_acidified_zone_wind_start_bottom = EffectID(rawValue: 2225)
    public static let ef_acidified_zone_wind_loop = EffectID(rawValue: 2226)
    public static let ef_acidified_zone_wind_loop_bottom = EffectID(rawValue: 2227)
    public static let ef_acidified_zone_ground_cast = EffectID(rawValue: 2228)
    public static let ef_acidified_zone_ground_cast_bottom = EffectID(rawValue: 2229)
    public static let ef_acidified_zone_ground = EffectID(rawValue: 2230)
    public static let ef_acidified_zone_ground_hit = EffectID(rawValue: 2231)
    public static let ef_acidified_zone_ground_start = EffectID(rawValue: 2232)
    public static let ef_acidified_zone_ground_start_bottom = EffectID(rawValue: 2233)
    public static let ef_acidified_zone_ground_loop = EffectID(rawValue: 2234)
    public static let ef_acidified_zone_ground_loop_bottom = EffectID(rawValue: 2235)
    public static let ef_helltree_cast = EffectID(rawValue: 2236)
    public static let ef_helltree_cast_bottom = EffectID(rawValue: 2237)
    public static let ef_helltree_dusty = EffectID(rawValue: 2238)
    public static let ef_helltree_howling = EffectID(rawValue: 2239)
    public static let ef_research_report_ring = EffectID(rawValue: 2240)
    public static let ef_research_report = EffectID(rawValue: 2241)
    public static let ef_research_report_cast = EffectID(rawValue: 2242)
    public static let ef_research_report_cast_bottom = EffectID(rawValue: 2243)
    public static let ef_state_lassitude = EffectID(rawValue: 2244)
    public static let ef_state_swooning = EffectID(rawValue: 2245)
    public static let ef_state_holyflame = EffectID(rawValue: 2246)
    public static let ef_wooden_warrior_cast = EffectID(rawValue: 2247)
    public static let ef_wooden_warrior_cast_bottom = EffectID(rawValue: 2248)
    public static let ef_wooden_warrior_ring = EffectID(rawValue: 2249)
    public static let ef_wooden_warrior_attack = EffectID(rawValue: 2250)
    public static let ef_wooden_warrior_attack_hit = EffectID(rawValue: 2251)
    public static let ef_wooden_warrior_throwrock = EffectID(rawValue: 2252)
    public static let ef_wooden_warrior_throwrock_hit = EffectID(rawValue: 2253)
    public static let ef_wooden_fairy_cast = EffectID(rawValue: 2254)
    public static let ef_wooden_fairy_ring = EffectID(rawValue: 2255)
    public static let ef_wooden_fairy_cast_bottom = EffectID(rawValue: 2256)
    public static let ef_wooden_fairy_dusty = EffectID(rawValue: 2257)
    public static let ef_serpens_deep_poisoning = EffectID(rawValue: 2258)
    public static let ef_serpens_deep_poisoning_bottom = EffectID(rawValue: 2259)
    public static let ef_diluvio_cold_force = EffectID(rawValue: 2260)
    public static let ef_diluvio_cold_force_bottom = EffectID(rawValue: 2261)
    public static let ef_ardor_flametechnic = EffectID(rawValue: 2262)
    public static let ef_ardor_flametechnic_bottom = EffectID(rawValue: 2263)
    public static let ef_procella_grace_breeze = EffectID(rawValue: 2264)
    public static let ef_procella_grace_breeze_bottom = EffectID(rawValue: 2265)
    public static let ef_terremotus_earth_care = EffectID(rawValue: 2266)
    public static let ef_terremotus_earth_care_bottom = EffectID(rawValue: 2267)
    public static let ef_state_lightningstrike = EffectID(rawValue: 2268)
    public static let ef_state_conflagration = EffectID(rawValue: 2269)
    public static let ef_state_frostbite = EffectID(rawValue: 2270)
    public static let ef_state_frostbite_finish = EffectID(rawValue: 2271)
    public static let ef_frostbite_screen = EffectID(rawValue: 2272)
    public static let ef_state_crystallization = EffectID(rawValue: 2273)
    public static let ef_state_deadlypoison = EffectID(rawValue: 2274)
    public static let ef_level4th = EffectID(rawValue: 2275)
    public static let ef_level4th_sub = EffectID(rawValue: 2276)
    public static let ef_unk_2277 = EffectID(rawValue: 2277)
    public static let ef_unk_2278 = EffectID(rawValue: 2278)
    public static let ef_third_consecration_bottom = EffectID(rawValue: 2279)
    public static let ef_servant_sign_bottom = EffectID(rawValue: 2280)
    public static let ef_unk_2281 = EffectID(rawValue: 2281)
    public static let ef_unk_2282 = EffectID(rawValue: 2282)
    public static let ef_unk_2283 = EffectID(rawValue: 2283)
    public static let ef_unk_2284 = EffectID(rawValue: 2284)
    public static let ef_unk_2285 = EffectID(rawValue: 2285)
    public static let ef_unk_2286 = EffectID(rawValue: 2286)
    public static let ef_unk_2287 = EffectID(rawValue: 2287)
    public static let ef_status_crate_up = EffectID(rawValue: 2288)
    public static let ef_status_crate_down = EffectID(rawValue: 2289)
    public static let ef_status_hplus_up = EffectID(rawValue: 2290)
    public static let ef_status_hplus_down = EffectID(rawValue: 2291)
    public static let ef_status_mres_up = EffectID(rawValue: 2292)
    public static let ef_status_mres_down = EffectID(rawValue: 2293)
    public static let ef_status_patk_up = EffectID(rawValue: 2294)
    public static let ef_status_patk_down = EffectID(rawValue: 2295)
    public static let ef_status_res_up = EffectID(rawValue: 2296)
    public static let ef_status_res_down = EffectID(rawValue: 2297)
    public static let ef_status_smatk_up = EffectID(rawValue: 2298)
    public static let ef_status_smatk_down = EffectID(rawValue: 2299)
    public static let ef_status_patk_smatk_up = EffectID(rawValue: 2300)
    public static let ef_unk_2301 = EffectID(rawValue: 2301)
    public static let ef_npc_killing_aura = EffectID(rawValue: 2302)
    public static let ef_npc_killing_aura_end = EffectID(rawValue: 2303)
    public static let ef_npc_killing_aura_hit = EffectID(rawValue: 2304)
    public static let ef_npc_curse_of_red_cube = EffectID(rawValue: 2305)
    public static let ef_npc_curse_of_blue_cube = EffectID(rawValue: 2306)
    public static let ef_unk_2307 = EffectID(rawValue: 2307)
    public static let ef_npc_cane_of_evil_eye = EffectID(rawValue: 2308)
    public static let ef_unk_2309 = EffectID(rawValue: 2309)
    public static let ef_unk_2310 = EffectID(rawValue: 2310)
    public static let ef_ui_enchant_intro_yellow = EffectID(rawValue: 2311)
    public static let ef_ui_enchant_success = EffectID(rawValue: 2312)
    public static let ef_ui_enchant_fail = EffectID(rawValue: 2313)
    public static let ef_ui_enchant_intro_blue = EffectID(rawValue: 2314)
    public static let ef_ui_levelup_success = EffectID(rawValue: 2315)
    public static let ef_ui_levelup_fail = EffectID(rawValue: 2316)
    public static let ef_ui_enchant_intro_green = EffectID(rawValue: 2317)
    public static let ef_ui_reset_success = EffectID(rawValue: 2318)
    public static let ef_ui_reset_fail = EffectID(rawValue: 2319)
    public static let ef_toxin_of_mandara_bomb = EffectID(rawValue: 2320)
    public static let ef_toxin_of_mandara_bomb_bottom = EffectID(rawValue: 2321)
    public static let ef_toxin_of_mandara_shock = EffectID(rawValue: 2322)
    public static let ef_needle_stinger = EffectID(rawValue: 2323)
    public static let ef_needle_stinger_bottom = EffectID(rawValue: 2324)
    public static let ef_needle_stinger_hit = EffectID(rawValue: 2325)
    public static let ef_absolute_zephyr = EffectID(rawValue: 2326)
    public static let ef_absolute_zephyr_bottom = EffectID(rawValue: 2327)
    public static let ef_absolute_zephyr_hit = EffectID(rawValue: 2328)
    public static let ef_twister_cutter = EffectID(rawValue: 2329)
    public static let ef_twister_cutter_hit = EffectID(rawValue: 2330)
    public static let ef_heilige_pferd = EffectID(rawValue: 2331)
    public static let ef_heilige_pferd_bottom = EffectID(rawValue: 2332)
    public static let ef_heilige_pferd_cast = EffectID(rawValue: 2333)
    public static let ef_goldene_tone = EffectID(rawValue: 2334)
    public static let ef_glanzen_spies = EffectID(rawValue: 2335)
    public static let ef_glanzen_spies_hit = EffectID(rawValue: 2336)
    public static let ef_blazing_and_furious = EffectID(rawValue: 2337)
    public static let ef_the_one_fighter_rises = EffectID(rawValue: 2338)
    public static let ef_the_one_fighter_rises_bottom = EffectID(rawValue: 2339)
    public static let ef_tempering = EffectID(rawValue: 2340)
    public static let ef_blast_forge = EffectID(rawValue: 2341)
    public static let ef_blast_forge_hit = EffectID(rawValue: 2342)
    public static let ef_unk_2343 = EffectID(rawValue: 2343)
    public static let ef_unk_2344 = EffectID(rawValue: 2344)
    public static let ef_unk_2345 = EffectID(rawValue: 2345)
    public static let ef_pok_94 = EffectID(rawValue: 2346)
    public static let ef_pok_95 = EffectID(rawValue: 2347)
    public static let ef_ske_twinkling_galaxy = EffectID(rawValue: 2348)
    public static let ef_unk_2349 = EffectID(rawValue: 2349)
    public static let ef_ske_star_cannon = EffectID(rawValue: 2350)
    public static let ef_nw_grenades_dropping = EffectID(rawValue: 2351)
    public static let ef_ss_fuumashouaku = EffectID(rawValue: 2352)
    public static let ef_unk_2353 = EffectID(rawValue: 2353)
    public static let ef_nw_mission_bombard = EffectID(rawValue: 2354)
    public static let ef_unk_2355 = EffectID(rawValue: 2355)
    public static let ef_pok_96 = EffectID(rawValue: 2356)
    public static let ef_pok_97 = EffectID(rawValue: 2357)
    public static let ef_pok_98 = EffectID(rawValue: 2358)
    public static let ef_pok_99 = EffectID(rawValue: 2359)
    public static let ef_pok_100 = EffectID(rawValue: 2360)
    public static let ef_pok_101 = EffectID(rawValue: 2361)
    public static let ef_pok_102 = EffectID(rawValue: 2362)
    public static let ef_pok_103 = EffectID(rawValue: 2363)
    public static let ef_pok_104 = EffectID(rawValue: 2364)
    public static let ef_pok_105 = EffectID(rawValue: 2365)
    public static let ef_hn_jupitel_thunder_storm = EffectID(rawValue: 2366)
    public static let ef_beginspell_ring_yellow = EffectID(rawValue: 2367)
    public static let ef_beginspell_swirl = EffectID(rawValue: 2368)
    public static let ef_beginspell_ring_white = EffectID(rawValue: 2369)
    public static let ef_unk_2370 = EffectID(rawValue: 2370)
    public static let ef_tetra_vortex_water_sub_2 = EffectID(rawValue: 2371)
    public static let ef_tetra_vortex_earth_sub_2 = EffectID(rawValue: 2372)
    public static let ef_volcano_black = EffectID(rawValue: 2373)
    public static let ef_change_size = EffectID(rawValue: 2374)
    public static let ef_unk_2375 = EffectID(rawValue: 2375)
    public static let ef_npc_20th_crystal_s = EffectID(rawValue: 2376)
    public static let ef_npc_20th_crystal_m = EffectID(rawValue: 2377)
    public static let ef_npc_20th_crystal_l = EffectID(rawValue: 2378)
    public static let ef_npc_gate_green_1 = EffectID(rawValue: 2379)
    public static let ef_npc_gate_purple_1 = EffectID(rawValue: 2380)
    public static let ef_npc_gate_red_1 = EffectID(rawValue: 2381)
    public static let ef_20th_firework = EffectID(rawValue: 2382)
    public static let ef_npc_gate_green_2 = EffectID(rawValue: 2383)
    public static let ef_npc_gate_purple_2 = EffectID(rawValue: 2384)
    public static let ef_npc_gate_red_2 = EffectID(rawValue: 2385)
    public static let ef_npc_gate_green_3 = EffectID(rawValue: 2386)
    public static let ef_npc_gate_purple_3 = EffectID(rawValue: 2387)
    public static let ef_npc_gate_red_3 = EffectID(rawValue: 2388)
    public static let ef_npc_gate_skyblue = EffectID(rawValue: 2389)
    public static let ef_unk_2390 = EffectID(rawValue: 2390)
    public static let ef_unk_2391 = EffectID(rawValue: 2391)
    public static let ef_unk_2392 = EffectID(rawValue: 2392)
    public static let ef_unk_2393 = EffectID(rawValue: 2393)
    public static let ef_serpent_shadow = EffectID(rawValue: 2394)
    public static let ef_rune_active_finish = EffectID(rawValue: 2395)
    public static let ef_runeset_active = EffectID(rawValue: 2396)
    public static let ef_runeset_upgrade_success = EffectID(rawValue: 2397)
    public static let ef_runeset_upgrade_fail = EffectID(rawValue: 2398)
    public static let ef_rune_broken = EffectID(rawValue: 2399)
    public static let ef_unk_2400 = EffectID(rawValue: 2400)
    public static let ef_alpha_down_anim = EffectID(rawValue: 2401)
    public static let ef_glow_black = EffectID(rawValue: 2402)
    public static let ef_new_battle_w_hit_2 = EffectID(rawValue: 2403)
    public static let ef_unk_2404 = EffectID(rawValue: 2404)
    public static let ef_new_pramen_reuse = EffectID(rawValue: 2405)
    public static let ef_the_w_protection_reuse = EffectID(rawValue: 2406)
    public static let ef_elemental_buster_fire_reuse = EffectID(rawValue: 2407)
    public static let ef_destructive_hurricane_bottom_reuse = EffectID(rawValue: 2408)
    public static let ef_crystal_impact_bottom_reuse = EffectID(rawValue: 2409)
    public static let ef_new_judex_target_reuse = EffectID(rawValue: 2410)
    public static let ef_unk_2411 = EffectID(rawValue: 2411)
    public static let ef_unk_2412 = EffectID(rawValue: 2412)
    public static let ef_unk_2413 = EffectID(rawValue: 2413)
    public static let ef_unk_2414 = EffectID(rawValue: 2414)
    public static let ef_unk_2415 = EffectID(rawValue: 2415)
    public static let ef_abc_chasing_line = EffectID(rawValue: 2416)
    public static let ef_abc_crossimpact_line = EffectID(rawValue: 2417)
    public static let ef_unk_2418 = EffectID(rawValue: 2418)
    public static let ef_unk_2419 = EffectID(rawValue: 2419)
    public static let ef_violen_hit = EffectID(rawValue: 2420)
    public static let ef_rune_slot_small = EffectID(rawValue: 2421)
    public static let ef_rune_slot_big = EffectID(rawValue: 2422)
    public static let ef_unk_2423 = EffectID(rawValue: 2423)
    public static let ef_c_aura_of_ghost_s = EffectID(rawValue: 2424)
    public static let ef_wh_wild_walk = EffectID(rawValue: 2425)
    public static let ef_force_anim_27 = EffectID(rawValue: 2426)
    public static let ef_heal_blue_2 = EffectID(rawValue: 2427)
    public static let ef_atque_poenitentia = EffectID(rawValue: 2428)
    public static let ef_perm_frost_oblivion = EffectID(rawValue: 2429)
    public static let ef_c_guide_of_dead_text = EffectID(rawValue: 2430)
    public static let ef_c_medjed_text = EffectID(rawValue: 2431)
    public static let ef_unk_2432 = EffectID(rawValue: 2432)
    public static let ef_unk_2433 = EffectID(rawValue: 2433)
    public static let ef_unk_2434 = EffectID(rawValue: 2434)
    public static let ef_unk_2435 = EffectID(rawValue: 2435)
    public static let ef_rg_coin_blue = EffectID(rawValue: 2436)
    public static let ef_rg_coin_blue_2 = EffectID(rawValue: 2437)
    public static let ef_unk_2438 = EffectID(rawValue: 2438)
    public static let ef_cruel_bite_line = EffectID(rawValue: 2439)
    public static let ef_unk_2440 = EffectID(rawValue: 2440)
    public static let ef_unk_2441 = EffectID(rawValue: 2441)
    public static let ef_quill_spear_line = EffectID(rawValue: 2442)
    public static let ef_c_2025rosfesta = EffectID(rawValue: 2443)
    public static let ef_unk_2444 = EffectID(rawValue: 2444)
    public static let ef_unk_2445 = EffectID(rawValue: 2445)
    public static let ef_unk_2446 = EffectID(rawValue: 2446)
    public static let ef_unk_2447 = EffectID(rawValue: 2447)
    public static let ef_unk_2448 = EffectID(rawValue: 2448)
    public static let ef_unk_2449 = EffectID(rawValue: 2449)
    public static let ef_unk_2450 = EffectID(rawValue: 2450)
    public static let ef_unk_2451 = EffectID(rawValue: 2451)
    public static let ef_unk_2452 = EffectID(rawValue: 2452)
    public static let ef_unk_2453 = EffectID(rawValue: 2453)
    public static let ef_unk_2454 = EffectID(rawValue: 2454)
    public static let ef_unk_2455 = EffectID(rawValue: 2455)
    public static let ef_unk_2456 = EffectID(rawValue: 2456)
    public static let ef_unk_2457 = EffectID(rawValue: 2457)
    public static let ef_s_beelzebub_wing = EffectID(rawValue: 2458)
    public static let ef_dk_servantweapon = EffectID(rawValue: 2460)
    public static let ef_dk_chargingpierce = EffectID(rawValue: 2461)
    public static let ef_ig_cross_rain = EffectID(rawValue: 2462)
    public static let ef_unk_2463 = EffectID(rawValue: 2463)
    public static let ef_unk_2464 = EffectID(rawValue: 2464)
    public static let ef_unk_2465 = EffectID(rawValue: 2465)
    public static let ef_kr_chop_chop = EffectID(rawValue: 2466)
    public static let ef_shc_shadow_exceed = EffectID(rawValue: 2467)
    public static let ef_unk_2468 = EffectID(rawValue: 2468)
    public static let ef_unk_2469 = EffectID(rawValue: 2469)
    public static let ef_unk_2470 = EffectID(rawValue: 2470)
    public static let ef_unk_2471 = EffectID(rawValue: 2471)
    public static let ef_unk_2472 = EffectID(rawValue: 2472)
    public static let ef_unk_2473 = EffectID(rawValue: 2473)
    public static let ef_unk_2474 = EffectID(rawValue: 2474)
    public static let ef_unk_2477 = EffectID(rawValue: 2477)
    public static let ef_unk_2478 = EffectID(rawValue: 2478)
    public static let ef_unk_2479 = EffectID(rawValue: 2479)
    public static let ef_unk_2480 = EffectID(rawValue: 2480)
    public static let ef_unk_2481 = EffectID(rawValue: 2481)
    public static let ef_unk_2482 = EffectID(rawValue: 2482)
    public static let ef_unk_2483 = EffectID(rawValue: 2483)
}

extension EffectID {
    public var name: String? {
        switch rawValue {
        case -1: "ef_none"
        case 0: "ef_hit1"
        case 1: "ef_hit2"
        case 2: "ef_hit3"
        case 3: "ef_hit4"
        case 4: "ef_hit5"
        case 5: "ef_hit6"
        case 6: "ef_entry"
        case 7: "ef_exit"
        case 8: "ef_warp"
        case 9: "ef_enhance"
        case 10: "ef_coin"
        case 11: "ef_endure"
        case 12: "ef_beginspell"
        case 13: "ef_glasswall"
        case 14: "ef_healsp"
        case 15: "ef_soulstrike"
        case 16: "ef_bash"
        case 17: "ef_magnumbreak"
        case 18: "ef_steal"
        case 19: "ef_hiding"
        case 20: "ef_pattack"
        case 21: "ef_detoxication"
        case 22: "ef_sight"
        case 23: "ef_stonecurse"
        case 24: "ef_fireball"
        case 25: "ef_firewall"
        case 26: "ef_icearrow"
        case 27: "ef_frostdiver"
        case 28: "ef_frostdiver2"
        case 29: "ef_lightbolt"
        case 30: "ef_thunderstorm"
        case 31: "ef_firearrow"
        case 32: "ef_napalmbeat"
        case 33: "ef_ruwach"
        case 34: "ef_teleportation"
        case 35: "ef_readyportal"
        case 36: "ef_portal"
        case 37: "ef_incagility"
        case 38: "ef_decagility"
        case 39: "ef_aqua"
        case 40: "ef_signum"
        case 41: "ef_angelus"
        case 42: "ef_blessing"
        case 43: "ef_incagidex"
        case 44: "ef_smoke"
        case 45: "ef_firefly"
        case 46: "ef_sandwind"
        case 47: "ef_torch"
        case 48: "ef_spraypond"
        case 49: "ef_firehit"
        case 50: "ef_firesplashhit"
        case 51: "ef_coldhit"
        case 52: "ef_windhit"
        case 53: "ef_poisonhit"
        case 54: "ef_beginspell2"
        case 55: "ef_beginspell3"
        case 56: "ef_beginspell4"
        case 57: "ef_beginspell5"
        case 58: "ef_beginspell6"
        case 59: "ef_beginspell7"
        case 60: "ef_lockon"
        case 61: "ef_warpzone"
        case 62: "ef_sightrasher"
        case 63: "ef_barrier"
        case 64: "ef_arrowshot"
        case 65: "ef_invenom"
        case 66: "ef_cure"
        case 67: "ef_provoke"
        case 68: "ef_mvp"
        case 69: "ef_skidtrap"
        case 70: "ef_brandishspear"
        case 71: "ef_cone"
        case 72: "ef_sphere"
        case 73: "ef_bowlingbash"
        case 74: "ef_icewall"
        case 75: "ef_gloria"
        case 76: "ef_magnificat"
        case 77: "ef_resurrection"
        case 78: "ef_recovery"
        case 79: "ef_earthspike"
        case 80: "ef_spearbmr"
        case 81: "ef_pierce"
        case 82: "ef_turnundead"
        case 83: "ef_sanctuary"
        case 84: "ef_impositio"
        case 85: "ef_lexaeterna"
        case 86: "ef_aspersio"
        case 87: "ef_lexdivina"
        case 88: "ef_suffragium"
        case 89: "ef_stormgust"
        case 90: "ef_lord"
        case 91: "ef_benedictio"
        case 92: "ef_meteorstorm"
        case 93: "ef_yufitel"
        case 94: "ef_yufitelhit"
        case 95: "ef_quagmire"
        case 96: "ef_firepillar"
        case 97: "ef_firepillarbomb"
        case 98: "ef_hasteup"
        case 99: "ef_flasher"
        case 100: "ef_removetrap"
        case 101: "ef_repairweapon"
        case 102: "ef_crashearth"
        case 103: "ef_perfection"
        case 104: "ef_maxpower"
        case 105: "ef_blastmine"
        case 106: "ef_blastminebomb"
        case 107: "ef_claymore"
        case 108: "ef_freezing"
        case 109: "ef_bubble"
        case 110: "ef_gaspush"
        case 111: "ef_springtrap"
        case 112: "ef_kyrie"
        case 113: "ef_magnus"
        case 114: "ef_bottom"
        case 115: "ef_blitzbeat"
        case 116: "ef_waterball"
        case 117: "ef_waterball2"
        case 118: "ef_fireivy"
        case 119: "ef_detecting"
        case 120: "ef_cloaking"
        case 121: "ef_sonicblow"
        case 122: "ef_sonicblowhit"
        case 123: "ef_grimtooth"
        case 124: "ef_venomdust"
        case 125: "ef_enchantpoison"
        case 126: "ef_poisonreact"
        case 127: "ef_poisonreact2"
        case 128: "ef_overthrust"
        case 129: "ef_splasher"
        case 130: "ef_twohandquicken"
        case 131: "ef_autocounter"
        case 132: "ef_grimtoothatk"
        case 133: "ef_freeze"
        case 134: "ef_freezed"
        case 135: "ef_icecrash"
        case 136: "ef_slowpoison"
        case 137: "ef_bottom2"
        case 138: "ef_firepillaron"
        case 139: "ef_sandman"
        case 140: "ef_revive"
        case 141: "ef_pneuma"
        case 142: "ef_heavensdrive"
        case 143: "ef_sonicblow2"
        case 144: "ef_brandish2"
        case 145: "ef_shockwave"
        case 146: "ef_shockwavehit"
        case 147: "ef_earthhit"
        case 148: "ef_pierceself"
        case 149: "ef_bowlingself"
        case 150: "ef_spearstabself"
        case 151: "ef_spearbmrself"
        case 152: "ef_holyhit"
        case 153: "ef_concentration"
        case 154: "ef_refineok"
        case 155: "ef_refinefail"
        case 156: "ef_jobchange"
        case 157: "ef_lvup"
        case 158: "ef_joblvup"
        case 159: "ef_toprank"
        case 160: "ef_party"
        case 161: "ef_rain"
        case 162: "ef_snow"
        case 163: "ef_sakura"
        case 164: "ef_status_state"
        case 165: "ef_banjjakii"
        case 166: "ef_makeblur"
        case 167: "ef_tamingsuccess"
        case 168: "ef_tamingfailed"
        case 169: "ef_energycoat"
        case 170: "ef_cartrevolution"
        case 171: "ef_venomdust2"
        case 172: "ef_changedark"
        case 173: "ef_changefire"
        case 174: "ef_changecold"
        case 175: "ef_changewind"
        case 176: "ef_changeflame"
        case 177: "ef_changeearth"
        case 178: "ef_chaingeholy"
        case 179: "ef_changepoison"
        case 180: "ef_hitdark"
        case 181: "ef_mentalbreak"
        case 182: "ef_magicalatthit"
        case 183: "ef_sui_explosion"
        case 184: "ef_darkattack"
        case 185: "ef_suicide"
        case 186: "ef_comboattack1"
        case 187: "ef_comboattack2"
        case 188: "ef_comboattack3"
        case 189: "ef_comboattack4"
        case 190: "ef_comboattack5"
        case 191: "ef_guidedattack"
        case 192: "ef_poisonattack"
        case 193: "ef_silenceattack"
        case 194: "ef_stunattack"
        case 195: "ef_petrifyattack"
        case 196: "ef_curseattack"
        case 197: "ef_sleepattack"
        case 198: "ef_telekhit"
        case 199: "ef_pong"
        case 200: "ef_level99"
        case 201: "ef_level99_2"
        case 202: "ef_level99_3"
        case 203: "ef_gumgang"
        case 204: "ef_potion1"
        case 205: "ef_potion2"
        case 206: "ef_potion3"
        case 207: "ef_potion4"
        case 208: "ef_potion5"
        case 209: "ef_potion6"
        case 210: "ef_potion7"
        case 211: "ef_potion8"
        case 212: "ef_darkbreath"
        case 213: "ef_deffender"
        case 214: "ef_keeping"
        case 215: "ef_summonslave"
        case 216: "ef_blooddrain"
        case 217: "ef_energydrain"
        case 218: "ef_potion_con"
        case 219: "ef_potion_"
        case 220: "ef_potion_berserk"
        case 221: "ef_potionpillar"
        case 222: "ef_defender"
        case 223: "ef_ganbantein"
        case 224: "ef_wind"
        case 225: "ef_volcano"
        case 226: "ef_grandcross"
        case 227: "ef_intimidate"
        case 228: "ef_chookgi"
        case 229: "ef_cloud"
        case 230: "ef_cloud2"
        case 231: "ef_mappillar"
        case 232: "ef_linelink"
        case 233: "ef_cloud3"
        case 234: "ef_spellbreaker"
        case 235: "ef_dispell"
        case 236: "ef_deluge"
        case 237: "ef_violentgale"
        case 238: "ef_landprotector"
        case 239: "ef_bottom_vo"
        case 240: "ef_bottom_de"
        case 241: "ef_bottom_vi"
        case 242: "ef_bottom_la"
        case 243: "ef_fastmove"
        case 244: "ef_magicrod"
        case 245: "ef_holycross"
        case 246: "ef_shieldcharge"
        case 247: "ef_mappillar2"
        case 248: "ef_providence"
        case 249: "ef_shieldboomerang"
        case 250: "ef_spearquicken"
        case 251: "ef_devotion"
        case 252: "ef_reflectshield"
        case 253: "ef_absorbspirits"
        case 254: "ef_steelbody"
        case 255: "ef_flamelauncher"
        case 256: "ef_frostweapon"
        case 257: "ef_lightningloader"
        case 258: "ef_seismicweapon"
        case 259: "ef_mappillar3"
        case 260: "ef_mappillar4"
        case 261: "ef_gumgang2"
        case 262: "ef_teihit1"
        case 263: "ef_gumgang3"
        case 264: "ef_teihit2"
        case 265: "ef_tanji"
        case 266: "ef_teihit1x"
        case 267: "ef_chimto"
        case 268: "ef_stealcoin"
        case 269: "ef_stripweapon"
        case 270: "ef_stripshield"
        case 271: "ef_striparmor"
        case 272: "ef_striphelm"
        case 273: "ef_chaincombo"
        case 274: "ef_rg_coin"
        case 275: "ef_backstap"
        case 276: "ef_teihit3"
        case 277: "ef_bottom_dissonance"
        case 278: "ef_bottom_lullaby"
        case 279: "ef_bottom_richmankim"
        case 280: "ef_bottom_eternalchaos"
        case 281: "ef_bottom_drumbattlefield"
        case 282: "ef_bottom_ringnibelungen"
        case 283: "ef_bottom_rokisweil"
        case 284: "ef_bottom_intoabyss"
        case 285: "ef_bottom_siegfried"
        case 286: "ef_bottom_whistle"
        case 287: "ef_bottom_assassincross"
        case 288: "ef_bottom_poembragi"
        case 289: "ef_bottom_appleidun"
        case 290: "ef_bottom_uglydance"
        case 291: "ef_bottom_humming"
        case 292: "ef_bottom_dontforgetme"
        case 293: "ef_bottom_fortunekiss"
        case 294: "ef_bottom_serviceforyou"
        case 295: "ef_talk_frostjoke"
        case 296: "ef_talk_scream"
        case 297: "ef_pokjuk"
        case 298: "ef_throwitem"
        case 299: "ef_throwitem2"
        case 300: "ef_chemicalprotection"
        case 301: "ef_pokjuk_sound"
        case 302: "ef_demonstration"
        case 303: "ef_chemical2"
        case 304: "ef_teleportation2"
        case 305: "ef_pharmacy_ok"
        case 306: "ef_pharmacy_fail"
        case 307: "ef_forestlight"
        case 308: "ef_throwitem3"
        case 309: "ef_firstaid"
        case 310: "ef_sprinklesand"
        case 311: "ef_loud"
        case 312: "ef_heal"
        case 313: "ef_heal2"
        case 314: "ef_exit2"
        case 315: "ef_glasswall2"
        case 316: "ef_readyportal2"
        case 317: "ef_portal2"
        case 318: "ef_bottom_mag"
        case 319: "ef_bottom_sanc"
        case 320: "ef_heal3"
        case 321: "ef_warpzone2"
        case 322: "ef_forestlight2"
        case 323: "ef_forestlight3"
        case 324: "ef_forestlight4"
        case 325: "ef_heal4"
        case 326: "ef_foot"
        case 327: "ef_foot2"
        case 328: "ef_beginasura"
        case 329: "ef_tripleattack"
        case 330: "ef_hitline"
        case 331: "ef_hptime"
        case 332: "ef_sptime"
        case 333: "ef_maple"
        case 334: "ef_blind"
        case 335: "ef_poison"
        case 336: "ef_guard"
        case 337: "ef_joblvup50"
        case 338: "ef_angel2"
        case 339: "ef_magnum2"
        case 340: "ef_callzone"
        case 341: "ef_portal3"
        case 342: "ef_couplecasting"
        case 343: "ef_heartcasting"
        case 344: "ef_entry2"
        case 345: "ef_saintwing"
        case 346: "ef_spherewind"
        case 347: "ef_colorpaper"
        case 348: "ef_lightsphere"
        case 349: "ef_waterfall"
        case 350: "ef_waterfall_90"
        case 351: "ef_waterfall_small"
        case 352: "ef_waterfall_small_90"
        case 353: "ef_waterfall_t2"
        case 354: "ef_waterfall_t2_90"
        case 355: "ef_waterfall_small_t2"
        case 356: "ef_waterfall_small_t2_90"
        case 357: "ef_mini_tetris"
        case 358: "ef_ghost"
        case 359: "ef_bat"
        case 360: "ef_bat2"
        case 361: "ef_soulbreaker"
        case 362: "ef_level99_4"
        case 363: "ef_vallentine"
        case 364: "ef_vallentine2"
        case 365: "ef_pressure"
        case 366: "ef_bash3d"
        case 367: "ef_aurablade"
        case 368: "ef_redbody"
        case 369: "ef_lkconcentration"
        case 370: "ef_bottom_gospel"
        case 371: "ef_angel"
        case 372: "ef_devil"
        case 373: "ef_dragonsmoke"
        case 374: "ef_bottom_basilica"
        case 375: "ef_assumptio"
        case 376: "ef_hitline2"
        case 377: "ef_bash3d2"
        case 378: "ef_energydrain2"
        case 379: "ef_transbluebody"
        case 380: "ef_magiccrasher"
        case 381: "ef_lightsphere2"
        case 382: "ef_lightblade"
        case 383: "ef_energydrain3"
        case 384: "ef_linelink2"
        case 385: "ef_linklight"
        case 386: "ef_truesight"
        case 387: "ef_falconassault"
        case 388: "ef_tripleattack2"
        case 389: "ef_portal4"
        case 390: "ef_meltdown"
        case 391: "ef_cartboost"
        case 392: "ef_rejectsword"
        case 393: "ef_tripleattack3"
        case 394: "ef_spherewind2"
        case 395: "ef_linelink3"
        case 396: "ef_pinkbody"
        case 397: "ef_level99_5"
        case 398: "ef_level99_6"
        case 399: "ef_bash3d3"
        case 400: "ef_bash3d4"
        case 401: "ef_napalmvalcan"
        case 402: "ef_portal5"
        case 403: "ef_magiccrasher2"
        case 404: "ef_bottom_spider"
        case 405: "ef_bottom_fogwall"
        case 406: "ef_soulburn"
        case 407: "ef_soulchange"
        case 408: "ef_baby"
        case 409: "ef_soulbreaker2"
        case 410: "ef_rainbow"
        case 411: "ef_peong"
        case 412: "ef_tanji2"
        case 413: "ef_pressedbody"
        case 414: "ef_spinedbody"
        case 415: "ef_kickedbody"
        case 416: "ef_airtexture"
        case 417: "ef_hitbody"
        case 418: "ef_doublegumgang"
        case 419: "ef_reflectbody"
        case 420: "ef_babybody"
        case 421: "ef_babybody2"
        case 422: "ef_giantbody"
        case 423: "ef_giantbody2"
        case 424: "ef_asurabody"
        case 425: "ef_4waybody"
        case 426: "ef_quakebody"
        case 427: "ef_asurabody_monster"
        case 428: "ef_hitline3"
        case 429: "ef_hitline4"
        case 430: "ef_hitline5"
        case 431: "ef_hitline6"
        case 432: "ef_electric"
        case 433: "ef_electric2"
        case 434: "ef_hitline7"
        case 435: "ef_stormkick"
        case 436: "ef_halfsphere"
        case 437: "ef_attackenergy"
        case 438: "ef_attackenergy2"
        case 439: "ef_chemical3"
        case 440: "ef_assumptio2"
        case 441: "ef_bluecasting"
        case 442: "ef_run"
        case 443: "ef_stoprun"
        case 444: "ef_stopeffect"
        case 445: "ef_jumpbody"
        case 446: "ef_landbody"
        case 447: "ef_foot3"
        case 448: "ef_foot4"
        case 449: "ef_tae_ready"
        case 450: "ef_grandcross2"
        case 451: "ef_soulstrike2"
        case 452: "ef_yufitel2"
        case 453: "ef_npc_stop"
        case 454: "ef_darkcasting"
        case 455: "ef_gumgangnpc"
        case 456: "ef_agiup"
        case 457: "ef_jumpkick"
        case 458: "ef_quakebody2"
        case 459: "ef_stormkick1"
        case 460: "ef_stormkick2"
        case 461: "ef_stormkick3"
        case 462: "ef_stormkick4"
        case 463: "ef_stormkick5"
        case 464: "ef_stormkick6"
        case 465: "ef_stormkick7"
        case 466: "ef_spinedbody2"
        case 467: "ef_beginasura1"
        case 468: "ef_beginasura2"
        case 469: "ef_beginasura3"
        case 470: "ef_beginasura4"
        case 471: "ef_beginasura5"
        case 472: "ef_beginasura6"
        case 473: "ef_beginasura7"
        case 474: "ef_aurablade2"
        case 475: "ef_devil1"
        case 476: "ef_devil2"
        case 477: "ef_devil3"
        case 478: "ef_devil4"
        case 479: "ef_devil5"
        case 480: "ef_devil6"
        case 481: "ef_devil7"
        case 482: "ef_devil8"
        case 483: "ef_devil9"
        case 484: "ef_devil10"
        case 485: "ef_doublegumgang2"
        case 486: "ef_doublegumgang3"
        case 487: "ef_blackdevil"
        case 488: "ef_flowercast"
        case 489: "ef_flowercast2"
        case 490: "ef_flowercast3"
        case 491: "ef_mochi"
        case 492: "ef_lamadan"
        case 493: "ef_edp"
        case 494: "ef_shieldboomerang2"
        case 495: "ef_rg_coin2"
        case 496: "ef_guard2"
        case 497: "ef_slim"
        case 498: "ef_slim2"
        case 499: "ef_slim3"
        case 500: "ef_chemicalbody"
        case 501: "ef_castspin"
        case 502: "ef_piercebody"
        case 503: "ef_soullink"
        case 504: "ef_chookgi2"
        case 505: "ef_memorize"
        case 506: "ef_soullight"
        case 507: "ef_mapae"
        case 508: "ef_itempokjuk"
        case 509: "ef_05val"
        case 510: "ef_beginasura11"
        case 511: "ef_night"
        case 512: "ef_chemical2dash"
        case 513: "ef_groundsample"
        case 514: "ef_gi_explosion"
        case 515: "ef_cloud4"
        case 516: "ef_cloud5"
        case 517: "ef_bottom_hermode"
        case 518: "ef_cartter"
        case 519: "ef_itemfast"
        case 520: "ef_shieldboomerang3"
        case 521: "ef_doublecastbody"
        case 522: "ef_gravitation"
        case 523: "ef_tarotcard1"
        case 524: "ef_tarotcard2"
        case 525: "ef_tarotcard3"
        case 526: "ef_tarotcard4"
        case 527: "ef_tarotcard5"
        case 528: "ef_tarotcard6"
        case 529: "ef_tarotcard7"
        case 530: "ef_tarotcard8"
        case 531: "ef_tarotcard9"
        case 532: "ef_tarotcard10"
        case 533: "ef_tarotcard11"
        case 534: "ef_tarotcard12"
        case 535: "ef_tarotcard13"
        case 536: "ef_tarotcard14"
        case 537: "ef_aciddemon"
        case 538: "ef_greenbody"
        case 539: "ef_throwitem4"
        case 540: "ef_babybody_back"
        case 541: "ef_throwitem5"
        case 542: "ef_bluebody"
        case 543: "ef_hated"
        case 544: "ef_redlightbody"
        case 545: "ef_ro2year"
        case 546: "ef_sma_ready"
        case 547: "ef_stin"
        case 548: "ef_red_hit"
        case 549: "ef_blue_hit"
        case 550: "ef_quakebody3"
        case 551: "ef_sma"
        case 552: "ef_sma2"
        case 553: "ef_stin2"
        case 554: "ef_hittexture"
        case 555: "ef_stin3"
        case 556: "ef_sma3"
        case 557: "ef_bluefall"
        case 558: "ef_bluefall_90"
        case 559: "ef_fastbluefall"
        case 560: "ef_fastbluefall_90"
        case 561: "ef_big_portal"
        case 562: "ef_big_portal2"
        case 563: "ef_screen_quake"
        case 564: "ef_homuncasting"
        case 565: "ef_hflimoon1"
        case 566: "ef_hflimoon2"
        case 567: "ef_hflimoon3"
        case 568: "ef_ho_up"
        case 569: "ef_hamidefence"
        case 570: "ef_hamicastle"
        case 571: "ef_hamiblood"
        case 572: "ef_hated2"
        case 573: "ef_twilight1"
        case 574: "ef_twilight2"
        case 575: "ef_twilight3"
        case 576: "ef_item_thunder"
        case 577: "ef_item_cloud"
        case 578: "ef_item_curse"
        case 579: "ef_item_zzz"
        case 580: "ef_item_rain"
        case 581: "ef_item_light"
        case 582: "ef_angel3"
        case 583: "ef_m01"
        case 584: "ef_m02"
        case 585: "ef_m03"
        case 586: "ef_m04"
        case 587: "ef_m05"
        case 588: "ef_m06"
        case 589: "ef_m07"
        case 590: "ef_kaizel"
        case 591: "ef_kaahi"
        case 592: "ef_cloud6"
        case 593: "ef_food01"
        case 594: "ef_food02"
        case 595: "ef_food03"
        case 596: "ef_food04"
        case 597: "ef_food05"
        case 598: "ef_food06"
        case 599: "ef_shrink"
        case 600: "ef_throwitem6"
        case 601: "ef_sight2"
        case 602: "ef_quakebody4"
        case 603: "ef_firehit2"
        case 604: "ef_npc_stop2"
        case 605: "ef_npc_stop2_del"
        case 606: "ef_fvoice"
        case 607: "ef_wink"
        case 608: "ef_cooking_ok"
        case 609: "ef_cooking_fail"
        case 610: "ef_temp_ok"
        case 611: "ef_temp_fail"
        case 612: "ef_hapgyeok"
        case 613: "ef_throwitem7"
        case 614: "ef_throwitem8"
        case 615: "ef_throwitem9"
        case 616: "ef_throwitem10"
        case 617: "ef_bunsinjyutsu"
        case 618: "ef_kouenka"
        case 619: "ef_hyousensou"
        case 620: "ef_bottom_suiton"
        case 621: "ef_stin4"
        case 622: "ef_thunderstorm2"
        case 623: "ef_chemical4"
        case 624: "ef_stin5"
        case 625: "ef_madness_blue"
        case 626: "ef_madness_red"
        case 627: "ef_rg_coin3"
        case 628: "ef_bash3d5"
        case 629: "ef_chookgi3"
        case 630: "ef_kirikage"
        case 631: "ef_tatami"
        case 632: "ef_kasumikiri"
        case 633: "ef_issen"
        case 634: "ef_kaen"
        case 635: "ef_baku"
        case 636: "ef_hyousyouraku"
        case 637: "ef_desperado"
        case 638: "ef_lightning_s"
        case 639: "ef_blind_s"
        case 640: "ef_poison_s"
        case 641: "ef_freezing_s"
        case 642: "ef_flare_s"
        case 643: "ef_rapidshower"
        case 644: "ef_magicalbullet"
        case 645: "ef_spreadattack"
        case 646: "ef_trackcasting"
        case 647: "ef_tracking"
        case 648: "ef_tripleaction"
        case 649: "ef_bullseye"
        case 650: "ef_map_magiczone"
        case 651: "ef_map_magiczone2"
        case 652: "ef_damage1"
        case 653: "ef_damage1_2"
        case 654: "ef_damage1_3"
        case 655: "ef_undeadbody"
        case 656: "ef_undeadbody_del"
        case 657: "ef_green_number"
        case 658: "ef_blue_number"
        case 659: "ef_red_number"
        case 660: "ef_purple_number"
        case 661: "ef_black_number"
        case 662: "ef_white_number"
        case 663: "ef_yellow_number"
        case 664: "ef_pink_number"
        case 665: "ef_bubble_drop"
        case 666: "ef_npc_earthquake"
        case 667: "ef_da_space"
        case 668: "ef_dragonfear"
        case 669: "ef_bleeding"
        case 670: "ef_wideconfuse"
        case 671: "ef_bottom_runner"
        case 672: "ef_bottom_transfer"
        case 673: "ef_crystal_blue"
        case 674: "ef_bottom_evilland"
        case 675: "ef_guard3"
        case 676: "ef_npc_slowcast"
        case 677: "ef_criticalwound"
        case 678: "ef_green99_3"
        case 679: "ef_green99_5"
        case 680: "ef_green99_6"
        case 681: "ef_mapsphere"
        case 682: "ef_pok_love"
        case 683: "ef_pok_white"
        case 684: "ef_pok_valen"
        case 685: "ef_pok_birth"
        case 686: "ef_pok_christmas"
        case 687: "ef_map_magiczone3"
        case 688: "ef_map_magiczone4"
        case 689: "ef_dust"
        case 690: "ef_torch_red"
        case 691: "ef_torch_green"
        case 692: "ef_map_ghost"
        case 693: "ef_glow1"
        case 694: "ef_glow2"
        case 695: "ef_glow4"
        case 696: "ef_torch_purple"
        case 697: "ef_cloud7"
        case 698: "ef_cloud8"
        case 699: "ef_flowerleaf"
        case 700: "ef_mapsphere2"
        case 701: "ef_glow11"
        case 702: "ef_glow12"
        case 703: "ef_circlelight"
        case 704: "ef_item315"
        case 705: "ef_item316"
        case 706: "ef_item317"
        case 707: "ef_item318"
        case 708: "ef_storm_min"
        case 709: "ef_pok_jap"
        case 710: "ef_map_greenlight"
        case 711: "ef_map_magicwall"
        case 712: "ef_map_greenlight2"
        case 713: "ef_yellowfly1"
        case 714: "ef_yellowfly2"
        case 715: "ef_bottom_blue"
        case 716: "ef_bottom_blue2"
        case 717: "ef_wewish"
        case 718: "ef_firepillaron2"
        case 719: "ef_forestlight5"
        case 720: "ef_soulbreaker3"
        case 721: "ef_ado_str"
        case 722: "ef_ign_str"
        case 723: "ef_chimto2"
        case 724: "ef_windcutter"
        case 725: "ef_detect2"
        case 726: "ef_frostmysty"
        case 727: "ef_crimson_str"
        case 728: "ef_hell_str"
        case 729: "ef_spr_mash"
        case 730: "ef_spr_soule"
        case 731: "ef_dhowl_str"
        case 732: "ef_earthwall"
        case 733: "ef_soulbreaker4"
        case 734: "ef_chainl_str"
        case 735: "ef_chookgi_fire"
        case 736: "ef_chookgi_wind"
        case 737: "ef_chookgi_water"
        case 738: "ef_chookgi_ground"
        case 739: "ef_magenta_trap"
        case 740: "ef_cobalt_trap"
        case 741: "ef_maize_trap"
        case 742: "ef_verdure_trap"
        case 743: "ef_normal_trap"
        case 744: "ef_cloaking2"
        case 745: "ef_aimed_str"
        case 746: "ef_arrowstorm_str"
        case 747: "ef_laulamus_str"
        case 748: "ef_lauagnus_str"
        case 749: "ef_milshield_str"
        case 750: "ef_concentration2"
        case 751: "ef_fireball2"
        case 752: "ef_bunsinjyutsu2"
        case 753: "ef_cleartime"
        case 754: "ef_glasswall3"
        case 755: "ef_oratio"
        case 756: "ef_potion_berserk2"
        case 757: "ef_circlepower"
        case 758: "ef_rolling1"
        case 759: "ef_rolling2"
        case 760: "ef_rolling3"
        case 761: "ef_rolling4"
        case 762: "ef_rolling5"
        case 763: "ef_rolling6"
        case 764: "ef_rolling7"
        case 765: "ef_rolling8"
        case 766: "ef_rolling9"
        case 767: "ef_rolling10"
        case 768: "ef_purplebody"
        case 769: "ef_stin6"
        case 770: "ef_rg_coin4"
        case 771: "ef_poisonwav"
        case 772: "ef_poisonsmoke"
        case 773: "ef_gumgang4"
        case 774: "ef_shieldboomerang4"
        case 775: "ef_castspin2"
        case 776: "ef_vulcanwav"
        case 777: "ef_agiup2"
        case 778: "ef_detect3"
        case 779: "ef_agiup3"
        case 780: "ef_detect4"
        case 781: "ef_electric3"
        case 782: "ef_guard4"
        case 783: "ef_bottom_barrier"
        case 784: "ef_bottom_stealth"
        case 785: "ef_repairtime"
        case 786: "ef_nc_anal"
        case 787: "ef_firethrow"
        case 788: "ef_venomimpress"
        case 789: "ef_frostmisty"
        case 790: "ef_burning"
        case 791: "ef_coldthrow"
        case 792: "ef_makehallu"
        case 793: "ef_hallutime"
        case 794: "ef_infraredscan"
        case 795: "ef_crashaxe"
        case 796: "ef_gthunder"
        case 797: "ef_stonering"
        case 798: "ef_intimidate2"
        case 799: "ef_stasis"
        case 800: "ef_redline"
        case 801: "ef_frostdiver3"
        case 802: "ef_bottom_basilica2"
        case 803: "ef_recognized"
        case 804: "ef_tetra"
        case 805: "ef_tetracasting"
        case 806: "ef_fireball3"
        case 807: "ef_intimidate3"
        case 808: "ef_recognized2"
        case 809: "ef_cloaking3"
        case 810: "ef_intimidate4"
        case 811: "ef_stretch"
        case 812: "ef_blackbody"
        case 813: "ef_enervation"
        case 814: "ef_enervation2"
        case 815: "ef_enervation3"
        case 816: "ef_enervation4"
        case 817: "ef_enervation5"
        case 818: "ef_enervation6"
        case 819: "ef_linelink4"
        case 820: "ef_rg_coin5"
        case 821: "ef_waterfall_ani"
        case 822: "ef_bottom_manhole"
        case 823: "ef_manhole"
        case 824: "ef_makefeint"
        case 825: "ef_forestlight6"
        case 826: "ef_darkcasting2"
        case 827: "ef_bottom_ani"
        case 828: "ef_bottom_maelstrom"
        case 829: "ef_bottom_bloodylust"
        case 830: "ef_beginspell_n1"
        case 831: "ef_beginspell_n2"
        case 832: "ef_heal_n"
        case 833: "ef_chookgi_n"
        case 834: "ef_joblvup50_2"
        case 835: "ef_chemical2dash2"
        case 836: "ef_chemical2dash3"
        case 837: "ef_rollingcast"
        case 838: "ef_water_below"
        case 839: "ef_water_fade"
        case 840: "ef_beginspell_n3"
        case 841: "ef_beginspell_n4"
        case 842: "ef_beginspell_n5"
        case 843: "ef_beginspell_n6"
        case 844: "ef_beginspell_n7"
        case 845: "ef_beginspell_n8"
        case 846: "ef_water_smoke"
        case 847: "ef_dance1"
        case 848: "ef_dance2"
        case 849: "ef_linkparticle"
        case 850: "ef_soullight2"
        case 851: "ef_spr_particle"
        case 852: "ef_spr_particle2"
        case 853: "ef_spr_plant"
        case 854: "ef_chemical_v"
        case 855: "ef_shootparticle"
        case 856: "ef_bot_reverb"
        case 857: "ef_rain_particle"
        case 858: "ef_chemical_v2"
        case 859: "ef_secra"
        case 860: "ef_bot_reverb2"
        case 861: "ef_circlepower2"
        case 862: "ef_secra2"
        case 863: "ef_chemical_v3"
        case 864: "ef_enervation7"
        case 865: "ef_circlepower3"
        case 866: "ef_spr_plant2"
        case 867: "ef_circlepower4"
        case 868: "ef_spr_plant3"
        case 869: "ef_rg_coin6"
        case 870: "ef_spr_plant4"
        case 871: "ef_circlepower5"
        case 872: "ef_spr_plant5"
        case 873: "ef_circlepower6"
        case 874: "ef_spr_plant6"
        case 875: "ef_circlepower7"
        case 876: "ef_spr_plant7"
        case 877: "ef_circlepower8"
        case 878: "ef_spr_plant8"
        case 879: "ef_heartasura"
        case 880: "ef_beginspell_150"
        case 881: "ef_level99_150"
        case 882: "ef_primecharge"
        case 883: "ef_glasswall4"
        case 884: "ef_gradius_laser"
        case 885: "ef_bash3d6"
        case 886: "ef_gumgang5"
        case 887: "ef_hitline8"
        case 888: "ef_electric4"
        case 889: "ef_teihit1t"
        case 890: "ef_spinmove"
        case 891: "ef_fireball4"
        case 892: "ef_tripleattack4"
        case 893: "ef_chemical3s"
        case 894: "ef_groundshake"
        case 895: "ef_dq9_charge"
        case 896: "ef_dq9_charge2"
        case 897: "ef_dq9_charge3"
        case 898: "ef_dq9_charge4"
        case 899: "ef_blueline"
        case 900: "ef_selfscroll"
        case 901: "ef_spr_lightprint"
        case 902: "ef_png_test"
        case 903: "ef_beginspell_yb"
        case 904: "ef_chemical2dash4"
        case 905: "ef_groundshake2"
        case 906: "ef_pressure2"
        case 907: "ef_rg_coin7"
        case 908: "ef_primecharge2"
        case 909: "ef_primecharge3"
        case 910: "ef_primecharge4"
        case 911: "ef_greencasting"
        case 912: "ef_wallofthorn"
        case 913: "ef_fireball5"
        case 914: "ef_throwitem11"
        case 915: "ef_spr_plant9"
        case 916: "ef_demonicfire"
        case 917: "ef_demonicfire2"
        case 918: "ef_demonicfire3"
        case 919: "ef_hellsplant"
        case 920: "ef_firewall2"
        case 921: "ef_vacuum"
        case 922: "ef_spr_plant10"
        case 923: "ef_spr_lightprint2"
        case 924: "ef_poisonsmoke2"
        case 925: "ef_makehallu2"
        case 926: "ef_shockwave2"
        case 927: "ef_spr_plant11"
        case 928: "ef_coldthrow2"
        case 929: "ef_demonicfire4"
        case 930: "ef_pressure3"
        case 931: "ef_linkparticle2"
        case 932: "ef_soullight3"
        case 933: "ef_chareffect"
        case 934: "ef_gumgang6"
        case 935: "ef_fireball6"
        case 936: "ef_gumgang7"
        case 937: "ef_gumgang8"
        case 938: "ef_gumgang9"
        case 939: "ef_bottom_de2"
        case 940: "ef_coldstatus"
        case 941: "ef_spr_lightprint3"
        case 942: "ef_waterball3"
        case 943: "ef_heal_n2"
        case 944: "ef_rain_particle2"
        case 945: "ef_cloud9"
        case 946: "ef_yellowfly3"
        case 947: "ef_el_gust"
        case 948: "ef_el_blast"
        case 949: "ef_el_aquaplay"
        case 950: "ef_el_upheaval"
        case 951: "ef_el_wild_storm"
        case 952: "ef_el_chilly_air"
        case 953: "ef_el_cursed_soil"
        case 954: "ef_el_cooler"
        case 955: "ef_el_tropic"
        case 956: "ef_el_pyrotechnic"
        case 957: "ef_el_petrology"
        case 958: "ef_el_heater"
        case 959: "ef_poison_mist"
        case 960: "ef_eraser_cutter"
        case 961: "ef_silent_breeze"
        case 962: "ef_magma_flow"
        case 963: "ef_graybody"
        case 964: "ef_lava_slide"
        case 965: "ef_sonic_claw"
        case 966: "ef_tinder_breaker"
        case 967: "ef_midnight_frenzy"
        case 968: "ef_macro"
        case 969: "ef_chemical_allrange"
        case 970: "ef_tetra_fire"
        case 971: "ef_tetra_water"
        case 972: "ef_tetra_wind"
        case 973: "ef_tetra_ground"
        case 974: "ef_emitter"
        case 975: "ef_volcanic_ash"
        case 976: "ef_level99_orb1"
        case 977: "ef_level99_orb2"
        case 978: "ef_level150"
        case 979: "ef_level150_sub"
        case 980: "ef_throwitem4_1"
        case 981: "ef_throw_happokunai"
        case 982: "ef_throw_multiple_coin"
        case 983: "ef_throw_bakuretsu"
        case 984: "ef_rotate_huumaranka"
        case 985: "ef_rotate_bg"
        case 986: "ef_rotate_line_gray"
        case 987: "ef_2011rwc"
        case 988: "ef_2011rwc2"
        case 989: "ef_kaihou"
        case 990: "ef_ground_explosion"
        case 991: "ef_kg_kagehumi"
        case 992: "ef_ko_zenkai_water"
        case 993: "ef_ko_zenkai_land"
        case 994: "ef_ko_zenkai_fire"
        case 995: "ef_ko_zenkai_wind"
        case 996: "ef_ko_jyumonjikiri"
        case 997: "ef_ko_setsudan"
        case 998: "ef_red_cross"
        case 999: "ef_ko_izayoi"
        case 1000: "ef_rotate_line_blue"
        case 1001: "ef_kg_kyomu"
        case 1002: "ef_ko_huumaranka"
        case 1003: "ef_bluelightbody"
        case 1004: "ef_kagemusya"
        case 1005: "ef_ob_gensou"
        case 1006: "ef_no100_firecracker"
        case 1007: "ef_ko_makibishi"
        case 1008: "ef_kaihou1"
        case 1009: "ef_akaitsuki"
        case 1010: "ef_zangetsu"
        case 1011: "ef_gensou"
        case 1012: "ef_hat_effect"
        case 1013: "ef_cherryblossom"
        case 1014: "ef_event_cloud"
        case 1015: "ef_run_make_ok"
        case 1016: "ef_run_make_failure"
        case 1017: "ef_miresult_make_ok"
        case 1018: "ef_miresult_make_fail"
        case 1019: "ef_all_ray_of_protection"
        case 1020: "ef_venomfog"
        case 1021: "ef_duststorm"
        case 1022: "ef_level160"
        case 1023: "ef_level160_sub"
        case 1024: "ef_mapchain"
        case 1025: "ef_magic_floor"
        case 1026: "ef_icemine"
        case 1027: "ef_flamecorss"
        case 1028: "ef_icemine_1"
        case 1029: "ef_dance_blade_atk"
        case 1030: "ef_darkpiercing"
        case 1031: "ef_invincibleoff2"
        case 1032: "ef_maxpain"
        case 1033: "ef_deathsummon"
        case 1034: "ef_moonstar"
        case 1035: "ef_strangelights"
        case 1036: "ef_super_star"
        case 1037: "ef_yellobody"
        case 1038: "ef_colorpaper2"
        case 1039: "ef_evils_paw"
        case 1040: "ef_gc_darkcrow"
        case 1041: "ef_rk_dragonbreath_water"
        case 1042: "ef_all_full_throttle"
        case 1043: "ef_sr_flashcombo"
        case 1044: "ef_rk_luxanima"
        case 1045: "ef_cloud10"
        case 1046: "ef_so_elemental_shield"
        case 1047: "ef_ab_offertorium"
        case 1048: "ef_wl_telekinesis_intense"
        case 1049: "ef_gn_illusiondoping"
        case 1050: "ef_nc_magma_eruption"
        case 1051: "ef_lg_kings_grace"
        case 1052: "ef_blooddrain2"
        case 1053: "ef_npc_wideweb"
        case 1054: "ef_npc_burnt"
        case 1055: "ef_npc_chill"
        case 1056: "ef_ra_unlimit"
        case 1057: "ef_ab_offertorium_ring"
        case 1058: "ef_sc_escape"
        case 1059: "ef_wm_frigg_song"
        case 1060: "ef_flicker"
        case 1061: "ef_c_maker"
        case 1062: "ef_hammer_of_god"
        case 1063: "ef_mass_spiral"
        case 1064: "ef_fire_rain"
        case 1065: "ef_whitebody"
        case 1066: "ef_banishing_buster"
        case 1067: "ef_slugshot"
        case 1068: "ef_d_tail"
        case 1069: "ef_bind_trap1"
        case 1070: "ef_bind_trap2"
        case 1071: "ef_bind_trap3"
        case 1072: "ef_jumpbody1"
        case 1073: "ef_animated_emitter"
        case 1074: "ef_rl_explosion"
        case 1075: "ef_c_maker_1"
        case 1076: "ef_qd_shot"
        case 1077: "ef_p_alter"
        case 1078: "ef_s_storm"
        case 1079: "ef_music_hat"
        case 1080: "ef_cloud_kill"
        case 1081: "ef_escape"
        case 1082: "ef_xeno_slasher"
        case 1083: "ef_flowersmoke"
        case 1084: "ef_fstone"
        case 1085: "ef_qscaraba"
        case 1086: "ef_ljosalfar"
        case 1087: "ef_happinessstar"
        case 1088: "ef_power_of_gaia"
        case 1089: "ef_maple_falls"
        case 1090: "ef_marking_use_changemonster"
        case 1091: "ef_magical_feather"
        case 1092: "ef_mermaid_longing"
        case 1093: "ef_gift_of_snow"
        case 1094: "ef_ach_complete"
        case 1095: "ef_time_accessory"
        case 1096: "ef_spritemable"
        case 1097: "ef_tunaparty"
        case 1098: "ef_freshshrimp"
        case 1099: "ef_unk_1099"
        case 1100: "ef_unk_1100"
        case 1101: "ef_su_sv_stemspear"
        case 1102: "ef_su_tunabelly"
        case 1103: "ef_su_scratch"
        case 1104: "ef_su_cn_powdering"
        case 1105: "ef_su_bite"
        case 1106: "ef_unk_1106"
        case 1107: "ef_su_scaroftarou"
        case 1108: "ef_su_arclousedash"
        case 1109: "ef_su_pickypeck"
        case 1110: "ef_su_sv_roottwist"
        case 1111: "ef_unk_1111"
        case 1112: "ef_unk_1112"
        case 1113: "ef_unk_1113"
        case 1114: "ef_warning_plane"
        case 1115: "ef_su_cn_meteor"
        case 1116: "ef_su_bunchofshrimp"
        case 1117: "ef_unk_1117"
        case 1118: "ef_unk_1118"
        case 1119: "ef_bite_scar"
        case 1120: "ef_su_lunatic_carrot_beat"
        case 1121: "ef_wide_critical_wound"
        case 1122: "ef_su_soul_attack"
        case 1123: "ef_su_grooming"
        case 1124: "ef_su_chattering"
        case 1125: "ef_su_lope"
        case 1126: "ef_su_hiss"
        case 1127: "ef_su_powerofflock"
        case 1128: "ef_unk_1128"
        case 1129: "ef_su_svg_spirit"
        case 1130: "ef_bakuretsu_hadou"
        case 1131: "ef_su_spirit_of_life"
        case 1132: "ef_su_stoop"
        case 1133: "ef_firedance"
        case 1134: "ef_richs_coin_a"
        case 1135: "ef_rl_b_trap"
        case 1136: "ef_rl_anti_material_blast"
        case 1137: "ef_e_chain"
        case 1138: "ef_heat_barrel"
        case 1139: "ef_h_mine"
        case 1140: "ef_fallen_angel"
        case 1141: "ef_we_oneforever"
        case 1142: "ef_we_cheerup"
        case 1143: "ef_unk_1143"
        case 1144: "ef_unk_1144"
        case 1145: "ef_rl_hammer_of_god"
        case 1146: "ef_unk_1146"
        case 1147: "ef_popcorn"
        case 1148: "ef_rl_r_trip"
        case 1149: "ef_immune_property"
        case 1150: "ef_move_coordinate"
        case 1151: "ef_immune_property_nothing"
        case 1152: "ef_immune_property_water"
        case 1153: "ef_immune_property_ground"
        case 1154: "ef_immune_property_fire"
        case 1155: "ef_immune_property_wind"
        case 1156: "ef_immune_property_poison"
        case 1157: "ef_immune_property_saint"
        case 1158: "ef_immune_property_darkness"
        case 1159: "ef_immune_property_telekinesis"
        case 1160: "ef_immune_property_undead"
        case 1161: "ef_quagmire_visual"
        case 1162: "ef_lord_of_vermillion_visual"
        case 1163: "ef_meteor_storm_visual"
        case 1164: "ef_unk_1164"
        case 1165: "ef_unk_1165"
        case 1166: "ef_unk_1166"
        case 1167: "ef_unk_1167"
        case 1168: "ef_unk_1168"
        case 1169: "ef_unk_1169"
        case 1170: "ef_unk_1170"
        case 1171: "ef_unk_1171"
        case 1172: "ef_unk_1172"
        case 1173: "ef_unk_1173"
        case 1174: "ef_unk_1174"
        case 1175: "ef_unk_1175"
        case 1176: "ef_unk_1176"
        case 1177: "ef_unk_1177"
        case 1178: "ef_unk_1178"
        case 1179: "ef_unk_1179"
        case 1180: "ef_unk_1180"
        case 1181: "ef_unk_1181"
        case 1182: "ef_unk_1182"
        case 1183: "ef_unk_1183"
        case 1184: "ef_unk_1184"
        case 1185: "ef_warpzone3"
        case 1186: "ef_dropitem_pink"
        case 1187: "ef_unk_1187"
        case 1188: "ef_unk_1188"
        case 1189: "ef_dropitem_yellow"
        case 1190: "ef_dropitem_purple"
        case 1191: "ef_unk_1191"
        case 1192: "ef_random_opt_yellow"
        case 1193: "ef_unk_1193"
        case 1194: "ef_unk_1194"
        case 1195: "ef_autoshadowspell_active"
        case 1196: "ef_new_cloud_kill"
        case 1197: "ef_lightsphere_sun"
        case 1198: "ef_lightsphere_moon"
        case 1199: "ef_lightsphere_star"
        case 1200: "ef_thunder_plazma_blast"
        case 1201: "ef_unk_1201"
        case 1202: "ef_novaexplosing"
        case 1203: "ef_star_emperor"
        case 1204: "ef_sma_black"
        case 1205: "ef_sma_black2"
        case 1206: "ef_stin_black"
        case 1207: "ef_peong_black"
        case 1208: "ef_energydrain_black"
        case 1209: "ef_blink_body"
        case 1210: "ef_linelink5"
        case 1211: "ef_subject_aura_1211"
        case 1212: "ef_subject_aura_1212"
        case 1213: "ef_subject_aura_1213"
        case 1214: "ef_sun_stance"
        case 1215: "ef_lunar_stance"
        case 1216: "ef_star_stance"
        case 1217: "ef_universe_stance"
        case 1218: "ef_solarburst"
        case 1219: "ef_sj_document"
        case 1220: "ef_falling_star"
        case 1221: "ef_flash_kick"
        case 1222: "ef_soul_unity"
        case 1223: "ef_stormkick8"
        case 1224: "ef_solar_explosion"
        case 1225: "ef_soul_collect"
        case 1226: "ef_level185"
        case 1227: "ef_level185_sub"
        case 1228: "ef_soul_golem"
        case 1229: "ef_newmoon_kick"
        case 1230: "ef_fullmoon_kick"
        case 1231: "ef_book_of_dimension"
        case 1232: "ef_book_of_creatingstar"
        case 1233: "ef_curse_explosion"
        case 1234: "ef_soul_reaper"
        case 1235: "ef_soul_shadow"
        case 1236: "ef_soul_fairy"
        case 1237: "ef_soul_falcon"
        case 1238: "ef_soul_curse"
        case 1239: "ef_prominence_kick"
        case 1240: "ef_soul_reaper_collect"
        case 1241: "ef_unk_1241"
        case 1242: "ef_soul_explosion"
        case 1243: "ef_soul_revolve"
        case 1244: "ef_test_effect_00"
        case 1245: "ef_test_effect_01"
        case 1246: "ef_test_effect_02"
        case 1247: "ef_test_effect_03"
        case 1248: "ef_test_effect_04"
        case 1249: "ef_test_effect_05"
        case 1250: "ef_test_effect_06"
        case 1251: "ef_test_effect_07"
        case 1252: "ef_test_effect_08"
        case 1253: "ef_test_effect_09"
        case 1254: "ef_new_meteorstorm"
        case 1255: "ef_new_meteorstorm_bottom"
        case 1256: "ef_unk_1256"
        case 1257: "ef_unk_1257"
        case 1258: "ef_new_adoramus"
        case 1259: "ef_new_adoramus_bottom"
        case 1260: "ef_tetra_vortex_cast"
        case 1261: "ef_tetra_vortex_core"
        case 1262: "ef_tetra_vortex_ball_1"
        case 1263: "ef_tetra_vortex_ball_2"
        case 1264: "ef_tetra_vortex_ball_3"
        case 1265: "ef_tetra_vortex_ball_4"
        case 1266: "ef_tetra_vortex_fire_exp"
        case 1267: "ef_tetra_vortex_water_exp"
        case 1268: "ef_tetra_vortex_wind_exp"
        case 1269: "ef_tetra_vortex_earth_exp"
        case 1270: "ef_tetra_vortex_fire_ground"
        case 1271: "ef_tetra_vortex_water_ground"
        case 1272: "ef_tetra_vortex_wind_ground"
        case 1273: "ef_tetra_vortex_earth_ground"
        case 1274: "ef_new_crimsonrock"
        case 1275: "ef_new_crimsonrock_bottom"
        case 1276: "ef_new_severerainstorm"
        case 1277: "ef_tetra_vortex_core_ground"
        case 1278: "ef_tetra_vortex_fire_sub"
        case 1279: "ef_tetra_vortex_water_sub"
        case 1280: "ef_tetra_vortex_wind_sub"
        case 1281: "ef_tetra_vortex_earth_sub"
        case 1282: "ef_new_diamonddust"
        case 1283: "ef_new_diamonddust_bottom"
        case 1284: "ef_new_diamonddust_cast"
        case 1285: "ef_new_severerainstorm_cast"
        case 1286: "ef_new_severerainstorm_hit"
        case 1287: "ef_new_secrament"
        case 1288: "ef_new_psychicwave"
        case 1289: "ef_new_psychicwave_bottom"
        case 1290: "ef_new_psychicwave_cast"
        case 1291: "ef_unk_1291"
        case 1292: "ef_unk_1292"
        case 1293: "ef_new_arrowstorm_00"
        case 1294: "ef_new_arrowstorm_01"
        case 1295: "ef_new_secrament_aura"
        case 1296: "ef_new_triangleshot"
        case 1297: "ef_new_triangleshot_bottom"
        case 1298: "ef_new_crimsonrock_sub"
        case 1299: "ef_new_rollingcutter"
        case 1300: "ef_new_rollingcutter_count_01"
        case 1301: "ef_new_rollingcutter_count_02"
        case 1302: "ef_new_rollingcutter_count_03"
        case 1303: "ef_new_rollingcutter_count_04"
        case 1304: "ef_new_rollingcutter_count_05"
        case 1305: "ef_new_rollingcutter_count_06"
        case 1306: "ef_new_rollingcutter_count_07"
        case 1307: "ef_new_rollingcutter_count_08"
        case 1308: "ef_new_rollingcutter_count_09"
        case 1309: "ef_new_rollingcutter_count_10"
        case 1310: "ef_new_rampageblaster"
        case 1311: "ef_new_rampageblaster_bottom"
        case 1312: "ef_new_feintbomb"
        case 1313: "ef_new_feintbomb_bottom"
        case 1314: "ef_new_crossripperslasher"
        case 1315: "ef_new_crossripperslasher_00"
        case 1316: "ef_new_crossripperslasher_01"
        case 1317: "ef_new_crossripperslasher_03"
        case 1318: "ef_new_crossripperslasher_05"
        case 1319: "ef_new_crossripperslasher_06"
        case 1320: "ef_new_crossripperslasher_07"
        case 1321: "ef_new_crossripperslasher_09"
        case 1322: "ef_new_crossripperslasher_11"
        case 1323: "ef_new_tigercannon"
        case 1324: "ef_new_triangleshot_arrow"
        case 1325: "ef_unk_1325"
        case 1326: "ef_unk_1326"
        case 1327: "ef_unk_1327"
        case 1328: "ef_unk_1328"
        case 1329: "ef_unk_1329"
        case 1330: "ef_unk_1330"
        case 1331: "ef_unk_1331"
        case 1332: "ef_unk_1332"
        case 1333: "ef_unk_1333"
        case 1334: "ef_unk_1334"
        case 1335: "ef_unk_1335"
        case 1336: "ef_unk_1336"
        case 1337: "ef_unk_1337"
        case 1338: "ef_unk_1338"
        case 1339: "ef_unk_1339"
        case 1340: "ef_unk_1340"
        case 1341: "ef_unk_1341"
        case 1342: "ef_unk_1342"
        case 1343: "ef_unk_1343"
        case 1344: "ef_unk_1344"
        case 1345: "ef_unk_1345"
        case 1346: "ef_unk_1346"
        case 1347: "ef_new_armscannon_01_up"
        case 1348: "ef_new_armscannon_01_down"
        case 1349: "ef_new_armscannon_05_up"
        case 1350: "ef_new_armscannon_05_down"
        case 1351: "ef_new_armscannon_07_up"
        case 1352: "ef_new_armscannon_07_down"
        case 1353: "ef_new_armscannon_11_up"
        case 1354: "ef_new_armscannon_11_down"
        case 1355: "ef_new_armscannon_explosion"
        case 1356: "ef_new_armscannon_explosion_bottom"
        case 1357: "ef_new_cart_cannon"
        case 1358: "ef_new_cart_cannon_explosion"
        case 1359: "ef_new_cart_cannon_explosion_bottom"
        case 1360: "ef_new_cart_cannon_fire"
        case 1361: "ef_new_cart_cannon_fire_bottom"
        case 1362: "ef_qscaraba_visual"
        case 1363: "ef_new_axetornado"
        case 1364: "ef_new_axetornado_bottom"
        case 1365: "ef_new_cart_tornado"
        case 1366: "ef_new_cart_tornado_bottom"
        case 1367: "ef_help_angel"
        case 1368: "ef_help_angel_bottom"
        case 1369: "ef_new_banishingpoint_target"
        case 1370: "ef_new_banishingpoint_target_bottom"
        case 1371: "ef_new_banishingpoint_cast"
        case 1372: "ef_new_banishingpoint_cast_bottom"
        case 1373: "ef_new_banishingpoint_01"
        case 1374: "ef_new_banishingpoint_05"
        case 1375: "ef_new_banishingpoint_07"
        case 1376: "ef_new_banishingpoint_11"
        case 1377: "ef_valkyrie_wing"
        case 1378: "ef_new_dragonbreath_bomb"
        case 1379: "ef_new_dragonbreath_bomb_bottom"
        case 1380: "ef_new_dragonbreath_01"
        case 1381: "ef_new_dragonbreath_05"
        case 1382: "ef_new_dragonbreath_07"
        case 1383: "ef_new_dragonbreath_11"
        case 1384: "ef_new_armscannon_cast"
        case 1385: "ef_new_armscannon_cast_bottom"
        case 1386: "ef_new_dragonbreath_water_bomb"
        case 1387: "ef_new_dragonbreath_water_bomb_bottom"
        case 1388: "ef_new_dragonbreath_water_01"
        case 1389: "ef_new_dragonbreath_water_05"
        case 1390: "ef_new_dragonbreath_water_07"
        case 1391: "ef_new_dragonbreath_water_11"
        case 1392: "ef_new_counter_slash"
        case 1393: "ef_new_counter_slash_bottom"
        case 1394: "ef_new_fatal_menace"
        case 1395: "ef_new_fatal_menace_bottom"
        case 1396: "ef_new_fatal_menace_cast"
        case 1397: "ef_new_fatal_menace_cast_bottom"
        case 1398: "ef_unk_1398"
        case 1399: "ef_new_heavens_drive"
        case 1400: "ef_new_cannon_spear_12"
        case 1401: "ef_new_cannon_spear_01"
        case 1402: "ef_new_cannon_spear_03"
        case 1403: "ef_new_cannon_spear_05"
        case 1404: "ef_new_cannon_spear_06"
        case 1405: "ef_new_cannon_spear_07"
        case 1406: "ef_new_cannon_spear_09"
        case 1407: "ef_new_cannon_spear_11"
        case 1408: "ef_new_cannon_spear_bottom"
        case 1409: "ef_new_tripleattack"
        case 1410: "ef_new_basicattack"
        case 1411: "ef_new_criticalattack"
        case 1412: "ef_new_rangedattack"
        case 1413: "ef_new_comet"
        case 1414: "ef_new_comet_bottom"
        case 1415: "ef_new_comet_cast_bottom"
        case 1416: "ef_new_comet_sub_exp"
        case 1417: "ef_new_comet_sub_exp_bottom"
        case 1418: "ef_new_moon_slash"
        case 1419: "ef_c_amdarais_effect"
        case 1420: "ef_new_grandcross"
        case 1421: "ef_new_comet_cast"
        case 1422: "ef_new_cart_cannon_cast"
        case 1423: "ef_new_cart_cannon_cast_bottom"
        case 1424: "ef_new_rayofgenesis"
        case 1425: "ef_new_rayofgenesis_cast"
        case 1426: "ef_new_rayofgenesis_cast_bottom"
        case 1427: "ef_new_rayofgenesis_hit"
        case 1428: "ef_mineffect_adoramus"
        case 1429: "ef_mineffect_adoramus_bottom"
        case 1430: "ef_mineffect_tetra_cast"
        case 1431: "ef_mineffect_tetra_core"
        case 1432: "ef_mineffect_tetra_fire"
        case 1433: "ef_mineffect_tetra_water"
        case 1434: "ef_mineffect_tetra_wind"
        case 1435: "ef_mineffect_tetra_earth"
        case 1436: "ef_mineffect_tetra_fire_bottom"
        case 1437: "ef_mineffect_tetra_water_bottom"
        case 1438: "ef_mineffect_tetra_wind_bottom"
        case 1439: "ef_mineffect_tetra_earth_bottom"
        case 1440: "ef_mineffect_tetra_core_bottom"
        case 1441: "ef_mineffect_crimsonrock"
        case 1442: "ef_mineffect_crimsonrock_bottom"
        case 1443: "ef_new_jackfrost_00"
        case 1444: "ef_new_jackfrost_01"
        case 1445: "ef_new_jackfrost_02"
        case 1446: "ef_new_jackfrost_cast"
        case 1447: "ef_new_jackfrost_rune"
        case 1448: "ef_new_jackfrost_art"
        case 1449: "ef_new_frostmisty"
        case 1450: "ef_mineffect_diamonddust"
        case 1451: "ef_mineffect_diamonddust_bottom"
        case 1452: "ef_mineffect_diamonddust_cast"
        case 1453: "ef_mineffect_secrament"
        case 1454: "ef_mineffect_psychicwave"
        case 1455: "ef_mineffect_psychicwave_bottom"
        case 1456: "ef_mineffect_psychicwave_cast"
        case 1457: "ef_mineffect_arrowstorm_00"
        case 1458: "ef_mineffect_arrowstorm_01"
        case 1459: "ef_mineffect_triangleshot"
        case 1460: "ef_mineffect_triangleshot_bottom"
        case 1461: "ef_mineffect_rampageblaster"
        case 1462: "ef_mineffect_rampageblaster_bottom"
        case 1463: "ef_mineffect_feintbomb"
        case 1464: "ef_mineffect_feintbomb_bottom"
        case 1465: "ef_new_earthgrave_visual"
        case 1466: "ef_mineffect_rollingcutter_cast"
        case 1467: "ef_mineffect_rollingcutter_01"
        case 1468: "ef_mineffect_rollingcutter_02"
        case 1469: "ef_mineffect_rollingcutter_03"
        case 1470: "ef_mineffect_rollingcutter_04"
        case 1471: "ef_mineffect_rollingcutter_05"
        case 1472: "ef_mineffect_rollingcutter_06"
        case 1473: "ef_mineffect_rollingcutter_07"
        case 1474: "ef_mineffect_rollingcutter_08"
        case 1475: "ef_mineffect_rollingcutter_09"
        case 1476: "ef_mineffect_rollingcutter_10"
        case 1477: "ef_mineffect_crossripperslasher"
        case 1478: "ef_mineffect_crossripperslasher_12"
        case 1479: "ef_mineffect_crossripperslasher_01"
        case 1480: "ef_mineffect_crossripperslasher_03"
        case 1481: "ef_mineffect_crossripperslasher_05"
        case 1482: "ef_mineffect_crossripperslasher_06"
        case 1483: "ef_mineffect_crossripperslasher_07"
        case 1484: "ef_mineffect_crossripperslasher_09"
        case 1485: "ef_mineffect_crossripperslasher_11"
        case 1486: "ef_mineffect_armscannon_01"
        case 1487: "ef_mineffect_armscannon_05"
        case 1488: "ef_mineffect_armscannon_07"
        case 1489: "ef_mineffect_armscannon_11"
        case 1490: "ef_mineffect_armscannon_explosion"
        case 1491: "ef_mineffect_armscannon_explosion_bottom"
        case 1492: "ef_mineffect_armscannon_cast"
        case 1493: "ef_mineffect_armscannon_cast_bottom"
        case 1494: "ef_mineffect_axetornado"
        case 1495: "ef_mineffect_axetornado_bottom"
        case 1496: "ef_mineffect_cart_cannon_explosion"
        case 1497: "ef_mineffect_cart_cannon_explosion_bottom"
        case 1498: "ef_mineffect_cart_cannon_fire_bottom"
        case 1499: "ef_mineffect_cart_cannon_cast"
        case 1500: "ef_mineffect_cart_cannon_cast_bottom"
        case 1501: "ef_mineffect_cart_tornado"
        case 1502: "ef_mineffect_cart_tornado_bottom"
        case 1503: "ef_mineffect_banishingpoint_target"
        case 1504: "ef_mineffect_banishingpoint_target_bottom"
        case 1505: "ef_mineffect_banishingpoint_cast"
        case 1506: "ef_mineffect_banishingpoint_cast_bottom"
        case 1507: "ef_mineffect_banishingpoint_01"
        case 1508: "ef_mineffect_banishingpoint_05"
        case 1509: "ef_mineffect_banishingpoint_07"
        case 1510: "ef_mineffect_banishingpoint_11"
        case 1511: "ef_mineffect_cannon_spear_12"
        case 1512: "ef_mineffect_cannon_spear_01"
        case 1513: "ef_mineffect_cannon_spear_03"
        case 1514: "ef_mineffect_cannon_spear_05"
        case 1515: "ef_mineffect_cannon_spear_06"
        case 1516: "ef_mineffect_cannon_spear_07"
        case 1517: "ef_mineffect_cannon_spear_09"
        case 1518: "ef_mineffect_cannon_spear_11"
        case 1519: "ef_mineffect_cannon_spear_bottom"
        case 1520: "ef_mineffect_dragonbreath_bomb"
        case 1521: "ef_mineffect_dragonbreath_01"
        case 1522: "ef_mineffect_dragonbreath_05"
        case 1523: "ef_mineffect_dragonbreath_07"
        case 1524: "ef_mineffect_dragonbreath_11"
        case 1525: "ef_whiteimprison_state"
        case 1526: "ef_mineffect_dragonbreath_water_bomb"
        case 1527: "ef_mineffect_dragonbreath_water_01"
        case 1528: "ef_mineffect_dragonbreath_water_05"
        case 1529: "ef_mineffect_dragonbreath_water_07"
        case 1530: "ef_mineffect_dragonbreath_water_11"
        case 1531: "ef_pok_thunder"
        case 1532: "ef_mineffect_tigercannon"
        case 1533: "ef_mineffect_severerainstorm_cast"
        case 1534: "ef_mineffect_comet"
        case 1535: "ef_mineffect_comet_bottom"
        case 1536: "ef_mineffect_comet_cast_bottom"
        case 1537: "ef_mineffect_comet_sub_exp"
        case 1538: "ef_mineffect_comet_sub_exp_bottom"
        case 1539: "ef_mineffect_comet_cast"
        case 1540: "ef_mineffect_jackfrost_00"
        case 1541: "ef_mineffect_jackfrost_01"
        case 1542: "ef_mineffect_jackfrost_02"
        case 1543: "ef_mineffect_jackfrost_cast"
        case 1544: "ef_mineffect_jackfrost_rune"
        case 1545: "ef_new_magnum_break"
        case 1546: "ef_new_poisonsmoke_1"
        case 1547: "ef_new_poisonsmoke_2"
        case 1548: "ef_new_poisonsmoke_cast"
        case 1549: "ef_new_fearbreeze"
        case 1550: "ef_new_hellinferno"
        case 1551: "ef_new_hellinferno_bottom"
        case 1552: "ef_new_hellinferno_cast_bottom"
        case 1553: "ef_new_hellinferno_sub"
        case 1554: "ef_new_hellinferno_sub_bottom"
        case 1555: "ef_evilland"
        case 1556: "ef_new_heal_blue"
        case 1557: "ef_new_clearance"
        case 1558: "ef_new_clearance_bottom"
        case 1559: "ef_new_clearance_cast"
        case 1560: "ef_new_heal_white"
        case 1561: "ef_new_varetyrspear"
        case 1562: "ef_new_varetyrspear_bottom"
        case 1563: "ef_new_varetyrspear_cast"
        case 1564: "ef_new_varetyrspear_cast_bottom"
        case 1565: "ef_new_heal_yellow"
        case 1566: "ef_new_crossimpact"
        case 1567: "ef_new_crossimpact_target"
        case 1568: "ef_new_crossimpact_hit"
        case 1569: "ef_new_reverberation"
        case 1570: "ef_new_fallenempire"
        case 1571: "ef_new_fallenempire_bottom"
        case 1572: "ef_new_fallenempire_hit"
        case 1573: "ef_new_gateofhell_cast"
        case 1574: "ef_new_gateofhell_target"
        case 1575: "ef_new_gateofhell"
        case 1576: "ef_new_howlingoflion"
        case 1577: "ef_new_howlingoflion_bottom"
        case 1578: "ef_new_howlingoflion_cast"
        case 1579: "ef_new_howlingoflion_cast_bottom"
        case 1580: "ef_new_howlingoflion_hit"
        case 1581: "ef_new_metallicsound"
        case 1582: "ef_new_metallicsound_bottom"
        case 1583: "ef_new_metallicsound_hit"
        case 1584: "ef_new_metallicsound_line"
        case 1585: "ef_new_reproduce"
        case 1586: "ef_new_reproduce_bottom"
        case 1587: "ef_new_soulexpansion_cast"
        case 1588: "ef_new_soulexpansion_cast_bottom"
        case 1589: "ef_new_soulexpansion_loop"
        case 1590: "ef_new_soulexpansion_loop_bottom"
        case 1591: "ef_new_soulexpansion_hit"
        case 1592: "ef_new_soulexpansion_hit_bottom"
        case 1593: "ef_new_reverberation_hit"
        case 1594: "ef_new_reverberation_note"
        case 1595: "ef_new_aromaoil"
        case 1596: "ef_new_aromaoil_bottom"
        case 1597: "ef_new_bathfoam"
        case 1598: "ef_new_bathfoam_bottom"
        case 1599: "ef_tetra_vortex_core_reuse"
        case 1600: "ef_guard5"
        case 1601: "ef_magic_circle_1"
        case 1602: "ef_bio5_plant_green"
        case 1603: "ef_bio5_plant_blue"
        case 1604: "ef_bio5_plant_yellow"
        case 1605: "ef_bio5_plant_white"
        case 1606: "ef_bio5_plant_red"
        case 1607: "ef_grade_enchant_intro"
        case 1608: "ef_grade_enchant_success"
        case 1609: "ef_grade_enchant_failed"
        case 1610: "ef_pok_magic"
        case 1611: "ef_blue_wave_1"
        case 1612: "ef_blue_wave_2"
        case 1613: "ef_blue_wave_3"
        case 1614: "ef_red_wave_1"
        case 1615: "ef_red_wave_2"
        case 1616: "ef_red_wave_3"
        case 1617: "ef_blackbubble_small"
        case 1618: "ef_blackbubble_midium"
        case 1619: "ef_blackbubble_large"
        case 1620: "ef_new_wallofthorn_cast"
        case 1621: "ef_new_wallofthorn_cast_bottom"
        case 1622: "ef_new_earthgrave_bottom"
        case 1623: "ef_new_earthgrave_hit"
        case 1624: "ef_new_ignitionbreak"
        case 1625: "ef_new_ignitionbreak_bottom"
        case 1626: "ef_new_ignitionbreak_cast"
        case 1627: "ef_new_judex_cast"
        case 1628: "ef_new_judex_cast_bottom"
        case 1629: "ef_new_judex_cast_loop"
        case 1630: "ef_new_judex_cast_loop_bottom"
        case 1631: "ef_new_judex_target"
        case 1632: "ef_new_judex_target_bottom"
        case 1633: "ef_new_judex_light"
        case 1634: "ef_new_judex_light_bottom"
        case 1635: "ef_new_chainlightning_cast"
        case 1636: "ef_new_chainlightning_cast_bottom"
        case 1637: "ef_new_chainlightning_lockon"
        case 1638: "ef_new_chainlightning_target"
        case 1639: "ef_new_mandragora"
        case 1640: "ef_new_mandragora_bottom"
        case 1641: "ef_new_mandragora_cast"
        case 1642: "ef_new_soundofdestruction_cast"
        case 1643: "ef_new_soundofdestruction_cast_bottom"
        case 1644: "ef_new_soundofdestruction_target"
        case 1645: "ef_new_aimedbolt_01"
        case 1646: "ef_new_aimedbolt_05"
        case 1647: "ef_new_aimedbolt_07"
        case 1648: "ef_new_aimedbolt_11"
        case 1649: "ef_new_aimedbolt_cast_bottom"
        case 1650: "ef_new_aimedbolt_end"
        case 1651: "ef_new_aimedbolt_target_loop"
        case 1652: "ef_new_unlimit"
        case 1653: "ef_new_unlimit_bottom"
        case 1654: "ef_new_epiclesis"
        case 1655: "ef_new_epiclesis_aura"
        case 1656: "ef_new_epiclesis_cast"
        case 1657: "ef_new_axeboomerang"
        case 1658: "ef_new_axeboomerang_cast"
        case 1659: "ef_new_axeboomerang_cast_bottom"
        case 1660: "ef_new_axeboomerang_hit"
        case 1661: "ef_hackandslash"
        case 1662: "ef_hackandslash_bottom"
        case 1663: "ef_hackandslash_hit"
        case 1664: "ef_new_sanctuary"
        case 1665: "ef_new_spellfist_fire"
        case 1666: "ef_new_spellfist_fire_bottom"
        case 1667: "ef_new_spellfist_water"
        case 1668: "ef_new_spellfist_water_bottom"
        case 1669: "ef_new_spellfist_wind"
        case 1670: "ef_stormslash_1"
        case 1671: "ef_stormslash_2"
        case 1672: "ef_stormslash_3"
        case 1673: "ef_stormslash_4"
        case 1674: "ef_stormslash_5"
        case 1675: "ef_new_cartboost"
        case 1676: "ef_new_cartboost_bottom"
        case 1677: "ef_new_safetywall"
        case 1678: "ef_new_sonicwave"
        case 1679: "ef_new_overbrand_01"
        case 1680: "ef_new_overbrand_03"
        case 1681: "ef_new_overbrand_05"
        case 1682: "ef_new_overbrand_06"
        case 1683: "ef_new_overbrand_07"
        case 1684: "ef_new_overbrand_09"
        case 1685: "ef_new_overbrand_11"
        case 1686: "ef_new_overbrand_12"
        case 1687: "ef_new_overbrand_cast"
        case 1688: "ef_new_overbrand_cast_bottom"
        case 1689: "ef_new_overbrand_hit"
        case 1690: "ef_new_windcutter"
        case 1691: "ef_new_windcutter_bottom_01"
        case 1692: "ef_new_windcutter_bottom_05"
        case 1693: "ef_new_windcutter_target"
        case 1694: "ef_servantweapon"
        case 1695: "ef_new_servantweapon_hit"
        case 1696: "ef_new_servantweapon_hit_bottom"
        case 1697: "ef_new_servantweapon_shoot_bottom"
        case 1698: "ef_new_powerswing_01"
        case 1699: "ef_new_powerswing_05"
        case 1700: "ef_new_powerswing_07"
        case 1701: "ef_new_powerswing_11"
        case 1702: "ef_new_powerswing_bottom"
        case 1703: "ef_new_vulcanarm"
        case 1704: "ef_new_vulcanarm_bottom"
        case 1705: "ef_new_vulcanarm_shothole"
        case 1706: "ef_new_earthdrive"
        case 1707: "ef_new_earthdrive_bottom"
        case 1708: "ef_new_earthdrive_target"
        case 1709: "ef_new_earthdrive_cast"
        case 1710: "ef_servant_sign"
        case 1711: "ef_servant_sign_down"
        case 1712: "ef_servant_sign_down_bottom"
        case 1713: "ef_servant_phantom_down"
        case 1714: "ef_servant_phantom_hit"
        case 1715: "ef_servant_phantom_hit_bottom"
        case 1716: "ef_servant_phantom_sub"
        case 1717: "ef_servant_phantom_sub_bottom"
        case 1718: "ef_servant_demolition_collect"
        case 1719: "ef_servant_demolition_hit"
        case 1720: "ef_servant_demolition_leftdown"
        case 1721: "ef_servant_demolition_rightdown"
        case 1722: "ef_dragonic_aura"
        case 1723: "ef_dragonic_aura_bottom"
        case 1724: "ef_dragonic_aura_hit"
        case 1725: "ef_dragonic_aura_hit_bottom"
        case 1726: "ef_dragonic_aura_buff"
        case 1727: "ef_dragonic_aura_buff_bottom"
        case 1728: "ef_madness_crusher"
        case 1729: "ef_madness_crusher_bottom"
        case 1730: "ef_new_autoshadowspell"
        case 1731: "ef_new_autoshadowspell_bottom"
        case 1732: "ef_destructive_hurricane"
        case 1733: "ef_destructive_hurricane_bottom"
        case 1734: "ef_destructive_hurricane_cast"
        case 1735: "ef_destructive_hurricane_cast_bottom"
        case 1736: "ef_destructive_hurricane_climax"
        case 1737: "ef_destructive_hurricane_hit"
        case 1738: "ef_deadly_projection_cast"
        case 1739: "ef_deadly_projection_cast_bottom"
        case 1740: "ef_deadly_projection_hit"
        case 1741: "ef_deadly_projection"
        case 1742: "ef_soul_vc_strike_cast"
        case 1743: "ef_soul_vc_strike_cast_bottom"
        case 1744: "ef_soul_vc_strike_hit"
        case 1745: "ef_rockdown"
        case 1746: "ef_rockdown_bottom"
        case 1747: "ef_rockdown_cast"
        case 1748: "ef_rockdown_cast_bottom"
        case 1749: "ef_rockdown_hit"
        case 1750: "ef_vigor_cast"
        case 1751: "ef_vigor_buff"
        case 1752: "ef_unk_1752"
        case 1753: "ef_rain_of_crystal"
        case 1754: "ef_rain_of_crystal_bottom"
        case 1755: "ef_storm_cannon"
        case 1756: "ef_crimsonarrow"
        case 1757: "ef_crimson_arrow_cast"
        case 1758: "ef_crimson_arrow_cast_bottom"
        case 1759: "ef_crimson_arrow_hit"
        case 1760: "ef_violentquake"
        case 1761: "ef_violent_quake_cast"
        case 1762: "ef_violent_quake_cast_bottom"
        case 1763: "ef_violent_quake_hit"
        case 1764: "ef_new_chargingpierce"
        case 1765: "ef_new_chargingpierce_cast"
        case 1766: "ef_new_chargingpierce_cast_bottom"
        case 1767: "ef_new_chargingpierce_hit"
        case 1768: "ef_astral_strike"
        case 1769: "ef_astral_strike_cast"
        case 1770: "ef_astral_strike_cast_bottom"
        case 1771: "ef_mystery_illusion"
        case 1772: "ef_mystery_illusion_bottom"
        case 1773: "ef_mystery_illusion_cast"
        case 1774: "ef_mystery_illusion_cast_bottom"
        case 1775: "ef_mystery_illusion_hit"
        case 1776: "ef_tornado_storm"
        case 1777: "ef_tornado_storm_bottom"
        case 1778: "ef_tornado_storm_cast"
        case 1779: "ef_tornado_storm_cast_bottom"
        case 1780: "ef_tornado_storm_hit"
        case 1781: "ef_frozen_slash"
        case 1782: "ef_frozen_slash_cast"
        case 1783: "ef_frozen_slash_cast_bottom"
        case 1784: "ef_frozen_slash_hit"
        case 1785: "ef_frozen_slash_ice_01"
        case 1786: "ef_frozen_slash_ice_02"
        case 1787: "ef_frozen_slash_ice_03"
        case 1788: "ef_frozen_slash_ice_04"
        case 1789: "ef_frozen_slash_ice_05"
        case 1790: "ef_frozen_slash_ice_06"
        case 1791: "ef_frozen_slash_ice_07"
        case 1792: "ef_frozen_slash_ice_08"
        case 1793: "ef_violent_quake_bottom"
        case 1794: "ef_all_bloom"
        case 1795: "ef_all_bloom_bottom"
        case 1796: "ef_all_bloom_cast"
        case 1797: "ef_all_bloom_cast_bottom"
        case 1798: "ef_unk_1798"
        case 1799: "ef_all_bloom_hit"
        case 1800: "ef_climax"
        case 1801: "ef_climax_light"
        case 1802: "ef_climax_cast"
        case 1803: "ef_climax_cast_loop"
        case 1804: "ef_floral_flare_road"
        case 1805: "ef_floral_flare_road_cast"
        case 1806: "ef_floral_flare_road_cast_bottom"
        case 1807: "ef_floral_flare_road_hit"
        case 1808: "ef_mediale_votum"
        case 1809: "ef_mediale_votum_cast"
        case 1810: "ef_mediale_votum_loop"
        case 1811: "ef_argutus_vita"
        case 1812: "ef_argutus_vita_cast"
        case 1813: "ef_argutus_telum"
        case 1814: "ef_argutus_telum_cast"
        case 1815: "ef_presens_acies"
        case 1816: "ef_presens_acies_cast"
        case 1817: "ef_new_d_machine"
        case 1818: "ef_new_d_machine_cast"
        case 1819: "ef_new_d_machine_cast_bottom"
        case 1820: "ef_new_d_machine_start"
        case 1821: "ef_new_d_machine_end"
        case 1822: "ef_arbitrium_cast"
        case 1823: "ef_arbitrium_cast_bottom"
        case 1824: "ef_arbitrium"
        case 1825: "ef_arbitrium_bottom"
        case 1826: "ef_arbitrium_hit"
        case 1827: "ef_dancing_knife_cast"
        case 1828: "ef_dancing_knife_cast_bottom"
        case 1829: "ef_dancing_knife"
        case 1830: "ef_abyss_dagger_hit_1830"
        case 1831: "ef_new_reparatio_cast"
        case 1832: "ef_new_reparatio_cast_bottom"
        case 1833: "ef_new_reparatio"
        case 1834: "ef_new_reparatio_bottom"
        case 1835: "ef_new_reparatio_target"
        case 1836: "ef_new_reparatio_target_bottom"
        case 1837: "ef_savage_impact"
        case 1838: "ef_eternal_slash_hit_1"
        case 1839: "ef_a_machine"
        case 1840: "ef_a_machine_cast"
        case 1841: "ef_unk_1841"
        case 1842: "ef_a_machine_hit"
        case 1843: "ef_unk_1843"
        case 1844: "ef_unk_1844"
        case 1845: "ef_unk_1845"
        case 1846: "ef_effligo"
        case 1847: "ef_effligo_bottom"
        case 1848: "ef_effligo_hit"
        case 1849: "ef_competentia"
        case 1850: "ef_competentia_bottom"
        case 1851: "ef_unk_1851"
        case 1852: "ef_competentia_loop"
        case 1853: "ef_competentia_loop_bottom"
        case 1854: "ef_crystal_impact"
        case 1855: "ef_crystal_impact_bottom"
        case 1856: "ef_crystal_impact_cast"
        case 1857: "ef_crystal_impact_cast_bottom"
        case 1858: "ef_crystal_impact_hit"
        case 1859: "ef_crystal_impact_buff"
        case 1860: "ef_religio"
        case 1861: "ef_religio_cast"
        case 1862: "ef_new_enchanting_shadow"
        case 1863: "ef_new_enchanting_shadow_bottom"
        case 1864: "ef_fatal_shadow_crow"
        case 1865: "ef_fatal_shadow_crow_bottom"
        case 1866: "ef_fatal_shadow_crow_hit"
        case 1867: "ef_shadow_exceed"
        case 1868: "ef_shadow_exceed_cast"
        case 1869: "ef_dropitem_blue"
        case 1870: "ef_dropitem_green"
        case 1871: "ef_dropitem_red"
        case 1872: "ef_new_pneuma"
        case 1873: "ef_deep_blind_trap_cast"
        case 1874: "ef_deep_blind_trap"
        case 1875: "ef_deep_blind_trap_hit"
        case 1876: "ef_new_sw_cast"
        case 1877: "ef_swift_trap_cast"
        case 1878: "ef_swift_trap"
        case 1879: "ef_swift_trap_hit"
        case 1880: "ef_solid_trap_cast"
        case 1881: "ef_solid_trap_cast_bottom"
        case 1882: "ef_solid_trap"
        case 1883: "ef_solid_trap_hit"
        case 1884: "ef_new_rush_quake"
        case 1885: "ef_new_rush_quake_bottom"
        case 1886: "ef_new_rush_quake_hit"
        case 1887: "ef_benedictum"
        case 1888: "ef_benedictum_cast"
        case 1889: "ef_benedictum_cast_bottom"
        case 1890: "ef_stratum_tremor_cast"
        case 1891: "ef_stratum_tremor_cast_bottom"
        case 1892: "ef_stratum_tremor_hit"
        case 1893: "ef_stratum_tremor"
        case 1894: "ef_stratum_tremor_bottom"
        case 1895: "ef_impact_crater"
        case 1896: "ef_impact_crater_bottom"
        case 1897: "ef_unk_1897"
        case 1898: "ef_impact_crater_hit"
        case 1899: "ef_wind_sign"
        case 1900: "ef_wind_sign_loop"
        case 1901: "ef_abr_mother_cast"
        case 1902: "ef_abr_mother"
        case 1903: "ef_abr_mother_01"
        case 1904: "ef_abr_mother_02"
        case 1905: "ef_hawk_rush"
        case 1906: "ef_abr_infinity"
        case 1907: "ef_abr_infinity_bottom"
        case 1908: "ef_abr_infinity_cast"
        case 1909: "ef_abr_infinity_hit"
        case 1910: "ef_abr_infinity_ring"
        case 1911: "ef_petitio"
        case 1912: "ef_eternal_slash"
        case 1913: "ef_eternal_slash_count"
        case 1914: "ef_eternal_slash_hit_2"
        case 1915: "ef_new_d_cannon"
        case 1916: "ef_new_d_cannon_cast"
        case 1917: "ef_new_d_cannon_hit"
        case 1918: "ef_new_d_cannon_entity"
        case 1919: "ef_flame_trap"
        case 1920: "ef_unk_1920"
        case 1921: "ef_flame_trap_cast"
        case 1922: "ef_flame_trap_hit"
        case 1923: "ef_flame_trap_ring"
        case 1924: "ef_new_dilectio_heal"
        case 1925: "ef_new_dilectio_heal_cast"
        case 1926: "ef_new_dilectio_heal_cast_bottom"
        case 1927: "ef_new_dilectio_heal_target"
        case 1928: "ef_new_dilectio_heal_target_bottom"
        case 1929: "ef_new_pramen_bottom"
        case 1930: "ef_new_pramen_cast"
        case 1931: "ef_new_pramen"
        case 1932: "ef_new_pramen_ring"
        case 1933: "ef_new_potent_venom"
        case 1934: "ef_new_battle_w"
        case 1935: "ef_new_battle_w_cast"
        case 1936: "ef_new_battle_w_bottom"
        case 1937: "ef_new_battle_w_hit"
        case 1938: "ef_new_battle_w_entity"
        case 1939: "ef_new_axe_stomp_hit"
        case 1940: "ef_new_axe_stomp_bottom"
        case 1941: "ef_new_axe_stomp"
        case 1942: "ef_new_axe_stomp_12"
        case 1943: "ef_new_axe_stomp_01"
        case 1944: "ef_new_axe_stomp_03"
        case 1945: "ef_new_axe_stomp_05"
        case 1946: "ef_new_axe_stomp_06"
        case 1947: "ef_new_axe_stomp_08"
        case 1948: "ef_new_axe_stomp_09"
        case 1949: "ef_new_axe_stomp_11"
        case 1950: "ef_crescivebolt_cast"
        case 1951: "ef_crescivebolt"
        case 1952: "ef_crescivebolt_hit"
        case 1953: "ef_shadow_stab"
        case 1954: "ef_eternal_slash_hit"
        case 1955: "ef_shadow_stab_hit2"
        case 1956: "ef_unk_1956"
        case 1957: "ef_pneumaticus_procella"
        case 1958: "ef_pneumaticus_procella_cast"
        case 1959: "ef_pneumaticus_procella_ring"
        case 1960: "ef_calumitygale"
        case 1961: "ef_calumitygale_cast"
        case 1962: "ef_calumitygale_loop"
        case 1963: "ef_sincere_faith_ring"
        case 1964: "ef_sincere_faith"
        case 1965: "ef_sincere_faith_bottom"
        case 1966: "ef_abyss_dagger"
        case 1967: "ef_abyss_dagger_hit"
        case 1968: "ef_hawk_boomerang"
        case 1969: "ef_hawk_boomerang_cast"
        case 1970: "ef_hawk_boomerang_hit"
        case 1971: "ef_hawk_boomerang_start"
        case 1972: "ef_gale_storm_cast"
        case 1973: "ef_gale_storm"
        case 1974: "ef_gale_storm_hit"
        case 1975: "ef_first_faith_power"
        case 1976: "ef_first_faith_power_cast"
        case 1977: "ef_first_faith_power_start"
        case 1978: "ef_judge"
        case 1979: "ef_judge_cast"
        case 1980: "ef_judge_start"
        case 1981: "ef_judge_aura"
        case 1982: "ef_third_exor_flame"
        case 1983: "ef_third_exor_flame_cast"
        case 1984: "ef_third_exor_flame_start"
        case 1985: "ef_third_exor_flame_aura"
        case 1986: "ef_powerful_faith_ring"
        case 1987: "ef_powerful_faith"
        case 1988: "ef_oleum_sanctum"
        case 1989: "ef_oleum_sanctum_bottom"
        case 1990: "ef_oleum_sanctum_hit"
        case 1991: "ef_oleum_sanctum_loop"
        case 1992: "ef_increasing_activity"
        case 1993: "ef_increasing_activity_cast"
        case 1994: "ef_increasing_activity_cast_bottom"
        case 1995: "ef_explosion_blaster"
        case 1996: "ef_explosion_blaster_bottom"
        case 1997: "ef_explosion_blaster_hit"
        case 1998: "ef_firm_faith_ring"
        case 1999: "ef_firm_faith"
        case 2000: "ef_mysticsymphony"
        case 2001: "ef_mysticsymphony_cast"
        case 2002: "ef_mysticsymphony_note"
        case 2003: "ef_activity_burn"
        case 2004: "ef_activity_burn_cast"
        case 2005: "ef_activity_burn_cast_bottom"
        case 2006: "ef_kvasirsonata"
        case 2007: "ef_kvasirsonata_cast"
        case 2008: "ef_kvasirsonata_cast_bottom"
        case 2009: "ef_serpens_bottom"
        case 2010: "ef_serpens_cast"
        case 2011: "ef_serpens_cast_bottom"
        case 2012: "ef_serpens_hit"
        case 2013: "ef_serpens_shield"
        case 2014: "ef_chain_reaction_shot_cast"
        case 2015: "ef_chain_reaction_shot_cast_bottom"
        case 2016: "ef_eternal_slash_hit_3"
        case 2017: "ef_chain_reaction_shot_hitsub"
        case 2018: "ef_chain_reaction_shot"
        case 2019: "ef_diluvio_ice"
        case 2020: "ef_diluvio_ice_bottom"
        case 2021: "ef_diluvio_cast"
        case 2022: "ef_diluvio_cast_bottom"
        case 2023: "ef_diluvio_hit"
        case 2024: "ef_diluvio_armor"
        case 2025: "ef_spell_enchanting"
        case 2026: "ef_diamond_storm"
        case 2027: "ef_diamond_storm_bottom"
        case 2028: "ef_diamond_storm_cast"
        case 2029: "ef_diamond_storm_cast_bottom"
        case 2030: "ef_diamond_storm_hit"
        case 2031: "ef_venom_swamp_bottom"
        case 2032: "ef_venom_swamp_cast"
        case 2033: "ef_venom_swamp_cast_bottom"
        case 2034: "ef_venom_swamp_hit"
        case 2035: "ef_ardor"
        case 2036: "ef_ardor_bottom"
        case 2037: "ef_ardor_cast"
        case 2038: "ef_ardor_cast_bottom"
        case 2039: "ef_ardor_hit"
        case 2040: "ef_ardor_flamearmor"
        case 2041: "ef_lightning_land"
        case 2042: "ef_lightning_land_bottom"
        case 2043: "ef_lightning_land_cast"
        case 2044: "ef_lightning_land_cast_bottom"
        case 2045: "ef_lightning_land_hit"
        case 2046: "ef_roseblossom_cast"
        case 2047: "ef_roseblossom_cast_bottom"
        case 2048: "ef_roseblossom_hit"
        case 2049: "ef_roseblossom_rose"
        case 2050: "ef_roseblossom_shot"
        case 2051: "ef_first_brand"
        case 2052: "ef_first_brand_aura"
        case 2053: "ef_first_brand_hit"
        case 2054: "ef_first_brand_start"
        case 2055: "ef_conflagration"
        case 2056: "ef_conflagration_bottom"
        case 2057: "ef_conflagration_cast"
        case 2058: "ef_conflagration_cast_bottom"
        case 2059: "ef_conflagration_hit"
        case 2060: "ef_sound_blend"
        case 2061: "ef_sound_blend_cast"
        case 2062: "ef_sound_blend_cast_bottom"
        case 2063: "ef_sound_blend_red"
        case 2064: "ef_metallic_fury"
        case 2065: "ef_jawaii_serenade"
        case 2066: "ef_jawaii_serenade_cast"
        case 2067: "ef_jawaii_serenade_cast_bottom"
        case 2068: "ef_pronmarch"
        case 2069: "ef_pronmarch_cast"
        case 2070: "ef_pronmarch_cast_bottom"
        case 2071: "ef_rhythmshooting_cast"
        case 2072: "ef_rhythmshooting_cast_bottom"
        case 2073: "ef_rhythmshooting_hit"
        case 2074: "ef_rhythmshooting_shot"
        case 2075: "ef_niflheim"
        case 2076: "ef_niflheim_cast"
        case 2077: "ef_unk_2077"
        case 2078: "ef_second_faith"
        case 2079: "ef_second_faith_aura"
        case 2080: "ef_second_faith_hit"
        case 2081: "ef_second_faith_start"
        case 2082: "ef_second_judgement"
        case 2083: "ef_second_flame"
        case 2084: "ef_second_flame_bottom"
        case 2085: "ef_third_flame_bomb"
        case 2086: "ef_third_flame_bomb_bottom"
        case 2087: "ef_abyss_strike"
        case 2088: "ef_abyss_strike_bottom"
        case 2089: "ef_abyss_strike_cast"
        case 2090: "ef_abyss_strike_cast_bottom"
        case 2091: "ef_abyss_strike_ground"
        case 2092: "ef_abyss_strike_ground_bottom"
        case 2093: "ef_abyss_strike_hit"
        case 2094: "ef_massive_flame_blaster"
        case 2095: "ef_massive_flame_blaster_hit"
        case 2096: "ef_massive_flame_blaster_hit_bottom"
        case 2097: "ef_third_consecration"
        case 2098: "ef_procella"
        case 2099: "ef_procella_bottom"
        case 2100: "ef_procella_cast"
        case 2101: "ef_procella_cast_bottom"
        case 2102: "ef_procella_hit"
        case 2103: "ef_procella_storm"
        case 2104: "ef_terremotus"
        case 2105: "ef_terremotus_cast"
        case 2106: "ef_terremotus_cast_bottom"
        case 2107: "ef_terremotus_hit"
        case 2108: "ef_terremotus_protect"
        case 2109: "ef_unk_2109"
        case 2110: "ef_from_the_abyss"
        case 2111: "ef_abyss_strike_hit_2"
        case 2112: "ef_third_punish"
        case 2113: "ef_third_punish_bottom"
        case 2114: "ef_frenzy_shot"
        case 2115: "ef_frenzy_shot_hit"
        case 2116: "ef_gef_nocturn"
        case 2117: "ef_gef_nocturn_cast"
        case 2118: "ef_gef_nocturn_cast_bottom"
        case 2119: "ef_roki_capriccio"
        case 2120: "ef_roki_capriccio_cast"
        case 2121: "ef_roki_capriccio_cast_bottom"
        case 2122: "ef_musical_interlude"
        case 2123: "ef_musical_interlude_cast"
        case 2124: "ef_ain_rhapsody"
        case 2125: "ef_ain_rhapsody_cast"
        case 2126: "ef_abyss_slayer"
        case 2127: "ef_abyss_slayer_cast"
        case 2128: "ef_abyss_slayer_cast_bottom"
        case 2129: "ef_abyss_square"
        case 2130: "ef_abyss_square_bottom"
        case 2131: "ef_abyss_dagger_hit_2"
        case 2132: "ef_deft_stab"
        case 2133: "ef_terra_drive"
        case 2134: "ef_terra_drive_bottom"
        case 2135: "ef_terra_drive_cast"
        case 2136: "ef_terra_drive_cast_bottom"
        case 2137: "ef_terra_drive_hit"
        case 2138: "ef_elemental_buster_cast"
        case 2139: "ef_elemental_buster_fire"
        case 2140: "ef_elemental_buster_fire_bottom"
        case 2141: "ef_elemental_buster_fire_hit"
        case 2142: "ef_elemental_buster_land"
        case 2143: "ef_elemental_buster_land_bottom"
        case 2144: "ef_elemental_buster_land_hit"
        case 2145: "ef_elemental_buster_poison"
        case 2146: "ef_elemental_buster_poison_bottom"
        case 2147: "ef_elemental_buster_poison_hit"
        case 2148: "ef_elemental_buster_water"
        case 2149: "ef_elemental_buster_water_bottom"
        case 2150: "ef_elemental_buster_water_hit"
        case 2151: "ef_elemental_buster_wind"
        case 2152: "ef_elemental_buster_wind_bottom"
        case 2153: "ef_elemental_buster_wind_hit"
        case 2154: "ef_unlucky_rush"
        case 2155: "ef_unlucky_rush_cast"
        case 2156: "ef_abyss_dagger_hit_3"
        case 2157: "ef_overslash"
        case 2158: "ef_overslash_bottom"
        case 2159: "ef_overslash_cast"
        case 2160: "ef_overslash_hit"
        case 2161: "ef_advanced_protection"
        case 2162: "ef_advanced_protection_bottom"
        case 2163: "ef_advanced_protection_cast"
        case 2164: "ef_advanced_protection_cast_bottom"
        case 2165: "ef_cross_rain"
        case 2166: "ef_cross_rain_bottom"
        case 2167: "ef_cross_rain_cast"
        case 2168: "ef_cross_rain_cast_bottom"
        case 2169: "ef_guard_stance"
        case 2170: "ef_guard_stance_cast"
        case 2171: "ef_guard_stance_cast_bottom"
        case 2172: "ef_attack_stance"
        case 2173: "ef_attack_stance_cast"
        case 2174: "ef_attack_stance_cast_bottom"
        case 2175: "ef_grand_judgement"
        case 2176: "ef_grand_judgement_bottom"
        case 2177: "ef_grand_judgement_buff"
        case 2178: "ef_grand_judgement_cast"
        case 2179: "ef_grand_judgement_cast_bottom"
        case 2180: "ef_holy_shield_cast"
        case 2181: "ef_holy_shield"
        case 2182: "ef_holy_shield_loop"
        case 2183: "ef_shield_shooting"
        case 2184: "ef_shield_shooting_cast"
        case 2185: "ef_shield_shooting_hit"
        case 2186: "ef_the_w_protection"
        case 2187: "ef_the_w_protection_cast"
        case 2188: "ef_guardianshield"
        case 2189: "ef_guardianshield_bottom"
        case 2190: "ef_guardianshield_sub"
        case 2191: "ef_judgement_cross"
        case 2192: "ef_judgement_cross_bottom"
        case 2193: "ef_judgement_cross_cast"
        case 2194: "ef_judgement_cross_cast_bottom"
        case 2195: "ef_judgement_cross_shot"
        case 2196: "ef_rebound_shield"
        case 2197: "ef_rebound_shield_bottom"
        case 2198: "ef_rebound_shield_cast"
        case 2199: "ef_rebound_shield_cast_bottom"
        case 2200: "ef_ultimatesacrifice"
        case 2201: "ef_ultimatesacrifice_bottom"
        case 2202: "ef_ultimatesacrifice_shine"
        case 2203: "ef_unk_2203"
        case 2204: "ef_acidified_zone_fire_cast"
        case 2205: "ef_acidified_zone_fire_cast_bottom"
        case 2206: "ef_acidified_zone_fire"
        case 2207: "ef_acidified_zone_fire_hit"
        case 2208: "ef_acidified_zone_fire_start"
        case 2209: "ef_acidified_zone_fire_start_bottom"
        case 2210: "ef_acidified_zone_fire_loop"
        case 2211: "ef_acidified_zone_fire_loop_bottom"
        case 2212: "ef_acidified_zone_water_cast"
        case 2213: "ef_acidified_zone_water_cast_bottom"
        case 2214: "ef_acidified_zone_water"
        case 2215: "ef_acidified_zone_water_hit"
        case 2216: "ef_acidified_zone_water_start"
        case 2217: "ef_acidified_zone_water_start_bottom"
        case 2218: "ef_acidified_zone_water_loop"
        case 2219: "ef_acidified_zone_water_loop_bottom"
        case 2220: "ef_acidified_zone_wind_cast"
        case 2221: "ef_acidified_zone_wind_cast_bottom"
        case 2222: "ef_acidified_zone_wind"
        case 2223: "ef_acidified_zone_wind_hit"
        case 2224: "ef_acidified_zone_wind_start"
        case 2225: "ef_acidified_zone_wind_start_bottom"
        case 2226: "ef_acidified_zone_wind_loop"
        case 2227: "ef_acidified_zone_wind_loop_bottom"
        case 2228: "ef_acidified_zone_ground_cast"
        case 2229: "ef_acidified_zone_ground_cast_bottom"
        case 2230: "ef_acidified_zone_ground"
        case 2231: "ef_acidified_zone_ground_hit"
        case 2232: "ef_acidified_zone_ground_start"
        case 2233: "ef_acidified_zone_ground_start_bottom"
        case 2234: "ef_acidified_zone_ground_loop"
        case 2235: "ef_acidified_zone_ground_loop_bottom"
        case 2236: "ef_helltree_cast"
        case 2237: "ef_helltree_cast_bottom"
        case 2238: "ef_helltree_dusty"
        case 2239: "ef_helltree_howling"
        case 2240: "ef_research_report_ring"
        case 2241: "ef_research_report"
        case 2242: "ef_research_report_cast"
        case 2243: "ef_research_report_cast_bottom"
        case 2244: "ef_state_lassitude"
        case 2245: "ef_state_swooning"
        case 2246: "ef_state_holyflame"
        case 2247: "ef_wooden_warrior_cast"
        case 2248: "ef_wooden_warrior_cast_bottom"
        case 2249: "ef_wooden_warrior_ring"
        case 2250: "ef_wooden_warrior_attack"
        case 2251: "ef_wooden_warrior_attack_hit"
        case 2252: "ef_wooden_warrior_throwrock"
        case 2253: "ef_wooden_warrior_throwrock_hit"
        case 2254: "ef_wooden_fairy_cast"
        case 2255: "ef_wooden_fairy_ring"
        case 2256: "ef_wooden_fairy_cast_bottom"
        case 2257: "ef_wooden_fairy_dusty"
        case 2258: "ef_serpens_deep_poisoning"
        case 2259: "ef_serpens_deep_poisoning_bottom"
        case 2260: "ef_diluvio_cold_force"
        case 2261: "ef_diluvio_cold_force_bottom"
        case 2262: "ef_ardor_flametechnic"
        case 2263: "ef_ardor_flametechnic_bottom"
        case 2264: "ef_procella_grace_breeze"
        case 2265: "ef_procella_grace_breeze_bottom"
        case 2266: "ef_terremotus_earth_care"
        case 2267: "ef_terremotus_earth_care_bottom"
        case 2268: "ef_state_lightningstrike"
        case 2269: "ef_state_conflagration"
        case 2270: "ef_state_frostbite"
        case 2271: "ef_state_frostbite_finish"
        case 2272: "ef_frostbite_screen"
        case 2273: "ef_state_crystallization"
        case 2274: "ef_state_deadlypoison"
        case 2275: "ef_level4th"
        case 2276: "ef_level4th_sub"
        case 2277: "ef_unk_2277"
        case 2278: "ef_unk_2278"
        case 2279: "ef_third_consecration_bottom"
        case 2280: "ef_servant_sign_bottom"
        case 2281: "ef_unk_2281"
        case 2282: "ef_unk_2282"
        case 2283: "ef_unk_2283"
        case 2284: "ef_unk_2284"
        case 2285: "ef_unk_2285"
        case 2286: "ef_unk_2286"
        case 2287: "ef_unk_2287"
        case 2288: "ef_status_crate_up"
        case 2289: "ef_status_crate_down"
        case 2290: "ef_status_hplus_up"
        case 2291: "ef_status_hplus_down"
        case 2292: "ef_status_mres_up"
        case 2293: "ef_status_mres_down"
        case 2294: "ef_status_patk_up"
        case 2295: "ef_status_patk_down"
        case 2296: "ef_status_res_up"
        case 2297: "ef_status_res_down"
        case 2298: "ef_status_smatk_up"
        case 2299: "ef_status_smatk_down"
        case 2300: "ef_status_patk_smatk_up"
        case 2301: "ef_unk_2301"
        case 2302: "ef_npc_killing_aura"
        case 2303: "ef_npc_killing_aura_end"
        case 2304: "ef_npc_killing_aura_hit"
        case 2305: "ef_npc_curse_of_red_cube"
        case 2306: "ef_npc_curse_of_blue_cube"
        case 2307: "ef_unk_2307"
        case 2308: "ef_npc_cane_of_evil_eye"
        case 2309: "ef_unk_2309"
        case 2310: "ef_unk_2310"
        case 2311: "ef_ui_enchant_intro_yellow"
        case 2312: "ef_ui_enchant_success"
        case 2313: "ef_ui_enchant_fail"
        case 2314: "ef_ui_enchant_intro_blue"
        case 2315: "ef_ui_levelup_success"
        case 2316: "ef_ui_levelup_fail"
        case 2317: "ef_ui_enchant_intro_green"
        case 2318: "ef_ui_reset_success"
        case 2319: "ef_ui_reset_fail"
        case 2320: "ef_toxin_of_mandara_bomb"
        case 2321: "ef_toxin_of_mandara_bomb_bottom"
        case 2322: "ef_toxin_of_mandara_shock"
        case 2323: "ef_needle_stinger"
        case 2324: "ef_needle_stinger_bottom"
        case 2325: "ef_needle_stinger_hit"
        case 2326: "ef_absolute_zephyr"
        case 2327: "ef_absolute_zephyr_bottom"
        case 2328: "ef_absolute_zephyr_hit"
        case 2329: "ef_twister_cutter"
        case 2330: "ef_twister_cutter_hit"
        case 2331: "ef_heilige_pferd"
        case 2332: "ef_heilige_pferd_bottom"
        case 2333: "ef_heilige_pferd_cast"
        case 2334: "ef_goldene_tone"
        case 2335: "ef_glanzen_spies"
        case 2336: "ef_glanzen_spies_hit"
        case 2337: "ef_blazing_and_furious"
        case 2338: "ef_the_one_fighter_rises"
        case 2339: "ef_the_one_fighter_rises_bottom"
        case 2340: "ef_tempering"
        case 2341: "ef_blast_forge"
        case 2342: "ef_blast_forge_hit"
        case 2343: "ef_unk_2343"
        case 2344: "ef_unk_2344"
        case 2345: "ef_unk_2345"
        case 2346: "ef_pok_94"
        case 2347: "ef_pok_95"
        case 2348: "ef_ske_twinkling_galaxy"
        case 2349: "ef_unk_2349"
        case 2350: "ef_ske_star_cannon"
        case 2351: "ef_nw_grenades_dropping"
        case 2352: "ef_ss_fuumashouaku"
        case 2353: "ef_unk_2353"
        case 2354: "ef_nw_mission_bombard"
        case 2355: "ef_unk_2355"
        case 2356: "ef_pok_96"
        case 2357: "ef_pok_97"
        case 2358: "ef_pok_98"
        case 2359: "ef_pok_99"
        case 2360: "ef_pok_100"
        case 2361: "ef_pok_101"
        case 2362: "ef_pok_102"
        case 2363: "ef_pok_103"
        case 2364: "ef_pok_104"
        case 2365: "ef_pok_105"
        case 2366: "ef_hn_jupitel_thunder_storm"
        case 2367: "ef_beginspell_ring_yellow"
        case 2368: "ef_beginspell_swirl"
        case 2369: "ef_beginspell_ring_white"
        case 2370: "ef_unk_2370"
        case 2371: "ef_tetra_vortex_water_sub_2"
        case 2372: "ef_tetra_vortex_earth_sub_2"
        case 2373: "ef_volcano_black"
        case 2374: "ef_change_size"
        case 2375: "ef_unk_2375"
        case 2376: "ef_npc_20th_crystal_s"
        case 2377: "ef_npc_20th_crystal_m"
        case 2378: "ef_npc_20th_crystal_l"
        case 2379: "ef_npc_gate_green_1"
        case 2380: "ef_npc_gate_purple_1"
        case 2381: "ef_npc_gate_red_1"
        case 2382: "ef_20th_firework"
        case 2383: "ef_npc_gate_green_2"
        case 2384: "ef_npc_gate_purple_2"
        case 2385: "ef_npc_gate_red_2"
        case 2386: "ef_npc_gate_green_3"
        case 2387: "ef_npc_gate_purple_3"
        case 2388: "ef_npc_gate_red_3"
        case 2389: "ef_npc_gate_skyblue"
        case 2390: "ef_unk_2390"
        case 2391: "ef_unk_2391"
        case 2392: "ef_unk_2392"
        case 2393: "ef_unk_2393"
        case 2394: "ef_serpent_shadow"
        case 2395: "ef_rune_active_finish"
        case 2396: "ef_runeset_active"
        case 2397: "ef_runeset_upgrade_success"
        case 2398: "ef_runeset_upgrade_fail"
        case 2399: "ef_rune_broken"
        case 2400: "ef_unk_2400"
        case 2401: "ef_alpha_down_anim"
        case 2402: "ef_glow_black"
        case 2403: "ef_new_battle_w_hit_2"
        case 2404: "ef_unk_2404"
        case 2405: "ef_new_pramen_reuse"
        case 2406: "ef_the_w_protection_reuse"
        case 2407: "ef_elemental_buster_fire_reuse"
        case 2408: "ef_destructive_hurricane_bottom_reuse"
        case 2409: "ef_crystal_impact_bottom_reuse"
        case 2410: "ef_new_judex_target_reuse"
        case 2411: "ef_unk_2411"
        case 2412: "ef_unk_2412"
        case 2413: "ef_unk_2413"
        case 2414: "ef_unk_2414"
        case 2415: "ef_unk_2415"
        case 2416: "ef_abc_chasing_line"
        case 2417: "ef_abc_crossimpact_line"
        case 2418: "ef_unk_2418"
        case 2419: "ef_unk_2419"
        case 2420: "ef_violen_hit"
        case 2421: "ef_rune_slot_small"
        case 2422: "ef_rune_slot_big"
        case 2423: "ef_unk_2423"
        case 2424: "ef_c_aura_of_ghost_s"
        case 2425: "ef_wh_wild_walk"
        case 2426: "ef_force_anim_27"
        case 2427: "ef_heal_blue_2"
        case 2428: "ef_atque_poenitentia"
        case 2429: "ef_perm_frost_oblivion"
        case 2430: "ef_c_guide_of_dead_text"
        case 2431: "ef_c_medjed_text"
        case 2432: "ef_unk_2432"
        case 2433: "ef_unk_2433"
        case 2434: "ef_unk_2434"
        case 2435: "ef_unk_2435"
        case 2436: "ef_rg_coin_blue"
        case 2437: "ef_rg_coin_blue_2"
        case 2438: "ef_unk_2438"
        case 2439: "ef_cruel_bite_line"
        case 2440: "ef_unk_2440"
        case 2441: "ef_unk_2441"
        case 2442: "ef_quill_spear_line"
        case 2443: "ef_c_2025rosfesta"
        case 2444: "ef_unk_2444"
        case 2445: "ef_unk_2445"
        case 2446: "ef_unk_2446"
        case 2447: "ef_unk_2447"
        case 2448: "ef_unk_2448"
        case 2449: "ef_unk_2449"
        case 2450: "ef_unk_2450"
        case 2451: "ef_unk_2451"
        case 2452: "ef_unk_2452"
        case 2453: "ef_unk_2453"
        case 2454: "ef_unk_2454"
        case 2455: "ef_unk_2455"
        case 2456: "ef_unk_2456"
        case 2457: "ef_unk_2457"
        case 2458: "ef_s_beelzebub_wing"
        case 2460: "ef_dk_servantweapon"
        case 2461: "ef_dk_chargingpierce"
        case 2462: "ef_ig_cross_rain"
        case 2463: "ef_unk_2463"
        case 2464: "ef_unk_2464"
        case 2465: "ef_unk_2465"
        case 2466: "ef_kr_chop_chop"
        case 2467: "ef_shc_shadow_exceed"
        case 2468: "ef_unk_2468"
        case 2469: "ef_unk_2469"
        case 2470: "ef_unk_2470"
        case 2471: "ef_unk_2471"
        case 2472: "ef_unk_2472"
        case 2473: "ef_unk_2473"
        case 2474: "ef_unk_2474"
        case 2477: "ef_unk_2477"
        case 2478: "ef_unk_2478"
        case 2479: "ef_unk_2479"
        case 2480: "ef_unk_2480"
        case 2481: "ef_unk_2481"
        case 2482: "ef_unk_2482"
        case 2483: "ef_unk_2483"
        default: nil
        }
    }
}
