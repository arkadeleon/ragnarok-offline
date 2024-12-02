//
//  BinaryDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum BinaryDecodingError: Error {
    case invalidEncoding(String.Encoding)
}

public class BinaryDecoder {
    let stream: any Stream
    let needsCloseStream: Bool

    public var bytesRemaining: Int {
        stream.length - stream.position
    }

    public init(stream: any Stream) {
        self.stream = stream
        self.needsCloseStream = false
    }

    public init(url: URL) throws {
        self.stream = try FileStream(url: url)
        self.needsCloseStream = true
    }

    public init(data: Data) {
        self.stream = MemoryStream(data: data)
        self.needsCloseStream = true
    }

    deinit {
        if needsCloseStream {
            stream.close()
        }
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        let count = MemoryLayout<Int8>.size
        var result: Int8 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        let count = MemoryLayout<Int16>.size
        var result: Int16 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        let count = MemoryLayout<Int32>.size
        var result: Int32 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        let count = MemoryLayout<Int64>.size
        var result: Int64 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        let count = MemoryLayout<UInt8>.size
        var result: UInt8 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        let count = MemoryLayout<UInt16>.size
        var result: UInt16 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        let count = MemoryLayout<UInt32>.size
        var result: UInt32 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        let count = MemoryLayout<UInt64>.size
        var result: UInt64 = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: Float.Type) throws -> Float {
        let count = MemoryLayout<Float>.size
        var result: Float = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode(_ type: [UInt8].Type, count: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        try bytes.withUnsafeMutableBytes { pointer in
            _ = try stream.read(pointer.baseAddress!, count: count)
        }
        return bytes
    }

    public func decode(_ type: String.Type, lengthOfBytes: Int, encoding: String.Encoding = .ascii) throws -> String {
        var bytes = [UInt8](repeating: 0, count: lengthOfBytes)
        try bytes.withUnsafeMutableBytes { pointer in
            _ = try stream.read(pointer.baseAddress!, count: lengthOfBytes)
        }
        bytes = bytes.prefix { $0 != 0 }
        guard let string = String(bytes: bytes, encoding: encoding) else {
            throw BinaryDecodingError.invalidEncoding(encoding)
        }
        return string
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: BinaryDecodable {
        let value = try T(from: self)
        return value
    }

    public func decode<T>(_ type: [T].Type, count: Int) throws -> [T] where T: BinaryDecodable {
        var array: [T] = []
        for _ in 0..<count {
            let element = try T(from: self)
            array.append(element)
        }
        return array
    }

    public func decode<T>(_ type: T.Type, configuration: T.BinaryDecodingConfiguration) throws -> T where T: BinaryDecodableWithConfiguration {
        let value = try T(from: self, configuration: configuration)
        return value
    }
}
