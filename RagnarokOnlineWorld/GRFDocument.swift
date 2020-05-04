//
//  GRFDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import DataCompression

public class GRFDocument {

    public struct Header {
        public static let size: UInt64 = 0x2e

        public let signature: [UInt8]
        public let key: [UInt8]
        public let fileTableOffset: UInt32
        public let skip: UInt32
        public let fileCount: UInt32
        public let version: UInt32
    }

    public struct Table {
        public static let size: UInt64 = 0x08

        public let packSize: UInt32
        public let realSize: UInt32
    }

    public struct Entry {
        public let filename: String
        public let packSize: UInt32
        public let lengthAligned: UInt32
        public let realSize: UInt32
        public let type: UInt8
        public let offset: UInt32
    }

    public enum Error: Swift.Error {
        case invalidHeader
        case invalidTable
    }

    public let header: Header
    public let table: Table
    public let entries: [Entry]

    private let fileHandle: FileHandle
    private let attributes: [FileAttributeKey : Any]

    public init(url: URL) throws {
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

        guard Header.size + UInt64(fileTableOffset) < attributes[.size] as? UInt64 ?? 0 else {
            throw Error.invalidHeader
        }

        header = Header(
            signature: signature,
            key: key,
            fileTableOffset: fileTableOffset,
            skip: skip,
            fileCount: fileCount - skip - 7,
            version: version
        )

        try fileHandle.seek(toOffset: Header.size + UInt64(fileTableOffset))

        let packSize = try fileHandle.readUInt32()
        let realSize = try fileHandle.readUInt32()

        table = Table(
            packSize: packSize,
            realSize: realSize
        )

        try fileHandle.seek(toOffset: Header.size + UInt64(fileTableOffset) + Table.size)
        let data = try fileHandle.readBytes(Int(packSize))
        guard let decompressedData = Data(data).unzip() else {
            throw Error.invalidTable
        }

        var pos = 0
        var entries: [Entry] = []
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

            let entry = Entry(
                filename: String(bytes: filename, encoding: .ascii) ?? "",
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
}
