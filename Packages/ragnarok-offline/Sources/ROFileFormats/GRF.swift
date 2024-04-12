//
//  GRF.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/1.
//

import Foundation
import CoreFoundation
import DataCompression
import ROCrypto
import ROStream

public enum GRFError: Error {
    case invalidVersion(UInt32)
    case invalidPath(GRF.Path)
    case dataCorrupted(Data)
}

public struct GRF {
    public var header: Header
    public var table: Table

    public init(url: URL) throws {
        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try Header(from: reader)

        try stream.seek(Int(header.fileTableOffset), origin: .current)

        table = try Table(from: reader, header: header)
    }
}

extension GRF {
    public struct Header {
        static let size: Int = 0x2e

        public var magic: String
        public var key: [UInt8]
        public var fileTableOffset: UInt32
        public var seed: UInt32
        public var fileCount: UInt32
        public var version: UInt32

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(15)
            guard magic == "Master of Magic" else {
                throw FileFormatError.invalidHeader(magic)
            }

            key = try reader.readBytes(15)
            fileTableOffset = try reader.readInt()
            seed = try reader.readInt()
            fileCount = try reader.readInt()
            version = try reader.readInt()

            fileCount = fileCount - seed - 7
        }
    }
}

extension GRF {
    public struct Table {
        static let size: UInt64 = 0x08

        public var tableSizeCompressed: UInt32
        public var tableSize: UInt32

        public var entries: [Entry] = []

        init(from reader: BinaryReader, header: Header) throws {
            switch header.version {
            case 0x102, 0x103:
                throw GRFError.invalidVersion(header.version)
            case 0x200:
                tableSizeCompressed = try reader.readInt()
                tableSize = try reader.readInt()

                let compressedData = try reader.readBytes(Int(tableSizeCompressed))
                guard let data = Data(compressedData).unzip() else {
                    throw GRFError.dataCorrupted(Data(compressedData))
                }

                var position = 0
                for _ in 0..<header.fileCount {
                    let entry = try Entry(data: data, position: &position)

                    if entry.type & EntryType.file.rawValue == 0 {
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

        static let file          = EntryType(rawValue: 0x01) // entry is a file
        static let encryptMixed  = EntryType(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
        static let encryptHeader = EntryType(rawValue: 0x04) // encryption mode 1 (header DES only)
    }

    public struct Entry: Comparable {
        public var path: Path
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
            path = Path(string: name)

            position = index + 1

            sizeCompressed = Data(data[(position + 0)..<(position + 4)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            sizeCompressedAligned = Data(data[(position + 4)..<(position + 8)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            size = Data(data[(position + 8)..<(position + 12)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            type = data[position + 12]
            offset = Data(data[(position + 13)..<(position + 17)]).withUnsafeBytes { $0.load(as: UInt32.self) }

            position += 17
        }

        public func data(from reader: BinaryReader) throws -> Data {
            try reader.stream.seek(Header.size + Int(offset), origin: .begin)

            var bytes = try reader.readBytes(Int(sizeCompressedAligned))

            if type & EntryType.encryptMixed.rawValue != 0 {
                let des = DES()
                des.decodeFull(buf: &bytes, len: Int(sizeCompressedAligned), entrylen: Int(sizeCompressed))
            } else if type & EntryType.encryptHeader.rawValue != 0 {
                let des = DES()
                des.decodeHeader(buf: &bytes, len: Int(sizeCompressedAligned))
            }

            guard let data = Data(bytes).unzip() else {
                throw GRFError.dataCorrupted(Data(bytes))
            }
            return data
        }

        public static func < (lhs: GRF.Entry, rhs: GRF.Entry) -> Bool {
            lhs.path < rhs.path
        }
    }
}

extension GRF {
    public class Path: Comparable, Hashable {
        public static let effectTextureDirectory = Path(string: "data\\texture\\effect")

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

        public init(string: String) {
            self.string = string
        }

        /// The result of replacing with the new extension.
        public func replacingExtension(_ newExtension: String) -> Path {
            let newLastComponent = stem + "." + newExtension
            let newString = parent.string + "\\" + newLastComponent
            return Path(string: newString)
        }

        public func hash(into hasher: inout Hasher) {
            string.hash(into: &hasher)
        }

        public static func == (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string == rhs.string
        }

        public static func < (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string < rhs.string
        }
    }
}
