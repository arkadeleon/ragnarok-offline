//
//  BinaryEncoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum BinaryEncodingError: Error {
    case invalidValue(any Sendable)
}

public protocol BinaryEncodable {
    func encode(to encoder: BinaryEncoder) throws
}

public protocol BinaryEncodableWithConfiguration {
    associatedtype BinaryEncodingConfiguration

    func encode(to encoder: BinaryEncoder, configuration: BinaryEncodingConfiguration) throws
}

public class BinaryEncoder {
    public private(set) var data: Data

    public init() {
        data = Data()
    }

    public func encode<T>(_ value: T) throws where T: FixedWidthInteger {
        let bytes = withUnsafeBytes(of: value, [UInt8].init)
        self.data.append(contentsOf: bytes)
    }

    public func encode(_ value: [UInt8]) throws {
        let data = Data(value)
        self.data.append(data)
    }

    public func encode(_ value: String, length: Int) throws {
        guard var data = value.data(using: .utf8) else {
            throw BinaryEncodingError.invalidValue(value)
        }
        guard data.count <= length else {
            throw BinaryEncodingError.invalidValue(value)
        }
        data.append(contentsOf: [UInt8](repeating: 0, count: length - data.count))
        self.data.append(data)
    }

    public func encode<T>(_ value: T) throws where T: BinaryEncodable {
        let encoder = BinaryEncoder()
        try value.encode(to: encoder)
        let data = encoder.data
        self.data.append(data)
    }
    
    public func encode<T>(_ value: T, configuration: T.BinaryEncodingConfiguration) throws where T: BinaryEncodableWithConfiguration {
        let encoder = BinaryEncoder()
        try value.encode(to: encoder, configuration: configuration)
        let data = encoder.data
        self.data.append(data)
    }

    public func encode<T>(_ value: T, length: Int) throws where T: BinaryEncodable & Sendable {
        let encoder = BinaryEncoder()
        try value.encode(to: encoder)
        var data = encoder.data
        guard data.count <= length else {
            throw BinaryEncodingError.invalidValue(value)
        }
        data.append(contentsOf: [UInt8](repeating: 0, count: length - data.count))
        self.data.append(data)
    }
}
