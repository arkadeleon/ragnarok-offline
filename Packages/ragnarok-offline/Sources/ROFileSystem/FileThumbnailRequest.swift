//
//  FileThumbnailRequest.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import CoreGraphics

public struct FileThumbnailRequest {
    public var file: File
    public var size: CGSize
    public var scale: CGFloat

    public init(file: File, size: CGSize, scale: CGFloat) {
        self.file = file
        self.size = size
        self.scale = scale
    }
}
