//
//  ScalarNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/12.
//

public struct ScalarNode<Value> where Value: NodeValue {
    public let value: Value

    public init?(intValue: Int) {
        if let value = Value.allCases.first(where: { $0.intValue == intValue }) {
            self.value = value
        } else {
            return nil
        }
    }

    public init?(stringValue: String) {
        if let value = Value.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(stringValue) == .orderedSame }) {
            self.value = value
        } else {
            return nil
        }
    }
}

extension ScalarNode: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let node = Self.init(stringValue: stringValue) {
            self = node
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(Self.self) does not exist.")
            throw DecodingError.valueNotFound(Self.self, context)
        }
    }
}
