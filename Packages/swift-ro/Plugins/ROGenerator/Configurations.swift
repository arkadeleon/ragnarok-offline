//
//  Configuration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/27.
//

let configurations: [Configuration] = [
    // MARK: - common/mmo.hpp
    .enum(
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
    .enum(
        source: "common/mmo.hpp",
        type: "e_mode",
        prefix: "MD_",
        exclude: ["MD_NONE"],
        outputType: "MonsterMode",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
        source: "common/mmo.hpp",
        type: "e_job",
        prefix: "JOB_",
        exclude: [
            "JOB_MAX_BASIC",
            "JOB_MAX",
        ],
        compatible: [
            "JOB_SUPER_NOVICE": ["JOB_SUPERNOVICE"],
        ],
        outputType: "JobID",
        extensions: [.decodable]
    ),
    .enum(
        source: "common/mmo.hpp",
        type: "e_sex",
        prefix: "SEX_",
        exclude: ["SEX_SERVER"],
        outputType: "Sex",
        extensions: [.decodable]
    ),
    // MARK: - map/battle.hpp
    .enum(
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
    .enum(
        source: "map/battle.hpp",
        type: "e_battle_check_target",
        prefix: "BCT_",
        outputType: "BattleCheckTarget",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    // MARK: - map/map.hpp
    .enum(
        source: "map/map.hpp",
        type: "e_mapid",
        prefix: "MAPID_",
        exclude: ["MAPID_ALL"],
        compatible: [
            "MAPID_SUPER_NOVICE": ["MAPID_SUPERNOVICE"],
        ],
        outputType: "EAJobID",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    // TODO: bl_type
    // TODO: npc_subtype
    .enum(
        source: "map/map.hpp",
        type: "e_race",
        prefix: "RC_",
        exclude: [
            "RC_NONE_",
            "RC_PLAYER_HUMAN",
            "RC_PLAYER_DORAM",
            "RC_ALL",
            "RC_MAX",
        ],
        outputType: "Race",
        extensions: [.decodable]
    ),
    .enum(
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
    .enum(
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
    .enum(
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
    .enum(
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
    .enum(
        source: "map/mob.hpp",
        type: "e_aegis_monstertype",
        prefix: "MONSTER_TYPE_",
        outputType: "MonsterAI",
        outputPrefix: "ai",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
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
    // MARK: - map/pc.hpp
    .enum(
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
    .enum(
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
    .enum(
        source: "map/pc.hpp",
        type: "e_card_type",
        prefix: "CARD_",
        exclude: ["MAX_CARD_TYPE"],
        outputType: "CardType",
        extensions: [.decodable]
    ),
    // MARK: - map/skill.hpp
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_nk",
        prefix: "NK_",
        exclude: ["NK_MAX"],
        outputType: "SkillDamageFlag",
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_inf",
        prefix: "INF_",
        suffix: "_SKILL",
        outputType: "SkillInfoFlag",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_inf2",
        prefix: "INF2_",
        exclude: ["INF2_MAX"],
        outputType: "SkillInfoFlag2",
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_require",
        prefix: "SKILL_REQ_",
        outputType: "SkillRequirement",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_nonear_npc",
        prefix: "SKILL_NONEAR_",
        outputType: "SkillNoNearNPC",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_cast_flags",
        prefix: "SKILL_CAST_",
        outputType: "SkillCastFlag",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_copyable_option",
        prefix: "SKILL_COPY_",
        outputType: "SkillCopyableOption",
        outputFormat: .hex,
        extensions: [.decodable]
    ),
    .enum(
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
    // MARK: - map/status.hpp
    .enum(
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
    .enum(
        source: "map/status.hpp",
        type: "efst_type",
        exclude: [
            "EFST_MAX",
        ],
        outputType: "OfficialStatusChangeID",
        extensions: [.decodable]
    ),
    .enum(
        source: "map/status.hpp",
        type: "e_sc_opt1",
        prefix: "OPT1_",
        exclude: [
            "OPT1_MAX",
        ],
        outputType: "StatusChangeOption1",
        extensions: [.decodable]
    ),
    .enum(
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
    .enum(
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
    .enum(
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
    .enum(
        source: "map/status.hpp",
        type: "e_scs_flag",
        prefix: "SCS_",
        exclude: [
            "SCS_MAX",
        ],
        outputType: "StatusChangeStateFlag",
        extensions: [.decodable]
    ),
    .enum(
        source: "map/status.hpp",
        type: "e_scb_flag",
        prefix: "SCB_",
        exclude: [
            "SCB_MAX",
        ],
        outputType: "StatusChangeBlockFlag",
        extensions: [.decodable]
    ),
    .enum(
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

struct Configuration {
    enum OutputFormat {
        case decimal
        case hex
    }

    enum Extension {
        case decodable
    }

    var source: String
    var kind: String
    var type: String
    var prefix: String
    var suffix: String
    var exclude: [String]
    var replace: [String : String]
    var compatible: [String : [String]]
    var outputType: String
    var outputPrefix: String?
    var outputFormat: OutputFormat
    var extensions: [Extension]

    static func `enum`(
        source: String,
        type: String,
        prefix: String = "",
        suffix: String = "",
        exclude: [String] = [],
        replace: [String : String] = [:],
        compatible: [String : [String]] = [:],
        outputType: String,
        outputPrefix: String? = nil,
        outputFormat: OutputFormat = .decimal,
        extensions: [Extension] = []
    ) -> Configuration {
        Configuration(
            source: source,
            kind: "enum",
            type: type,
            prefix: prefix,
            suffix: suffix,
            exclude: exclude,
            replace: replace,
            compatible: compatible,
            outputType: outputType,
            outputPrefix: outputPrefix,
            outputFormat: outputFormat,
            extensions: extensions
        )
    }
}
