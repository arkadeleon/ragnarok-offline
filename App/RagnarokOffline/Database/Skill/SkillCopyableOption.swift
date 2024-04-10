//
//  SkillCopyableOption.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillCopyableOption: String, CaseIterable, CodingKey, Decodable {
    case plagiarism = "Plagiarism"
    case reproduce = "Reproduce"
}

extension SkillCopyableOption: Identifiable {
    public var id: Int {
        switch self {
        case .plagiarism: 0x1
        case .reproduce: 0x2
        }
    }
}

extension SkillCopyableOption: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
