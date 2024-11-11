//
//  BinaryEncodable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/9.
//

public protocol BinaryEncodable {
    func encode(to encoder: BinaryEncoder) throws
}

public protocol BinaryEncodableWithConfiguration {
    associatedtype BinaryEncodingConfiguration

    func encode(to encoder: BinaryEncoder, configuration: BinaryEncodingConfiguration) throws
}

extension Int8: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension Int16: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension Int32: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension Int64: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension UInt8: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension UInt16: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension UInt32: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension UInt64: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}

extension Float: BinaryEncodable {
    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(self)
    }
}
