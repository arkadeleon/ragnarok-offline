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

struct GRFArchiveHeader {
    static let size: UInt64 = 0x2e

    let signature: [UInt8]
    let key: [UInt8]
    let fileTableOffset: UInt32
    let skip: UInt32
    let fileCount: UInt32
    let version: UInt32
}

struct GRFArchiveTable {
    static let size: UInt64 = 0x08

    let packSize: UInt32
    let realSize: UInt32
}

struct GRFArchiveEntry: ArchiveEntry, Equatable {
    let name: String
    let packSize: UInt32
    let lengthAligned: UInt32
    let realSize: UInt32
    let type: UInt8
    let offset: UInt32

    var path: String {
        name
    }

    var lastPathComponent: String {
        String(path.split(separator: "\\").last ?? "")
    }

    var pathExtension: String {
        (lastPathComponent as NSString).pathExtension
    }
}

struct GRFArchiveEntryType: OptionSet {
    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let file          = GRFArchiveEntryType(rawValue: 0x01) // entry is a file
    static let encryptMixed  = GRFArchiveEntryType(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
    static let encryptHeader = GRFArchiveEntryType(rawValue: 0x04) // encryption mode 1 (header DES only)
}

class GRFArchive: NSObject, Archive {

    enum Error: Swift.Error {
        case invalidHeader
        case invalidTable
        case invalidEntry
    }

    let url: URL
    let header: GRFArchiveHeader
    let table: GRFArchiveTable
    let entries: [GRFArchiveEntry]

    private let fileHandle: FileHandle
    private let attributes: [FileAttributeKey : Any]

    init(url: URL) throws {
        self.url = url
        
        fileHandle = try FileHandle(forReadingFrom: url)
        attributes = try FileManager.default.attributesOfItem(atPath: url.path)

        let signature = try fileHandle.readBytes(15)
        let key = try fileHandle.readBytes(15)
        let fileTableOffset = try fileHandle.readUInt32()
        let skip = try fileHandle.readUInt32()
        let fileCount = try fileHandle.readUInt32()
        let version = try fileHandle.readUInt32()

        guard String(bytes: signature, encoding: .ascii) == "Master of Magic" else {
            throw Error.invalidHeader
        }

        guard version == 0x200 else {
            throw Error.invalidHeader
        }

        guard GRFArchiveHeader.size + UInt64(fileTableOffset) < attributes[.size] as? UInt64 ?? 0 else {
            throw Error.invalidHeader
        }

        header = GRFArchiveHeader(
            signature: signature,
            key: key,
            fileTableOffset: fileTableOffset,
            skip: skip,
            fileCount: fileCount - skip - 7,
            version: version
        )

        try fileHandle.seek(toOffset: GRFArchiveHeader.size + UInt64(fileTableOffset))

        let packSize = try fileHandle.readUInt32()
        let realSize = try fileHandle.readUInt32()

        table = GRFArchiveTable(
            packSize: packSize,
            realSize: realSize
        )

        try fileHandle.seek(toOffset: GRFArchiveHeader.size + UInt64(fileTableOffset) + GRFArchiveTable.size)
        let data = try fileHandle.readBytes(Int(packSize))
        guard let decompressedData = Data(data).unzip() else {
            throw Error.invalidTable
        }

        var pos = 0
        var entries: [GRFArchiveEntry] = []
        for _ in 0..<header.fileCount {
            var filename: [UInt8] = []
            while decompressedData[pos] != 0 {
                filename.append(decompressedData[pos])
                pos += 1
            }
            pos += 1

            let packSize = Data(decompressedData[(pos + 0)..<(pos + 4)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let lengthAligned = Data(decompressedData[(pos + 4)..<(pos + 8)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let realSize = Data(decompressedData[(pos + 8)..<(pos + 12)]).withUnsafeBytes { $0.load(as: UInt32.self) }
            let type = decompressedData[12]
            let offset = Data(decompressedData[(pos + 13)..<(pos + 17)]).withUnsafeBytes { $0.load(as: UInt32.self) }

            let cfEncoding = CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
            let nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
            let nsFilename = NSString(data: Data(filename), encoding: nsEncoding) ?? ""

            let entry = GRFArchiveEntry(
                name: nsFilename as String,
                packSize: packSize,
                lengthAligned: lengthAligned,
                realSize: realSize,
                type: type,
                offset: offset
            )

            entries.append(entry)

            pos += 17
        }

        self.entries = entries
    }

    deinit {
        fileHandle.closeFile()
    }

    func contents(of entry: GRFArchiveEntry) throws -> Data {
        try fileHandle.seek(toOffset: GRFArchiveHeader.size + UInt64(entry.offset))
        var bytes = try fileHandle.readBytes(Int(entry.lengthAligned))

        if entry.type & GRFArchiveEntryType.file.rawValue == 0 {
            guard let data = Data(bytes).unzip() else {
                throw Error.invalidEntry
            }
            return data
        }

        let decryptor = DESDecryptor()
        if entry.type & GRFArchiveEntryType.encryptMixed.rawValue != 0 {
            decryptor.decodeFull(buf: &bytes, len: Int(entry.lengthAligned), entrylen: Int(entry.packSize))
        } else if entry.type & GRFArchiveEntryType.encryptHeader.rawValue != 0 {
            decryptor.decodeHeader(buf: &bytes, len: Int(entry.lengthAligned))
        }

        guard let data = Data(bytes).unzip() else {
            throw Error.invalidEntry
        }
        return data
    }
}
