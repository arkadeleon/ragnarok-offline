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
    case invalidURL(URL)
    case invalidVersion(UInt32)
    case invalidEntryPath(String)
    case dataCorrupted(Data)
}

public struct GRF {
    public var header: GRF.Header
    public var table: GRF.Table

    public init(url: URL) throws {
        guard let stream = FileStream(url: url) else {
            throw GRFError.invalidURL(url)
        }

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
        public var path: GRFPath
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
            path = GRFPath(string: name)

            position = index + 1

            sizeCompressed = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
            sizeCompressedAligned = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 4, as: UInt32.self) }
            size = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 8, as: UInt32.self) }
            type = data[position + 12]
            offset = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 13, as: UInt32.self) }

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
