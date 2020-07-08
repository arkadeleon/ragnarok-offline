//
//  BMPDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ImageIO

struct BMPDocument: Document {

    var image: CGImage

    init(from stream: Stream) throws {
        let data = try stream.readToEnd()

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            throw DocumentError.invalidContents
        }

        self.image = image
    }
}
