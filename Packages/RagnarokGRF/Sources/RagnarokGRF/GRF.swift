//
//  GRF.swift
//  RagnarokGRF
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
    case invalidProtectedData(String)
    case missingProtectedKey(UInt32)
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
            let eventHorizon = Array("Event Horizon\0".utf8)

            magic = try decoder.decode([UInt8].self, count: 16)
            key = try decoder.decode([UInt8].self, count: 14)

            guard magic == masterOfMagic || magic.dropLast(2) == eventHorizon else {
                throw GRFError.invalidHeader(magic)
            }

            let data = try decoder.decode([UInt8].self, count: 16)

            version = data.littleEndianUInt32(at: 12)

            if version == 0x300 && data[5..<8].allSatisfy({ $0 == 0 }) {
                fileTableOffset = data.littleEndianUInt64(at: 0)

                fileCount = data.littleEndianUInt32(at: 8)
            } else {
                fileTableOffset = UInt64(data.littleEndianUInt32(at: 0))

                let seed = data.littleEndianUInt32(at: 4)
                let fileCount = data.littleEndianUInt32(at: 8)
                self.fileCount = fileCount - seed - 7
            }
        }
    }
}

extension GRF {
    struct Table: BinaryDecodableWithConfiguration {
        static let size = 0x08

        var tableSizeCompressed: UInt32
        var tableSize: UInt32

        var entries: [GRF.Entry]

        var protectedKeys: [UInt32 : [UInt8]] = [:]

