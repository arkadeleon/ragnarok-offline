//
//  GRF.swift
//  GRF
//
//  Created by Leon Li on 2020/5/1.
//

import BinaryIO
import CoreFoundation
import DataCompression
import Foundation

public enum GRFError: Error {
    case invalidURL(URL)
    case invalidHeader([UInt8])
    case invalidVersion(UInt32)
    case invalidEntryPath(String)
    case dataCorrupted(Data)
    case lzmaCompressionIsNotSupported
}

struct GRF {
    var header: GRF.Header
    var table: GRF.Table

    init(url: URL) throws {
        guard let stream = FileStream(forReadingFrom: url) else {
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

        var magic: [UInt8]
        var key: [UInt8]
        var fileTableOffset: UInt64
        var fileCount: UInt32
        var version: UInt32

        init(from decoder: BinaryDecoder) throws {
            let masterOfMagic = Array("Master of Magic\0".utf8)
            let eventHorizon = Array("Event Horizon\0RL".utf8)

            magic = try decoder.decode([UInt8].self, count: 16)
            key = try decoder.decode([UInt8].self, count: 14)

            switch magic {
            case masterOfMagic:
                let fileTableOffset = try decoder.decode(UInt32.self)
                self.fileTableOffset = UInt64(fileTableOffset)

                let seed = try decoder.decode(UInt32.self)
                let fileCount = try decoder.decode(UInt32.self)
                self.fileCount = fileCount - seed - 7
            case eventHorizon:
                let fileTableOffset = try decoder.decode(UInt64.self)
                self.fileTableOffset = fileTableOffset + 4

                fileCount = try decoder.decode(UInt32.self)
            default:
                throw GRFError.invalidHeader(magic)
            }

            version = try decoder.decode(UInt32.self)
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

                    let position2 = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let encodedName = [UInt8](data[(position + 2)..<(position + 2 + Int(nameLength))])
                    var decodedName = des.decodeFileName(fileName: encodedName)
                    decodedName = decodedName.prefix(while: { $0 != 0 })
                    let name = String(data: Data(decodedName), encoding: .isoLatin1) ?? ""
                    let path = GRFPathReference(string: name)

                    position += Int(position2)

                    let compressedSizeBase = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let compressedSizeAligned = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let decompressedSize = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    var types = GRF.EntryTypes(rawValue: data[position])
                    switch path.extension.lowercased() {
                    case "act", "gat", "gnd", "str":
                        types.insert(.encryptHeader)
                    default:
                        types.insert(.encryptMixed)
                    }
                    position += 1

                    let dataOffset = data.withUnsafeBytes {
                        UInt64($0.loadUnaligned(fromByteOffset: position, as: UInt32.self))
                    }
                    position += 4

                    if !types.contains(.file) {
                        continue
                    }

                    let entry = GRF.Entry(
                        path: GRFPathReference(string: name),
                        sizeCompressed: compressedSizeBase - decompressedSize - 715,
                        sizeCompressedAligned: compressedSizeAligned - 37579,
                        size: decompressedSize,
                        types: types,
                        offset: dataOffset
                    )
                    entries.append(entry)
                }
            case 0x200, 0x300:
                tableSizeCompressed = try decoder.decode(UInt32.self)
                tableSize = try decoder.decode(UInt32.self)

                let compressedData = try decoder.decode([UInt8].self, count: Int(tableSizeCompressed))
                if compressedData.first == 0 {
                    throw GRFError.lzmaCompressionIsNotSupported
                }

                let decompressor = GzipDecompressor()
                let data = try decompressor.unzip(data: Data(compressedData))

                var position = 0
                for _ in 0..<header.fileCount {
                    guard let index = data[position...].firstIndex(of: 0) else {
                        throw GRFError.dataCorrupted(data)
                    }

                    let name = String(data: data[position..<index], encoding: .isoLatin1) ?? ""
                    let path = GRFPathReference(string: name)

                    position = index + 1

                    let sizeCompressed = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let sizeCompressedAligned = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let size = data.withUnsafeBytes {
                        $0.loadUnaligned(fromByteOffset: position, as: UInt32.self)
                    }
                    position += 4

                    let types = GRF.EntryTypes(rawValue: data[position])
                    position += 1

                    let offset: UInt64
                    if header.version == 0x200 {
                        offset = data.withUnsafeBytes {
                            UInt64($0.loadUnaligned(fromByteOffset: position, as: UInt32.self))
                        }
                        position += 4
                    } else {
                        offset = data.withUnsafeBytes {
                            $0.loadUnaligned(fromByteOffset: position, as: UInt64.self)
                        }
                        position += 8
                    }

                    if !types.contains(.file) {
                        continue
                    }

                    let entry = GRF.Entry(
                        path: path,
                        sizeCompressed: sizeCompressed,
                        sizeCompressedAligned: sizeCompressedAligned,
                        size: size,
                        types: types,
                        offset: offset
                    )
                    entries.append(entry)
                }
            default:
                throw GRFError.invalidVersion(header.version)
            }
        }
    }
}

extension GRF {
    struct EntryTypes: OptionSet {
        static let file          = GRF.EntryTypes(rawValue: 0x01) // entry is a file
        static let encryptMixed  = GRF.EntryTypes(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
        static let encryptHeader = GRF.EntryTypes(rawValue: 0x04) // encryption mode 1 (header DES only)

        let rawValue: UInt8

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    struct Entry {
        var path: GRFPathReference
        var sizeCompressed: UInt32
        var sizeCompressedAligned: UInt32
        var size: UInt32
        var types: GRF.EntryTypes
        var offset: UInt64

        func data(from stream: any BinaryIO.Stream) throws -> Data {
            try stream.seek(GRF.Header.size + Int(offset), origin: .begin)

            let decoder = BinaryDecoder(stream: stream)
            var bytes = try decoder.decode([UInt8].self, count: Int(sizeCompressedAligned))

            if types.contains(.encryptMixed) {
                let des = DES()
                des.decodeFull(buf: &bytes, len: Int(sizeCompressedAligned), entrylen: Int(sizeCompressed))
            } else if types.contains(.encryptHeader) {
                let des = DES()
                des.decodeHeader(buf: &bytes, len: Int(sizeCompressedAligned))
            }

            if bytes.first == 0 {
                throw GRFError.lzmaCompressionIsNotSupported
            }

            let decompressor = GzipDecompressor()
            let data = try decompressor.unzip(data: Data(bytes))
            return data
        }
    }
}
