//
//  GRFDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import CoreFoundation
import DataCompression

struct GRFHeader {

    static let size: UInt64 = 0x2e

    let signature: String
    let key: Data
    let fileTableOffset: UInt32
    let skip: UInt32
    let fileCount: UInt32
    let version: UInt32
}

struct GRFTable {

    static let size: UInt64 = 0x08

    let packSize: UInt32
    let realSize: UInt32
    let data: Data
}

struct GRFEntry: Equatable {

    let name: String
    let packSize: UInt32
    let lengthAligned: UInt32
    let realSize: UInt32
    let type: UInt8
    let offset: UInt32
}

struct GRFEntryType: OptionSet {

    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let file          = GRFEntryType(rawValue: 0x01) // entry is a file
    static let encryptMixed  = GRFEntryType(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
    static let encryptHeader = GRFEntryType(rawValue: 0x04) // encryption mode 1 (header DES only)
}

struct GRFDocument: Document {

    var header: GRFHeader
    var table: GRFTable
    var entries: [GRFEntry]
    var entryNameTable: String

    init(from stream: Stream) throws {
        let reader = BinaryReader(stream: stream)

        let signature = try reader.readString(count: 15)
        let key = try reader.readData(count: 15)
        let fileTableOffset = try reader.readUInt32()
        let skip = try reader.readUInt32()
        let fileCount = try reader.readUInt32()
        let version = try reader.readUInt32()

        guard signature == "Master of Magic" else {
            throw DocumentError.invalidContents
        }

        guard version == 0x200 else {
            throw DocumentError.invalidContents
        }

        guard GRFHeader.size + UInt64(fileTableOffset) < (try stream.length()) else {
            throw DocumentError.invalidContents
        }

        header = GRFHeader(
            signature: signature,
            key: key,
            fileTableOffset: fileTableOffset,
            skip: skip,
            fileCount: fileCount - skip - 7,
            version: version
        )

        try reader.skip(count: UInt64(fileTableOffset))

        let packSize = try reader.readUInt32()
        let realSize = try reader.readUInt32()

        let compressedData = try reader.readData(count: Int(packSize))
        guard let data = compressedData.unzip() else {
            throw DocumentError.invalidContents
        }

        table = GRFTable(
            packSize: packSize,
            realSize: realSize,
            data: data
        )

        var entries: [GRFEntry] = []
        var entryNameTable = ""

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
            let type = table.data[12]
            let offset = Data(table.data[(pos + 13)..<(pos + 17)]).withUnsafeBytes { $0.load(as: UInt32.self) }

            let entry = GRFEntry(
                name: name as String,
                packSize: packSize,
                lengthAligned: lengthAligned,
                realSize: realSize,
                type: type,
                offset: offset
            )

            entries.append(entry)

            entryNameTable += entry.name + "\0"

            pos += 17
        }

        self.entries = entries
        self.entryNameTable = entryNameTable
    }

    func entryNames(forPath path: String) -> [String] {
        let pattern = path.replacingOccurrences(of: "\\", with: "\\\\") + "([^(\\x0|\\\\)]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let entryNameTable = self.entryNameTable as NSString
        let range = NSRange(location: 0, length: entryNameTable.length)
        let matches = regex.matches(in: entryNameTable as String, options: [], range: range)

        var entryNames: [String] = []
        for match in matches {
            let entryName = entryNameTable.substring(with: match.range)
            entryNames.append(entryName)
        }

        return Array(Set(entryNames))
    }

    func entry(forName name: String) -> GRFEntry? {
        return entries.first { $0.name == name }
    }

    func contents(of entry: GRFEntry, from stream: Stream) throws -> Data {
        let reader = BinaryReader(stream: stream)

        try reader.skip(count: GRFHeader.size + UInt64(entry.offset))
        var bytes = try Array(reader.readData(count: Int(entry.lengthAligned)))

        if entry.type & GRFEntryType.file.rawValue == 0 {
            guard let data = Data(bytes).unzip() else {
                throw DocumentError.invalidContents
            }
            return data
        }

        let decryptor = DESDecryptor()
        if entry.type & GRFEntryType.encryptMixed.rawValue != 0 {
            decryptor.decodeFull(buf: &bytes, len: Int(entry.lengthAligned), entrylen: Int(entry.packSize))
        } else if entry.type & GRFEntryType.encryptHeader.rawValue != 0 {
            decryptor.decodeHeader(buf: &bytes, len: Int(entry.lengthAligned))
        }

        guard let data = Data(bytes).unzip() else {
            throw DocumentError.invalidContents
        }
        return data
    }
}
