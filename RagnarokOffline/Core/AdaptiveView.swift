//
//  AdaptiveView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/10.
//

import SwiftUI

struct AdaptiveView<Compact, Regular>: View where Compact: View, Regular: View {
    @ViewBuilder var compact: () -> Compact
    @ViewBuilder var regular: () -> Regular

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .compact {
            compact()
        } else {
            regular()
        }
    }
}

#Preview {
    AdaptiveView {
        List {
        }
    } regular: {
        Grid {
        }
    }
}
