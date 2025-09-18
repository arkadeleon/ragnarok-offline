//
//  ItemJobs.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/1/10.
//

import Constants

struct ItemJobs: Decodable {
    static let all: Set<EAJobID> = [
        .acolyte,
        .alchemist,
        .archer,
        .assassin,
        .barddancer,
        .blacksmith,
        .crusader,
        .gunslinger,
        .hunter,
        .kagerouoboro,
        .knight,
        .mage,
        .merchant,
        .monk,
        .ninja,
        .novice,
        .priest,
        .rebellion,
        .rogue,
        .sage,
        .soul_linker,
        .star_gladiator,
        .summoner,
        .super_novice,
        .swordman,
        .taekwon,
        .thief,
        .wizard,
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
