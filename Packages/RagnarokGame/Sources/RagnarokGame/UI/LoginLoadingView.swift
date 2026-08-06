//
//  LoginLoadingView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/9.
//

import SwiftUI

struct LoginLoadingView: View {
    @Environment(GameContext.self) private var gameContext

    var body: some View {
        MessageBoxView(gameContext.messageStringTable.localizedMessageString(forID: 121))
    }
}

#Preview {
    LoginLoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameContext.testing)
}
