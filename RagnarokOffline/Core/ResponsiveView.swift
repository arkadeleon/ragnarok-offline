//
//  ResponsiveView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/10.
//

import SwiftUI

struct ResponsiveView<Compact, Regular>: View where Compact: View, Regular: View {
    let compact: Compact
    let regular: Regular

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            compact
        } else {
            regular
        }
    }

    init(@ViewBuilder compact: () -> Compact, @ViewBuilder regular: () -> Regular) {
        self.compact = compact()
        self.regular = regular()
    }
}

#Preview {
    ResponsiveView {
        List {
        }
    } regular: {
        Grid {
        }
    }
}
