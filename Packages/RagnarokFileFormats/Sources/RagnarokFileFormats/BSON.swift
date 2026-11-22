//
//  BSON.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2026/11/22.
//

import BinaryIO
import Foundation

public enum BSONError: Error, Equatable, Sendable {
    case truncatedData
    case invalidDocumentLength(Int)
    case missingDocumentTerminator
    case invalidUTF8String
    case invalidBooleanValue(UInt8)
    case unsupportedElementType(UInt8)
}

public struct BSON: FileFormat, Equatable {
    public var root: [String : BSON.Value]

    public init(from decoder: BinaryDecoder) throws {
        let document = try decoder.decode(BSON.Document.self)
        root = document.elements
    }
}

extension BSON {
    public struct Document: BinaryDecodable, Equatable, Sendable {
        public var elements: [String : BSON.Value] = [:]

        public init(from decoder: BinaryDecoder) throws {
            let startRemaining = decoder.bytesRemaining
            guard startRemaining >= 4 else {
                throw BSONError.truncatedData
            }

            let length = Int(try decoder.decode(Int32.self))
            guard length >= 5, length <= startRemaining else {
                throw BSONError.invalidDocumentLength(length)
            }

            let endRemaining = startRemaining - length
            let minRemaining = endRemaining + 1

            while decoder.bytesRemaining > minRemaining {
                let type = try decoder.decode(UInt8.self)
                if type == 0 {
                    break
                }
                let key = try decoder.decode(BSON.CString.self, configuration: minRemaining).value
                let value = try decoder.decode(BSON.Value.self, configuration: BSON.Value.BinaryDecodingConfiguration(type: type, minRemaining: minRemaining))
                elements[key] = value
            }

            guard decoder.bytesRemaining == minRemaining, try decoder.decode(UInt8.self) == 0 else {
                throw BSONError.missingDocumentTerminator
            }
        }
    }

    public struct Array: BinaryDecodable, Equatable, Sendable {
        public var elements: [BSON.Value] = []

        public init(from decoder: BinaryDecoder) throws {
            let startRemaining = decoder.bytesRemaining
            guard startRemaining >= 4 else {
                throw BSONError.truncatedData
            }

            let length = Int(try decoder.decode(Int32.self))
            guard length >= 5, length <= startRemaining else {
                throw BSONError.invalidDocumentLength(length)
            }

            let endRemaining = startRemaining - length
            let minRemaining = endRemaining + 1

            while decoder.bytesRemaining > minRemaining {
                let type = try decoder.decode(UInt8.self)
                if type == 0 {
                    break
                }
                _ = try decoder.decode(BSON.CString.self, configuration: minRemaining)
                let value = try decoder.decode(BSON.Value.self, configuration: BSON.Value.BinaryDecodingConfiguration(type: type, minRemaining: minRemaining))
                elements.append(value)
            }

            guard decoder.bytesRemaining == minRemaining, try decoder.decode(UInt8.self) == 0 else {
                throw BSONError.missingDocumentTerminator
            }
        }
    }

    public enum Value: BinaryDecodableWithConfiguration, Equatable, Sendable {
        public struct BinaryDecodingConfiguration: Sendable {
            public let type: UInt8
            public let minRemaining: Int

            public init(type: UInt8, minRemaining: Int) {
                self.type = type
                self.minRemaining = minRemaining
            }
        }

        case double(Double)
        case string(String)
        case document([String : BSON.Value])
        case array([BSON.Value])
        case binary(subtype: UInt8, data: Data)
        case objectID(Data)
        case bool(Bool)
        case utcDateTime(Int64)
        case null
        case int32(Int32)
        case timestamp(UInt64)
        case int64(Int64)

        public var documentValue: [String : BSON.Value]? {
            if case .document(let value) = self {
                return value
            }
            return nil
        }

        public var arrayValue: [BSON.Value]? {
            if case .array(let value) = self {
                return value
            }
            return nil
        }

        public var stringValue: String? {
            if case .string(let value) = self {
                return value
            }
            return nil
        }

        public var boolValue: Bool? {
            if case .bool(let value) = self {
                return value
            }
            return nil
        }

        public var intValue: Int? {
            switch self {
            case .int32(let value):
                Int(value)
            case .int64(let value):
                Int(value)
            default:
                nil
            }
        }

        public var doubleValue: Double? {
            switch self {
            case .double(let value):
                value
            case .int32(let value):
                Double(value)
            case .int64(let value):
                Double(value)
            default:
                nil
            }
        }

        public init(from decoder: BinaryDecoder, configuration: BinaryDecodingConfiguration) throws {
            let minRemaining = configuration.minRemaining

            switch configuration.type {
            case 0x01:
                guard decoder.bytesRemaining - 8 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let bits = try decoder.decode(UInt64.self)
                self = .double(Double(bitPattern: bits))
            case 0x02:
                guard decoder.bytesRemaining - 4 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let byteCount = Int(try decoder.decode(Int32.self))
                guard byteCount >= 1, decoder.bytesRemaining - byteCount >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let bytes = try decoder.decode([UInt8].self, count: byteCount)
                guard bytes.last == 0, let string = String(bytes: bytes.dropLast(), encoding: .utf8) else {
                    throw BSONError.invalidUTF8String
                }
                self = .string(string)
            case 0x03:
                let document = try decoder.decode(BSON.Document.self)
                self = .document(document.elements)
            case 0x04:
                let array = try decoder.decode(BSON.Array.self)
                self = .array(array.elements)
            case 0x05:
                guard decoder.bytesRemaining - 5 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let byteCount = Int(try decoder.decode(Int32.self))
                guard byteCount >= 0, decoder.bytesRemaining - (1 + byteCount) >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let subtype = try decoder.decode(UInt8.self)
                let bytes = try decoder.decode([UInt8].self, count: byteCount)
                self = .binary(subtype: subtype, data: Data(bytes))
            case 0x06, 0x0A:
                self = .null
            case 0x07:
                guard decoder.bytesRemaining - 12 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let bytes = try decoder.decode([UInt8].self, count: 12)
                self = .objectID(Data(bytes))
            case 0x08:
                guard decoder.bytesRemaining - 1 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                let flag = try decoder.decode(UInt8.self)
                switch flag {
                case 0:
                    self = .bool(false)
                case 1:
                    self = .bool(true)
                default:
                    throw BSONError.invalidBooleanValue(flag)
                }
            case 0x09:
                guard decoder.bytesRemaining - 8 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                self = .utcDateTime(try decoder.decode(Int64.self))
            case 0x10:
                guard decoder.bytesRemaining - 4 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                self = .int32(try decoder.decode(Int32.self))
            case 0x11:
                guard decoder.bytesRemaining - 8 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                self = .timestamp(try decoder.decode(UInt64.self))
            case 0x12:
                guard decoder.bytesRemaining - 8 >= minRemaining else {
                    throw BSONError.truncatedData
                }
                self = .int64(try decoder.decode(Int64.self))
            default:
                throw BSONError.unsupportedElementType(configuration.type)
            }
        }
    }

    private struct CString: BinaryDecodableWithConfiguration {
        let value: String

        init(from decoder: BinaryDecoder, configuration minRemaining: Int) throws {
            var bytes: [UInt8] = []
            while decoder.bytesRemaining > minRemaining {
                let byte = try decoder.decode(UInt8.self)
                if byte == 0 {
                    guard let string = String(bytes: bytes, encoding: .utf8) else {
                        throw BSONError.invalidUTF8String
                    }
                    value = string
                    return
                }
                bytes.append(byte)
            }
            throw BSONError.truncatedData
        }
    }
}
