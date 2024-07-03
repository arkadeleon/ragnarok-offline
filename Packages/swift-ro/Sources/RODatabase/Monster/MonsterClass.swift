//
//  MonsterClass.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum MonsterClass: CaseIterable, CodingKey, Decodable {
    case normal
    case boss
    case guardian
    case battlefield
    case event

    public var intValue: Int {
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

    public init?(stringValue: String) {
        if let monsterClass = MonsterClass.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = monsterClass
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let monsterClass = MonsterClass(stringValue: stringValue) {
            self = monsterClass
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Monster class does not exist.")
            throw DecodingError.valueNotFound(MonsterClass.self, context)
        }
    }
}
