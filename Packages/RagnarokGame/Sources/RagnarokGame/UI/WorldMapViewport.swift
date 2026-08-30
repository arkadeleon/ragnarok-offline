//
//  WorldMapViewport.swift
//  RagnarokGame
//
//  Created on 2026/8/30.
//

import CoreGraphics

// The map is first scaled to fit the container. `zoomScale` multiplies that
// fitted size, and `offset` shifts the result in points from the center of the
// container.
struct WorldMapViewport: Equatable {
    struct Transform: Equatable {
        var magnification: CGFloat = 1

        // Where the pinch started, in unit space of the container.
        var anchor: CGPoint?

        var translation: CGSize = .zero
    }

    private let minimumZoomScale: CGFloat = 1
    private let maximumZoomScale: CGFloat = 6

    var zoomScale: CGFloat = 1
    var offset: CGSize = .zero

    func applying(
        _ transform: Transform,
        containerSize: CGSize,
        fittedMapSize: CGSize
    ) -> WorldMapViewport {
        let proposedZoomScale = min(max(zoomScale * transform.magnification, minimumZoomScale), maximumZoomScale)
        let zoomRatio = proposedZoomScale / zoomScale

        var proposedOffset = offset
        if let anchor = transform.anchor {
            let anchorFromCenter = CGPoint(
                x: (anchor.x - 0.5) * containerSize.width,
                y: (anchor.y - 0.5) * containerSize.height
            )
            proposedOffset.width += (anchorFromCenter.x - offset.width) * (1 - zoomRatio)
            proposedOffset.height += (anchorFromCenter.y - offset.height) * (1 - zoomRatio)
        }

        proposedOffset.width += transform.translation.width
        proposedOffset.height += transform.translation.height

        return WorldMapViewport(
            zoomScale: proposedZoomScale,
            offset: Self.clampedOffset(
                proposedOffset,
                zoomScale: proposedZoomScale,
                containerSize: containerSize,
                fittedMapSize: fittedMapSize
            )
        )
    }

    func clamped(containerSize: CGSize, fittedMapSize: CGSize) -> Self {
        WorldMapViewport(
            zoomScale: zoomScale,
            offset: Self.clampedOffset(
                offset,
                zoomScale: zoomScale,
                containerSize: containerSize,
                fittedMapSize: fittedMapSize
            )
        )
    }

    // A point in the container turned into image pixels, or nil when it falls
    // outside the map.
    func imagePoint(
        at location: CGPoint,
        containerSize: CGSize,
        fittedMapSize: CGSize,
        imageSize: CGSize
    ) -> CGPoint? {
        guard fittedMapSize.width > 0, fittedMapSize.height > 0 else {
            return nil
        }

        let displayedMapSize = CGSize(
            width: fittedMapSize.width * zoomScale,
            height: fittedMapSize.height * zoomScale
        )
        let displayedMapOrigin = CGPoint(
            x: (containerSize.width - displayedMapSize.width) / 2 + offset.width,
            y: (containerSize.height - displayedMapSize.height) / 2 + offset.height
        )
        let displayedMapRect = CGRect(origin: displayedMapOrigin, size: displayedMapSize)
        guard displayedMapRect.contains(location) else {
            return nil
        }

        return CGPoint(
            x: (location.x - displayedMapOrigin.x) * imageSize.width / displayedMapSize.width,
            y: (location.y - displayedMapOrigin.y) * imageSize.height / displayedMapSize.height
        )
    }

    private static func clampedOffset(
        _ offset: CGSize,
        zoomScale: CGFloat,
        containerSize: CGSize,
        fittedMapSize: CGSize
    ) -> CGSize {
        let horizontalLimit = max((fittedMapSize.width * zoomScale - containerSize.width) / 2, 0)
        let verticalLimit = max((fittedMapSize.height * zoomScale - containerSize.height) / 2, 0)

        return CGSize(
            width: min(max(offset.width, -horizontalLimit), horizontalLimit),
            height: min(max(offset.height, -verticalLimit), verticalLimit)
        )
    }
}
