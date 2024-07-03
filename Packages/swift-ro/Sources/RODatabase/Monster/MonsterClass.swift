//
//  MonsterClass.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum MonsterClass: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case normal
    case boss
    case guardian
    case battlefield
    case event

    public var rawValue: Int {
        switch self {
        case .normal: RA_CLASS_NORMAL
        case .boss: RA_CLASS_BOSS
        case .guardian: RA_CLASS_GUARDIAN
        case .battlefield: RA_CLASS_BATTLEFIELD
        case .event: RA_CLASS_EVENT
        }
    }

    public var stringValue: String {
        switch self {
        case .normal: "Normal"
        case .boss: "Boss"
        case .guardian: "Guardian"
        case .battlefield: "Battlefield"
        case .event: "Event"
        }
    }
}
