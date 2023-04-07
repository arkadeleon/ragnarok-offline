//
//  PreviewItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct PreviewItemView: View {

    let previewItem: PreviewItem

    var body: some View {
        switch previewItem.fileType {
        case .txt, .xml, .ini, .lua, .lub:
            TextPreviewView(previewItem: previewItem)
        case .bmp, .jpg, .tga, .pal:
            ImagePreviewView(previewItem: previewItem)
        case .mp3, .wav:
            AudioPreviewView(previewItem: previewItem)
        case .spr:
            SpritePreviewView(previewItem: previewItem)
        case .act:
            ActionPreviewView(previewItem: previewItem)
        case .rsm:
            ModelPreviewView(previewItem: previewItem)
        case .rsw:
            WorldPreviewView(previewItem: previewItem)
        case .xxx:
            EmptyView()
        }
    }
}
