//
//  AdaptiveSearch.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/30.
//

import SwiftUI

struct AdaptiveSearch: ViewModifier {
    @Binding var text: String

    @Environment(\.horizontalSizeClass) private var sizeClass

    private var placement: SearchFieldPlacement {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            .automatic
        } else {
            if sizeClass == .compact {
                .navigationBarDrawer(displayMode: .always)
            } else {
                .automatic
            }
        }
        #else
        .automatic
        #endif
    }

    func body(content: Content) -> some View {
        content
            .searchable(text: $text, placement: placement)
    }
}

extension View {
    func adaptiveSearch(text: Binding<String>) -> some View {
        modifier(AdaptiveSearch(text: text))
    }
}
