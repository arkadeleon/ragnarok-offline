//
//  ImagePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ImagePreviewView: UIViewControllerRepresentable {

    let previewItem: PreviewItem

    func makeUIViewController(context: Context) -> some UIViewController {
        ImagePreviewViewController(previewItem: previewItem)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
