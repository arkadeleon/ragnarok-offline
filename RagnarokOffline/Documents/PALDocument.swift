//
//  PALDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

struct PALDocument: Document {

    var colors: [simd_uchar4]

    init(from stream: Stream) throws {
        let reader = StreamReader(stream: stream)

        colors = try (0..<256).map { _ in
            try [
                reader.readUInt8(),
                reader.readUInt8(),
                reader.readUInt8(),
                reader.readUInt8()
            ]
        }
    }
}

extension PALDocument {

    func image(at size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let blockSize = CGSizeMake(size.width / 16, size.height / 16)

        let image = renderer.image { context in
            for x in 0..<16 {
                for y in 0..<16 {
                    let color = colors[y * 16 + x]
                    let uiColor = UIColor(
                        red: CGFloat(color[0]) / 255,
                        green: CGFloat(color[1]) / 255,
                        blue: CGFloat(color[2]) / 255,
                        alpha: 1
                    )
                    uiColor.setFill()

                    let rect = CGRect(
                        x: CGFloat(x) * blockSize.width,
                        y: CGFloat(y) * blockSize.height,
                        width: blockSize.width,
                        height: blockSize.height
                    )
                    context.fill(rect)
                }
            }
        }
        return image
    }
}
