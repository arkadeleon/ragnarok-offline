//
//  SkillCopyableOption.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/4.
//

import rAthenaCommon

public enum SkillCopyableOption: Option {
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
}
