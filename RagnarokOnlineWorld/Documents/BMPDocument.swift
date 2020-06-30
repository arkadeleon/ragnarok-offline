//
//  BMPDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import ImageIO

class BMPDocument: Document {

    private(set) var image: CGImage?

    override func load(from contents: Data) throws {
        guard let imageSource = CGImageSourceCreateWithData(contents as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            throw DocumentError.invalidContents
        }

        self.image = image
    }
}
