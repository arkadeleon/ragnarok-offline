//
//  YAMLDecoder.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/16.
//

import Foundation

enum YamlError: Error {
    case dataCouldNotBeDecoded(encoding: String.Encoding)
}

/// `Codable`-style `Decoder` that can be used to decode a `Decodable` type from a given `String` and optional
/// user info mapping. Similar to `Foundation.JSONDecoder`.
class YAMLDecoder {

    init() {
    }

    /// Decode a `Decodable` type from a given `Node` and optional user info mapping.
    ///
    /// - parameter type:    `Decodable` type to decode.
    /// - parameter node:     YAML Node to decode.
    /// - parameter userInfo: Additional key/values which can be used when looking up keys to decode.
    ///
    /// - returns: Returns the decoded type `T`.
    ///
    /// - throws: `DecodingError` or `YamlError` if something went wrong while decoding.
    func decode<T>(_ type: T.Type = T.self,
                   from node: YAMLNode,
                   userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T where T: Swift.Decodable {
        let decoder = _YAMLDecoder(referencing: node, userInfo: userInfo)
        let container = try decoder.singleValueContainer()
        return try container.decode(type)
    }

    /// Decode a `Decodable` type from a given `String` and optional user info mapping.
    ///
    /// - parameter type:    `Decodable` type to decode.
    /// - parameter yaml:     YAML string to decode.
    /// - parameter userInfo: Additional key/values which can be used when looking up keys to decode.
    ///
    /// - returns: Returns the decoded type `T`.
    ///
    /// - throws: `DecodingError` or `YamlError` if something went wrong while decoding.
    func decode<T>(_ type: T.Type = T.self,
                   from yaml: String,
                   userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T where T: Swift.Decodable {
        do {
            let parser = YAMLParser(yaml: yaml)
            let node = parser.parse()
            return try self.decode(type, from: node, userInfo: userInfo)
        } catch let error as DecodingError {
            throw error
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [],
                                                    debugDescription: "The given data was not valid YAML.",
                                                    underlyingError: error))
        }
    }

    /// Decode a `Decodable` type from a given `Data` and optional user info mapping.
    ///
    /// - parameter type:    `Decodable` type to decode.
    /// - parameter yaml:     YAML data to decode.
    /// - parameter userInfo: Additional key/values which can be used when looking up keys to decode.
    ///
    /// - returns: Returns the decoded type `T`.
    ///
    /// - throws: `DecodingError` or `YamlError` if something went wrong while decoding.
    func decode<T>(_ type: T.Type = T.self,
                   from yamlData: Data,
                   userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T where T: Swift.Decodable {
        guard let yamlString = String(data: yamlData, encoding: .utf8) else {
            throw YamlError.dataCouldNotBeDecoded(encoding: .utf8)
        }

        return try decode(type, from: yamlString, userInfo: userInfo)
    }
}

private struct _YAMLDecoder: Decoder {

    fileprivate let node: YAMLNode

    init(referencing node: YAMLNode, userInfo: [CodingUserInfoKey: Any], codingPath: [any CodingKey] = []) {
        self.node = node
        self.userInfo = userInfo
        self.codingPath = codingPath
    }

    // MARK: - Swift.Decoder Methods

    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard case .mapping(let nodes) = node else {
            throw _typeMismatch(at: codingPath, expectation: YAMLNode.self, reality: node)
        }
        return .init(_YAMLKeyedDecodingContainer<Key>(decoder: self, wrapping: nodes))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard case .sequence(let sequence) = node else {
            throw _typeMismatch(at: codingPath, expectation: YAMLNode.self, reality: node)
        }
        return _YAMLUnkeyedDecodingContainer(decoder: self, wrapping: sequence)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        return self
    }

    // MARK: -

    /// create a new `_Decoder` instance referencing `node` as `key` inheriting `userInfo`
    func decoder(referencing node: YAMLNode, `as` key: any CodingKey) -> _YAMLDecoder {
        return .init(referencing: node, userInfo: userInfo, codingPath: codingPath + [key])
    }
}

extension _YAMLDecoder: SingleValueDecodingContainer {

