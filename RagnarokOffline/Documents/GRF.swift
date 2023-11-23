//
//  GRF.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import CoreFoundation
import DataCompression

struct GRF {
    var header: Header
    var table: Table

    init(url: URL) throws {
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
    struct Header {
        static let size: Int = 0x2e

        var magic: String
        var key: [UInt8]
        var fileTableOffset: UInt32
        var seed: UInt32
        var fileCount: UInt32
        var version: UInt32

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(15)
            guard magic == "Master of Magic" else {
                throw DocumentError.invalidContents
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
    struct Table {
        static let size: UInt64 = 0x08

        var tableSizeCompressed: UInt32
        var tableSize: UInt32

        var entries: [Entry]
        var directories: Set<Path>

        init(from reader: BinaryReader, header: Header) throws {
            switch header.version {
            case 0x102, 0x103:
                throw DocumentError.invalidContents
            case 0x200:
                tableSizeCompressed = try reader.readInt()
                tableSize = try reader.readInt()

                let compressedData = try reader.readBytes(Int(tableSizeCompressed))
                guard let data = Data(compressedData).unzip() else {
                    throw DocumentError.invalidContents
                }

                entries = []

                var position = 0
                for _ in 0..<header.fileCount {
                    let entry = try Entry(data: data, position: &position)

                    if entry.type & EntryType.file.rawValue == 0 {
                        continue
                    }

                    entries.append(entry)
                }
            default:
                throw DocumentError.invalidContents
            }

            directories = Set(entries.map({ $0.path.parent }))
            for directory in directories {
                var parent = directory
                repeat {
                    parent = parent.parent
                    directories.insert(parent)
                } while !parent.string.isEmpty
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

    struct Entry: Comparable {
        var path: Path
        var sizeCompressed: UInt32
        var sizeCompressedAligned: UInt32
        var size: UInt32
        var type: UInt8
        var offset: UInt32

        init(data: Data, position: inout Int) throws {
            guard let index = data[position...].firstIndex(of: 0) else {
                throw DocumentError.invalidContents
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

        func data(from reader: BinaryReader) throws -> Data {
            try reader.stream.seek(Header.size + Int(offset), origin: .begin)

            var bytes = try reader.readBytes(Int(sizeCompressedAligned))

            if type & EntryType.encryptMixed.rawValue != 0 {
                let decryptor = DESDecryptor()
                decryptor.decodeFull(buf: &bytes, len: Int(sizeCompressedAligned), entrylen: Int(sizeCompressed))
            } else if type & EntryType.encryptHeader.rawValue != 0 {
                let decryptor = DESDecryptor()
                decryptor.decodeHeader(buf: &bytes, len: Int(sizeCompressedAligned))
            }

            guard let data = Data(bytes).unzip() else {
                throw DocumentError.invalidContents
            }
            return data
        }

        static func < (lhs: GRF.Entry, rhs: GRF.Entry) -> Bool {
            lhs.path < rhs.path
        }
    }
}

extension GRF {
    class Path: Comparable, Hashable {
        static let effectTextureDirectory = Path(string: "data\\texture\\effect")

        /// A string representation of the path.
        let string: String

        /// The parent path.
        lazy var parent: Path = {
            let startIndex = string.startIndex
            if let endIndex = string.lastIndex(of: "\\") {
                let substring = string[startIndex..<endIndex]
                return Path(string: String(substring))
            } else {
                return Path(string: "")
            }
        }()

        /// The last path component (including any extension).
        var lastComponent: String {
            string.split(separator: "\\").last.map(String.init) ?? ""
        }

        /// The last path component (without any extension).
        var stem: String {
            lastComponent.split(separator: ".").dropLast().joined(separator: ".")
        }

        /// The filename extension (without any leading dot).
        var `extension`: String {
            lastComponent.split(separator: ".").last.map(String.init) ?? ""
        }

        init(string: String) {
            self.string = string
        }

        /// The result of replacing with the new extension.
        func replacingExtension(_ newExtension: String) -> Path {
            let newLastComponent = stem + "." + newExtension
            let newString = parent.string + "\\" + newLastComponent
            return Path(string: newString)
        }

        func hash(into hasher: inout Hasher) {
            string.hash(into: &hasher)
        }

        static func == (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string == rhs.string
        }

        static func < (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string < rhs.string
        }
    }
}
