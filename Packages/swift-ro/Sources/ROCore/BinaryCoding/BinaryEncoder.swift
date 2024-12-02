//
//  BinaryEncoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum BinaryEncodingError: Error {
    case invalidEncoding(String.Encoding)
    case invalidLengthOfBytes(Int)
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

    public func encode(_ value: [UInt8]) throws {
        try value.withUnsafeBytes { pointer in
            _ = try stream.write(pointer.baseAddress!, count: pointer.count)
        }
    }

    public func encode(_ value: String, encoding: String.Encoding = .ascii) throws {
        guard let data = value.data(using: encoding) else {
            throw BinaryEncodingError.invalidEncoding(encoding)
        }
        try data.withUnsafeBytes { pointer in
            _ = try stream.write(pointer.baseAddress!, count: pointer.count)
        }
    }

    public func encode(_ value: String, lengthOfBytes: Int, encoding: String.Encoding = .ascii) throws {
        guard var data = value.data(using: encoding) else {
            throw BinaryEncodingError.invalidEncoding(encoding)
        }
        guard data.count <= lengthOfBytes else {
            throw BinaryEncodingError.invalidLengthOfBytes(lengthOfBytes)
        }
        data.append(contentsOf: [UInt8](repeating: 0, count: lengthOfBytes - data.count))
        try data.withUnsafeBytes { pointer in
            _ = try stream.write(pointer.baseAddress!, count: pointer.count)
        }
    }

    public func encode<T>(_ value: T) throws where T: BinaryEncodable {
        let encoder = BinaryEncoder(stream: stream)
        try value.encode(to: encoder)
    }

    public func encode<T>(_ value: [T]) throws where T: BinaryEncodable {
        let encoder = BinaryEncoder(stream: stream)
        for element in value {
            try element.encode(to: encoder)
        }
    }

    public func encode<T>(_ value: T, configuration: T.BinaryEncodingConfiguration) throws where T: BinaryEncodableWithConfiguration {
        let encoder = BinaryEncoder(stream: stream)
        try value.encode(to: encoder, configuration: configuration)
    }
}
