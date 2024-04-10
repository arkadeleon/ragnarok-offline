//
//  FilePreviewPageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

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
