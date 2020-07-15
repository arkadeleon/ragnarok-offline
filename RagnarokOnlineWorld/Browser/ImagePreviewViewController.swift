//
//  ImagePreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    let source: DocumentSource

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(source: DocumentSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = source.name

        view.backgroundColor = .systemBackground

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

        loadSource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let image = imageView.image?.cgImage {
            updateZoomScale(image: image)
            centerScrollViewContents()
        }
    }

    private func loadSource() {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
                return
            }

            var image: CGImage? = nil
            let loader = DocumentLoader()
            switch self.source.fileType.lowercased() {
            case "bmp":
                image = try? loader.load(BMPDocument.self, from: data).image
            case "jpg", "jpeg":
                image = try? loader.load(JPGDocument.self, from: data).image
            default:
                break
            }

            DispatchQueue.main.async {
                if let image = image {
                    self.imageView.image = UIImage(cgImage: image)
                    self.imageView.frame = CGRect(x: 0, y: 0, width: image.width, height: image.height)

                    self.scrollView.contentSize = CGSize(width: image.width, height: image.height)

                    self.updateZoomScale(image: image)
                    self.centerScrollViewContents()
                }
            }
        }
    }

    private func updateZoomScale(image: CGImage) {
        let scrollViewFrame = scrollView.bounds

        let scaleWidth = scrollViewFrame.size.width / CGFloat(image.width)
        let scaleHeight = scrollViewFrame.size.height / CGFloat(image.height)
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

extension ImagePreviewViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
