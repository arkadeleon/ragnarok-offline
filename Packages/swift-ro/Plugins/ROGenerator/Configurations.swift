//
//  Configuration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/27.
//

let configurations: [Configuration] = [
    .enum(
        path: "map/map.hpp",
        type: "_sp",
        prefix: "SP_",
        outputType: "StatusProperty"
    ),
    .decodable(
        path: "common/mmo.hpp",
        type: "item_types",
        prefix: "IT_",
        excludes: [
            "IT_UNKNOWN",
            "IT_UNKNOWN2",
            "IT_MAX",
        ],
        outputType: "ItemType"
    ),
    .decodable(
        path: "common/mmo.hpp",
        type: "e_mode",
        prefix: "MD_",
        excludes: ["MD_NONE"],
        outputType: "MonsterMode",
        outputFormat: .hex
    ),
    .decodable(
        path: "common/mmo.hpp",
        type: "e_job",
        prefix: "JOB_",
        compatibles: ["JOB_SUPER_NOVICE": ["JOB_SUPERNOVICE"]],
        excludes: [
            "JOB_MAX_BASIC",
            "JOB_MAX",
        ],
        outputType: "Job"
    ),
    .decodable(
        path: "common/mmo.hpp",
        type: "e_sex",
        prefix: "SEX_",
        excludes: ["SEX_SERVER"],
        outputType: "Sex"
    ),
    .decodable(
        path: "map/pc.hpp",
        type: "weapon_type",
        prefix: "W_",
        excludes: [
            "MAX_WEAPON_TYPE",
            "W_DOUBLE_DD",
            "W_DOUBLE_SS",
            "W_DOUBLE_AA",
            "W_DOUBLE_DS",
            "W_DOUBLE_DA",
            "W_DOUBLE_SA",
            "MAX_WEAPON_TYPE_ALL",
        ],
        outputType: "WeaponType"
    ),
    .decodable(
        path: "map/pc.hpp",
        type: "e_ammo_type",
        prefix: "AMMO_",
        excludes: [
            "AMMO_NONE",
            "MAX_AMMO_TYPE",
        ],
        outputType: "AmmoType"
    ),
    .decodable(
        path: "map/pc.hpp",
        type: "e_card_type",
        prefix: "CARD_",
        excludes: ["MAX_CARD_TYPE"],
        outputType: "CardType"
    ),
]

struct Configuration {
    enum OutputFormat {
        case decimal
        case hex
    }

    var path: String
    var type: String
    var prefix: String
    var excludes: [String] = []
    var compatibles: [String : [String]] = [:]
    var outputType: String
    var outputFormat: OutputFormat
    var isDecodable = true

    static func `enum`(
        path: String,
        type: String,
        prefix: String,
        compatibles: [String : [String]] = [:],
        excludes: [String] = [],
        outputType: String,
        outputFormat: OutputFormat = .decimal
    ) -> Configuration {
        Configuration(
            path: path,
            type: type,
            prefix: prefix,
            excludes: excludes,
            compatibles: compatibles,
            outputType: outputType,
            outputFormat: outputFormat,
            isDecodable: false
        )
    }

    static func decodable(
        path: String,
        type: String,
        prefix: String,
        compatibles: [String : [String]] = [:],
        excludes: [String] = [],
        outputType: String,
        outputFormat: OutputFormat = .decimal
    ) -> Configuration {
        Configuration(
            path: path,
            type: type,
            prefix: prefix,
            excludes: excludes,
            compatibles: compatibles,
            outputType: outputType,
            outputFormat: outputFormat,
            isDecodable: true
        )
    }
}
