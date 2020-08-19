//
//  PreviewItem+Thumbnail.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

extension PreviewItem {

    var placeholder: UIImage? {
        switch fileType {
        case .txt, .xml, .ini, .lua, .lub:
            return UIImage(systemName: "doc.text")
        case .bmp, .jpg, .tga, .pal:
            return UIImage(systemName: "photo")
        case .mp3, .wav:
            return UIImage(systemName: "waveform.circle")
        case .spr:
            return UIImage(systemName: "photo")
        case .act:
            return UIImage(systemName: "bolt")
        case .rsm:
            return UIImage(systemName: "square.stack.3d.up")
        case .rsw:
            return UIImage(systemName: "map")
        case .xxx:
            return UIImage(systemName: "doc")
        }
    }
}
