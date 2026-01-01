//
//  ConstantConversion.swift
//  RagnarokOfflineGenerator
//
//  Created by Leon Li on 2024/9/27.
//

let allConstantConversions: [ConstantConversion] = [
    // MARK: - common/mmo.hpp
    .cEnum(
        source: "common/mmo.hpp",
        type: "item_types",
        prefix: "IT_",
        exclude: [
            "IT_UNKNOWN",
            "IT_UNKNOWN2",
            "IT_MAX",
        ],
        outputType: "ItemType",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "common/mmo.hpp",
        type: "e_mode",
        prefix: "MD_",
        exclude: [
            "MD_NONE",
        ],
        outputType: "MonsterMode",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .optionSet(
        source: "common/mmo.hpp",
        type: "equip_pos",
        prefix: "EQP_",
        insert: [
            ("EQP_BOTH_HAND", 0x2 | 0x20)
        ],
        exclude: [
            "EQP_SHADOW_ACC_RL",
        ],
        replace: [
            "EQP_HAND_R": "EQP_RIGHT_HAND",
            "EQP_HAND_L": "EQP_LEFT_HAND",
            "EQP_ACC_R": "EQP_RIGHT_ACCESSORY",
            "EQP_ACC_L": "EQP_LEFT_ACCESSORY",
            "EQP_SHADOW_ACC_R": "EQP_SHADOW_RIGHT_ACCESSORY",
            "EQP_SHADOW_ACC_L": "EQP_SHADOW_LEFT_ACCESSORY",
            "EQP_ACC_RL": "EQP_BOTH_ACCESSORY",
        ],
        outputType: "EquipPositions",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "common/mmo.hpp",
        type: "e_guild_skill",
        exclude: [
            "GD_SKILLBASE",
            "GD_MAX",
        ],
        outputType: "GuildSkillID",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "common/mmo.hpp",
        type: "e_job",
        prefix: "JOB_",
        exclude: [
            "JOB_MAX_BASIC",
            "JOB_SECOND_JOB_START",
            "JOB_SECOND_JOB_END",
            "JOB_MAX",
        ],
        compatible: [
            "JOB_SUPER_NOVICE": ["JOB_SUPERNOVICE"],
        ],
        outputType: "JobID",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "common/mmo.hpp",
        type: "e_sex",
        prefix: "SEX_",
        exclude: [
            "SEX_SERVER",
        ],
        outputType: "Gender",
        extensions: [.decodable]
    ),
    // MARK: - map/battle.hpp
    .cEnum(
        source: "map/battle.hpp",
        type: "e_battle_flag",
        prefix: "BF_",
        exclude: [
            "BF_WEAPONMASK",
            "BF_RANGEMASK",
            "BF_SKILLMASK",
        ],
        outputType: "BattleFlag",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/battle.hpp",
        type: "e_battle_check_target",
        prefix: "BCT_",
        outputType: "BattleCheckTarget",
        outputFormat: .hex,
        extensions: [.rawRepresentable, .decodable]
    ),
    // MARK: - map/clif.hpp
    .cEnum(
        source: "map/clif.hpp",
        type: "e_damage_type",
        prefix: "DMG_",
        outputType: "DamageType",
        extensions: [.decodable]
    ),
    // MARK: - map/itemdb.hpp
    .optionSet(
        source: "map/itemdb.hpp",
        type: "e_item_job",
        prefix: "ITEMJ_",
        exclude: [
            "ITEMJ_NONE",
            "ITEMJ_MAX",
        ],
        outputType: "ItemClasses",
        extensions: [.decodable]
    ),
    // MARK: - map/map.hpp
    .cEnum(
        source: "map/map.hpp",
        type: "e_mapid",
        prefix: "MAPID_",
        exclude: [
            "MAPID_ALL",
        ],
        compatible: [
            "MAPID_STAR_GLADIATOR": ["MAPID_STARGLADIATOR"],
            "MAPID_DEATH_KNIGHT": ["MAPID_DEATHKNIGHT"],
            "MAPID_SOUL_LINKER": ["MAPID_SOULLINKER"],
            "MAPID_DARK_COLLECTOR": ["MAPID_DARKCOLLECTOR"],
            "MAPID_SUPER_NOVICE": ["MAPID_SUPERNOVICE"],
        ],
        outputType: "EAJobID",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    // TODO: bl_type
    // TODO: npc_subtype
    .cEnum(
        source: "map/map.hpp",
        type: "e_race",
        prefix: "RC_",
        exclude: [
            "RC_NONE_",
            "RC_ALL",
            "RC_MAX",
        ],
        outputType: "Race",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/map.hpp",
        type: "e_race2",
        prefix: "RC2_",
        exclude: [
            "RC2_NONE",
            "RC2_MAX",
        ],
        outputType: "Race2",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/map.hpp",
        type: "e_element",
        prefix: "ELE_",
        exclude: [
            "ELE_NONE",
            "ELE_ALL",
            "ELE_MAX",
        ],
        outputType: "Element",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/map.hpp",
        type: "_sp",
        prefix: "SP_",
        exclude: [
            "SP_0a",
            "SP_1a",
            "SP_1b",
            "SP_1c",
            "SP_1d",
            "SP_1e",
            "SP_1f",
            "SP_26",
            "SP_27",
            "SP_28",
            "SP_36",
        ],
        outputType: "StatusProperty"
    ),
    // MARK: - map/mob.hpp
    .cEnum(
        source: "map/mob.hpp",
        type: "e_size",
        prefix: "SZ_",
        exclude: [
            "SZ_ALL",
            "SZ_MAX",
        ],
        replace: [
            "SZ_BIG": "SZ_LARGE",
        ],
        outputType: "Size",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/mob.hpp",
        type: "e_aegis_monstertype",
        prefix: "MONSTER_TYPE_",
        outputType: "MonsterAI",
        outputFormat: .hex,
        extensions: [.rawRepresentable, .decodable]
    ),
    .cEnum(
        source: "map/mob.hpp",
        type: "e_aegis_monsterclass",
        prefix: "CLASS_",
        exclude: [
            "CLASS_NONE",
            "CLASS_ALL",
            "CLASS_MAX",
        ],
        outputType: "MonsterClass",
        extensions: [.decodable]
    ),
    // MARK: - map/path.hpp
    .cEnum(
        source: "map/path.hpp",
        type: "directions",
        prefix: "DIR_",
        exclude: [
            "DIR_CENTER",
            "DIR_MAX",
        ],
        outputType: "Direction"
    ),
    // MARK: - map/pc.hpp
    .cEnum(
        source: "map/pc.hpp",
        type: "e_params",
        prefix: "PARAM_",
        exclude: [
            "PARAM_MAX",
        ],
        outputType: "Parameter",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/pc.hpp",
        type: "weapon_type",
        prefix: "W_",
        exclude: [
            "MAX_WEAPON_TYPE",
            "W_DOUBLE_DD",
            "W_DOUBLE_SS",
            "W_DOUBLE_AA",
            "W_DOUBLE_DS",
            "W_DOUBLE_DA",
            "W_DOUBLE_SA",
            "MAX_WEAPON_TYPE_ALL",
        ],
        outputType: "WeaponType",
        outputPrefix: "w_",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/pc.hpp",
        type: "e_ammo_type",
        prefix: "AMMO_",
        exclude: [
            "AMMO_NONE",
            "MAX_AMMO_TYPE",
        ],
        outputType: "AmmoType",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/pc.hpp",
        type: "e_card_type",
        prefix: "CARD_",
        exclude: [
            "MAX_CARD_TYPE",
        ],
        outputType: "CardType",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/pc.hpp",
        type: "e_mado_type",
        prefix: "MADO_",
        exclude: [
            "MADO_MAX",
        ],
        outputType: "MadoType"
    ),
    // MARK: - map/skill.hpp
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_nk",
        prefix: "NK_",
        exclude: [
            "NK_MAX",
        ],
        outputType: "SkillDamageFlag",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_inf",
        prefix: "INF_",
        suffix: "_SKILL",
        outputType: "SkillInfoFlag",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_inf2",
        prefix: "INF2_",
        exclude: [
            "INF2_MAX",
        ],
        outputType: "SkillInfoFlag2",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_require",
        prefix: "SKILL_REQ_",
        outputType: "SkillRequirement",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_nonear_npc",
        prefix: "SKILL_NONEAR_",
        outputType: "SkillNoNearNPC",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_cast_flags",
        prefix: "SKILL_CAST_",
        outputType: "SkillCastFlag",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_copyable_option",
        prefix: "SKILL_COPY_",
        outputType: "SkillCopyableOption",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_unit_flag",
        prefix: "UF_",
        exclude: [
            "UF_NONE",
            "UF_MAX",
        ],
        outputType: "SkillUnitFlag",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_require_state",
        prefix: "ST_",
        outputType: "SkillStateRequirement",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill",
        outputType: "SkillID",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/skill.hpp",
        type: "e_skill_unit_id",
        prefix: "UNT_",
        exclude: [
            "UNT_MAX",
        ],
        outputType: "SkillUnitID",
        extensions: [.rawRepresentable, .decodable]
    ),
    // MARK: - map/status.hpp
    .cEnum(
        source: "map/status.hpp",
        type: "sc_type",
        prefix: "SC_",
        exclude: [
            "SC_NONE",
            "SC_COMMON_MIN",
            "SC_COMMON_MAX",
            "SC_MAX",
        ],
        outputType: "StatusChangeID",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "efst_type",
        exclude: [
            "EFST_MAX",
        ],
        outputType: "OfficialStatusChangeID",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_sc_opt1",
        prefix: "OPT1_",
        exclude: [
            "OPT1_MAX",
        ],
        outputType: "StatusChangeOption1",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_sc_opt2",
        prefix: "OPT2_",
        exclude: [
            "OPT2_MAX",
        ],
        outputType: "StatusChangeOption2",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_sc_opt3",
        prefix: "OPT3_",
        exclude: [
            "OPT3_MAX",
        ],
        outputType: "StatusChangeOption3",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_option",
        prefix: "OPTION_",
        exclude: [
            "OPTION_MAX",
        ],
        outputType: "StatusChangeOption",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_scs_flag",
        prefix: "SCS_",
        exclude: [
            "SCS_MAX",
        ],
        outputType: "StatusChangeStateFlag",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_scb_flag",
        prefix: "SCB_",
        exclude: [
            "SCB_MAX",
        ],
        outputType: "StatusChangeBlockFlag",
        extensions: [.decodable]
    ),
    .cEnum(
        source: "map/status.hpp",
        type: "e_status_change_flag",
        prefix: "SCF_",
        exclude: [
            "SCF_MAX",
        ],
        outputType: "StatusChangeFlag",
        extensions: [.decodable]
    ),
]

struct ConstantConversion {
    enum Kind {
        case cEnum
        case optionSet
    }

    enum OutputFormat {
        case decimal
        case hex
    }

    enum Extension {
        case rawRepresentable
        case decodable
    }

    var kind: Kind
    var source: String
    var type: String
    var prefix: String
    var suffix: String
    var insert: [(String, Int)]
    var exclude: [String]
    var replace: [String : String]
    var compatible: [String : [String]]
    var outputType: String
    var outputPrefix: String?
    var outputFormat: OutputFormat
    var extensions: [Extension]

    static func cEnum(
        source: String,
        type: String,
        prefix: String = "",
        suffix: String = "",
        insert: [(String, Int)] = [],
        exclude: [String] = [],
        replace: [String : String] = [:],
        compatible: [String : [String]] = [:],
        outputType: String,
        outputPrefix: String? = nil,
        outputFormat: OutputFormat = .decimal,
        extensions: [Extension] = []
    ) -> ConstantConversion {
        ConstantConversion(
            kind: .cEnum,
            source: source,
            type: type,
            prefix: prefix,
            suffix: suffix,
            insert: insert,
            exclude: exclude,
            replace: replace,
            compatible: compatible,
            outputType: outputType,
            outputPrefix: outputPrefix,
            outputFormat: outputFormat,
            extensions: extensions
        )
    }

    static func optionSet(
        source: String,
        type: String,
        prefix: String = "",
        suffix: String = "",
        insert: [(String, Int)] = [],
        exclude: [String] = [],
        replace: [String : String] = [:],
        compatible: [String : [String]] = [:],
        outputType: String,
        outputPrefix: String? = nil,
        extensions: [Extension] = []
    ) -> ConstantConversion {
        ConstantConversion(
            kind: .optionSet,
            source: source,
            type: type,
            prefix: prefix,
            suffix: suffix,
            insert: insert,
            exclude: exclude,
            replace: replace,
            compatible: compatible,
            outputType: outputType,
            outputPrefix: outputPrefix,
            outputFormat: .hex,
            extensions: extensions
        )
    }
}
