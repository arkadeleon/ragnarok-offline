//
//  Gender.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum Gender: String, CaseIterable, CodingKey, Decodable {
    case female = "Female"
    case male = "Male"
    case both = "Both"
}

extension Gender: Identifiable {
    public var id: Int {
        switch self {
        case .female: RA_SEX_FEMALE
        case .male: RA_SEX_MALE
        case .both: RA_SEX_BOTH
        }
    }
}

extension Gender: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
