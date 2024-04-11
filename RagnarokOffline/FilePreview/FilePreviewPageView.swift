//
//  FilePreviewPageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import ROFileSystem

struct FilePreviewPageView: UIViewControllerRepresentable {
    let file: File
    let files: [File]

    func makeUIViewController(context: Context) -> UINavigationController {
        let pageViewController = FilePreviewPageViewController(file: file, files: files)
        let navigationController = UINavigationController(rootViewController: pageViewController)
        return navigationController
    }

    func updateUIViewController(_ navigationController: UINavigationController, context: Context) {
    }
}
