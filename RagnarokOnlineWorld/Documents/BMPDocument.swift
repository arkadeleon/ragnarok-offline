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

    let source: DocumentSource
    let name: String

    required init(source: DocumentSource) {
        self.source = source
        self.name = source.name
    }

    func load() -> Result<CGImage, DocumentError> {
        guard let data = try? source.data() else {
            return .failure(.invalidSource)
        }

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            return .failure(.invalidContents)
        }

        return .success(image)
    }
}
