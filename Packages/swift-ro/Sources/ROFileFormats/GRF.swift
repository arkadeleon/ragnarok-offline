//
//  GRF.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/1.
//

import CoreFoundation
import DataCompression
import Foundation
import ROCore

public enum GRFError: Error {
    case invalidVersion(UInt32)
    case invalidPath(String)
    case dataCorrupted(Data)
}

public struct GRF {
    public var header: GRF.Header
    public var table: GRF.Table

    public init(url: URL) throws {
        let stream = try FileStream(url: url)
        defer {
            stream.close()
        }

        let decoder = BinaryDecoder(stream: stream)

        header = try decoder.decode(GRF.Header.self)

        try stream.seek(Int(header.fileTableOffset), origin: .current)

        table = try decoder.decode(GRF.Table.self, configuration: header)
    }
}

extension GRF {
    public struct Header: BinaryDecodable {
        static let size = 0x2e

        public var magic: String
        public var key: [UInt8]
        public var fileTableOffset: UInt32
        public var seed: UInt32
        public var fileCount: UInt32
        public var version: UInt32

        public init(from decoder: BinaryDecoder) throws {
            magic = try decoder.decode(String.self, lengthOfBytes: 15)
            guard magic == "Master of Magic" else {
                throw FileFormatError.invalidHeader(magic, expected: "Master of Magic")
            }

            key = try decoder.decode([UInt8].self, count: 15)
            fileTableOffset = try decoder.decode(UInt32.self)
            seed = try decoder.decode(UInt32.self)
            fileCount = try decoder.decode(UInt32.self)
            version = try decoder.decode(UInt32.self)

            fileCount = fileCount - seed - 7
        }
    }
}

extension GRF {
    public struct Table: BinaryDecodableWithConfiguration {
        static let size = 0x08

        public var tableSizeCompressed: UInt32
        public var tableSize: UInt32

        public var entries: [GRF.Entry] = []

        public init(from decoder: BinaryDecoder, configuration header: GRF.Header) throws {
            switch header.version {
            case 0x102, 0x103:
                throw GRFError.invalidVersion(header.version)
            case 0x200:
                tableSizeCompressed = try decoder.decode(UInt32.self)
                tableSize = try decoder.decode(UInt32.self)

                let compressedData = try decoder.decode([UInt8].self, count: Int(tableSizeCompressed))
                guard let data = Data(compressedData).unzip() else {
                    throw GRFError.dataCorrupted(Data(compressedData))
                }

                var position = 0
                for _ in 0..<header.fileCount {
                    let entry = try GRF.Entry(data: data, position: &position)

                    if entry.type & GRF.EntryType.file.rawValue == 0 {
                        continue
                    }

                    entries.append(entry)
                }
            default:
                throw GRFError.invalidVersion(header.version)
            }
        }
    }
}

extension GRF {
    struct EntryType: OptionSet {
        let rawValue: UInt8

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        static let file          = GRF.EntryType(rawValue: 0x01) // entry is a file
        static let encryptMixed  = GRF.EntryType(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
        static let encryptHeader = GRF.EntryType(rawValue: 0x04) // encryption mode 1 (header DES only)
    }

    public struct Entry {
        public var path: GRF.Path
        public var sizeCompressed: UInt32
        public var sizeCompressedAligned: UInt32
        public var size: UInt32
        public var type: UInt8
        public var offset: UInt32

        init(data: Data, position: inout Int) throws {
            guard let index = data[position...].firstIndex(of: 0) else {
                throw GRFError.dataCorrupted(data)
            }

            let name = String(data: data[position..<index], encoding: .koreanEUC) ?? ""
            path = GRF.Path(string: name)

            position = index + 1

            sizeCompressed = Data(data[(position + 0)..<(position + 4)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            sizeCompressedAligned = Data(data[(position + 4)..<(position + 8)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            size = Data(data[(position + 8)..<(position + 12)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            type = data[position + 12]
            offset = Data(data[(position + 13)..<(position + 17)]).withUnsafeBytes { $0.load(as: UInt32.self) }

            position += 17
        }

        public func data(from stream: any ROCore.Stream) throws -> Data {
            try stream.seek(GRF.Header.size + Int(offset), origin: .begin)

            let decoder = BinaryDecoder(stream: stream)
            var bytes = try decoder.decode([UInt8].self, count: Int(sizeCompressedAligned))

            if type & GRF.EntryType.encryptMixed.rawValue != 0 {
                let des = DES()
                des.decodeFull(buf: &bytes, len: Int(sizeCompressedAligned), entrylen: Int(sizeCompressed))
            } else if type & GRF.EntryType.encryptHeader.rawValue != 0 {
                let des = DES()
                des.decodeHeader(buf: &bytes, len: Int(sizeCompressedAligned))
            }

            guard let data = Data(bytes).unzip() else {
                throw GRFError.dataCorrupted(Data(bytes))
            }
            return data
        }
    }
}

extension GRF {
    public class Path: Hashable {
        /// A string representation of the path.
        public let string: String

        /// The parent path.
        public lazy var parent: Path = {
            let startIndex = string.startIndex
            if let endIndex = string.lastIndex(of: "\\") {
                let substring = string[startIndex..<endIndex]
                return Path(string: String(substring))
            } else {
                return Path(string: "")
            }
        }()

        /// The last path component (including any extension).
        public var lastComponent: String {
            string.split(separator: "\\").last.map(String.init) ?? ""
        }

        /// The last path component (without any extension).
        public var stem: String {
            lastComponent.split(separator: ".").dropLast().joined(separator: ".")
        }

        /// The filename extension (without any leading dot).
        public var `extension`: String {
            lastComponent.split(separator: ".").last.map(String.init) ?? ""
        }

        init(string: String) {
            self.string = string
        }

        public init(components: [String]) {
            self.string = components.joined(separator: "\\")
        }

        public func appending(_ components: [String]) -> GRF.Path {
            GRF.Path(string: ([string] + components).joined(separator: "\\"))
        }

        /// The result of replacing with the new extension.
        public func replacingExtension(_ newExtension: String) -> Path {
            let newLastComponent = stem + "." + newExtension
            let newString = parent.string + "\\" + newLastComponent
            return Path(string: newString)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(string)
        }

        public static func == (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string == rhs.string
        }
    }
}
