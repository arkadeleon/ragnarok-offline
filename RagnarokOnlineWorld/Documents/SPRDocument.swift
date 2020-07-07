//
//  SPRDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/18.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum SPRType: Int {

    case pal = 0
    case rgba = 1
}

struct SPRFrame {

    var type: SPRType
    var width: UInt16
    var height: UInt16
    var data: Data
}

class SPRDocument: Document {

    struct Contents {
        var header: String
        var version: String
        var indexed_count: UInt16
        var rgba_count: UInt16
        var frames: [SPRFrame]
        var palette: Data
    }

    let source: DocumentSource
    let name: String

    required init(source: DocumentSource) {
        self.source = source
        self.name = source.name
    }

    func load() -> Result<Contents, DocumentError> {
        guard let data = try? source.data() else {
            return .failure(.invalidSource)
        }

        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readSPRContents(count: data.count)
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readSPRContents(count: Int) throws -> SPRDocument.Contents {
        let header = try readString(count: 2)
        guard header == "SP" else {
            throw DocumentError.invalidContents
        }

        let minor = try readUInt8()
        let major = try readUInt8()
        let version = "\(major).\(minor)"

        let indexed_count = try readUInt16()

        var rgba_count: UInt16 = 0
        if version > "1.1" {
            rgba_count = try readUInt16()
        }

        var frames: [SPRFrame] = []

        if version < "2.1" {
            frames += try readSPRIndexedImage(indexed_count: indexed_count)
        } else {
            frames += try readSPRIndexedImageRLE(indexed_count: indexed_count)
        }

        frames += try readSPRRGBAImage(rgba_count: rgba_count)

        var palette = Data()
        if version > "1.0" {
            try stream.seek(toOffset: UInt64(count) - 1024)
            palette = try readData(count: 1024)
        }

        let contents = SPRDocument.Contents(
            header: header,
            version: version,
            indexed_count: indexed_count,
            rgba_count: rgba_count,
            frames: frames,
            palette: palette
        )
        return contents
    }

    fileprivate func readSPRIndexedImage(indexed_count: UInt16) throws -> [SPRFrame] {
        var frames: [SPRFrame] = []
        for _ in 0..<indexed_count {
            let width = try readUInt16()
            let height = try readUInt16()
            let data = try readData(count: Int(width) * Int(height))
            let frame = SPRFrame(
                type: .pal,
                width: width,
                height: height,
                data: data
            )
            frames.append(frame)
        }
        return frames
    }

    fileprivate func readSPRIndexedImageRLE(indexed_count: UInt16) throws -> [SPRFrame] {
        var frames: [SPRFrame] = []
        for _ in 0..<indexed_count {
            let width = try readUInt16()
            let height = try readUInt16()
            let length = try readUInt16()
            let raw = try readData(count: Int(length))
            var data = Data(capacity: Int(width) * Int(height))

            let stream = DataStream(data: raw)
            let reader = BinaryReader(stream: stream)

            while let c = try? reader.readUInt8() {
                data.append(c)

                if c == 0 {
                    if let count = try? reader.readUInt8() {
                        if count == 0 {
                            data.append(count)
                        } else {
                            for _ in 1..<count {
                                data.append(c)
                            }
                        }
                    }
                }
            }

            let frame = SPRFrame(
                type: .pal,
                width: width,
                height: height,
                data: data
            )
            frames.append(frame)
        }
        return frames
    }

    fileprivate func readSPRRGBAImage(rgba_count: UInt16) throws -> [SPRFrame] {
        var frames: [SPRFrame] = []
        for _ in 0..<rgba_count {
            let width = try readUInt16()
            let height = try readUInt16()
            let data = try readData(count: Int(width) * Int(height) * 4)
            let frame = SPRFrame(
                type: .rgba,
                width: width,
                height: height,
                data: data
            )
            frames.append(frame)
        }
        return frames
    }
}
