//
//  FilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct FilesView: UIViewControllerRepresentable {
    let file: File

    func makeUIViewController(context: Context) -> FilesViewController {
        FilesViewController(file: file)
    }

    func updateUIViewController(_ filesViewController: FilesViewController, context: Context) {
    }
}
