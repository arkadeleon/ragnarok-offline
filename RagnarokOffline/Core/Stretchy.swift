//
//  Stretchy.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/18.
//

import SwiftUI

// Reference: https://nilcoalescing.com/blog/StretchyHeaderInSwiftUI
struct Stretchy: ViewModifier {
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                let currentHeight = geometryProxy.size.height
                let scrollOffset = geometryProxy.frame(in: .scrollView).minY
                let positiveOffset = max(0, scrollOffset)

                let newHeight = currentHeight + positiveOffset
                let scaleFactor = newHeight / currentHeight

                return content.scaleEffect(
                    x: scaleFactor,
                    y: scaleFactor,
                    anchor: .bottom
                )
            }
    }
}

extension View {
    func stretchy() -> some View {
        modifier(Stretchy())
    }
}
