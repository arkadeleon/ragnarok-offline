//
//  TGADocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import Accelerate

enum TGAType: UInt8 {

    case NO_DATA     = 0
    case INDEXED     = 1
    case RGB         = 2
    case GREY        = 3
    case RLE_INDEXED = 9
    case RLE_RGB     = 10
    case RLE_GREY    = 11
}

enum TGAOrigin: Int {

    case BOTTOM_LEFT  = 0x00
    case BOTTOM_RIGHT = 0x01
    case TOP_LEFT     = 0x02
    case TOP_RIGHT    = 0x03
    case SHIFT        = 0x04
    case MASK         = 0x30
}

struct TGAHeader {

    var idLength: UInt8
    var colorMapType: UInt8
    var imageType: UInt8
    var colorMapIndex: UInt16
    var colorMapLength: UInt16
    var colorMapDepth: UInt8
    var offsetX: UInt16
    var offsetY: UInt16
    var width: UInt16
    var height: UInt16
    var pixelDepth: UInt8
    var flags: UInt8

    var hasEncoding: Bool {
        imageType == TGAType.RLE_INDEXED.rawValue || imageType == TGAType.RLE_RGB.rawValue || imageType == TGAType.RLE_GREY.rawValue
    }

    var hasColorMap: Bool {
        imageType == TGAType.RLE_INDEXED.rawValue || imageType == TGAType.INDEXED.rawValue
    }

    var isGreyColor: Bool {
        imageType == TGAType.RLE_GREY.rawValue || imageType == TGAType.GREY.rawValue
    }
}

struct TGADocument: Document {

    let header: TGAHeader
    let image: CGImage

    init(from stream: Stream) throws {
        let reader = BinaryReader(stream: stream)

        header = try reader.readTGAHeader()

        try reader.skip(count: UInt64(header.idLength))

        let palette: Data?
        if header.hasColorMap {
            let colorMapSize  = Int(header.colorMapLength) * Int(header.colorMapDepth >> 3)
            palette = try reader.readData(count: colorMapSize)
        } else {
            palette = nil
        }

        let pixelSize = Int(header.pixelDepth) >> 3
        let imageSize = Int(header.width) * Int(header.height)
        let pixelTotal = imageSize * pixelSize

        let imageData: Data
        if header.hasEncoding {
            imageData = try reader.readTGARLE(pixelSize: pixelSize, outputSize: pixelTotal)
        } else {
            if header.hasColorMap {
                imageData = try reader.readData(count: imageSize)
            } else {
                imageData = try reader.readData(count: pixelTotal)
            }
        }

        let width = Int(header.width)
        let height = Int(header.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw DocumentError.invalidContents
        }

        guard let pixels = context.data?.bindMemory(to: Pixel_8888.self, capacity: width * height) else {
            throw DocumentError.invalidContents
        }

        let origin = (Int(header.flags) & TGAOrigin.MASK.rawValue) >> TGAOrigin.SHIFT.rawValue

        let x_start: Int
        let x_step: Int
        let x_end: Int
        let y_start: Int
        let y_step: Int
        let y_end: Int

        if origin == TGAOrigin.TOP_LEFT.rawValue || origin == TGAOrigin.TOP_RIGHT.rawValue {
            y_start = 0
            y_step = 1
            y_end = height
        } else {
            y_start = height - 1
            y_step = -1
            y_end = -1
        }

        if origin == TGAOrigin.TOP_LEFT.rawValue || origin == TGAOrigin.BOTTOM_LEFT.rawValue {
            x_start = 0
            x_step = 1
            x_end = width
        } else {
            x_start = width - 1
            x_step = -1
            x_end = -1
        }

        let getImageData: (UnsafeMutablePointer<Pixel_8888>, Data, Data?, Int, Int, Int, Int, Int, Int, Int) -> ()

        switch header.pixelDepth {
        case 8:
            getImageData = header.isGreyColor ? getImageDataGrey8bits : getImageData8bits;
        case 16:
            getImageData = header.isGreyColor ? getImageDataGrey16bits : getImageData16bits;
        case 24:
            getImageData = getImageData24bits;
        case 32:
            getImageData = getImageData32bits;
        default:
            throw DocumentError.invalidContents
        }

        getImageData(pixels, imageData, palette, width, y_start, y_step, y_end, x_start, x_step, x_end)

        guard let image = context.makeImage()?.decoded else {
            throw DocumentError.invalidContents
        }

        self.image = image
    }
}

extension BinaryReader {

