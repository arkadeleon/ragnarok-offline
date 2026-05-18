//
//  AdaptiveNavigationTransition.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/18.
//

import SwiftUI

extension View {
    @ViewBuilder func adaptiveNavigationTransition(sourceID: some Hashable, in namespace: Namespace.ID) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self.navigationTransition(.automatic)
        }
        #else
        self.navigationTransition(.automatic)
        #endif
    }
}
