//
//  ImageDocumentViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import DataCompression

class ImageDocumentViewController: UIViewController {

    let document: DocumentWrapper

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(document: DocumentWrapper) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        title = document.name
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

        scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        loadDocumentContents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let image = imageView.image {
            updateZoomScale(image: image)
            centerScrollViewContents()
        }
    }

    private func loadDocumentContents() {
        DispatchQueue.global().async {
            guard let data = self.document.contents() else {
                return
            }

            var image: UIImage? = nil
            switch self.document.contentType {
            case .bmp, .png, .jpg, .tga:
                image = UIImage(data: data)
            case .ebm:
                if let decompressedData = data.unzip() {
                    image = UIImage(data: decompressedData)
                }
            case .pal:
                let palette = try? Palette(data: data)
                image = palette?.image(at: CGSize(width: 256, height: 256)).map(UIImage.init)
            default:
                break
            }

            DispatchQueue.main.async {
                guard let image = image else {
                    return
                }

                self.imageView.image = image
                self.imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

                self.scrollView.contentSize = image.size

                self.updateZoomScale(image: image)
                self.centerScrollViewContents()
            }
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

extension ImageDocumentViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}