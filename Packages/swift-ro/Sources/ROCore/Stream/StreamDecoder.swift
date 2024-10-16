//
//  StreamDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/12.
//

import Foundation

public class StreamDecoder {
    public init() {
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let decoder = _StreamDecoder(stream: stream, codingPath: [], userInfo: [:])
        return try type.init(from: decoder)
    }
}

struct _StreamDecoder: Decoder {
    let stream: any Stream
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey : Any]

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        _StreamUnkeyedDecodingContainer(decoder: self)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw DecodingError.typeMismatch(SingleValueDecodingContainer.self, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }
}

struct _StreamUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let decoder: _StreamDecoder

    var codingPath: [any CodingKey] {
        decoder.codingPath
    }

    var count: Int?

    var isAtEnd: Bool {
        decoder.stream.position + 1 == decoder.stream.length
    }

    var currentIndex: Int

    init(decoder: _StreamDecoder) {
        self.decoder = decoder
        self.count = decoder.stream.length - decoder.stream.position
        self.currentIndex = 0
    }

    func decodeNil() -> Bool {
        false
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let count = MemoryLayout<Bool>.size
        var result: Bool = false
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try decoder.stream.read(pointer, count: count)
        }
        return result
    }

    mutating func decode(_ type: String.Type) throws -> String {
        throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        try decodeFloat()
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        try decodeFloat()
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        try decodeInt()
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeInt()
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeInt()
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeInt()
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeInt()
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    mutating func decode(_ type: Int128.Type) throws -> Int128 {
        try decodeInt()
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try decodeInt()
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeInt()
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeInt()
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeInt()
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeInt()
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    mutating func decode(_ type: UInt128.Type) throws -> UInt128 {
        try decodeInt()
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try type.init(from: decoder)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        throw DecodingError.typeMismatch(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }

    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        self
    }

    mutating func superDecoder() throws -> any Decoder {
        decoder
    }

    private mutating func decodeInt<T: FixedWidthInteger>() throws -> T {
        let count = MemoryLayout<T>.size
        var result: T = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try decoder.stream.read(pointer, count: count)
        }
        return result
    }

    private mutating func decodeFloat<T: FloatingPoint>() throws -> T {
        let count = MemoryLayout<T>.size
        var result: T = 0
        try withUnsafeMutablePointer(to: &result) { pointer in
            _ = try decoder.stream.read(pointer, count: count)
        }
        return result
    }
}
