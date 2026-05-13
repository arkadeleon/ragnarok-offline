//
//  ZoomableImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/13.
//

import SwiftUI

#if canImport(UIKit)

import UIKit

struct ZoomableImageView: UIViewRepresentable {
    var image: CGImage

    func makeUIView(context: Context) -> ZoomableImageScrollView {
        ZoomableImageScrollView()
    }

    func updateUIView(_ scrollView: ZoomableImageScrollView, context: Context) {
        scrollView.setImage(image)
    }
}

final class ZoomableImageScrollView: UIScrollView, UIScrollViewDelegate {
    private let imageView = UIImageView()
    private var imageSize: CGSize = .zero
    private var currentImage: CGImage?
    private var hasAppliedInitialZoom = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = self
        backgroundColor = .clear
        bounces = true
        bouncesZoom = true
        contentInsetAdjustmentBehavior = .never
        decelerationRate = .fast
        delaysContentTouches = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: CGImage) {
        guard currentImage !== image else {
            return
        }

        currentImage = image
        imageSize = CGSize(width: image.width, height: image.height)
        imageView.image = UIImage(cgImage: image, scale: 1, orientation: .up)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        contentSize = imageSize
        hasAppliedInitialZoom = false
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateZoomScales()
        centerImage()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    private func updateZoomScales() {
        guard imageSize.width > 0, imageSize.height > 0, bounds.width > 0, bounds.height > 0 else {
            return
        }

        let fitScale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let minimumScale = max(fitScale, 0.01)
        let maximumScale = max(minimumScale * 8, 8)

        minimumZoomScale = minimumScale
        maximumZoomScale = maximumScale

        if !hasAppliedInitialZoom {
            zoomScale = minimumScale
            hasAppliedInitialZoom = true
        } else if zoomScale < minimumScale {
            zoomScale = minimumScale
        }
    }

    private func centerImage() {
        let zoomedImageSize = CGSize(width: imageSize.width * zoomScale, height: imageSize.height * zoomScale)
        let horizontalInset = max((bounds.width - zoomedImageSize.width) / 2, 0)
        let verticalInset = max((bounds.height - zoomedImageSize.height) / 2, 0)
        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }

        if zoomScale > minimumZoomScale * 1.01 {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let tapLocation = gesture.location(in: imageView)
            let targetScale = min(maximumZoomScale, max(minimumZoomScale * 2.5, 1))
            zoom(to: zoomRect(for: targetScale, centeredAt: tapLocation), animated: true)
        }
    }

    private func zoomRect(for scale: CGFloat, centeredAt center: CGPoint) -> CGRect {
        let size = CGSize(width: bounds.width / scale, height: bounds.height / scale)
        let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        return CGRect(origin: origin, size: size)
    }
}

#elseif canImport(AppKit)

import AppKit

struct ZoomableImageView: NSViewRepresentable {
    var image: CGImage

    func makeNSView(context: Context) -> ZoomableImageScrollView {
        ZoomableImageScrollView()
    }

    func updateNSView(_ scrollView: ZoomableImageScrollView, context: Context) {
        scrollView.setImage(image)
    }
}

final class ZoomableImageScrollView: NSScrollView {
    private let imageView = NSImageView()
    private var imageSize: CGSize = .zero
    private var currentImage: CGImage?
    private var hasAppliedInitialMagnification = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        drawsBackground = false
        allowsMagnification = true
        usesPredominantAxisScrolling = false
        hasHorizontalScroller = true
        hasVerticalScroller = true
        autohidesScrollers = true
        documentView = imageView

        imageView.imageScaling = .scaleProportionallyUpOrDown

        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(_:)))
        doubleClickGesture.numberOfClicksRequired = 2
        addGestureRecognizer(doubleClickGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: CGImage) {
        guard currentImage !== image else {
            return
        }

        currentImage = image
        imageSize = CGSize(width: image.width, height: image.height)
        imageView.image = NSImage(cgImage: image, size: imageSize)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        hasAppliedInitialMagnification = false
        needsLayout = true
    }

    override func layout() {
        super.layout()
        updateMagnificationLimits()
    }

    private func updateMagnificationLimits() {
        guard imageSize.width > 0, imageSize.height > 0, contentView.bounds.width > 0, contentView.bounds.height > 0 else {
            return
        }

        let fitScale = min(contentView.bounds.width / imageSize.width, contentView.bounds.height / imageSize.height)
        let minimumScale = max(fitScale, 0.01)
        let maximumScale = max(minimumScale * 8, 8)

        minMagnification = minimumScale
        maxMagnification = maximumScale

        if !hasAppliedInitialMagnification {
            magnification = minimumScale
            hasAppliedInitialMagnification = true
        } else if magnification < minimumScale {
            magnification = minimumScale
        }
    }

    @objc private func handleDoubleClick(_ gesture: NSClickGestureRecognizer) {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }

        if magnification > minMagnification * 1.01 {
            setMagnification(minMagnification, centeredAt: gesture.location(in: imageView))
        } else {
            let targetScale = min(maxMagnification, max(minMagnification * 2.5, 1))
            setMagnification(targetScale, centeredAt: gesture.location(in: imageView))
        }
    }
}

#endif
