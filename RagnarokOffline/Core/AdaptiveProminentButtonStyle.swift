//
//  AdaptiveProminentButtonStyle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/18.
//

import SwiftUI

extension View {
    @ViewBuilder func adaptiveProminentButtonStyle() -> some View {
        #if os(visionOS)
        self.buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
        #else
        if #available(iOS 26.0, macOS 26.0, *) {
            self.buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
        } else {
            self.buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
        }
        #endif
    }
}
