//
//  Size.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum Size: CaseIterable, CodingKey, Decodable {
    case small
    case medium
    case large

    public var intValue: Int {
        switch self {
        case .small: RA_SZ_SMALL
        case .medium: RA_SZ_MEDIUM
        case .large: RA_SZ_BIG
        }
    }

    public var stringValue: String {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }

    public init?(stringValue: String) {
        if let size = Size.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = size
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let size = Size(stringValue: stringValue) {
            self = size
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Size does not exist.")
            throw DecodingError.valueNotFound(Size.self, context)
        }
    }
}
