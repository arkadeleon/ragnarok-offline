//
//  LoginLoadingView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/9.
//

import SwiftUI

struct LoginLoadingView: View {
    @Environment(GameSession.self) private var gameSession

    var body: some View {
        MessageBoxView(gameSession.messageStringTable.localizedMessageString(forID: 121))
    }
}

#Preview {
    LoginLoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
