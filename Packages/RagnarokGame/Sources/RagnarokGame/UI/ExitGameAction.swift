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
