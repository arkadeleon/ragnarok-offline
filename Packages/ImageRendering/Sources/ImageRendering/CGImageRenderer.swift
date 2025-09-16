//
//  CGImageRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/28.
//

import CoreGraphics

public class CGImageRenderer {
    public let size: CGSize
    public let flipped: Bool

    private lazy var context: CGContext? = {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )

        if flipped {
            // Flip vertically.
            let transform = CGAffineTransform(1, 0, 0, -1, 0, size.height)
            context?.concatenate(transform)
        }

        return context
    }()

    public init(size: CGSize, flipped: Bool) {
        self.size = size
        self.flipped = flipped
    }

    public func image(actions: (CGContext) -> Void) -> CGImage? {
        guard let context else {
            return nil
        }

        actions(context)

        let image = context.makeImage()
        return image
    }
}
