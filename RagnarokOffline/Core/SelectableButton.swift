//
//  SelectableButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/23.
//

import SwiftUI

struct SelectableButton: View {
    var isSelected: Bool
    var action: () -> Void
    var label: Text

    var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.accentColor : Color.secondary)
    }

    init(_ titleResource: LocalizedStringResource, isSelected: Bool, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.action = action
        self.label = Text(titleResource)
    }

    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.action = action
        self.label = Text(title)
    }
}
