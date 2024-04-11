//
//  GATPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit
import ROFileFormats
import ROFileSystem

class GATPreviewViewController: UIViewController {
    let file: File

    private var imageView: UIImageView!

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(frame: view.bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        Task {
            if let image = await loadImage() {
                imageView.image = UIImage(cgImage: image)
            }
        }
    }

    nonisolated private func loadImage() async -> CGImage? {
        guard let gatData = file.contents() else {
            return nil
        }

        guard let gat = try? GAT(data: gatData) else {
            return nil
        }

        let image = gat.image()
        return image
    }
}
