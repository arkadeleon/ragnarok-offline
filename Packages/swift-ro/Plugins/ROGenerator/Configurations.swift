//
//  Configuration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/27.
//

let configurations: [Configuration] = [
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
        outputType: "Job",
        outputStringValues: [
            "JOB_SUPER_NOVICE": ["JOB_SUPER_NOVICE", "JOB_SUPERNOVICE"],
        ],
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
    .enum(
        source: "map/map.hpp",
        type: "e_mapid",
        prefix: "MAPID_",
        exclude: ["MAPID_ALL"],
        outputType: "EAJob",
        outputFormat: .hex,
        outputStringValues: [
            "MAPID_SUPER_NOVICE": ["MAPID_SUPER_NOVICE", "MAPID_SUPERNOVICE"]
        ],
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
    var exclude: [String]
    var outputType: String
    var outputPrefix: String?
    var outputFormat: OutputFormat
    var outputStringValues: [String : [String]]
    var settings: [Setting : Bool]

    static func `enum`(
        source: String,
        type: String,
        prefix: String,
        exclude: [String] = [],
        outputType: String,
        outputPrefix: String? = nil,
        outputFormat: OutputFormat = .decimal,
        outputStringValues: [String : [String]] = [:],
        settings: [Setting : Bool] = [:]
    ) -> Configuration {
        Configuration(
            source: source,
            kind: "enum",
            type: type,
            prefix: prefix,
            exclude: exclude,
            outputType: outputType,
            outputPrefix: outputPrefix,
            outputFormat: outputFormat,
            outputStringValues: outputStringValues,
            settings: settings
        )
    }
}
