//
//  EmptyContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/7.
//

import SwiftUI

struct EmptyContentView: View {
    var titleKey: LocalizedStringKey

    var body: some View {
        Text(titleKey)
            .font(.title2)
            .bold()
            .foregroundStyle(Color.secondary)
    }

    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
    }
}

#Preview {
    EmptyContentView("Empty Content")
}
