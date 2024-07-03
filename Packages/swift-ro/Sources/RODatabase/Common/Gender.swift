//
//  Gender.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum Gender: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case female
    case male
    case both

    public var rawValue: Int {
        switch self {
        case .female: RA_SEX_FEMALE
        case .male: RA_SEX_MALE
        case .both: RA_SEX_BOTH
        }
    }

    public var stringValue: String {
        switch self {
        case .female: "Female"
        case .male: "Male"
        case .both: "Both"
        }
    }
}
