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
    var entries: [Entry]
    var directories: Set<Path>

    init(url: URL) throws {
        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        let signature = try reader.readString(15)
        let key = try reader.readBytes(15)
        let fileTableOffset: UInt32 = try reader.readInt()
        let skip: UInt32 = try reader.readInt()
        let fileCount: UInt32 = try reader.readInt()
        let version: UInt32 = try reader.readInt()

        guard signature == "Master of Magic" else {
            throw DocumentError.invalidContents
        }

        guard version == 0x200 else {
            throw DocumentError.invalidContents
        }

        guard Header.size + Int(fileTableOffset) < stream.length else {
            throw DocumentError.invalidContents
        }

        header = Header(
            signature: signature,
            key: Data(key),
            fileTableOffset: fileTableOffset,
            skip: skip,
            fileCount: fileCount - skip - 7,
            version: version
        )

        try stream.seek(Int(fileTableOffset), origin: .current)

        let packSize: UInt32 = try reader.readInt()
        let realSize: UInt32 = try reader.readInt()

        let compressedData = try reader.readBytes(Int(packSize))
        guard let data = Data(compressedData).unzip() else {
            throw DocumentError.invalidContents
        }

        table = Table(
            packSize: packSize,
            realSize: realSize,
            data: data
        )

        entries = []

        var pos = 0
        for _ in 0..<header.fileCount {
            guard let index = table.data[pos...].firstIndex(of: 0) else {
                break
            }

            let name = String(data: table.data[pos..<index], encoding: .koreanEUC) ?? ""

            pos = index + 1

            let packSize = Data(table.data[(pos + 0)..<(pos + 4)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let lengthAligned = Data(table.data[(pos + 4)..<(pos + 8)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let realSize = Data(table.data[(pos + 8)..<(pos + 12)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let type = table.data[pos + 12]
            let offset = Data(table.data[(pos + 13)..<(pos + 17)]).withUnsafeBytes { $0.load(as: UInt32.self) }

            pos += 17

            if type & EntryType.file.rawValue == 0 {
                continue
            }

            let entry = Entry(
                path: Path(string: name),
                packSize: packSize,
                lengthAligned: lengthAligned,
                realSize: realSize,
                type: type,
                offset: offset
            )
            entries.append(entry)
        }

        directories = Set(entries.map({ $0.path.removingLastComponent() }))
    }
}

extension GRF {
    struct Header {
        static let size: Int = 0x2e

        var signature: String
        var key: Data
        var fileTableOffset: UInt32
        var skip: UInt32
        var fileCount: UInt32
        var version: UInt32
    }
}

extension GRF {
    struct Table {
        static let size: UInt64 = 0x08

        var packSize: UInt32
        var realSize: UInt32
        var data: Data
    }
}

extension GRF {
    struct Entry: Comparable {
        var path: Path
        var packSize: UInt32
        var lengthAligned: UInt32
        var realSize: UInt32
        var type: UInt8
        var offset: UInt32

        func data(from reader: BinaryReader) throws -> Data {
            try reader.stream.seek(Header.size + Int(offset), origin: .begin)

            var bytes = try reader.readBytes(Int(lengthAligned))

            if type & EntryType.encryptMixed.rawValue != 0 {
                let decryptor = DESDecryptor()
                decryptor.decodeFull(buf: &bytes, len: Int(lengthAligned), entrylen: Int(packSize))
            } else if type & EntryType.encryptHeader.rawValue != 0 {
                let decryptor = DESDecryptor()
                decryptor.decodeHeader(buf: &bytes, len: Int(lengthAligned))
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

    struct EntryType: OptionSet {
        let rawValue: UInt8

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        static let file          = EntryType(rawValue: 0x01) // entry is a file
        static let encryptMixed  = EntryType(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
        static let encryptHeader = EntryType(rawValue: 0x04) // encryption mode 1 (header DES only)
    }
}

extension GRF {
    struct Path: Comparable, Hashable {
        /// A string representation of the path.
        let string: String

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

        /// The path except for the last path component.
        func removingLastComponent() -> Path {
            let startIndex = string.startIndex
            guard let endIndex = string.lastIndex(of: "\\") else {
                return self
            }

            let substring = string[startIndex..<endIndex]
            return Path(string: String(substring))
        }

        /// The result of replacing with the new extension.
        func replacingExtension(_ newExtension: String) -> Path {
            let newLastComponent = stem + "." + newExtension
            let newString = removingLastComponent().string + "\\" + newLastComponent
            return Path(string: newString)
        }

        static func < (lhs: GRF.Path, rhs: GRF.Path) -> Bool {
            lhs.string < rhs.string
        }
    }
}
