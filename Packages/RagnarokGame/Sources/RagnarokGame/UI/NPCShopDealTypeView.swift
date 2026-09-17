//
//  NPCShopDealTypeView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/17.
//

import SwiftUI

struct NPCShopDealTypeView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    var body: some View {
        MessageBoxView(gameContext.messageStringTable.localizedMessageString(forID: 92)) {
            Button("buy") {
                gameSession.selectDealType(.buy)
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)

            Button("sell") {
                gameSession.selectDealType(.sell)
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)

            Button("cancel") {
                gameSession.cancelDealSelection()
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)
        }
    }
}

#Preview {
    NPCShopDealTypeView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
        .environment(GameContext.testing)
}
