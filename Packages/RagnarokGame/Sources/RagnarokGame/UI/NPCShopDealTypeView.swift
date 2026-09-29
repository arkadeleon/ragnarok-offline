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
            Button {
                gameSession.selectDealType(.buy)
            } label: {
                Text("buy", bundle: #bundle)
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)

            Button {
                gameSession.selectDealType(.sell)
            } label: {
                Text("sell", bundle: #bundle)
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)

            Button {
                gameSession.cancelDealSelection()
            } label: {
                Text("cancel", bundle: #bundle)
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
