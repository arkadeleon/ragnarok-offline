//
//  FileThumbnail.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import CoreGraphics

final class FileThumbnail: Sendable {
    let cgImage: CGImage

    init(cgImage: CGImage) {
        self.cgImage = cgImage
    }
}
