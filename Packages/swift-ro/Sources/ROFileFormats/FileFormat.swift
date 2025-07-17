//
//  FileFormat.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/10.
//

import BinaryIO
import Foundation

public protocol FileFormat: BinaryDecodable, Sendable {
}

extension FileFormat {
    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(Self.self)
    }
}

public enum FileFormatError: Error {
    case invalidHeader(String, expected: String)
}

public struct FileFormatVersion: Sendable {
    public let major: UInt8
    public let minor: UInt8

    public init(major: UInt8, minor: UInt8) {
        self.major = major
        self.minor = minor
    }
}

extension FileFormatVersion: Comparable {
    public static func < (lhs: FileFormatVersion, rhs: FileFormatVersion) -> Bool {
        if lhs.major == rhs.major {
            lhs.minor < rhs.minor
        } else {
            lhs.major < rhs.major
        }
    }
}

extension FileFormatVersion: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor)"
    }
}

extension FileFormatVersion: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let components = value.split(separator: ".").compactMap({ UInt8($0) })
        self.major = components[0]
        self.minor = components[1]
    }
}
