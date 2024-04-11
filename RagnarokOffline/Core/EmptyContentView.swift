//
//  EmptyContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/7.
//

import SwiftUI

struct EmptyContentView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundStyle(.secondary)
    }

    init(_ title: String) {
        self.title = title
    }
}

#Preview {
    EmptyContentView("Empty Content")
}