    func readTGAHeader() throws -> TGAHeader {
        let header = try TGAHeader(
            idLength: readUInt8(),
            colorMapType: readUInt8(),
            imageType: readUInt8(),
            colorMapIndex: readUInt16(),
            colorMapLength: readUInt16(),
            colorMapDepth: readUInt8(),
            offsetX: readUInt16(),
            offsetY: readUInt16(),
            width: readUInt16(),
            height: readUInt16(),
            pixelDepth: readUInt8(),
            flags: readUInt8()
        )

        if header.imageType == TGAType.NO_DATA.rawValue {
            throw DocumentError.invalidContents
        }

//        if header.hasColorMap {
//            if header.colorMapLength > 256 || header.colorMapSize != 24 || header.colorMapType != 1 {
//                throw DocumentError.invalidContents
//            }
//        } else {
//            if header.colorMapType != 0 {
//                throw DocumentError.invalidContents
//            }
//        }

        if header.width <= 0 || header.height <= 0 {
            throw DocumentError.invalidContents
        }

        if (header.pixelDepth != 8  &&
            header.pixelDepth != 16 &&
            header.pixelDepth != 24 &&
            header.pixelDepth != 32) {
            throw DocumentError.invalidContents
        }

        return header
    }

    func readTGARLE(pixelSize: Int, outputSize: Int) throws -> Data {
        var output = Data()

        while output.count < outputSize {
            let c = try readUInt8()
            let count = Int(c & 0x7f) + 1

            if (c & 0x80) != 0 {
                // RLE
                let pixels = try readData(count: pixelSize)
                for _ in 0..<count {
                    output.append(pixels)
                }
            } else {
                let pixels = try readData(count: pixelSize * count)
                output.append(pixels)
            }
        }

        return output
    }
}

private func getImageData8bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                               indexes: Data,
                               colormap: Data?,
                               width: Int,
                               y_start: Int,
                               y_step: Int,
                               y_end: Int,
                               x_start: Int,
                               x_step: Int,
                               x_end: Int) {
    guard let colormap = colormap else {
        return
    }

    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            let color = Int(indexes[i])
            imageData[x + width * y].3 = 255
            imageData[x + width * y].2 = colormap[(color * 3) + 0]
            imageData[x + width * y].1 = colormap[(color * 3) + 1]
            imageData[x + width * y].0 = colormap[(color * 3) + 2]
            i += 1
        }
    }
}

private func getImageData16bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                                pixels: Data,
                                colormap: Data?,
                                width: Int,
                                y_start: Int,
                                y_step: Int,
                                y_end: Int,
                                x_start: Int,
                                x_step: Int,
                                x_end: Int) {
    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            let color = Int(pixels[i + 0]) | (Int(pixels[i + 1]) << 8)
            imageData[x + width * y].0 = UInt8((color & 0x7C00) >> 7)
            imageData[x + width * y].1 = UInt8((color & 0x03E0) >> 2)
            imageData[x + width * y].2 = UInt8((color & 0x001F) >> 3)
            imageData[x + width * y].3 = (color & 0x8000) > 0 ? 0 : 255
            i += 2
        }
    }
}

private func getImageData24bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                                pixels: Data,
                                colormap: Data?,
                                width: Int,
                                y_start: Int,
                                y_step: Int,
                                y_end: Int,
                                x_start: Int,
                                x_step: Int,
                                x_end: Int) {
    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            imageData[x + width * y].3 = 255
            imageData[x + width * y].2 = pixels[i + 0]
            imageData[x + width * y].1 = pixels[i + 1]
            imageData[x + width * y].0 = pixels[i + 2]
            i += 3
        }
    }
}

private func getImageData32bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                                pixels: Data,
                                colormap: Data?,
                                width: Int,
                                y_start: Int,
                                y_step: Int,
                                y_end: Int,
                                x_start: Int,
                                x_step: Int,
                                x_end: Int) {
    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            imageData[x + width * y].2 = pixels[i + 0]
            imageData[x + width * y].1 = pixels[i + 1]
            imageData[x + width * y].0 = pixels[i + 2]
            imageData[x + width * y].3 = pixels[i + 3]
            i += 4
        }
    }
}

private func getImageDataGrey8bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                                   pixels: Data,
                                   colormap: Data?,
                                   width: Int,
                                   y_start: Int,
                                   y_step: Int,
                                   y_end: Int,
                                   x_start: Int,
                                   x_step: Int,
                                   x_end: Int) {
    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            let color = pixels[i]
            imageData[x + width * y].0 = color
            imageData[x + width * y].1 = color
            imageData[x + width * y].2 = color
            imageData[x + width * y].3 = 255
            i += 1
        }
    }
}

private func getImageDataGrey16bits(imageData: UnsafeMutablePointer<Pixel_8888>,
                                    pixels: Data,
                                    colormap: Data?,
                                    width: Int,
                                    y_start: Int,
                                    y_step: Int,
                                    y_end: Int,
                                    x_start: Int,
                                    x_step: Int,
                                    x_end: Int) {
    var i = 0
    for y in stride(from: y_start, to: y_end, by: y_step) {
        for x in stride(from: x_start, to: x_end, by: x_step) {
            imageData[x + width * y].0 = pixels[i + 0]
            imageData[x + width * y].1 = pixels[i + 0]
            imageData[x + width * y].2 = pixels[i + 0]
            imageData[x + width * y].3 = pixels[i + 1]
            i += 2
        }
    }
}
