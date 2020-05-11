//
//  ImageDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ImageDocument: Document {

    private(set) var image: UIImage?

    override func load(from contents: Data) throws {
        switch fileType {
        case "bmp", "jpg", "jpeg":
            image = UIImage(data: contents)
        default:
            break
        }
    }
}
