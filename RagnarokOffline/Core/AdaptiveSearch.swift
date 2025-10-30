//
//  AdaptiveSearch.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/30.
//

import SwiftUI

struct AdaptiveSearch: ViewModifier {
    @Binding var text: String
    var onSearch: (String) async -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    private var placement: SearchFieldPlacement {
        #if os(macOS)
        .automatic
        #else
        if sizeClass == .compact {
            .navigationBarDrawer(displayMode: .always)
        } else {
            .automatic
        }
        #endif
    }

    func body(content: Content) -> some View {
        content
            .searchable(text: $text, placement: placement)
            .task(id: text) {
                await onSearch(text)
            }
    }
}

extension View {
    func adaptiveSearch(text: Binding<String>, onSearch: @escaping (String) async -> Void) -> some View {
        modifier(AdaptiveSearch(text: text, onSearch: onSearch))
    }
}
