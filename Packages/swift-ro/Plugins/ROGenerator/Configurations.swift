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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "common/mmo.hpp",
        type: "e_mode",
        prefix: "MD_",
        exclude: ["MD_NONE"],
        outputType: "MonsterMode",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "common/mmo.hpp",
        type: "e_sex",
        prefix: "SEX_",
        exclude: ["SEX_SERVER"],
        outputType: "Sex",
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/battle.hpp",
        type: "e_battle_check_target",
        prefix: "BCT_",
        outputType: "BattleCheckTarget",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/mob.hpp",
        type: "e_aegis_monstertype",
        prefix: "MONSTER_TYPE_",
        outputType: "MonsterAI",
        outputPrefix: "ai",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/pc.hpp",
        type: "e_card_type",
        prefix: "CARD_",
        exclude: ["MAX_CARD_TYPE"],
        outputType: "CardType",
        settings: [
            .isDecodable: true,
        ]
    ),
    // MARK: - map/skill.hpp
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_nk",
        prefix: "NK_",
        exclude: ["NK_MAX"],
        outputType: "SkillDamageFlag",
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_inf",
        prefix: "INF_",
        suffix: "_SKILL",
        outputType: "SkillInfoFlag",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_inf2",
        prefix: "INF2_",
        exclude: ["INF2_MAX"],
        outputType: "SkillInfoFlag2",
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_require",
        prefix: "SKILL_REQ_",
        outputType: "SkillRequirement",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_nonear_npc",
        prefix: "SKILL_NONEAR_",
        outputType: "SkillNoNearNPC",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_cast_flags",
        prefix: "SKILL_CAST_",
        outputType: "SkillCastFlag",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/skill.hpp",
        type: "e_skill_copyable_option",
        prefix: "SKILL_COPY_",
        outputType: "SkillCopyableOption",
        outputFormat: .hex,
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
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
        settings: [
            .isDecodable: true,
        ]
    ),
    .enum(
        source: "map/status.hpp",
        type: "efst_type",
        exclude: [
            "EFST_MAX",
        ],
        outputType: "OfficialStatusChangeID",
        settings: [
            .isDecodable: true,
        ]
    ),
]

struct Configuration {
    enum OutputFormat {
        case decimal
        case hex
    }

    enum Setting {
        case isDecodable
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
    var settings: [Setting : Bool]

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
        settings: [Setting : Bool] = [:]
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
            settings: settings
        )
    }
}
