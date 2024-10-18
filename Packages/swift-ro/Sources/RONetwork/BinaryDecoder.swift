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
    public private(set) var data: Data

    public init(data: Data) {
        self.data = data
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        let length = type.bitWidth / 8
        let data = self.data.prefix(length)
        guard data.count == length else {
            throw BinaryDecodingError.dataCorrupted
        }

        self.data.removeFirst(length)

        let values = data.withUnsafeBytes { pointer in
            pointer.bindMemory(to: type)
        }
        return values[0]
    }

    public func decode(_ type: [UInt8].Type, length: Int) throws -> [UInt8] {
        let data = self.data.prefix(length)
        guard data.count == length else {
            throw BinaryDecodingError.dataCorrupted
        }

        self.data.removeFirst(length)

        let bytes = [UInt8](data)
        return bytes
    }

    public func decode(_ type: String.Type, length: Int) throws -> String {
        let data = self.data.prefix(length)
        guard data.count == length else {
            throw BinaryDecodingError.dataCorrupted
        }

        self.data.removeFirst(length)

        let endIndex = data.firstIndex(of: 0) ?? data.endIndex
        guard let string = String(data: data[..<endIndex], encoding: .utf8) else {
            throw BinaryDecodingError.dataCorrupted
        }
        return string
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: BinaryDecodable {
        let value = try type.init(from: self)
        return value
    }

    public func decode<T>(_ type: T.Type, configuration: T.BinaryDecodingConfiguration) throws -> T where T: BinaryDecodableWithConfiguration {
        let value = try type.init(from: self, configuration: configuration)
        return value
    }

    public func decode<T>(_ type: T.Type, length: Int) throws -> T where T: BinaryDecodable {
        let data = self.data.prefix(length)
        guard data.count == length else {
            throw BinaryDecodingError.dataCorrupted
        }

        self.data.removeFirst(length)

        let decoder = BinaryDecoder(data: data)
        let value = try type.init(from: decoder)
        return value
    }
}
