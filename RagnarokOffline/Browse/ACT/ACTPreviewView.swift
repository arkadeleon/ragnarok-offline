//
//  ACTPreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ACTPreviewView: UIViewControllerRepresentable {
    let document: DocumentWrapper

    func makeUIViewController(context: Context) -> ACTPreviewViewController {
        ACTPreviewViewController(document: document)
    }

    func updateUIViewController(_ uiViewController: ACTPreviewViewController, context: Context) {
    }
}
