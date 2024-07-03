//
//  CaseIterable+RawValue.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/3.
//

extension RawRepresentable where RawValue == Int, Self: CaseIterable {
    public init?(rawValue: Int) {
        if let value = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = value
        } else {
            return nil
        }
    }
}

extension CodingKey where Self: CaseIterable, Self: RawRepresentable, Self.RawValue == Int {
    public var intValue: Int? {
        rawValue
    }

    public init?(intValue: Int) {
        self.init(rawValue: intValue)
    }

    public init?(stringValue: String) {
        if let value = Self.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self = value
        } else {
            return nil
        }
    }
}

extension Decodable where Self: CaseIterable, Self: RawRepresentable, Self.RawValue == Int, Self: CodingKey {
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
