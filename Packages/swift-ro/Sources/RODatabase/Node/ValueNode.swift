//
//  ValueNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/12.
//

struct ValueNode<Value>: Decodable where Value: CodingValue {
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
