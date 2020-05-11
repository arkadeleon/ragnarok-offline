//
//  ImageDocumentViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ImageDocumentViewController: UIViewController, UIScrollViewDelegate {

    let document: ImageDocument

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(document: ImageDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = document.name

        view.backgroundColor = .systemBackground

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        view.addSubview(scrollView)

        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        document.open { _ in
            self.imageView.image = self.document.image
            self.document.close()
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
