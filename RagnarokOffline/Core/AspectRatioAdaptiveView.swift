//
//  AspectRatioAdaptiveView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/9/11.
//

import SwiftUI

struct AspectRatioAdaptiveView<Tall, Wide>: View where Tall: View, Wide: View {
    @ViewBuilder var tall: Tall
    @ViewBuilder var wide: Wide

    @State private var isWide = false

    var body: some View {
        Group {
            if isWide {
                wide
            } else {
                tall
            }
        }
        .onGeometryChange(for: Bool.self) { geometryProxy in
            geometryProxy.size.width > geometryProxy.size.height
        } action: { isWide in
            self.isWide = isWide
        }
    }
}

#Preview {
    AspectRatioAdaptiveView {
        VStack {
            Color.red
            Color.blue
        }
    } wide: {
        HStack {
            Color.red
            Color.blue
        }
    }
}
