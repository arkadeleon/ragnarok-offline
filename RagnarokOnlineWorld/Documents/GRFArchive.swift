//
//  GRFArchive.swift
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

class GRFArchive: NSObject {

    enum Error: Swift.Error {
        case invalidHeader
        case invalidTable
        case invalidEntry
    }

    let url: URL
    let header: GRFHeader
    let table: GRFTable

    private(set) var entries: [GRFEntry] = []
    private(set) var entryNameTable = ""

    init(url: URL) throws {
        self.url = url

        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        let signature = try reader.readString(count: 15, encoding: String.Encoding.ascii.rawValue)
        let key = try reader.readData(count: 15)
        let fileTableOffset = try reader.readUInt32()
        let skip = try reader.readUInt32()
        let fileCount = try reader.readUInt32()
        let version = try reader.readUInt32()

        guard signature == "Master of Magic" else {
            throw Error.invalidHeader
        }

        guard version == 0x200 else {
            throw Error.invalidHeader
        }

        guard GRFHeader.size + UInt64(fileTableOffset) < (try stream.length()) else {
            throw Error.invalidHeader
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
            throw Error.invalidTable
        }

        table = GRFTable(
            packSize: packSize,
            realSize: realSize,
            data: data
        )

        super.init()
    }

    func unarchive() {
        guard entries.count == 0 else {
            return
        }

        var pos = 0

        for _ in 0..<header.fileCount {
            guard let index = table.data[pos...].firstIndex(of: 0) else {
                break
            }

            let cfEncoding = CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
            let encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
            let name = NSString(data: table.data[pos..<index], encoding: encoding) ?? ""

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

    func contents(of entry: GRFEntry) throws -> Data {
        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        try reader.skip(count: GRFHeader.size + UInt64(entry.offset))
        var bytes = try Array(reader.readData(count: Int(entry.lengthAligned)))

        if entry.type & GRFEntryType.file.rawValue == 0 {
            guard let data = Data(bytes).unzip() else {
                throw Error.invalidEntry
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
            throw Error.invalidEntry
        }
        return data
    }
}
