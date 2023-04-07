//
//  GRFDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import CoreFoundation
import DataCompression

struct GRFHeader {

    static let size: UInt64 = 0x2e

    var signature: String
    var key: Data
    var fileTableOffset: UInt32
    var skip: UInt32
    var fileCount: UInt32
    var version: UInt32
}

struct GRFTable {

    static let size: UInt64 = 0x08

    var packSize: UInt32
    var realSize: UInt32
    var data: Data
}

struct GRFEntry {

    var name: String
    var packSize: UInt32
    var lengthAligned: UInt32
    var realSize: UInt32
    var type: UInt8
    var offset: UInt32

    func data(from stream: Stream) throws -> Data {
        try stream.seek(toOffset: GRFHeader.size + UInt64(offset))
        let reader = StreamReader(stream: stream)

        var bytes = try Array(reader.readData(count: Int(lengthAligned)))

        if type & GRFEntryType.encryptMixed.rawValue != 0 {
            let decryptor = DESDecryptor()
            decryptor.decodeFull(buf: &bytes, len: Int(lengthAligned), entrylen: Int(packSize))
        } else if type & GRFEntryType.encryptHeader.rawValue != 0 {
            let decryptor = DESDecryptor()
            decryptor.decodeHeader(buf: &bytes, len: Int(lengthAligned))
        }

        guard let data = Data(bytes).unzip() else {
            throw DocumentError.invalidContents
        }
        return data
    }
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

    init(from stream: Stream) throws {
        let reader = StreamReader(stream: stream)

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

            if type & GRFEntryType.file.rawValue == 0 {
                continue
            }

            let entry = GRFEntry(
                name: name,
                packSize: packSize,
                lengthAligned: lengthAligned,
                realSize: realSize,
                type: type,
                offset: offset
            )

            entries.append(entry)
        }

        self.entries = entries
    }
}
