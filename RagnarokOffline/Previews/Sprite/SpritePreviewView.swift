//
//  SpritePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SpritePreviewView: UIViewControllerRepresentable {

    let previewItem: PreviewItem

    func makeUIViewController(context: Context) -> some UIViewController {
        SpritePreviewViewController(previewItem: previewItem)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
