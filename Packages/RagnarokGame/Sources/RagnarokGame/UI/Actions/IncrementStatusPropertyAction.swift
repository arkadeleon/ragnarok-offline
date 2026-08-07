//
//  IncrementStatusPropertyAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/7.
//

import RagnarokConstants
import SwiftUI

struct IncrementStatusPropertyAction {
    var action: (StatusProperty, Int) -> Void

    func callAsFunction(_ sp: StatusProperty, by amount: Int) {
        action(sp, amount)
    }
}

extension EnvironmentValues {
    @Entry var incrementStatusProperty: IncrementStatusPropertyAction?
}

extension View {
    nonisolated func onIncrementStatusProperty(
        perform action: @escaping (StatusProperty, Int) -> Void
    ) -> some View {
        environment(\.incrementStatusProperty, IncrementStatusPropertyAction(action: action))
    }
}
