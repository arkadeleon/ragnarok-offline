//
//  ResponsiveView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/10.
//

import SwiftUI

struct ResponsiveView<Compact, Regular>: View where Compact: View, Regular: View {
    var compact: () -> Compact
    var regular: () -> Regular

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            compact()
        } else {
            regular()
        }
    }

    init(@ViewBuilder compact: @escaping () -> Compact, @ViewBuilder regular: @escaping () -> Regular) {
        self.compact = compact
        self.regular = regular
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
