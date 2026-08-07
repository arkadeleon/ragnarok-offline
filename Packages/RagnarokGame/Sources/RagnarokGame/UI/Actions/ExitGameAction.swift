//
//  ExitGameAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/16.
//

import SwiftUI

struct ExitGameAction {
    var action: () -> Void

    func callAsFunction() {
        action()
    }
}

extension EnvironmentValues {
    @Entry var exitGame = ExitGameAction(action: {})
}

extension View {
    nonisolated public func onExitGame(
        perform action: @escaping () -> Void
    ) -> some View {
        environment(\.exitGame, ExitGameAction(action: action))
    }
}
