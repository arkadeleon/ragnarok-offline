//
//  HelpView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/5.
//

import SwiftUI

struct HelpView: View {
    var onDone: () -> Void

    var body: some View {
        ScrollView {
            Text(LocalizedStringResource("HELP_DESCRIPTION", table: "Help"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle("Help")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
    }
}

#Preview {
    HelpView {
    }
}
