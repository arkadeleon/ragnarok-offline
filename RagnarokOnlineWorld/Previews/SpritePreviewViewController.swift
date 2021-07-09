//
//  SpritePreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class SpritePreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = previewItem.name

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

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard let data = try? self.previewItem.data() else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(SPRDocument.self, from: data) else {
                return
            }

            DispatchQueue.main.async {
                guard let image = document.imageForFrame(at: 0) else {
                    return
                }

                self.imageView.image = UIImage(cgImage: image)
                self.imageView.frame = CGRect(x: 0, y: 0, width: image.width, height: image.height)

                self.scrollView.contentSize = CGSize(width: image.width, height: image.height)

                self.updateZoomScale(image: image)
                self.centerScrollViewContents()
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

extension SpritePreviewViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
