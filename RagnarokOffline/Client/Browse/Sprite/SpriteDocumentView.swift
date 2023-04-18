//
//  SpriteDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SpriteDocumentView: UIViewControllerRepresentable {

    let document: DocumentWrapper

    func makeUIViewController(context: Context) -> some UIViewController {
        SpriteDocumentViewController(document: document)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
