//
//  GraphicsImageRenderer.swift
//  ImageRendering
//
//  Created by Leon Li on 2024/10/18.
//

import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class GraphicsImageRenderer {
    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public func image(actions: @escaping (CGContext) -> Void) -> CGImage? {
        #if os(macOS)
        let nsImage = NSImage(size: NSSizeFromCGSize(size), flipped: false) { _ in
            if let cgContext = NSGraphicsContext.current?.cgContext {
                actions(cgContext)
                return true
            } else {
                return false
            }
        }
        let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        return cgImage
        #else
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { context in
            actions(context.cgContext)
        }
        return uiImage.cgImage
        #endif
    }
}
