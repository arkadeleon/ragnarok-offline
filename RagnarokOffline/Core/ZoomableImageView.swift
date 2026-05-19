//
//  ZoomableImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/13.
//

import SwiftUI

#if canImport(UIKit)

import UIKit

struct ZoomableImageView: UIViewControllerRepresentable {
    var image: CGImage

    func makeUIViewController(context: Context) -> ZoomableImageViewController {
        ZoomableImageViewController(image: image)
    }

    func updateUIViewController(_ viewController: ZoomableImageViewController, context: Context) {
    }
}

final class ZoomableImageViewController: UIViewController, UIScrollViewDelegate {
    private let image: CGImage
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var hasAppliedInitialZoom = false

    init(image: CGImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        imageView = UIImageView()
        scrollView.addSubview(imageView)

        // Set image
        let imageSize = CGSize(width: image.width, height: image.height)
        imageView.image = UIImage(cgImage: image, scale: 1, orientation: .up)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        scrollView.contentSize = imageSize
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateZoomScales()
        centerImage()
    }

    private func updateZoomScales() {
        let imageSize = CGSize(width: image.width, height: image.height)
        let scrollViewSize = scrollView.bounds.size

        guard imageSize.width > 0, imageSize.height > 0, scrollViewSize.width > 0, scrollViewSize.height > 0 else {
            return
        }

        let fitScale = min(scrollViewSize.width / imageSize.width, scrollViewSize.height / imageSize.height)
        let minimumScale = min(fitScale / 4, 1)
        let maximumScale = max(fitScale * 16, 1)

        scrollView.minimumZoomScale = minimumScale
        scrollView.maximumZoomScale = maximumScale

        if !hasAppliedInitialZoom {
            scrollView.zoomScale = fitScale
            hasAppliedInitialZoom = true
        } else if scrollView.zoomScale < minimumScale {
            scrollView.zoomScale = minimumScale
        } else if scrollView.zoomScale > maximumScale {
            scrollView.zoomScale = maximumScale
        }
    }

    private func centerImage() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) / 2
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) / 2
        }

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

#elseif canImport(AppKit)

import AppKit

struct ZoomableImageView: NSViewControllerRepresentable {
    var image: CGImage

    func makeNSViewController(context: Context) -> ZoomableImageViewController {
        ZoomableImageViewController(image: image)
    }

    func updateNSViewController(_ viewController: ZoomableImageViewController, context: Context) {
    }
}

final class ZoomableImageViewController: NSViewController {
    private let image: CGImage
    private var scrollView: NSScrollView!
    private var imageView: NSImageView!
    private var hasAppliedInitialMagnification = false

    init(image: CGImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = NSScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.drawsBackground = false
        scrollView.allowsMagnification = true
        scrollView.usesPredominantAxisScrolling = false
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        view.addSubview(scrollView)

        imageView = NSImageView()
        scrollView.documentView = imageView

        // Set image
        let imageSize = CGSize(width: image.width, height: image.height)
        imageView.image = NSImage(cgImage: image, size: imageSize)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        updateMagnificationLimits()
    }

    private func updateMagnificationLimits() {
        let imageSize = CGSize(width: image.width, height: image.height)
        let scrollViewSize = scrollView.contentView.bounds.size

        guard imageSize.width > 0, imageSize.height > 0, scrollViewSize.width > 0, scrollViewSize.height > 0 else {
            return
        }

        let fitScale = min(scrollViewSize.width / imageSize.width, scrollViewSize.height / imageSize.height)
        let minimumScale = min(fitScale / 4, 1)
        let maximumScale = max(fitScale * 16, 1)

        scrollView.minMagnification = minimumScale
        scrollView.maxMagnification = maximumScale

        if !hasAppliedInitialMagnification {
            scrollView.magnification = fitScale
            hasAppliedInitialMagnification = true
        } else if scrollView.magnification < minimumScale {
            scrollView.magnification = minimumScale
        } else if scrollView.magnification > maximumScale {
            scrollView.magnification = maximumScale
        }
    }
}

#endif