        init(from decoder: BinaryDecoder, configuration header: GRF.Header) throws {
            switch header.version {
            case 0x102, 0x103:
                tableSizeCompressed = 0
                tableSize = 0

                entries = []
                entries.reserveCapacity(Int(header.fileCount))

                let data = try decoder.decode([UInt8].self, count: decoder.bytesRemaining)

                var position = 0
                for _ in 0..<header.fileCount {
                    let nameLength = data[position] - 6

                    let position2 = data.littleEndianUInt32(at: position)
                    position += 4

                    let encodedName = [UInt8](data[(position + 2)..<(position + 2 + Int(nameLength))])
                    var decodedName = DES.decodeFileName(fileName: encodedName)
                    decodedName = decodedName.prefix(while: { $0 != 0 })
                    let name = String(data: Data(decodedName), encoding: .isoLatin1) ?? ""
                    let path = GRFPathReference(string: name)

                    position += Int(position2)

                    let compressedSizeBase = data.littleEndianUInt32(at: position)
                    position += 4

                    let compressedSizeAligned = data.littleEndianUInt32(at: position)
                    position += 4

                    let decompressedSize = data.littleEndianUInt32(at: position)
                    position += 4

                    var types = GRF.EntryTypes(rawValue: data[position])
                    switch path.extension.lowercased() {
                    case "act", "gat", "gnd", "str":
                        types.insert(.encryptHeader)
                    default:
                        types.insert(.encryptMixed)
                    }
                    position += 1

                    let dataOffset = UInt64(data.littleEndianUInt32(at: position))
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
                var keyBlockSize: UInt32 = 0
                if header.version == 0x300 {
                    keyBlockSize = try decoder.decode(UInt32.self)
                }

                tableSizeCompressed = try decoder.decode(UInt32.self)
                tableSize = try decoder.decode(UInt32.self)

                entries = []
                entries.reserveCapacity(Int(header.fileCount))

                let compressedData = try decoder.decode([UInt8].self, count: Int(tableSizeCompressed))
                if compressedData.first == 0 {
                    throw GRFError.lzmaCompressionIsNotSupported
                }

                // The key block follows the compressed table. An invalid one does not prevent reading the archive.
                if keyBlockSize > 0 && keyBlockSize <= 20 + 65535 * 64 && Int(keyBlockSize) <= decoder.bytesRemaining {
                    let keyBlock = try decoder.decode([UInt8].self, count: Int(keyBlockSize))
                    protectedKeys = (try? GRF.ProtectedDecoder.decodeArchiveKeys(keyBlock)) ?? [:]
                }

                let data = try Zlib.inflate(compressedData, capacity: Int(tableSize)).data

                var position = 0
                for _ in 0..<header.fileCount {
                    guard let index = data[position...].firstIndex(of: 0) else {
                        throw GRFError.dataCorrupted(Data(data))
                    }

                    let nameBytes = data[position..<index]
                    let name = String(bytes: nameBytes, encoding: .isoLatin1) ?? ""
                    let path = GRFPathReference(string: name)

                    position = index + 1

                    let sizeCompressed = data.littleEndianUInt32(at: position)
                    position += 4

                    let sizeCompressedAligned = data.littleEndianUInt32(at: position)
                    position += 4

                    let size = data.littleEndianUInt32(at: position)
                    position += 4

                    let types = GRF.EntryTypes(rawValue: data[position])
                    position += 1

                    let offset: UInt64
                    if header.version == 0x200 {
                        offset = UInt64(data.littleEndianUInt32(at: position))
                        position += 4
                    } else {
                        offset = data.littleEndianUInt64(at: position)
                        position += 8
                    }

                    if !types.contains(.file) && !types.contains(.gravityEncrypted) {
                        continue
                    }

                    let entry = GRF.Entry(
                        path: path,
                        sizeCompressed: sizeCompressed,
                        sizeCompressedAligned: sizeCompressedAligned,
                        size: size,
                        types: types,
                        offset: offset,
                        rawName: types.contains(.gravityEncrypted) ? Array(nameBytes) : nil
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
        static let file             = GRF.EntryTypes(rawValue: 0x01) // entry is a file
        static let encryptMixed     = GRF.EntryTypes(rawValue: 0x02) // encryption mode 0 (header DES + periodic DES/shuffle)
        static let encryptHeader    = GRF.EntryTypes(rawValue: 0x04) // encryption mode 1 (header DES only)
        static let gravityEncrypted = GRF.EntryTypes(rawValue: 0x80) // Gravity protected content (version 0x300)

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

        // Original filename bytes of a protected entry, used to derive its decryption hash.
        var rawName: [UInt8]? = nil

        func data(from stream: any BinaryIO.Stream, protectedKeys: [UInt32 : [UInt8]] = [:]) throws -> Data {
            if types.contains(.gravityEncrypted) {
                let data = try protectedData(from: stream, protectedKeys: protectedKeys)
                return Data(data)
            }

            try stream.seek(GRF.Header.size + Int(offset), origin: .begin)

            let decoder = BinaryDecoder(stream: stream)
            var bytes = try decoder.decode([UInt8].self, count: Int(sizeCompressedAligned))

            if types.contains(.encryptMixed) {
                DES.decodeFull(buf: &bytes, len: Int(sizeCompressedAligned), entrylen: Int(sizeCompressed))
            } else if types.contains(.encryptHeader) {
                DES.decodeHeader(buf: &bytes, len: Int(sizeCompressedAligned))
            }

            if bytes.first == 0 {
                throw GRFError.lzmaCompressionIsNotSupported
            }

            let data = try Zlib.inflate(bytes, capacity: Int(size)).data
            return Data(data)
        }

        private func protectedData(from stream: any BinaryIO.Stream, protectedKeys: [UInt32 : [UInt8]]) throws -> [UInt8] {
            guard types == .gravityEncrypted,
                  let rawName,
                  sizeCompressed >= GRF.ProtectedDecoder.headerSize,
                  sizeCompressedAligned >= sizeCompressed,
                  sizeCompressedAligned <= GRF.ProtectedDecoder.maxPackedSize,
                  size <= GRF.ProtectedDecoder.maxOutputSize,
                  stream.length - GRF.Header.size >= Int(sizeCompressedAligned),
                  offset <= UInt64(stream.length - GRF.Header.size - Int(sizeCompressedAligned)) else {
                throw GRFError.invalidProtectedData("Invalid protected GRF entry metadata: \(path.string)")
            }

            try stream.seek(GRF.Header.size + Int(offset), origin: .begin)

            let decoder = BinaryDecoder(stream: stream)
            let payload = try decoder.decode([UInt8].self, count: Int(sizeCompressed))
            let data = try GRF.ProtectedDecoder.decode(payload, rawName: rawName, expectedSize: Int(size), archiveKeys: protectedKeys)
            return data
        }
    }
}
