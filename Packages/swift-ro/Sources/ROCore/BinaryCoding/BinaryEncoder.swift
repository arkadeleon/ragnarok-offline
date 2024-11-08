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
    let stream: any Stream

    public init(stream: any Stream) {
        self.stream = stream
    }

    public func encode<T>(_ value: T) throws where T: FixedWidthInteger {
        let count = MemoryLayout<T>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode<T>(_ value: T) throws where T: FloatingPoint {
        let count = MemoryLayout<T>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode<T>(_ value: T) throws where T: BinaryEncodable {
        let encoder = BinaryEncoder(stream: stream)
        try value.encode(to: encoder)
    }

    public func encode<T>(_ value: T, configuration: T.BinaryEncodingConfiguration) throws where T: BinaryEncodableWithConfiguration {
        let encoder = BinaryEncoder(stream: stream)
        try value.encode(to: encoder, configuration: configuration)
    }

    public func encodeBytes(_ bytes: [UInt8]) throws {
        _ = try stream.write(bytes, count: bytes.count)
    }

    public func encodeString(_ string: String, count: Int, encoding: String.Encoding = .ascii) throws {
        guard var data = string.data(using: encoding) else {
            throw BinaryEncodingError.invalidValue(string)
        }
        guard data.count <= count else {
            throw BinaryEncodingError.invalidValue(string)
        }
        data.append(contentsOf: [UInt8](repeating: 0, count: count - data.count))
        try data.withUnsafeBytes { pointer in
            _ = try stream.write(pointer.baseAddress!, count: pointer.count)
        }
    }
}
