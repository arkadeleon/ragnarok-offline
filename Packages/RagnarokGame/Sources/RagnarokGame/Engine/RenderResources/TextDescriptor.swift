//
//  TextDescriptor.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/15.
//

import CoreGraphics
import Foundation
import RagnarokCore

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct TextDescriptor: Hashable {
    let text: AttributedString

    /// The size of the drawn text, in points.
    let size: SIMD2<Float>

    init(text: AttributedString) {
        self.text = text

        let textSize = text.drawableString(isOutline: false).size()
        self.size = [
            Float(ceil(textSize.width)) + 2,
            Float(ceil(textSize.height)) + 2,
        ]
    }

    /// Draws the text at 2 pixels per point.
    func makeImage() -> CGImage? {
        let scale: CGFloat = 2
        let imageSize = CGSize(width: CGFloat(size.x) * scale, height: CGFloat(size.y) * scale)
        let renderer = CGImageRenderer(size: imageSize, flipped: true)
        return renderer.image(for: text, scale: scale)
    }
}

extension CGImageRenderer {
    fileprivate func image(for attributedText: AttributedString, scale: CGFloat) -> CGImage? {
        image { context in
            context.scaleBy(x: scale, y: scale)

            #if canImport(UIKit)
            UIGraphicsPushContext(context)
            defer {
                UIGraphicsPopContext()
            }
            #elseif canImport(AppKit)
            let previousContext = NSGraphicsContext.current
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: flipped)
            defer {
                NSGraphicsContext.current = previousContext
            }
            #endif

            let outlineString = attributedText.drawableString(isOutline: true)
            let colorString = attributedText.drawableString(isOutline: false)

            let offsets: [CGPoint] = [
                CGPoint(x: 0, y: -1),
                CGPoint(x: 0, y: 1),
                CGPoint(x: -1, y: 0),
                CGPoint(x: 1, y: 0),
            ]
            for offset in offsets {
                outlineString.draw(at: CGPoint(x: 1 + offset.x, y: 1 + offset.y))
            }

            colorString.draw(at: CGPoint(x: 1, y: 1))
        }
    }
}

extension AttributedString {
    /// The outline string is black all over.
    fileprivate func drawableString(isOutline: Bool) -> NSAttributedString {
        let string = NSMutableAttributedString(self)
        let range = NSRange(location: 0, length: string.length)

        #if canImport(UIKit)
        let font = UIFont(name: "Arial", size: 12) ?? .systemFont(ofSize: 12)
        let defaultColor = isOutline ? UIColor.black : UIColor.white
        #elseif canImport(AppKit)
        let font = NSFont(name: "Arial", size: 12) ?? .systemFont(ofSize: 12)
        let defaultColor = isOutline ? NSColor.black : NSColor.white
        #endif

        string.addAttribute(.font, value: font, range: range)

        if isOutline {
            string.addAttribute(.foregroundColor, value: defaultColor, range: range)
        } else {
            string.enumerateAttribute(.foregroundColor, in: range) { value, subrange, _ in
                if value == nil {
                    string.addAttribute(.foregroundColor, value: defaultColor, range: subrange)
                }
            }
        }

        return string
    }
}
