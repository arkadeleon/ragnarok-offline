//
//  FileThumbnailRequest.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import CoreGraphics

struct FileThumbnailRequest {
    var file: File
    var size: CGSize
    var scale: CGFloat

    init(file: File, size: CGSize, scale: CGFloat) {
        self.file = file
        self.size = size
        self.scale = scale
    }
}
