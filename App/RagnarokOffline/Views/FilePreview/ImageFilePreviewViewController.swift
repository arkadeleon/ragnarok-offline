//
//  ImageFilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import DataCompression
import RagnarokOfflineFileFormats
import RagnarokOfflineGraphics
import RagnarokOfflineFileSystem

class ImageFilePreviewViewController: UIViewController {
    let file: File

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
        title = file.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .tertiarySystemBackground
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        Task {
            guard let image = await loadImage() else {
                return
            }

            imageView.image = image
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

            scrollView.contentSize = image.size

            updateZoomScale(image: image)
            centerScrollViewContents()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let image = imageView.image {
            updateZoomScale(image: image)
            centerScrollViewContents()
        }
    }

    nonisolated private func loadImage() async -> UIImage? {
        guard let type = file.type, let data = file.contents() else {
            return nil
        }

        switch type {
        case .ebm:
            guard let decompressedData = data.unzip() else {
                return nil
            }
            let image = UIImage(data: decompressedData)
            return image
        case .pal:
            let pal = try? PAL(data: data)
            let image = pal?.image(at: CGSize(width: 256, height: 256)).map(UIImage.init)
            return image
        default:
            let image = UIImage(data: data)
            return image
        }
    }

    private func updateZoomScale(image: UIImage) {
        let scrollViewFrame = scrollView.bounds

        let scaleWidth = scrollViewFrame.size.width / CGFloat(image.size.width)
        let scaleHeight = scrollViewFrame.size.height / CGFloat(image.size.height)
        let minScale = min(scaleWidth, scaleHeight)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 3

        scrollView.zoomScale = minScale
    }

    private func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
        }

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension ImageFilePreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
