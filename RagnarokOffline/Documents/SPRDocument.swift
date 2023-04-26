//
//  SPRDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/18.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics
import Foundation
import UIKit

enum SPRFrameType: Int {
    case indexed = 0
    case rgba = 1
}

struct SPRFrame {
    var type: SPRFrameType
    var width: UInt16
    var height: UInt16
    var data: Data
}

struct SPRDocument {

    var header: String
    var version: String
    var indexedFrameCount: UInt16
    var rgbaFrameCount: UInt16
    var frames: [SPRFrame]
    var palette: Palette?

    init(data: Data) throws {
        var buffer = ByteBuffer(data: data)

        header = try buffer.readString(length: 2)
        guard header == "SP" else {
            throw DocumentError.invalidContents
        }

        let minor = try buffer.readUInt8()
        let major = try buffer.readUInt8()
        version = "\(major).\(minor)"

        indexedFrameCount = try buffer.readUInt16()

        rgbaFrameCount = 0
        if version > "1.1" {
            rgbaFrameCount = try buffer.readUInt16()
        }

        frames = []

        if version < "2.1" {
            frames += try (0..<indexedFrameCount).map { _ in
                try buffer.readIndexedFrame()
            }
        } else {
            frames += try (0..<indexedFrameCount).map { _ in
                try buffer.readIndexedFrameRLE()
            }
        }

        frames += try (0..<rgbaFrameCount).map { _ in
            try buffer.readRGBAFrame()
        }

        if version > "1.0" {
            try buffer.moveReaderIndex(to: data.count - 1024)
            let paletteData = try buffer.readData(length: 1024)
            palette = try Palette(data: paletteData)
        }
    }
}

extension SPRDocument {

    func imageForFrame(at index: Int) -> UIImage? {
        let frame = frames[index]
        let width = Int(frame.width)
        let height = Int(frame.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        switch frame.type {
        case .indexed:
            guard let palette else {
                return nil
            }

            let byteOrder = CGBitmapInfo.byteOrder32Big
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            let data = frame.data
                .map { colorIndex in
                    var color = palette.colors[Int(colorIndex)]
                    color.alpha = colorIndex == 0 ? 0 : 255
                    return [color.red, color.green, color.blue, color.alpha]
                }
                .flatMap({ $0 })
            guard let provider = CGDataProvider(data: Data(data) as CFData) else {
                return nil
            }

            guard let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            ) else {
                return nil
            }

            let image = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
            return image
        case .rgba:
            let byteOrder = CGBitmapInfo.byteOrder32Little
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            guard let provider = CGDataProvider(data: frame.data as CFData) else {
                return nil
            }

            guard let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            ) else {
                return nil
            }

            let image = UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
            return image
        }
    }
}

extension ByteBuffer {

    @inlinable
    mutating func readIndexedFrame() throws -> SPRFrame {
        let width = try readUInt16()
        let height = try readUInt16()
        let data = try readData(length: Int(width) * Int(height))
        let frame = SPRFrame(
            type: .indexed,
            width: width,
            height: height,
            data: data
        )
        return frame
    }

    @inlinable
    mutating func readIndexedFrameRLE() throws -> SPRFrame {
        let width = try readUInt16()
        let height = try readUInt16()
        var data = Data(capacity: Int(width) * Int(height))

        let endIndex = try Int(readUInt16()) + readerIndex
        while readerIndex < endIndex {
            let c = try readUInt8()
            data.append(c)

            if c == 0 {
                let count = try readUInt8()
                if count == 0 {
                    data.append(count)
                } else {
                    for _ in 1..<count {
                        data.append(c)
                    }
                }
            }
        }

        let frame = SPRFrame(
            type: .indexed,
            width: width,
            height: height,
            data: data
        )
        return frame
    }

    @inlinable
    mutating func readRGBAFrame() throws -> SPRFrame {
        let width = try readUInt16()
        let height = try readUInt16()
        let data = try readData(length: Int(width) * Int(height) * 4)
        let frame = SPRFrame(
            type: .rgba,
            width: width,
            height: height,
            data: data
        )
        return frame
    }
}
