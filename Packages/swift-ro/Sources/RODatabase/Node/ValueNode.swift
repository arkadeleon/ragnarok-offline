//
//  ValueNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/12.
//

public protocol ValueNode: Sendable {
    var intValue: Int { get }

    var stringValue: String { get }

    init?(intValue: Int)

    init?(stringValue: String)
}

extension ValueNode where Self: RawRepresentable, Self.RawValue == Int {
    public var intValue: Int {
        rawValue
    }
}

extension ValueNode where Self: CaseIterable {
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

struct DecodableValueNode<Value>: Decodable where Value: ValueNode {
    let value: Value

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Value.init(stringValue: stringValue) {
            self.value = value
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(Self.self) does not exist.")
            throw DecodingError.valueNotFound(Self.self, context)
        }
    }
}
