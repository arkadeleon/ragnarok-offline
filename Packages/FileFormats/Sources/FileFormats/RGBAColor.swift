//
//  RGBAColor.swift
//  FileFormats
//
//  Created by Leon Li on 2023/12/7.
//

import Accelerate
import BinaryIO

public struct RGBAColor: BinaryDecodable, Hashable, Sendable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(from decoder: BinaryDecoder) throws {
        red = try decoder.decode(UInt8.self)
        green = try decoder.decode(UInt8.self)
        blue = try decoder.decode(UInt8.self)
        alpha = try decoder.decode(UInt8.self)
    }
}

extension CGImage {
    public func applyingColor(_ color: RGBAColor) -> CGImage? {
        if color == RGBAColor(red: 255, green: 255, blue: 255, alpha: 255) {
            return self
        }

        // Presume the format is RGBA8888
        guard let format = vImage_CGImageFormat(cgImage: self) else {
            return nil
        }

        guard var src = try? vImage_Buffer(cgImage: self) else {
            return nil
        }

        defer {
            src.free()
        }

        guard var dest = try? vImage_Buffer(width: width, height: height, bitsPerPixel: UInt32(bitsPerPixel)) else {
            return nil
        }

        defer {
            dest.free()
        }

        let r = UInt16(color.red)
        let g = UInt16(color.green)
        let b = UInt16(color.blue)
        let a = UInt16(color.alpha)
        let matrix: [UInt16] = [
            r, 0, 0, 0,
            0, g, 0, 0,
            0, 0, b, 0,
            0, 0, 0, a,
        ]

        let divisor: Int32 = 256

        let error = vImageMatrixMultiply_ARGB8888(&src, &dest, matrix, divisor, nil, nil, 0)
        guard error == kvImageNoError else {
            return nil
        }

        let image = try? dest.createCGImage(format: format)
        return image
    }
}