    func decodeNil() -> Bool {
        if case .null = node {
            return true
        } else {
            return false
        }
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        if let value = node.value().flatMap(Bool.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: String.Type) throws -> String {
        if let value = node.value() {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Double.Type) throws -> Double {
        if let value = node.value().flatMap(Double.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        if let value = node.value().flatMap(Float.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Int.Type) throws -> Int {
        if let value = node.value().flatMap(Int.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        if let value = node.value().flatMap(Int8.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        if let value = node.value().flatMap(Int16.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        if let value = node.value().flatMap(Int32.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        if let value = node.value().flatMap(Int64.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        if let value = node.value().flatMap(UInt.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        if let value = node.value().flatMap(UInt8.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        if let value = node.value().flatMap(UInt16.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        if let value = node.value().flatMap(UInt32.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        if let value = node.value().flatMap(UInt64.init) {
            return value
        } else {
            throw _typeMismatch(at: codingPath, expectation: type, reality: node)
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try type.init(from: self)
    }
}

private struct _YAMLKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

    private let decoder: _YAMLDecoder
    private let nodes: [String : YAMLNode]

    init(decoder: _YAMLDecoder, wrapping nodes: [String : YAMLNode]) {
        self.decoder = decoder
        self.nodes = nodes
    }

    // MARK: - Swift.KeyedDecodingContainerProtocol Methods

    var codingPath: [any CodingKey] { return decoder.codingPath }

    var allKeys: [Key] {
        nodes.keys.compactMap({ Key.init(stringValue: $0) })
    }

    func contains(_ key: Key) -> Bool {
        nodes[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return try decoder(for: key).decodeNil()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        return try decoder(for: key).decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                    forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        return try decoder(for: key).container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
        return try decoder(for: key).unkeyedContainer()
    }

    func superDecoder() throws -> any Decoder { return try decoder(for: _YAMLCodingKey.super) }
    func superDecoder(forKey key: Key) throws -> any Decoder { return try decoder(for: key) }

    // MARK: -

    private func node(for key: any CodingKey) throws -> YAMLNode {
        guard let node = nodes[key.stringValue] else {
            throw _keyNotFound(at: codingPath, key, "No value associated with key \(key) (\"\(key.stringValue)\").")
        }
        return node
    }

    private func decoder(for key: any CodingKey) throws -> _YAMLDecoder {
        return decoder.decoder(referencing: try node(for: key), as: key)
    }
}

private struct _YAMLUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    private let decoder: _YAMLDecoder
    private let nodes: [YAMLNode]

    init(decoder: _YAMLDecoder, wrapping nodes: [YAMLNode]) {
        self.decoder = decoder
        self.nodes = nodes
        self.currentIndex = 0
    }

    // MARK: - Swift.UnkeyedDecodingContainer Methods

    var codingPath: [any CodingKey] { return decoder.codingPath }
    var count: Int? { return nodes.count }
    var isAtEnd: Bool { return currentIndex >= nodes.count }
    var currentIndex: Int

    mutating func decodeNil() throws -> Bool {
        try throwErrorIfAtEnd(Any?.self)
        return try currentDecoder { $0.decodeNil() }
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try currentDecoder { try $0.decode(type) }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        return try currentDecoder { try $0.container(keyedBy: type) }
    }

    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        return try currentDecoder { try $0.unkeyedContainer() }
    }

    mutating func superDecoder() throws -> any Decoder { return try currentDecoder { $0 } }

    // MARK: -

    private var currentKey: any CodingKey { return _YAMLCodingKey(index: currentIndex) }
    private var currentNode: YAMLNode { return nodes[currentIndex] }

    private func throwErrorIfAtEnd<T>(_ type: T.Type) throws {
        if isAtEnd { throw _valueNotFound(at: codingPath + [currentKey], type, "Unkeyed container is at end.") }
    }

    private mutating func currentDecoder<T>(closure: (_YAMLDecoder) throws -> T) throws -> T {
        try throwErrorIfAtEnd(T.self)
        let decoded: T = try closure(decoder.decoder(referencing: currentNode, as: currentKey))
        currentIndex += 1
        return decoded
    }
}

// MARK: - CodingKey for `_UnkeyedEncodingContainer`, `_UnkeyedDecodingContainer`, `superEncoder` and `superDecoder`

struct _YAMLCodingKey: CodingKey { // swiftlint:disable:this type_name
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = _YAMLCodingKey(stringValue: "super")!
}

// MARK: - DecodingError helpers

private func _keyNotFound(at codingPath: [any CodingKey], _ key: any CodingKey, _ description: String) -> DecodingError {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
    return.keyNotFound(key, context)
}

private func _valueNotFound(at codingPath: [any CodingKey], _ type: Any.Type, _ description: String) -> DecodingError {
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
    return .valueNotFound(type, context)
}

private func _typeMismatch(at codingPath: [any CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
    let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
    let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
    return .typeMismatch(expectation, context)
}

// MARK: TopLevelDecoder

#if canImport(Combine)
import protocol Combine.TopLevelDecoder

extension YAMLDecoder: TopLevelDecoder {
    typealias Input = Data

    func decode<T>(_ type: T.Type, from: Data) throws -> T where T: Decodable {
        try decode(type, from: from, userInfo: [:])
    }
}
#endif
