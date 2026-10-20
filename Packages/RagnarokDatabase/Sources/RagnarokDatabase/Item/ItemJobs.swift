//
//  ItemJobs.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/1/10.
//

import RagnarokConstants

struct ItemJobs: Decodable {
    static let all: Set<EAJobID> = [
        .novice,
        .swordman,
        .mage,
        .archer,
        .acolyte,
        .merchant,
        .thief,
        .taekwon,
        .gunslinger,
        .ninja,
        .summoner,
        .super_novice,
        .knight,
        .wizard,
        .hunter,
        .priest,
        .blacksmith,
        .assassin,
        .star_gladiator,
        .rebellion,
        .kagerouoboro,
        .spirit_handler,
        .crusader,
        .sage,
        .barddancer,
        .monk,
        .alchemist,
        .rogue,
        .soul_linker,
    ]

    var jobs: Set<EAJobID> = []

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String : Bool].self)

        if dictionary.keys.contains("All") {
            jobs = ItemJobs.all
        }

        let trueKeys = dictionary.compactMap {
            $0.value ? $0.key : nil
        }
        let falseKeys = dictionary.compactMap {
            !$0.value ? $0.key : nil
        }

        for trueKey in trueKeys {
            if let job = EAJobID(stringValue: trueKey) {
                jobs.insert(job)
            }
        }
        for falseKey in falseKeys {
            if let job = EAJobID(stringValue: falseKey) {
                jobs.remove(job)
            }
        }
    }
}
