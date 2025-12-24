//
//  SectionHeaderView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/24.
//

import SwiftUI

struct SectionHeaderView<Content>: View where Content: View {
    var content: () -> Content

    var body: some View {
        content()
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(Color.primary)
            .textCase(nil)
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    init(_ titleKey: LocalizedStringResource) where Content == Text {
        content = {
            Text(titleKey)
        }
    }
}
