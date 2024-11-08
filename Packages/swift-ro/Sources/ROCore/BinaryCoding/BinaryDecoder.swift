//
//  BinaryDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public enum BinaryDecodingError: Error {
    case dataCorrupted
}

public protocol BinaryDecodable {
    init(from decoder: BinaryDecoder) throws
}

public protocol BinaryDecodableWithConfiguration {
    associatedtype BinaryDecodingConfiguration

    init(from decoder: BinaryDecoder, configuration: BinaryDecodingConfiguration) throws
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

    public init(data: Data) {
        self.stream = MemoryStream(data: data)
        self.needsCloseStream = true
    }

    deinit {
        if needsCloseStream {
            stream.close()
        }
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        let count = MemoryLayout<T>.size
        var result: T = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: FloatingPoint {
        let count = MemoryLayout<T>.size
        var result: T = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try stream.read(pointer, count: count)
        }
        return result
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: BinaryDecodable {
        let value = try type.init(from: self)
        return value
    }

    public func decode<T>(_ type: T.Type, configuration: T.BinaryDecodingConfiguration) throws -> T where T: BinaryDecodableWithConfiguration {
        let value = try type.init(from: self, configuration: configuration)
        return value
    }

    public func decodeBytes(_ count: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        try bytes.withUnsafeMutableBytes { pointer in
            _ = try stream.read(pointer.baseAddress!, count: count)
        }
        return bytes
    }

    public func decodeString(_ count: Int, encoding: String.Encoding = .ascii) throws -> String {
        var bytes = [UInt8](repeating: 0, count: count)
        try bytes.withUnsafeMutableBytes { pointer in
            _ = try stream.read(pointer.baseAddress!, count: count)
        }
        bytes = bytes.prefix { $0 != 0 }
        guard let string = String(bytes: bytes, encoding: encoding) else {
            throw StreamError.invalidEncoding
        }
        return string
    }
}
