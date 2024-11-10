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

public class BinaryEncoder {
    let stream: any Stream

    public init(stream: any Stream) {
        self.stream = stream
    }

    public func encode(_ value: Int8) throws {
        let count = MemoryLayout<Int8>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: Int16) throws {
        let count = MemoryLayout<Int16>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: Int32) throws {
        let count = MemoryLayout<Int32>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: Int64) throws {
        let count = MemoryLayout<Int64>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: UInt8) throws {
        let count = MemoryLayout<UInt8>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: UInt16) throws {
        let count = MemoryLayout<UInt16>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: UInt32) throws {
        let count = MemoryLayout<UInt32>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: UInt64) throws {
        let count = MemoryLayout<UInt64>.size
        var value = value
        try withUnsafePointer(to: &value) { pointer in
            _ = try stream.write(pointer, count: count)
        }
    }

    public func encode(_ value: Float) throws {
        let count = MemoryLayout<Float>.size
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
