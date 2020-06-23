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

    private var reader: BinaryReader!

    private(set) var header = ""
    private(set) var version = ""
    private(set) var indexed_count: UInt16 = 0
    private(set) var rgba_count: UInt16 = 0
    private(set) var palette = Data()
    private(set) var frames: [SPRFrame] = []

    override func load(from contents: Data) throws {
        let stream = DataStream(data: contents)
        reader = BinaryReader(stream: stream)

        header = try reader.readString(count: 2)
        guard header == "SP" else {
            throw StreamError.invalidContents
        }

        let minor = try reader.readUInt8()
        let major = try reader.readUInt8()
        version = "\(major).\(minor)"

        indexed_count = try reader.readUInt16()

        if version > "1.1" {
            rgba_count = try reader.readUInt16()
        }

        frames = []

        if version < "2.1" {
            try readIndexedImage()
        } else {
            try readIndexedImageRLE()
        }

        try readRGBAImage()

        if version > "1.0" {
            try stream.seek(toOffset: UInt64(contents.count) - 1024)
            palette = try reader.readData(count: 1024)
        }

        reader = nil
    }

    private func readIndexedImage() throws {
        for _ in 0..<indexed_count {
            let width = try reader.readUInt16()
            let height = try reader.readUInt16()
            let data = try reader.readData(count: Int(width) * Int(height))
            let frame = SPRFrame(
                type: .pal,
                width: width,
                height: height,
                data: data
            )
            frames.append(frame)
        }
    }

    private func readIndexedImageRLE() throws {
        for _ in 0..<indexed_count {
            let width = try reader.readUInt16()
            let height = try reader.readUInt16()
            let length = try reader.readUInt16()
            let raw = try reader.readData(count: Int(length))
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
    }

    private func readRGBAImage() throws {
        for _ in 0..<rgba_count {
            let width = try reader.readUInt16()
            let height = try reader.readUInt16()
            let data = try reader.readData(count: Int(width) * Int(height) * 4)
            let frame = SPRFrame(
                type: .rgba,
                width: width,
                height: height,
                data: data
            )
            frames.append(frame)
        }
    }
}
