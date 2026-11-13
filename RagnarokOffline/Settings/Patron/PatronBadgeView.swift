//
//  PatronBadgeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/12.
//

import SwiftUI

struct PatronBadgeView: View {
    var body: some View {
        Text("Patron", tableName: "Settings")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.tint, in: Capsule())
    }
}

#Preview {
    PatronBadgeView()
        .padding()
}
