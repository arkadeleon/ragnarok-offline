//
//  SkillCopyableOption.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillCopyableOption: CaseIterable, CodingKey, Decodable {
    case plagiarism
    case reproduce

    public var intValue: Int {
        switch self {
        case .plagiarism: 0x1
        case .reproduce: 0x2
        }
    }

    public var stringValue: String {
        switch self {
        case .plagiarism: "Plagiarism"
        case .reproduce: "Reproduce"
        }
    }

    public init?(stringValue: String) {
        if let skillCopyableOption = SkillCopyableOption.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = skillCopyableOption
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let skillCopyableOption = SkillCopyableOption(stringValue: stringValue) {
            self = skillCopyableOption
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Skill copyable option does not exist.")
            throw DecodingError.valueNotFound(SkillCopyableOption.self, context)
        }
    }
}
