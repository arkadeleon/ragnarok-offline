//
//  GRF.swift
//  GRF
//
//  Created by Leon Li on 2020/5/1.
//

import BinaryIO
import CoreFoundation
import Foundation
import SwiftGzip

public enum GRFError: Error {
    case invalidURL(URL)
    case invalidHeader(String, expected: String)
    case invalidVersion(UInt32)
    case invalidEntryPath(String)
    case dataCorrupted(Data)
}

struct GRF {
    var header: GRF.Header
    var table: GRF.Table

    init(url: URL) throws {
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
    struct Header: BinaryDecodable {
        static let size = 0x2e

        var magic: String
        var key: [UInt8]
        var fileTableOffset: UInt32
        var seed: UInt32
        var fileCount: UInt32
        var version: UInt32

        init(from decoder: BinaryDecoder) throws {
            magic = try decoder.decode(String.self, lengthOfBytes: 16)
            guard magic == "Master of Magic" else {
                throw GRFError.invalidHeader(magic, expected: "Master of Magic")
            }

            key = try decoder.decode([UInt8].self, count: 14)
            fileTableOffset = try decoder.decode(UInt32.self)
            seed = try decoder.decode(UInt32.self)
            let fileCount = try decoder.decode(UInt32.self)
            version = try decoder.decode(UInt32.self)

            self.fileCount = fileCount - seed - 7
        }
    }
}

extension GRF {
    struct Table: BinaryDecodableWithConfiguration {
        static let size = 0x08

        var tableSizeCompressed: UInt32
        var tableSize: UInt32

        var entries: [GRF.Entry] = []

        init(from decoder: BinaryDecoder, configuration header: GRF.Header) throws {
            switch header.version {
            case 0x102, 0x103:
                tableSizeCompressed = 0
                tableSize = 0

                let data = try decoder.decode([UInt8].self, count: decoder.bytesRemaining)
                let des = DES()

                var position = 0
                for _ in 0..<header.fileCount {
                    let nameLength = data[position] - 6

                    let position2 = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
                    position += 4

                    let encodedName = [UInt8](data[(position + 2)..<(position + 2 + Int(nameLength))])
                    var decodedName = des.decodeFileName(fileName: encodedName)
                    decodedName = decodedName.prefix(while: { $0 != 0 })
                    let name = String(data: Data(decodedName), encoding: .isoLatin1) ?? ""
                    let path = GRFPath(string: name)

                    position += Int(position2)

                    let compressedSizeBase = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
                    position += 4

                    let compressedSizeAligned = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
                    position += 4

                    let decompressedSize = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
                    position += 4

                    var type = data[position]
                    switch path.extension.lowercased() {
                    case "act", "gat", "gnd", "str":
                        type |= GRF.EntryType.encryptHeader.rawValue
                    default:
                        type |= GRF.EntryType.encryptMixed.rawValue
                    }
                    position += 1

                    let dataOffset = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
                    position += 4

                    let entry = GRF.Entry(
                        path: GRFPath(string: name),
                        sizeCompressed: compressedSizeBase - decompressedSize - 715,
                        sizeCompressedAligned: compressedSizeAligned - 37579,
                        size: decompressedSize,
                        type: type,
                        offset: dataOffset
                    )

                    if entry.type & GRF.EntryType.file.rawValue == 0 {
                        continue
                    }

                    entries.append(entry)
                }
            case 0x200:
                tableSizeCompressed = try decoder.decode(UInt32.self)
                tableSize = try decoder.decode(UInt32.self)

                let decompressor = GzipDecompressor()
                let compressedData = try decoder.decode([UInt8].self, count: Int(tableSizeCompressed))
                let data = try decompressor.unzip(data: Data(compressedData))

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

    struct Entry: Codable {
        var path: GRFPath
        var sizeCompressed: UInt32
        var sizeCompressedAligned: UInt32
        var size: UInt32
        var type: UInt8
        var offset: UInt32

        init(path: GRFPath, sizeCompressed: UInt32, sizeCompressedAligned: UInt32, size: UInt32, type: UInt8, offset: UInt32) {
            self.path = path
            self.sizeCompressed = sizeCompressed
            self.sizeCompressedAligned = sizeCompressedAligned
            self.size = size
            self.type = type
            self.offset = offset
        }

        init(data: Data, position: inout Int) throws {
            guard let index = data[position...].firstIndex(of: 0) else {
                throw GRFError.dataCorrupted(data)
            }

            let name = String(data: data[position..<index], encoding: .isoLatin1) ?? ""
            path = GRFPath(string: name)

            position = index + 1

            sizeCompressed = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
            sizeCompressedAligned = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 4, as: UInt32.self) }
            size = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 8, as: UInt32.self) }
            type = data[position + 12]
            offset = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position + 13, as: UInt32.self) }

            position += 17
        }

        func data(from stream: any BinaryIO.Stream) throws -> Data {
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

            let decompressor = GzipDecompressor()
            let data = try decompressor.unzip(data: Data(bytes))
            return data
        }
    }
}
