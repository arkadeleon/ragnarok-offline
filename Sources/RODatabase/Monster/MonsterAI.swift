//
//  MonsterAI.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum MonsterAI: String, CaseIterable, CodingKey, Decodable {
    case ai01 = "01"
    case ai02 = "02"
    case ai03 = "03"
    case ai04 = "04"
    case ai05 = "05"
    case ai06 = "06"
    case ai07 = "07"
    case ai08 = "08"
    case ai09 = "09"
    case ai10 = "10"
    case ai11 = "11"
    case ai12 = "12"
    case ai13 = "13"
    case ai17 = "17"
    case ai19 = "19"
    case ai20 = "20"
    case ai21 = "21"
    case ai24 = "24"
    case ai25 = "25"
    case ai26 = "26"
    case ai27 = "27"
}

extension MonsterAI: Identifiable {
    public var id: Int {
        switch self {
        case .ai01: RA_MONSTER_TYPE_01
        case .ai02: RA_MONSTER_TYPE_02
        case .ai03: RA_MONSTER_TYPE_03
        case .ai04: RA_MONSTER_TYPE_04
        case .ai05: RA_MONSTER_TYPE_05
        case .ai06: RA_MONSTER_TYPE_06
        case .ai07: RA_MONSTER_TYPE_07
        case .ai08: RA_MONSTER_TYPE_08
        case .ai09: RA_MONSTER_TYPE_09
        case .ai10: RA_MONSTER_TYPE_10
        case .ai11: RA_MONSTER_TYPE_11
        case .ai12: RA_MONSTER_TYPE_12
        case .ai13: RA_MONSTER_TYPE_13
        case .ai17: RA_MONSTER_TYPE_17
        case .ai19: RA_MONSTER_TYPE_19
        case .ai20: RA_MONSTER_TYPE_20
        case .ai21: RA_MONSTER_TYPE_21
        case .ai24: RA_MONSTER_TYPE_24
        case .ai25: RA_MONSTER_TYPE_25
        case .ai26: RA_MONSTER_TYPE_26
        case .ai27: RA_MONSTER_TYPE_27
        }
    }
}

extension MonsterAI: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
