//
//  JPGDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ImageIO

struct JPGDocument: Document {

    var image: CGImage

    init(from stream: Stream) throws {
        let data = try stream.readToEnd()

        guard let dataProvider = CGDataProvider(data: data as CFData),
              let image = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        else {
            throw DocumentError.invalidContents
        }

        self.image = image
    }
}
