//
//  ByteBuffer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/25.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

enum ByteBufferReadingError: Error {
    case bufferUnderflow
    case invalidEncoding
}

struct ByteBuffer {

    private(set) var readerIndex = 0

    private let data: Data

    init(data: Data) {
        self.data = data
    }

    @inlinable
    mutating func moveReaderIndex(forwardBy offset: Int) throws {
        try moveReaderIndex(to: readerIndex + offset)
    }

    @inlinable
    mutating func moveReaderIndex(to offset: Int) throws {
        guard offset <= data.count else {
            throw ByteBufferReadingError.bufferUnderflow
        }
        readerIndex = offset
    }

    @inlinable
    mutating func readBytes(length: Int) throws -> [UInt8] {
        guard readerIndex + length <= data.count else {
            throw ByteBufferReadingError.bufferUnderflow
        }
        let bytes = [UInt8](data[readerIndex..<(readerIndex + length)])
        try moveReaderIndex(forwardBy: length)
        return bytes
    }

    @inlinable
    mutating func readUInt8() throws -> UInt8 {
        let bytes = try readBytes(length: 1)
        return bytes.withUnsafeBytes { $0.load(as: UInt8.self) }
    }

    @inlinable
    mutating func readInt8() throws -> Int8 {
        let bytes = try readBytes(length: 1)
        return bytes.withUnsafeBytes { $0.load(as: Int8.self) }
    }

    @inlinable
    mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(length: 2)
        return bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
    }

    @inlinable
    mutating func readInt16() throws -> Int16 {
        let bytes = try readBytes(length: 2)
        return bytes.withUnsafeBytes { $0.load(as: Int16.self) }
    }

    @inlinable
    mutating func readUInt32() throws -> UInt32 {
        let bytes = try readBytes(length: 4)
        return bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
    }

    @inlinable
    mutating func readInt32() throws -> Int32 {
        let bytes = try readBytes(length: 4)
        return bytes.withUnsafeBytes { $0.load(as: Int32.self) }
    }

    @inlinable
    mutating func readFloat32() throws -> Float32 {
        let bytes = try readBytes(length: 4)
        return bytes.withUnsafeBytes { $0.load(as: Float32.self) }
    }

    @inlinable
    mutating func readFloat64() throws -> Float64 {
        let bytes = try readBytes(length: 8)
        return bytes.withUnsafeBytes { $0.load(as: Float64.self) }
    }

    @inlinable
    mutating func readData(length: Int) throws -> Data {
        let bytes = try readBytes(length: length)
        let data = Data(bytes)
        return data
    }

    @inlinable
    mutating func readString(length: Int, encoding: String.Encoding = .ascii) throws -> String {
        let bytes = try readBytes(length: length)
        let data = Data(bytes.prefix { $0 != 0 })
        guard let string = String(data: data, encoding: encoding) else {
            throw ByteBufferReadingError.invalidEncoding
        }
        return string
    }
}
