//
//  Gender.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum Gender: CaseIterable, CodingKey, Decodable {
    case female
    case male
    case both

    public var intValue: Int {
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

    public init?(stringValue: String) {
        if let gender = Gender.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = gender
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let gender = Gender(stringValue: stringValue) {
            self = gender
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Gender does not exist.")
            throw DecodingError.valueNotFound(Gender.self, context)
        }
    }
}
