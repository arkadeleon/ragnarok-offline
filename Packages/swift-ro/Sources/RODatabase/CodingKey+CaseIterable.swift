//
//  CodingKey+CaseIterable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/3.
//

extension CodingKey where Self: CaseIterable {
    public init?(intValue: Int) {
        if let value = Self.allCases.first(where: { $0.intValue == intValue }) {
            self = value
        } else {
            return nil
        }
    }

    public init?(stringValue: String) {
        if let value = Self.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = value
        } else {
            return nil
        }
    }
}

extension Decodable where Self: CodingKey {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Self.init(stringValue: stringValue) {
            self = value
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(Self.self) does not exist.")
            throw DecodingError.valueNotFound(Self.self, context)
        }
    }
}
