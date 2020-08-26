//
//  SPRDocument.swift
//  RagnarokOffline
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

struct SPRDocument: Document {

    var header: String
    var version: String
    var indexed_count: UInt16
    var rgba_count: UInt16
    var frames: [SPRFrame]
    var palette: Data

    init(from stream: Stream) throws {
        try stream.seek(toOffset: 0)
        let reader = StreamReader(stream: stream)

        header = try reader.readString(count: 2)
        guard header == "SP" else {
            throw DocumentError.invalidContents
        }

        let minor = try reader.readUInt8()
        let major = try reader.readUInt8()
        version = "\(major).\(minor)"

        indexed_count = try reader.readUInt16()

        rgba_count = 0
        if version > "1.1" {
            rgba_count = try reader.readUInt16()
        }

        var frames: [SPRFrame] = []

        if version < "2.1" {
            frames += try reader.readSPRIndexedImage(indexed_count: indexed_count)
        } else {
            frames += try reader.readSPRIndexedImageRLE(indexed_count: indexed_count)
        }

        frames += try reader.readSPRRGBAImage(rgba_count: rgba_count)

        self.frames = frames

        var palette = Data()
        if version > "1.0" {
            try stream.seek(toOffset: stream.length() - 1024)
            palette = try reader.readData(count: 1024)
        }
        self.palette = palette
    }
}

extension StreamReader {

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

            let stream = MemoryStream(data: raw)
            let reader = StreamReader(stream: stream)

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
