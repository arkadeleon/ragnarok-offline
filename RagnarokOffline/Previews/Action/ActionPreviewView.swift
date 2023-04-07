//
//  ActionPreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ActionPreviewView: UIViewControllerRepresentable {

    let previewItem: PreviewItem

    func makeUIViewController(context: Context) -> some UIViewController {
        ActionPreviewViewController(previewItem: previewItem)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
