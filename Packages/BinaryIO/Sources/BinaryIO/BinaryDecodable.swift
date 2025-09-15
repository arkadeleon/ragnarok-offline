//
//  BinaryDecodable.swift
//  BinaryIO
//
//  Created by Leon Li on 2024/11/10.
//

public protocol BinaryDecodable {
    init(from decoder: BinaryDecoder) throws
}

public protocol BinaryDecodableWithConfiguration {
    associatedtype BinaryDecodingConfiguration

    init(from decoder: BinaryDecoder, configuration: BinaryDecodingConfiguration) throws
}

extension Int8: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(Int8.self)
    }
}

extension Int16: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(Int16.self)
    }
}

extension Int32: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(Int32.self)
    }
}

extension Int64: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(Int64.self)
    }
}

extension UInt8: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(UInt8.self)
    }
}

extension UInt16: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(UInt16.self)
    }
}

extension UInt32: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(UInt32.self)
    }
}

extension UInt64: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(UInt64.self)
    }
}

extension Float: BinaryDecodable {
    public init(from decoder: BinaryDecoder) throws {
        self = try decoder.decode(Float.self)
    }
}
