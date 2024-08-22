//
//  BinaryDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/6/28.
//

import Foundation

public protocol BinaryDecodable {
    init(from decoder: BinaryDecoder) throws
}

public enum BinaryDecodingError: Error {
    case dataCorrupted
}

public class BinaryDecoder {
    var data: Data

    init(data: Data) {
        self.data = data
    }

    public func decode<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
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

        guard let string = String(data: data, encoding: .utf8) else {
            throw BinaryDecodingError.dataCorrupted
        }
        return string
    }

    public func decode<T: BinaryDecodable>(_ type: T.Type) throws -> T {
        let value = try type.init(from: self)
        return value
    }

    public func decode<T: BinaryDecodable>(_ type: T.Type, length: Int) throws -> T {
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
