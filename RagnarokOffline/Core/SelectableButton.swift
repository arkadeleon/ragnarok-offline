//
//  SelectableButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/23.
//

import SwiftUI

struct SelectableButton<Label>: View where Label: View {
    var isSelected: Bool
    var action: () -> Void
    var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.accentColor : Color.secondary)
    }

    init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.isSelected = isSelected
        self.action = action
        self.label = label
    }

    init(_ titleResource: LocalizedStringResource, isSelected: Bool, action: @escaping () -> Void) where Label == Text {
        self.isSelected = isSelected
        self.action = action
        self.label = {
            Text(titleResource)
        }
    }

    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) where Label == Text {
        self.isSelected = isSelected
        self.action = action
        self.label = {
            Text(title)
        }
    }
}
