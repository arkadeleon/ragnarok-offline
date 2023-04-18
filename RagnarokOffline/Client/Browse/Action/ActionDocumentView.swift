//
//  ActionDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ActionDocumentView: UIViewControllerRepresentable {

    let document: DocumentWrapper

    func makeUIViewController(context: Context) -> some UIViewController {
        ActionDocumentViewController(document: document)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
