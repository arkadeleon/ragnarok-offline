//
//  Bytes.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/14.
//

import Foundation

public struct Bytes: Encodable, DecodableWithConfiguration {
    public struct DecodingConfiguration: ExpressibleByIntegerLiteral {
        public let count: Int

        public init(count: Int) {
            self.count = count
        }

        public init(integerLiteral value: Int) {
            count = value
        }
    }

    public let bytes: [UInt8]

    public init(repeating repeatedValue: UInt8, count: Int) {
        bytes = Array(repeating: repeatedValue, count: count)
    }

    public init?(string: String, encoding: String.Encoding, count: Int) {
        guard let data = string.data(using: encoding) else {
            return nil
        }

        if data.count >= count {
            bytes = [UInt8](data[0..<count])
        } else {
            bytes = [UInt8](data) + [UInt8](repeating: 0, count: count - data.count)
        }
    }

    public init(from decoder: any Decoder, configuration: DecodingConfiguration) throws {
        var container = try decoder.unkeyedContainer()

        var bytes: [UInt8] = []
        for _ in 0..<configuration.count {
            let byte = try container.decode(UInt8.self)
            bytes.append(byte)
        }
        self.bytes = bytes
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        for byte in bytes {
            try container.encode(byte)
        }
    }
}

extension Bytes {
    public func string(using encoding: String.Encoding) -> String? {
        String(bytes: bytes.prefix(while: { $0 != 0 }) , encoding: encoding)
    }
}
