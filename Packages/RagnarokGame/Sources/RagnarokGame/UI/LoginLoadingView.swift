//
//  LoginLoadingView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/9.
//

import SwiftUI

struct LoginLoadingView: View {
    @Environment(\.messageStringTable) private var messageStringTable

    var body: some View {
        MessageBoxView(messageStringTable.localizedMessageString(forID: 121))
    }
}

#Preview {
    LoginLoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
